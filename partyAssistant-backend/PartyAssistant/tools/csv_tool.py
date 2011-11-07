#coding=utf-8
'''
Created on 2010-1-6

@author: lihuanhuan
'''
from settings import PROJECT_ROOT

import csv, codecs, cStringIO, re, random, os, StringIO
from clients.csv_setting import *
from tools.exceptions import MyError
from tools.email_tool import email_re
from clients.forms import cell_phone_re

from events.models import Meeting, MeetingsClients, ClientInfo, Event, MeetingsClientInfosValues
from clients.models import Client
from event_solr import data_import_handler 
from tools.contact_tool import Contactor
from tools.client_name_to_pinyin_tool import name_to_pinyin, name_to_acronym
from tools.md5_tool import md5_encryption
from tools.client_group_tool import insert_client_group, dbc_group
from tools.name_split import name_split

choices = [u'男', u'女']
override_choices = [u'是', u'否']
REG_GROUP_GOOGLE = r'::: [\w*|\s*]'

##暂时没有用到类UTF8Recoder 和 UnicodeReader， UnicodeWriter
#class UTF8Recoder:
#    """
#    Iterator that reads an encoded stream and reencodes the input to UTF-8
#    """
#    def __init__(self, f, encoding):
#        self.reader = codecs.getreader(encoding)(f)
#
#    def __iter__(self):
#        return self
#
#    def next(self):
#        return self.reader.next().encode("utf-8")
#
#class UnicodeReader:
#    """
#    A CSV reader which will iterate over lines in the CSV file "f",
#    which is encoded in the given encoding.
#    """
#
#    def __init__(self, f, dialect = csv.excel, encoding = "utf-8", **kwds):
#        f = UTF8Recoder(f, encoding)
#        self.reader = csv.reader(f, dialect = dialect, **kwds)
#
#    def next(self):
#        row = self.reader.next()
#        return [unicode(s, "utf-8") for s in row]
#
#    def __iter__(self):
#        return self
#
#class UnicodeWriter:
#    """
#    A CSV writer which will write rows to CSV file "f",
#    which is encoded in the given encoding.
#    """
#
#    def __init__(self, f, dialect = csv.excel, encoding = "utf-8", **kwds):
#        # Redirect output to a queue
#        self.queue = cStringIO.StringIO()
#        self.writer = csv.writer(self.queue, dialect = dialect, **kwds)
#        self.stream = f
#        self.encoder = codecs.getincrementalencoder(encoding)()
#
#    def writerow(self, row):
#        self.writer.writerow([s.encode("utf-8") for s in row])
#        # Fetch UTF-8 output from the queue ...
#        data = self.queue.getvalue()
#        data = data.decode("utf-8")
#        # ... and reencode it into the target encoding
#        data = self.encoder.encode(data)
#        # write to the target stream
#        self.stream.write(data)
#        # empty queue
#        self.queue.truncate(0)
#
#    def writerows(self, rows):
#        for row in rows:
#            self.writerow(row)
#
#这个地方之处理了gbk和utf8的，而且第一栏必须是“姓名” 违背这些条件的情况都未做处理(现版本已经不使用该函数了)
def get_import_client_csv_file_encode(table_head_0):
    # table_head_0是表头第一列'姓名'
    # '姓名'的 utf-8编码
    if table_head_0 == '\xef\xbb\xbf\xe5\xa7\x93\xe5\x90\x8d':
        return 'utf-8'
    # '姓名'的gbk编码 
    elif table_head_0 == '\xd0\xd5\xc3\xfb':
        return 'gbk'

