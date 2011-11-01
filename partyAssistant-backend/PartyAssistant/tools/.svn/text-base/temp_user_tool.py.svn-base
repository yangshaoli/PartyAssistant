#coding=utf-8
import datetime

'''
如果用户是临时帐号并且超过了7天试用，就需要他激活帐号
'''

def tempuser_check(u):
    if u and u.userprofile.limit == u'临时账户':
        d = datetime.datetime.now()
        create_time = u.date_joined
        if d > create_time + datetime.timedelta(days = 7):
            return False
    return True
 
