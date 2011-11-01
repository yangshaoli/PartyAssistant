#encoding=utf-8

import atom
import gdata.contacts
import gdata.contacts.service
import re

from events.models import Meeting, MeetingsClients, ClientInfo, Event, MeetingsClientInfosValues
from clients.models import Client
from event_solr import data_import_handler 

from tools.md5_tool import md5_encryption
from tools.client_group_tool import insert_client_group, dbc_group
from tools.exceptions import MyError
from tools.client_name_to_pinyin_tool import name_to_pinyin, name_to_acronym
from tools.name_split import name_split
from django.contrib.auth.models import User

email_re = re.compile(
    r"(([-!#$%&'*+/=?^_`{}|~0-9A-Z]+(\.[-!#$%&'*+/=?^_`{}|~0-9A-Z]+)*"  # dot-atom   
    r'|^"([\001-\010\013\014\016-\037!#-\[\]-\177]|\\[\001-011\013\014\016-\177])*"' # quoted-string   
    r')@(?:[A-Z0-9]+(?:-*[A-Z0-9]+)*\.)+[A-Z]{2,6})', re.IGNORECASE)  # domain   
cell_phone_re = re.compile(r'[0-9]{11}')

class Contactor():
    
    def __init__(self):
        for i in range(0, len(self.Attr_List)):
            if type(self.Attr_Len[i][0]) == type(1):
                setattr(self, self.Attr_List[i], '')
            elif type(self.Attr_Len[i][0]) == type(True):
                setattr(self, self.Attr_List[i], self.Attr_Len[i][0])
                
    Attr_List = ['name', 'email', 'replace', 'templag', 'phone', 'company', 'group', 'nation' , 'address', 'gender', 'title', 'race', \
                 'birth_year', 'birth_month', 'birth_day', 'age', 'code', 'telphone', 'msn', 'qq']
    
    #String (min_length,max_length) *min_leng=0可为空;  Bool(default,default);
    Attr_Len = [(1, 64), (1, 75), (False, False), (False, False), (0, 11), (0, 64), (0, 256), (0, 16), (0, 128), (0, 8), (0, 16), (0, 16), \
                 (0, 4), (0, 2), (0, 2), (0, 4), (0, 8), (0, 16), (0, 128), (0, 16)]
    
    Attr_List_CN = [u'姓名', u'邮箱', u'是否替换栏', u'是否加入通讯录', u'手机', u'公司', u'分组', u'国籍' , u'联系地址', u'性别', u'职位', u'民族', \
                 u'出生年份', u'出生月份', u'出生日期', u'年龄', u'邮编', u'联系电话', 'MSN', 'QQ']
    
    def check(self):
        error_msg = []
        if self.gender in ['Mr.', 'Mr', u'先生', 'Male', u'男']:
            self.gender = u'男'
        elif self.gender in ['Mrs', 'Miss', 'Ms', 'Female', u'女', u'小姐', u'女士']:
            self.gender = u'女'
        else:
            self.gender = ''
        if self.replace == True or self.replace == u'是':
            self.replace = True
        else:
            self.replace = False
        for i in range(0, len(self.Attr_List)):
            if type(self.Attr_Len[i][0]) == type(0):
                min_len = self.Attr_Len[i][0]
                max_len = self.Attr_Len[i][1]
                attr_name = self.Attr_List[i]
                cn_name = self.Attr_List_CN[i]
                if min_len != 0:
                    if not getattr(self, attr_name):
                        error_msg.append((attr_name, u'%s不能为空' % cn_name))
                else:
                    # 没有用not ... 是因为 可能会有int型的，需要做默认为0的处理
                    if getattr(self, attr_name) == '' or getattr(self, attr_name) == None:
                        setattr(self, attr_name, '')
                if len(getattr(self, attr_name)) > max_len:
                    setattr(self, attr_name, '')
                    error_msg.append((attr_name, u'%s长度不能超过%d' % (cn_name, max_len)))
        #特殊处理
        if not email_re.match(self.email):
            error_msg.append(('email', u'联系人邮箱格式不正确'))
        if self.phone and not cell_phone_re.match(self.phone):
            self.phone = ''
            error_msg.append(('phone', u'手机号码格式错误'))
        if self.group and self.group[-1] == ';':
            self.group = self.group[:-1]
        if self.birth_year:
            try:
                x = int(self.birth_year)
                if x < 1930 or x > 2010:
                    self.birth_year = ''
                    error_msg.append(('birth_year', u'出生年份超出系统范围'))
            except Exception:
                self.birth_year = ''
                error_msg.append(('birth_year', u'出生年份格式错误'))
        if self.birth_month:
            try:
                self.birth_month = str(int(self.birth_month))
                x = int(self.birth_month)
                if x < 1 or x > 12:
                    self.birth_month = ''
                    error_msg.append(('birth_month', u'出生月份超出系统范围'))
            except Exception:
                self.birth_month = ''
                error_msg.append(('birth_month', u'出生月份格式错误'))
        if self.birth_day:
            try:
                self.birth_day = str(int(self.birth_day))
                x = int(self.birth_day)
                if x < 1 or x > 31:
                    self.birth_day = ''
                    error_msg.append(('birth_day', u'出生日期超出系统范围'))
            except Exception:
                self.birth_day = ''
                error_msg.append(('birth_day', u'出生日期格式错误'))
        return error_msg
        

