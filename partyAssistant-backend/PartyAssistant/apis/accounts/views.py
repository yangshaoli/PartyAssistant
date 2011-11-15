#coding=utf-8
'''
Created on 2011-11-7

@author: liuxue
'''

from django.http import HttpResponse
from django.utils import simplejson

from django.contrib.auth.models import User
from django.db.transaction import commit_on_success
from django.views.decorators.csrf import csrf_exempt
 

from utils.tools.my_exception import myException
from utils.tools.apis_json_response import apis_json_response_decorator
import re

from ERROR_MSG_SETTINGS import *

from utils.tools.reg_phone_num import regPhoneNum

re_username = re.compile(r'^[a-zA-Z]+\w+$')
re_a = re.compile(r'\d+\-\d+\-\d+ \d+\:\d+\:\d+')
SMS_APPLY_TIPS_CONTENT = u'(报名点击:aaa, 不报名点击:bbb)'        

@csrf_exempt
@apis_json_response_decorator
@commit_on_success
def accountLogin(request):
    if request.method == 'POST':
        user = authenticate(username = request.POST['username'], password = request.POST['password'])
        if user:
            return {
                    'uid':user.id,
                    'name':user.username,
                    }
        else:
            raise myException(ERROR_ACCOUNTLOGIN_INVALID_PWD)

@csrf_exempt
@apis_json_response_decorator
@commit_on_success
def accountRegist(request):
    if request.method == 'POST':
        username = request.POST['username']
        password = request.POST['password']
        if len(username) > 14 or len(username) < 6:
            raise myException(ERROR_ACCOUNTREGIST_USERNAME_LENTH_WRONG)
        if len(password) > 16 or len(password) < 6:
            raise myException(ERROR_ACCOUNTREGIST_PWD_LENTH_WRONG)
        if not re_username.match(username):
            raise myException(ERROR_ACCOUNTREGIST_USERNAME_INVALID_FORMAT)
        user = User.objects.create_user(username, '', password)
        return {'uid':user.id}


@csrf_exempt
@apis_json_response_decorator
@commit_on_success
def accountLogout(request):
    pass