#从CSV文件导入联系人（会议联系人）的方法
def import_client_by_csv_tool(type, object, csv_file, add_to_client):
    c = csv_file.read()
    reader = csv.reader(StringIO.StringIO(c))
    try:
        data = reader.next()
    except Exception, e:
        if str(e) == 'line contains NULL byte':
            try:
                csv_file.seek(0)
                csv_content = csv_file.read().decode('utf-16')
                reader = csv.reader(StringIO.StringIO(csv_content))
                data = reader.next()
            except Exception, e:
                raise Exception(u'错误:您的模板非法，请打开您的CSV文件，重新检查数据后再次上传，如果多次失败，请联系我们。错误提示：%s' % str(e))
        else:
            raise Exception(u'错误:您的模板非法，请打开您的CSV文件，重新检查数据后再次上传，如果多次失败，请联系我们。错误提示：%s' % str(e))
    column_data = get_column_of_csv(type, data)     #返回CSV类型和CSV文件中所需列的序号
    correct_count = 0
    incorrect_count = 0
    error_message = {}
    i = 0
    for row in reader:
        if row:
            i += 1
            try:
                contactor = create_contactor(row, column_data)      #创建Contactor对象
            except Exception, e:
                return str(e)
            check_error_msg = contactor.check()       #使用contactor类中的check()以校验数据是否符合数据库要求
            temp_error_list = []
            status = 'pass'
            for msg in check_error_msg:
                if msg[0] in ['email', 'name']:
                    status = 'stop'
                    error_message.update({i:msg[1]})   #error_message中记录了行号和错误信息
                    incorrect_count += 1
                    break;
                else:
                    temp_error_list.append(msg[1])
            if status == 'stop':
                continue
            elif temp_error_list:
                msg = ';'.join(temp_error_list)
                if len(msg) > 20:
                    msg = msg[:20] + '...'
                error_message.update({i:msg})
            # 获取usercompany
            if isinstance(object, Meeting):
                usercompany = object.company
            else:
                usercompany = object.userprofile.company
            name_pinyin = name_to_pinyin(contactor.name)
            name_acronym = name_to_acronym(contactor.name)
            first_name = name_split(contactor.name)
            client = Client.objects.get_or_create(name = contactor.name, email = contactor.email, usercompany = usercompany, defaults = {'tempflag':True,
                                                                                                                                        'first_name':first_name,
                                                                                                                                        'name_pinyin':name_pinyin,
                                                                                                                                        'name_acronym':name_acronym})
            existed_flag = client[1]
            client = client[0]
            client.tempflag = (not add_to_client) and client.tempflag
            if existed_flag or contactor.replace:
                client.company = contactor.company
                client.cell_phone = contactor.phone
                client.group = contactor.group
                client.age = contactor.age
                client.gender = contactor.gender
                client.address = contactor.address
                client.nation = contactor.nation
                client.code = contactor.code
                client.qq = contactor.qq
                client.msn = contactor.msn
                client.telphone = contactor.telphone
                client.title = contactor.title
                client.race = contactor.race
                client.birth_year = contactor.birth_year
                client.birth_month = contactor.birth_month
                client.birth_day = contactor.birth_day
            client.save()
            group_name = dbc_group(client.group)
            insert_client_group(group_name, usercompany)
            if existed_flag:
                data_import_handler.Client_Import_Handler().add_client_index(client)
            else:
                data_import_handler.Client_Import_Handler().update_client_index(client)
            if isinstance(object, Meeting):
                client_key = md5_encryption(str(object.id) + ',' + str(client.id))
                meetingclient = MeetingsClients.objects.get_or_create(client = client,
                                                                    meeting = object,
                                                                    defaults = {'apply_status':u'未报名',
                                                                                    'approve_status':u'未审批',
                                                                                    'present_status':u'未签到',
                                                                                    'client_key':client_key,
                                                                                    }
                                                                                    )
                if meetingclient[1]:
                    meetings_clients = meetingclient[0]
                    Event.objects.create(object_id = meetings_clients.id, object_type = 'MeetingsClients', type = u'状态变化', detail = u'添加客户到会议')
                    client_info_additional_list = ClientInfo.objects.filter(meeting = object).order_by('order')
                    if client_info_additional_list:
                        for client_info in client_info_additional_list:
                            MeetingsClientInfosValues.objects.create(meetings_clients = meetings_clients, name = client_info.name, value = '')
            correct_count += 1
    csv_file.close()
    return {'correct_count':correct_count,
                'incorrect_count':incorrect_count,
                'error_message':error_message}