def GmailLogin(username, password):
    gd_client = gdata.contacts.service.ContactsService()
    gd_client.email = username
    gd_client.password = password
    gd_client.source = 'exampleCo-exampleApp-1'
    try:
        gd_client.ProgrammaticLogin()
        return gd_client
    except Exception, e:
        if str(e) == 'Incorrect username or password':
            raise MyError(u'用户名或密码错误')
        else:
            raise MyError(u'未知错误')
        
def ImportContactFromGmail(feed, object, add_to_client):
    error_message = {}
    correct_count = 0
    incorrect_count = 0
    for i, entry in enumerate(feed.entry):
        contactor = Contactor()
        contactor.name = entry.title.text
        if entry.organization:
            contactor.company = entry.organization.org_name.text
        for email in entry.email:
            if email.primary and email.primary == 'true':
                contactor.email = email.address
        for group in entry.group_membership_info:
            contactor.group = group.href + contactor.group + u';'
        for phone in entry.phone_number:
            if cell_phone_re.search(phone.text):
                contactor.phone = phone.text
        if contactor.name == ''  and contactor.email == '':
            continue
        try:
            contactor.check()
        except Exception, e:
            error_message.update({i:str(e.value)})
            incorrect_count += 1
            continue
        if isinstance(object, Meeting):
            usercompany = object.company
            contactor.tempflag = True
        else:
            usercompany = object.userprofile.company
        name_pinyin = name_to_pinyin(contactor.name)
        name_acronym = name_to_acronym(contactor.name)
        first_name = name_split(contactor.name)
        client = Client.objects.get_or_create(name = contactor.name,
                                                              email = contactor.email,
                                                              usercompany = usercompany,
                                                              defaults = {'tempflag':True,
                                                                                'first_name':first_name,
                                                                                'name_pinyin' : name_pinyin,
                                                                               'name_acronym' : name_acronym
                                                                               }
                                                              )
        existed_flag = client[1]
        client = client[0]
        client.tempflag = (not add_to_client) and client.tempflag
        client.company = contactor.company
        client.group = contactor.group
        client.cell_phone = contactor.phone
        client.tempflag = contactor.tempflag and client.tempflag
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
        if existed_flag:
            data_import_handler.Client_Import_Handler().add_client_index(client)
        else:
            data_import_handler.Client_Import_Handler().update_client_index(client)
        insert_client_group(group_name, usercompany)
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
    return {'correct_count':correct_count,
            'incorrect_count':incorrect_count,
            'error_message':error_message}
