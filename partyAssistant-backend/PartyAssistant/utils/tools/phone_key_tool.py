#coding=utf-8
'''
Created on 2011-12-30

@author: liuxue
'''
from apps.accounts.models import UserBindingTemp
import random

def generate_phone_code(): #产生手机验证码
#    while True:
#        userkey = ''.join(random.sample([chr(i) for i in range(48, 58) + range(65, 91) + range(97, 123)], 6))
#        exists = UserBindingTemp.objects.filter(key=userkey).count() > 0
#        if exists:
#            userkey = ''.join(random.sample([chr(i) for i in range(48, 58) + range(65, 90) + range(97, 122)], 6))
#        else:
#            return userkey
    return ''.join(random.sample([chr(i) for i in range(48, 58) + range(65, 91) + range(97, 123)], 6))