# 根据不同类型的CSV文件 获取所需列的行号
def get_column_of_csv(type, data):
    data = decode_gb(data)
    if type == 'outlook':
        try:
            data.index('First Name')
            type = 'outlook-en'
        except Exception:
            type = 'outlook-cn'
    if type == 'yahoo':
        try:
            data.index(u'中间名')
            type = 'yahoo-cn'
        except Exception:
            try:
                data.index('First Name')
                type = 'yahoo-common'
            except Exception:
                type = 'yahoo-special'
    if type in ['hotmail']:
        column_data = [type, {
                            'FIRST_NAME_INDEX' : Return_Index(data, 'First Name'),
                            'MIDDLE_NAME_INDEX' : Return_Index(data, 'Middle Name'),
                            'LAST_NAME_INDEX' : Return_Index(data, 'Last Name'),
                            'MOBILE_PHONE_INDEX' : Return_Index(data, 'Mobile Phone'),
                            'EMAIL_INDEX' : Return_Index_List(data, ['E-mail Address', 'E-mail 2 Address', 'E-mail 3 Address']),
                            'COMPANY_INDEX' : Return_Index(data, 'Company'),
                            'TITLE_INDEX':Return_Index(data, 'Job Title'),
                            'ADDRESS_INDEX':Return_Index_List(data, ['Business Street', 'Home Street']),
                            'GENDER_INDEX':Return_Index(data, 'Gender'),
                            'GROUP_INDEX':Return_Index(data, 'Categories'),
                            'AGE_INDEX':Return_Index(data, 'AGE_INDEX-NONE'),
                            'BIRTH_INDEX':Return_Index(data, 'Birthday'),
                            'QQ_INDEX':Return_Index(data, 'QQ_INDEX-NONE'),
                            'MSN_INDEX':Return_Index(data, 'MSN_INDEX-NONE'),
                            'TELPHONE_INDEX':Return_Index_List(data, ['Business Phone', 'Business Phone 2', 'Home Phone', 'Home Phone 2']),
                            'CODE_INDEX':Return_Index_List(data, ['Business Postal Code', 'Home Postal Code']),
                            'NATION_INDEX':Return_Index_List(data, ['Business Country', 'Home Country']),
                            'RACE_INDEX':Return_Index(data, 'RACE_INDEX-NONE'),
                            'NAME_INDEX':Return_Index(data, 'NAME_INDEX-NONE'),
                            'REPLACE_INDEX':Return_Index(data, 'REPLACE_INDEX-NONE'),
                            }]
    elif type in ['outlook-en']:
        column_data = [type, {
                            'FIRST_NAME_INDEX' : Return_Index(data, 'First Name'),
                            'MIDDLE_NAME_INDEX' : Return_Index(data, 'Middle Name'),
                            'LAST_NAME_INDEX' : Return_Index(data, 'Last Name'),
                            'MOBILE_PHONE_INDEX' : Return_Index(data, 'Mobile Phone'),
                            'EMAIL_INDEX' : Return_Index(data, 'E-mail Address'),
                            'COMPANY_INDEX' : Return_Index(data, 'Company'),
                            'TITLE_INDEX':Return_Index(data, 'Job Title'),
                            'ADDRESS_INDEX':Return_Index_List(data, ['Business Street', 'Business Street 2', 'Business Street 3' , 'Home Street', 'Home Street 2', 'Home Street 3', 'Other Street', 'Other Street 2', 'Other Street 3']),
                            'GENDER_INDEX':Return_Index(data, 'Title'),
                            'GROUP_INDEX':Return_Index(data, 'Categories'),
                            'AGE_INDEX':Return_Index(data, 'AGE_INDEX-NONE'),
                            'BIRTH_INDEX':Return_Index(data, 'Birthday'),
                            'QQ_INDEX':Return_Index(data, 'QQ_INDEX-NONE'),
                            'MSN_INDEX':Return_Index(data, 'MSN_INDEX-NONE'),
                            'TELPHONE_INDEX':Return_Index_List(data, ['Business Phone', 'Business Phone 2', 'Home Phone', 'Home Phone 2']),
                            'CODE_INDEX':Return_Index_List(data, ['Business Postal Code', 'Home Postal Code', 'Other Postal Code']),
                            'NATION_INDEX':Return_Index_List(data, ['Business Country', 'Home Country', 'Other Country']),
                            'RACE_INDEX':Return_Index(data, 'RACE_INDEX-NONE'),
                            'NAME_INDEX':Return_Index(data, 'NAME_INDEX-NONE'),
                            'REPLACE_INDEX':Return_Index(data, 'REPLACE_INDEX-NONE'),
                            }]
    elif type in [ 'yahoo-common']:
        column_data = [type, {
                            'FIRST_NAME_INDEX' : Return_Index(data, 'First Name'),
                            'MIDDLE_NAME_INDEX' : Return_Index(data, 'Middle Name'),
                            'LAST_NAME_INDEX' : Return_Index(data, 'Last Name'),
                            'MOBILE_PHONE_INDEX' : Return_Index(data, 'Mobile Phone'),
                            'EMAIL_INDEX' : Return_Index(data, 'E-mail Address'),
                            'COMPANY_INDEX' : Return_Index(data, 'Company'),
                            'TITLE_INDEX':Return_Index(data, 'Job Title'),
                            'ADDRESS_INDEX':Return_Index_List(data, ['Business Street', 'Business Street 2', 'Business Street 3' , 'Home Street', 'Home Street 2', 'Home Street 3', 'Other Street', 'Other Street 2', 'Other Street 3']),
                            'GENDER_INDEX':Return_Index(data, 'Gender'),
                            'GROUP_INDEX':Return_Index(data, 'Categories'),
                            'AGE_INDEX':Return_Index(data, 'AGE_INDEX-NONE'),
                            'BIRTH_INDEX':Return_Index(data, 'Birthday'),
                            'QQ_INDEX':Return_Index(data, 'QQ_INDEX-NONE'),
                            'MSN_INDEX':Return_Index(data, 'MSN_INDEX-NONE'),
                            'TELPHONE_INDEX':Return_Index_List(data, ['Business Phone', 'Business Phone 2', 'Home Phone', 'Home Phone 2']),
                            'CODE_INDEX':Return_Index_List(data, ['Business Postal Code', 'Home Postal Code', 'Other Postal Code']),
                            'NATION_INDEX':Return_Index_List(data, ['Business Country', 'Home Country', 'Other Country']),
                            'RACE_INDEX':Return_Index(data, 'RACE_INDEX-NONE'),
                            'NAME_INDEX':Return_Index(data, 'NAME_INDEX-NONE'),
                            'REPLACE_INDEX':Return_Index(data, 'REPLACE_INDEX-NONE'),
                            }]
    elif type in ['gmail', ]:
        column_data = [type, {
                                'FIRST_NAME_INDEX' : Return_Index(data, 'Given Name'),
                                'MIDDLE_NAME_INDEX' : Return_Index(data, 'Additional Name'),
                                'LAST_NAME_INDEX' : Return_Index(data, 'Family Name'),
                                'NAME_INDEX':Return_Index(data, 'Name'),
                                'MOBILE_PHONE_INDEX' : Return_Index_4_Gmail(data, 'Phone'),
                                'EMAIL_INDEX' : Return_Index_4_Gmail(data, 'Email'),
                                'COMPANY_INDEX' : Return_Index_4_Gmail(data, 'Company'),
                                'GENDER_INDEX':Return_Index(data, 'Gender'),
                                'ADDRESS_INDEX':Return_Index_4_Gmail(data, 'Address'),
                                'TITLE_INDEX':Return_Index_4_Gmail(data, 'Title'),
                                'BIRTH_INDEX':Return_Index_4_Gmail(data, 'Birthday'),
                                'GROUP_INDEX':Return_Index(data, 'Group Membership'),
                                'AGE_INDEX':Return_Index(data, 'AGE_INDEX-NONE'),
                                'QQ_INDEX':Return_Index(data, 'QQ_INDEX-NONE'),
                                'MSN_INDEX':Return_Index(data, 'MSN_INDEX-NONE'),
                                'TELPHONE_INDEX':Return_Index(data, 'TELPHONE_INDEX-NONE'),
                                'CODE_INDEX':Return_Index(data, 'CODE_INDEX-NONE'),
                                'NATION_INDEX':Return_Index(data, 'NATION_INDEX-NONE'),
                                'RACE_INDEX':Return_Index(data, 'RACE_INDEX-NONE'),
                                'REPLACE_INDEX':Return_Index(data, 'REPLACE_INDEX-NONE'),
                                    }]
    elif type == 'yahoo-special':
        column_data = [type , {
                            'FIRST_NAME_INDEX' : Return_Index(data, 'First'),
                            'MIDDLE_NAME_INDEX' : Return_Index(data, 'Middle'),
                            'LAST_NAME_INDEX' : Return_Index(data, 'Last'),
                            'MOBILE_PHONE_INDEX' : Return_Index(data, 'Mobile'),
                            'EMAIL_INDEX' : Return_Index(data, 'Email'),
                            'COMPANY_INDEX' : Return_Index(data, 'Company'),
                            'TITLE_INDEX':Return_Index(data, 'TITLE_INDEX-NONE'),
                            'ADDRESS_INDEX':Return_Index(data, 'ADDRESS_INDEX-NONE'),
                            'GENDER_INDEX':Return_Index(data, 'GENDER_INDEX-NONE'),
                            'GROUP_INDEX':Return_Index(data, 'GROUP_INDEX-NONE'),
                            'AGE_INDEX':Return_Index(data, 'AGE_INDEX-NONE'),
                            'BIRTH_INDEX':Return_Index(data, 'BIRTH_INDEX-NONE'),
                            'QQ_INDEX':Return_Index(data, 'QQ_INDEX-NONE'),
                            'MSN_INDEX':Return_Index(data, 'MSN_INDEX-NONE'),
                            'TELPHONE_INDEX':Return_Index(data, 'TELPHONE_INDEX-NONE'),
                            'CODE_INDEX':Return_Index(data, 'CODE_INDEX-NONE'),
                            'NATION_INDEX':Return_Index(data, 'NATION_INDEX-NONE'),
                            'RACE_INDEX':Return_Index(data, 'RACE_INDEX-NONE'),
                            'NAME_INDEX':Return_Index(data, 'NAME_INDEX-NONE'),
                            'REPLACE_INDEX':Return_Index(data, 'REPLACE_INDEX-NONE'),
                            }]
    elif type == 'yahoo-cn':
        column_data = [type , {
                                'FIRST_NAME_INDEX' : Return_Index(data, 'First'),
                                'MIDDLE_NAME_INDEX' : Return_Index(data, u'中间名'),
                                'LAST_NAME_INDEX' : Return_Index(data, 'Last'),
                                'MOBILE_PHONE_INDEX' : Return_Index(data, 'Mobile'),
                                'EMAIL_INDEX' : Return_Index(data, 'Email'),
                                'COMPANY_INDEX' : Return_Index(data, 'Company'),
                                'TITLE_INDEX':Return_Index(data, 'TITLE_INDEX-NONE'),
                                'ADDRESS_INDEX':Return_Index(data, 'ADDRESS_INDEX-NONE'),
                                'GENDER_INDEX':Return_Index(data, 'GENDER_INDEX-NONE'),
                                'GROUP_INDEX':Return_Index(data, 'GROUP_INDEX-NONE'),
                                'AGE_INDEX':Return_Index(data, 'AGE_INDEX-NONE'),
                                'BIRTH_INDEX':Return_Index(data, 'BIRTH_INDEX-NONE'),
                                'QQ_INDEX':Return_Index(data, 'QQ_INDEX-NONE'),
                                'MSN_INDEX':Return_Index(data, 'MSN_INDEX-NONE'),
                                'TELPHONE_INDEX':Return_Index(data, 'TELPHONE_INDEX-NONE'),
                                'CODE_INDEX':Return_Index(data, 'CODE_INDEX-NONE'),
                                'NATION_INDEX':Return_Index(data, 'NATION_INDEX-NONE'),
                                'RACE_INDEX':Return_Index(data, 'RACE_INDEX-NONE'),
                                'NAME_INDEX':Return_Index(data, 'NAME_INDEX-NONE'),
                                'REPLACE_INDEX':Return_Index(data, 'REPLACE_INDEX-NONE'),
                                }]
    elif type == 'custom':
        column_data = [type , {
                            'NAME_INDEX' : Return_Index(data, u'姓名'),
                            'MOBILE_PHONE_INDEX' : Return_Index(data, u'手机号码'),
                            'EMAIL_INDEX' : Return_Index(data, u'邮箱'),
                            'COMPANY_INDEX' : Return_Index(data, u'公司'),
                            'GROUP_INDEX' : Return_Index(data, u'客户分组'),
                            'REPLACE_INDEX':Return_Index(data, u'是否覆盖已存在的客户'),
                            'FIRST_NAME_INDEX' : Return_Index(data, 'FIRST_NAME_INDEX-NONE'),
                            'MIDDLE_NAME_INDEX' : Return_Index(data, u'MIDDLE_NAME_INDEX-NONE'),
                            'LAST_NAME_INDEX' : Return_Index(data, 'LAST_NAME_INDEX-NONE'),
                            'TITLE_INDEX':Return_Index(data, u'职位'),
                            'ADDRESS_INDEX':Return_Index(data, u'联系地址'),
                            'GENDER_INDEX':Return_Index(data, u'性别'),
                            'AGE_INDEX':Return_Index(data, u'年龄'),
                            'BIRTH_INDEX':Return_Index(data, u'出生年月日'),
                            'QQ_INDEX':Return_Index(data, 'QQ'),
                            'MSN_INDEX':Return_Index(data, 'MSN'),
                            'TELPHONE_INDEX':Return_Index(data, u'联系电话'),
                            'CODE_INDEX':Return_Index(data, u'邮编'),
                            'NATION_INDEX':Return_Index(data, u'国籍'),
                            'RACE_INDEX':Return_Index(data, u'民族'),
                            }]
