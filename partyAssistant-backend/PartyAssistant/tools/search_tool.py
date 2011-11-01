# coding=utf-8
from tools.exceptions import MyError

from settings import PROJECT_ROOT

import re
acronym_character_re = re.compile(r'[a-zA-Z]{2,9}')

#以下的几个函数都是用于搜索时的检查和替换，不过暂时取消了通过前缀查询功能
def process_search_client_key(search_key):
    search_key = search_key.replace('：', ':')
    search_key = search_key.replace(u'姓名', 'name')
    search_key = search_key.replace(u'公司', 'company')
    search_key = search_key.replace(u'分组', 'group')
    search_key_array = search_key.split(':')
    if len(search_key_array) > 2:
        raise MyError(u'您输入的格式不正确，请按正确格式输入 ')
    if len(search_key_array) == 2 and search_key_array[1] == '':
        raise MyError(u'关键字不能为空')
    if len(search_key_array) == 2 and (search_key_array[0] not in ['name', 'company', 'group']):
        raise MyError(u'只能通过姓名，公司，分组查询')
    for i in range(len(search_key_array)):
        search_key_array[i] = search_key_array[i].strip()
    search_key = ':'.join(search_key_array)
    return search_key

def restore_search_client_key(search_key):
    search_key = search_key.replace('name', u'姓名')
    search_key = search_key.replace('company', u'公司')
    search_key = search_key.replace('group', u'分组')
    return search_key

def process_search_meeting_key(search_key):
    search_key = search_key.replace('：', ':')
    search_key = search_key.replace(u'会议名称', 'title')
    search_key = search_key.replace(u'类型', 'type')
    search_key = search_key.replace(u'状态', 'status')
    search_key_array = search_key.split(':')
    if len(search_key_array) > 2:
        raise MyError(u'您输入的格式不正确，请按正确格式输入 ')
    if len(search_key_array) == 2 and search_key_array[1] == '':
        raise MyError(u'关键字不能为空')
    if len(search_key_array) == 2 and (search_key_array[0] not in ['title', 'type', 'status']):
        raise MyError(u'只能通过只能通过会议名称，类型，状态查询查询')
    for i in range(len(search_key_array)):
        search_key_array[i] = search_key_array[i].strip()
    search_key = ':'.join(search_key_array)
    return search_key

def restore_search_meeting_key(search_key):
    search_key = search_key.replace('title', u'会议名称')
    search_key = search_key.replace('type', u'类型')
    search_key = search_key.replace('status', u'状态')
    search_key = search_key.replace('start_time', u'开始时间')
    return search_key

def process_search_meeting_client_key(search_key):
    search_key = search_key.replace('：', ':')
    search_key = search_key.replace(u'姓名', 'name')
    search_key = search_key.replace(u'公司', 'company')
    search_key = search_key.replace(u'分组', 'group')
    search_key = search_key.replace(u'报名状态', 'apply_status')
    search_key = search_key.replace(u'审批状态', 'approve_status')
    search_key = search_key.replace(u'现场状态', 'present_status')
    search_key = search_key.replace(u'临时客户', 'tempflag')
    search_key_array = search_key.split(':')
    if len(search_key_array) > 2:
        raise MyError(u'您输入的格式不正确，请按正确格式输入 ')
    if len(search_key_array) == 2 and search_key_array[1] == '':
        raise MyError(u'关键字不能为空')
    if len(search_key_array) == 2 and (search_key_array[0] not in ['name', 'company', 'group', 'tempflag', 'apply_status', 'approve_status', 'present_status']):
        raise MyError(u'只能通过姓名，公司，分组, 临时客户，报名状态，审批状态，现场状态查询')
    for i in range(len(search_key_array)):
        search_key_array[i] = search_key_array[i].strip()
    search_key = ':'.join(search_key_array)
    return search_key

def restore_search_meeting_client_key(search_key):
    search_key = search_key.replace('name', u'姓名')
    search_key = search_key.replace('company', u'公司')
    search_key = search_key.replace('group', u'分组')
    search_key = search_key.replace('apply_status', u'报名状态')
    search_key = search_key.replace('approve_status', u'审批状态')
    search_key = search_key.replace('present_status', u'现场状态')
    search_key = search_key.replace('tempflag', u'临时客户')
    return search_key

#以下方法正在使用

def check_search_string_special_characters(search_string):
    message = ''
    for char in ['+', '-', '^', '~', '(', ')', '[', ']', '{', '}', '*']:
        if search_string.count(char) != 0:
            message = u'查询条件中含有非法字符，请重新输入'
            break
        continue
    return message

# 如输入li 搜索是否有符合的姓
def check_search_string_first_name_or_not(search_string):
    new_search_string = ''
    if acronym_character_re.match(search_string) != None:
        result_list = []
        try:
            file = open('%(PROJECT_ROOT)s/media/pinyin_tmp/baijiaxing_pinyin.txt' % globals(), 'r+')
        except:
            pass
        finally:
            bytes = file.read()
            lines = bytes.split('\n')
            for line in lines:
                if line.split(":")[1].strip() == search_string.strip() :
                    result = line.split(":")[0]
                    if result not in result_list:
                        result_list.append(result)
            file.close()
            new_search_string = ' '.join(result_list)
    return new_search_string
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
