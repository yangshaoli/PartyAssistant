#encoding=utf-8
from clients.models import ClientGroup, Client
from clients.csv_setting import GROUP_BREAK
import re

# 该方法没用了
def replace_group(name, usercompany, val):
    val = val.decode('utf8')
    reg = re.compile(ur'\w+[\u4e00-\u9fa5]*|[\u4e00-\u9fa5]+\w*')
    temp_list = val.strip().split(",")
    for temp in range(0, len(temp_list)):
        temp_temp_list = temp_list[temp].split(";")
        for temp_temp in range(0, len(temp_temp_list)):
            temp_temp_list[temp_temp] = reg.sub(lambda match : name + match.group(), temp_temp_list[temp_temp])
#            temp_temp_list[temp_temp] = reg.sub(lambda match : match.group(), temp_temp_list[temp_temp])
        temp_list[temp] = ' AND '.join(temp_temp_list)
        temp_list[temp] = '(' + temp_list[temp] + ' AND usercompany:' + usercompany + ')'
    val = ' OR '.join(temp_list)
    return val

def dbc_group(group_name):
    if group_name.find(u'；') != -1:
        group_name = group_name.replace(u'；', ';')
    return group_name

#当添加客户时，同时更新表ClientGroup
def insert_client_group(insert_groupname, company):
    group_list = insert_groupname.split(GROUP_BREAK)
    for groupname in group_list:
        if groupname.strip() != '':
            group = ClientGroup.objects.filter(name = groupname, company = company)
            if not group:
                ClientGroup.objects.create(company = company, name = groupname)

#当添加客户时，如果csv中是覆盖客户, 同时更新表ClientGroup
def delete_client_group_for_overriden(old_groupname, new_groupname, company, client_id):
    old_groupname_list = old_groupname.split(GROUP_BREAK)
    new_groupname_list = new_groupname.split(GROUP_BREAK)
    for groupname in new_groupname_list:
        if groupname.strip() != '' and groupname not in old_groupname_list:
            group = ClientGroup.objects.filter(name = groupname)
            if not group:
                ClientGroup.objects.create(name = groupname, company = company)
    for groupname in old_groupname_list:
        if groupname.strip() != '' and groupname not in new_groupname_list:
            client_list = Client.objects.filter(group = groupname, tempflag = False, usercompany = company).exclude(pk = client_id)
            if not client_list:
                group = ClientGroup.objects.filter(name = groupname, company = company)
                if group:
                    group[0].delete()

#当删除客户时, 同时更新表ClientGroup
def delete_client_group_for_delete_client_directly(groupname, company, client_id):
    groupname_list = groupname.split(GROUP_BREAK)
    for groupname in groupname_list:
        if groupname.strip() != '':
            client_list = Client.objects.filter(group = groupname, tempflag = False, usercompany = company).exclude(pk = client_id)
            if not client_list:
                group = ClientGroup.objects.filter(name = groupname, company = company)
                if group:
                    group[0].delete()