#Outlook中文版、163和126的CSV默认是GB2312编码制式的，所以我们需要把取到的数据进行解码，list内容不能修改，我们只能新建一个list 然后往里面添加解完码的数据
    elif type == 'outlook-cn':
        column_data = [type , {
                                'FIRST_NAME_INDEX' : Return_Index(data, u'姓'),
                                'MIDDLE_NAME_INDEX' : Return_Index(data, u'中间名'),
                                'LAST_NAME_INDEX' : Return_Index(data, u'名'),
                                'MOBILE_PHONE_INDEX' : Return_Index(data, u'移动电话'),
                                'EMAIL_INDEX' : Return_Index(data, u'电子邮件地址'),
                                'COMPANY_INDEX' : Return_Index(data, u'单位'),
                                'TITLE_INDEX':Return_Index(data, 'TITLE_INDEX-NONE'),
                                'ADDRESS_INDEX':Return_Index(data, 'ADDRESS_INDEX-NONE'),
                                'GENDER_INDEX':Return_Index(data, 'GENDER_INDEX-NONE'),
                                'GROUP_INDEX':Return_Index(data, 'GROUP_INDEX-NONE'),
                                'AGE_INDEX':Return_Index(data, 'AGE_INDEX-NONE'),
                                'BIRTH_INDEX':Return_Index(data, 'BIRTH_INDEX-NONE'),
                                'QQ_INDEX':Return_Index(data, 'QQ_INDEX-NONE'),
                                'MSN_INDEX':Return_Index(data, 'MSN_INDEX-NONE'),
                                'TELPHONE_INDEX':Return_Index(data, 'TELPHONE_INDEX-NONE'),
                                'CODE_INDEX':Return_Index(data, 'CODE_INDEX-NONE'),
                                'NATION_INDEX':Return_Index(data, 'NATION_INDEX-NONE'),
                                'RACE_INDEX':Return_Index(data, 'RACE_INDEX-NONE'),
                                'NAME_INDEX':Return_Index(data, 'NAME_INDEX-NONE'),
                                'REPLACE_INDEX':Return_Index(data, 'REPLACE_INDEX-NONE'),
                                }]
    elif type in ['163', '126']:
        print [data[0].decode('utf-8')]
        column_data = [type , {
                                'NAME_INDEX' : Return_Index(data, u'姓名'),
                                'MOBILE_PHONE_INDEX' : Return_Index(data, u'移动电话'),
                                'EMAIL_INDEX' : Return_Index(data, u'邮件地址'),
                                'COMPANY_INDEX' : Return_Index(data, u'公司'),
                                'CODE_INDEX':Return_Index_List(data, [u'公司邮编', u'邮政编码']),
                                'ADDRESS_INDEX':Return_Index_List(data, [u'公司地址', u'联系地址']),
                                'TELPHONE_INDEX':Return_Index_List(data, [u'公司电话', u'联系电话']),
                                'BIRTH_INDEX':Return_Index(data, u'生日'),
                                'TITLE_INDEX':Return_Index(data, u'职位'),
                                'GROUP_INDEX':Return_Index(data, u'联系组'),
                                'GENDER_INDEX':Return_Index(data, 'GENDER_INDEX-NONE'),
                                'AGE_INDEX':Return_Index(data, 'AGE_INDEX-NONE'),
                                'QQ_INDEX':Return_Index(data, 'QQ_INDEX-NONE'),
                                'MSN_INDEX':Return_Index(data, 'MSN_INDEX-NONE'),
                                'NATION_INDEX':Return_Index(data, 'NATION_INDEX-NONE'),
                                'RACE_INDEX':Return_Index(data, 'RACE_INDEX-NONE'),
                                'REPLACE_INDEX':Return_Index(data, 'REPLACE_INDEX-NONE'),
                                'FIRST_NAME_INDEX' : Return_Index(data, u'FIRST_NAME_INDEX-NONE'),
                                'MIDDLE_NAME_INDEX' : Return_Index(data, u'MIDDLE_NAME_INDEX-NONE'),
                                'LAST_NAME_INDEX' : Return_Index(data, u'LAST_NAME_INDEX-NONE'),
                                }]
    elif type in ['sohu']:
        column_data = [type, {
                            'NAME_INDEX' : Return_Index(data, u'昵称'),
                            'MOBILE_PHONE_INDEX' : Return_Index(data, u'移动电话'),
                            'EMAIL_INDEX' : Return_Index(data, u'电子邮件地址'),
                            'COMPANY_INDEX' : Return_Index_List(data, [u'公司所在街道', u'家庭所在街道']),
                            'CODE_INDEX':Return_Index_List(data, [u'公司所在地的邮政编码', u'家庭所在地的邮政编码']),
                            'ADDRESS_INDEX':Return_Index_List(data, [u'公司所在街道', u'家庭所在街道']),
                            'TELPHONE_INDEX':Return_Index_List(data, [u'商务电话', '住宅电话']),
                            'BIRTH_INDEX':Return_Index(data, u'TELPHONE_INDEX-NONE'),
                            'TITLE_INDEX':Return_Index(data, u'TITLE_INDEX-NONE'),
                            'GROUP_INDEX':Return_Index(data, u'GROUP_INDEX_NONE'),
                            'GENDER_INDEX':Return_Index(data, 'GENDER_INDEX-NONE'),
                            'AGE_INDEX':Return_Index(data, 'AGE_INDEX-NONE'),
                            'QQ_INDEX':Return_Index(data, 'QQ_INDEX-NONE'),
                            'MSN_INDEX':Return_Index(data, 'MSN_INDEX-NONE'),
                            'NATION_INDEX':Return_Index(data, 'NATION_INDEX-NONE'),
                            'RACE_INDEX':Return_Index(data, 'RACE_INDEX-NONE'),
                            'REPLACE_INDEX':Return_Index(data, 'REPLACE_INDEX-NONE'),
                            'FIRST_NAME_INDEX' : Return_Index(data, u'FIRST_NAME_INDEX-NONE'),
                            'MIDDLE_NAME_INDEX' : Return_Index(data, u'MIDDLE_NAME_INDEX-NONE'),
                            'LAST_NAME_INDEX' : Return_Index(data, u'LAST_NAME_INDEX-NONE'),
                            }]
    return column_data

#将每一行数据中的GB2312字符解码
def decode_gb(data):
    new_data = []
    for data_gb in data:
        try:
            new_data.append(data_gb.decode('gb2312'))
        except Exception:
            try:
                new_data.append(data_gb.decode('utf-8'))
            except Exception:
                new_data.append(data_gb)
    return new_data
    
def google_group_handler(data):
    list = data.split(':::')
    if list:
        nlist = []
        for d in list:
            nlist.append(d.strip())
        return ';'.join(nlist)
    return ''
            
def Split_Birthday(data):
    reg_1 = re.compile(r'^[1-2][0,9][0-9]{2}[0,1][0-9][0-3][0-9]$')
    reg_2 = re.compile(r'^[1-2][0,9][0-9]{2}/[0,1]?[0-9]/[0-3]?[0-9]$')
    reg_3 = re.compile(r'^[1-2][0,9][0-9]{2}-[0,1]?[0-9]-[0-3]?[0-9]$')
    if data:
        if reg_1.search(data):
            return [data[:4], data[4:6], data[6:8]]
        if reg_2.search(data):
            return data.split(r'/')
        if reg_3.search(data):
            return data.split('-')
    return ['', '', '']

#创建Contactor对象
def create_contactor(row, column_data):
    if column_data[0] in ['gmail']:
        data = column_data[1]
        contactor = Contactor()
        first_name = Return_Index_Value(row, data['FIRST_NAME_INDEX'])
        middle_name = Return_Index_Value(row, data['MIDDLE_NAME_INDEX'])
        last_name = Return_Index_Value(row, data['LAST_NAME_INDEX'])
        name = Return_Index_Value(row, data['NAME_INDEX'])
        if name:
            contactor.name = name
        else:
            contactor.name = Return_Name_Nation(first_name, middle_name, last_name)
        contactor.email = Return_Index_Value_4_Gmail(row, data['EMAIL_INDEX'])
        contactor.phone = Return_Index_Value_4_Gmail(row, data['MOBILE_PHONE_INDEX'])
        contactor.company = Return_Index_Value_4_Gmail(row, data['COMPANY_INDEX'])
        contactor.group = google_group_handler(Return_Index_Value(row, data['GROUP_INDEX']))
        contactor.gender = Return_Index_Value(row, data['GENDER_INDEX'])
        contactor.code = Return_Index_Value(row, data['CODE_INDEX'])
        contactor.age = Return_Index_Value(row, data['AGE_INDEX'])
        contactor.address = Return_Index_Value(row, data['ADDRESS_INDEX'])
        contactor.nation = Return_Index_Value(row, data['NATION_INDEX'])
        contactor.title = Return_Index_Value_4_Gmail(row, data['TITLE_INDEX'])
        contactor.birth_year = Split_Birthday(Return_Index_Value(row, data['BIRTH_INDEX']))[0]
        contactor.birth_month = Split_Birthday(Return_Index_Value(row, data['BIRTH_INDEX']))[1]
        contactor.birth_day = Split_Birthday(Return_Index_Value(row, data['BIRTH_INDEX']))[2]
        
        contactor.qq = Return_Index_Value(row, data['QQ_INDEX'])
        contactor.msn = Return_Index_Value(row, data['MSN_INDEX'])
        contactor.telphone = Return_Index_Value(row, data['TELPHONE_INDEX'])
        contactor.race = Return_Index_Value(row, data['RACE_INDEX'])
        contactor.replace = True
    else:
        data = column_data[1]
        contactor = Contactor()
        first_name = Return_Index_Value(row, data['FIRST_NAME_INDEX'])
        middle_name = Return_Index_Value(row, data['MIDDLE_NAME_INDEX'])
        last_name = Return_Index_Value(row, data['LAST_NAME_INDEX'])
        name = Return_Index_Value(row, data['NAME_INDEX'])
        if name:
            contactor.name = name
        else:
            contactor.name = Return_Name_Nation(first_name, middle_name, last_name)
        contactor.email = Return_Index_Value(row, data['EMAIL_INDEX'])
        contactor.phone = Return_Index_Value(row, data['MOBILE_PHONE_INDEX'])
        contactor.company = Return_Index_Value(row, data['COMPANY_INDEX'])
        contactor.group = Return_Index_Value(row, data['GROUP_INDEX'])
        contactor.gender = Return_Index_Value(row, data['GENDER_INDEX'])
        contactor.code = Return_Index_Value(row, data['CODE_INDEX'])
        contactor.age = Return_Index_Value(row, data['AGE_INDEX'])
        contactor.address = Return_Index_Value(row, data['ADDRESS_INDEX'])
        contactor.nation = Return_Index_Value(row, data['NATION_INDEX'])
        contactor.title = Return_Index_Value(row, data['TITLE_INDEX'])
        contactor.birth_year = Split_Birthday(Return_Index_Value(row, data['BIRTH_INDEX']))[0]
        contactor.birth_month = Split_Birthday(Return_Index_Value(row, data['BIRTH_INDEX']))[1]
        contactor.birth_day = Split_Birthday(Return_Index_Value(row, data['BIRTH_INDEX']))[2]
        contactor.qq = Return_Index_Value(row, data['QQ_INDEX'])
        contactor.msn = Return_Index_Value(row, data['MSN_INDEX'])
        contactor.telphone = Return_Index_Value(row, data['TELPHONE_INDEX'])
        contactor.race = Return_Index_Value(row, data['RACE_INDEX'])
        contactor.replace = Return_Index_Value(row, data['REPLACE_INDEX'])
#    if column_data[0] in ['yahoo-common', 'yahoo-special', 'yahoo-cn', 'outlook-cn', 'outlook-en', 'hotmail']:
#        data = column_data[1]
#        contactor = Contactor()
#        first_name = Return_Index_Value(row, data['FIRST_NAME_INDEX'])
#        middle_name = Return_Index_Value(row, data['MIDDLE_NAME_INDEX'])
#        last_name = Return_Index_Value(row, data['LAST_NAME_INDEX'])
#        contactor.name = Return_Name_Nation(first_name, middle_name, last_name)
#        contactor.email = Return_Index_Value(row, data['EMAIL_ADDRESS_INDEX'])
#        contactor.phone = Return_Index_Value(row, data['MOBILE_PHONE_INDEX'])
#        contactor.company = Return_Index_Value(row, data['COMPANY_INDEX'])
#        contactor.replace = True
#    elif column_data[0] in [ '163', '126', 'sohu']:
#        data = column_data[1]
#        contactor = Contactor()
#        contactor.name = Return_Index_Value(row, data['NAME_INDEX'])
#        contactor.email = Return_Index_Value(row, data['EMAIL_ADDRESS_INDEX'])
#        contactor.phone = Return_Index_Value(row, data['MOBILE_PHONE_INDEX'])
#        contactor.company = Return_Index_Value(row, data['COMPANY_INDEX'])
#        contactor.replace = True
#    elif column_data[0] in ['custom', ]:
#        data = column_data[1]
#        contactor = Contactor()
#        contactor.name = Return_Index_Value(row, data['NAME_INDEX'])
#        contactor.email = Return_Index_Value(row, data['EMAIL_ADDRESS_INDEX'])
#        contactor.phone = Return_Index_Value(row, data['MOBILE_PHONE_INDEX'])
#        contactor.company = Return_Index_Value(row, data['COMPANY_INDEX'])
#        contactor.group = Return_Index_Value(row, data['GROUP_INDEX'])
#        contactor.replace = Return_Index_Value(row, data['REPLACE_INDEX'])
    return contactor

#返回某一项属性在CSV文件中的序号
def Return_Index(data, index_name):
    try:
        return data.index(index_name)
    except Exception:
        return None

#返回某一项属性在CSV文件中的序号（多可能）
def Return_Index_List(data, index_name_list):
    n_l = []
    for index_name in index_name_list:
        try:
            n_l.append(data.index(index_name))
        except Exception:
            continue
    return n_l

def Return_Index_4_Gmail(data, index_name):
    list = []
    if index_name == 'Phone':
        list.append(index_name)
        for i in range(1, 10):
            type = 'Phone %d - Type' % i
            num = 'Phone %d - Value' % i
            try:
                list.append((data.index(type), data.index(num)))
            except Exception:
                return list
        return list
    elif index_name in ['Company', 'Title']:
        list.append(index_name)
        for i in range(1, 10):
            try:
                n = data.index('Organization %d - Name' % i)
                t = data.index('Organization %d - Title' % i)
                list.append((n, t))
            except Exception:
                return list
        return list
    elif index_name == 'Email':
        list.append(index_name)
        for i in range(1, 10):
            try:
                d = data.index('E-mail %d - Value' % i)
                list.append(d)
            except Exception:
                return list
        return list
    elif index_name == 'Address':
        list.append(index_name)
        for i in range(1, 10):
            try:
                d = data.index('Address %d - Formatted' % i)
                list.append(d)
            except Exception:
                return list
        return list
    elif index_name == 'Birthday':
        try:
            return data.index(index_name)
        except Exception:
            return None
            
        

#返回某一行中，该序号列中的内容
def Return_Index_Value(row, index_num):
    if type(index_num) == type([]):
        data = ''
        for index in index_num:
            try:
                data = row[index].strip().decode('gb2312')
            except Exception:
                try:
                    data = row[index].strip().decode('utf-8')
                except Exception:
                    data = ''
            if data:
                break
        return data
    else:
        if index_num == -1 or index_num == None:
            return ''
        else:
            try:
                return row[index_num].strip().decode('gb2312')
            except Exception:
                try:
                    return row[index_num].strip().decode('utf-8')
                except Exception:
                    return ''

def Return_Index_Value_4_Gmail(row, list_data):
    new_list = list_data[:]
    type = new_list.pop(0)
    if new_list:
        if type == 'Phone':
            for tuple_data in new_list:
                if row[tuple_data[0]] == 'Mobile':
                    try:
                        return row[tuple_data[1]].strip().decode('utf-8')
                    except Exception:
                        try:
                            return row[tuple_data[1]].strip().decode('gb2312')
                        except Exception:
                            return ''
                else:
                    pass
        elif type == 'Company':
            for tuple_data in new_list:
                if row[tuple_data[0]]:
                    try:
                        return row[tuple_data[0]].strip().decode('utf-8')
                    except Exception:
                        try:
                            return row[tuple_data[0]].strip().decode('gb2312')
                        except Exception:
                            return ''
            return ''
        elif type == 'Title':
            for tuple_data in new_list:
                if row[tuple_data[1]]:
                    try:
                        return row[tuple_data[1]].strip().decode('utf-8')
                    except Exception:
                        try:
                            return row[tuple_data[1]].strip().decode('gb2312')
                        except Exception:
                            return ''
            return ''
        elif type == 'Email':
            for data in new_list:
                if row[data]:
                    try:
                        return row[data].strip().decode('utf-8')
                    except Exception:
                        try:
                            return row[tuple_data[1]].strip().decode('gb2312')
                        except Exception:
                            return ''
                else:
                    continue
            return ''
        elif type == 'Address':
            for data in new_list:
                if row[data]:
                    try:
                        return row[data].strip().decode('utf-8')
                    except Exception:
                        try:
                            return row[tuple_data[1]].strip().decode('gb2312')
                        except Exception:
                            return ''
                else:
                    continue
            return ''
    else:
        return ''

#拼接名称
def Return_Name_Nation(first, middle, last):
    re_eng = re.compile(r'[a-zA-Z]+')
    if re_eng.match(first):
        name = first + ' ' + middle + ' ' + last
    else:
        name = last + middle + first
    return name.strip()

# 该版本中已不使用此函数
def decode_import_client_csv_row(row, encode, line_num):
    #将csv内容编码成unicode
    decode_name = unicode(row[CSV_CLIENT_NAME_INDEX], encode).strip()
#    decode_gender = unicode(row[CSV_CLIENT_GENDER_INDEX], encode).strip()
    decode_email = unicode(row[CSV_CLIENT_EMAIL_INDEX], encode).strip()
    decode_group = unicode(row[CSV_CLIENT_GROUP_INDEX], encode).strip()
    decode_company = unicode(row[CSV_CLIENT_COMPANY_INDEX], encode).strip()
    decode_cellphone = unicode(row[CSV_CLIENT_CELLPHONE_INDEX], encode).strip()
    decode_override = unicode(row[CSV_CLIENT_OVERRIDE_INDEX], encode).strip()
    if decode_name == '':
        raise MyError(u'错误:第' + str(line_num) + u'行出错，姓名不能为空')
    if len(decode_name) > 64:
        raise MyError(u'错误:第' + str(line_num) + u'行出错，姓名的最大长度为64位')
#    if decode_gender == '':
#        raise MyError(u'错误:第' + str(line_num) + u'行出错，性别不能为空')
    if decode_email == '':
        raise MyError(u'错误:第' + str(line_num) + u'行出错，邮箱不能为空')
    if  len(row) > CSV_CLIENT_COLUMN_COUNT:
        raise MyError(u'错误:第' + str(line_num) + u'行的参数过多')
    if  len(row) < CSV_CLIENT_COLUMN_COUNT:
        raise MyError(u'错误:第' + str(line_num) + u'行的参数过少')
    if not email_re.search(decode_email):
        raise MyError(u'错误:第' + str(line_num) + u'行的邮箱格式不合法.')
    if len(decode_email) > 64:
        raise MyError(u'错误:第' + str(line_num) + u'行出错，邮箱的最大长度为64位')
#    if not decode_gender in choices:
#        raise MyError(u'错误:第' + str(line_num) + u'行出错,性别只可以是男或女')
    if len(decode_company) > 64:
        raise MyError(u'错误:第' + str(line_num) + u'行出错，公司的最大长度为64位')
    if len(decode_group) > 256:
        raise MyError(u'错误:第' + str(line_num) + u'行出错，客户分组的最大长度为256位')
    if decode_group.lower() == 'all':
        raise MyError(u'错误:第' + str(line_num) + u'行出错，客户分组中all是保留字')
    if decode_cellphone != '' and cell_phone_re.search(decode_cellphone) == None:
        raise MyError(u'错误:第' + str(line_num) + u'行出错，手机号码只能输入数字')
    if decode_cellphone != '' and len(decode_cellphone) != 11:
        raise MyError(u'错误:第' + str(line_num) + u'行出错，手机号码只能为11位')
    if not decode_override in override_choices:
        raise MyError(u'错误:第' + str(line_num) + u'行出错,是否覆盖已存在的客户只可以填是或者否')
    
    return decode_name, decode_email, decode_group, decode_company, decode_cellphone, decode_override


def valid_csv_data(row, line_num):
    if not len(row) == CSV_CLIENT_COLUMN_COUNT:
        raise MyError(u'错误:第' + str(line_num) + '行数据非法，请重新检查数据后再次上传，如果多次失败，请联系我们。')
