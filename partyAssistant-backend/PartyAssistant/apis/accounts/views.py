#coding=utf-8
'''
Created on 2011-11-7

@author: liuxue
'''

from django.contrib.auth import authenticate

from django.contrib.auth.models import User
from django.db.transaction import commit_on_success
from django.views.decorators.csrf import csrf_exempt
 
from apps.accounts.models import UserIPhoneToken
from apps.parties.models import PartiesClients, Party

from utils.structs.my_exception import myException
from utils.tools.apis_json_response_tool import apis_json_response_decorator
import re

from ERROR_MSG_SETTINGS import *

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
            device_token = request.POST['device_token']
            print device_token
            if device_token:
#                if request.POST['device_type'] == 'iphone':
                usertoken, created = UserIPhoneToken.objects.get_or_create(device_token = device_token, defaults = {'user' : user})
                if usertoken.user != user:
                    usertoken.user = user
                    usertoken.save()
            return {
                    'uid':user.id,
                    'name':user.userprofile.true_name,
                    }
        else:
            print 'error'
            raise myException(ERROR_ACCOUNTLOGIN_INVALID_PWD)

@csrf_exempt
@apis_json_response_decorator
@commit_on_success
def accountLogout(request):
    if request.method == 'POST':
        user = request.user
        if user:
            device_token = request.POST['device_token']
            user_token_list = UserIPhoneToken.objects.filter(user = user, device_token = device_token)
            for user_token in user_token_list:
                user_token.delete()
        logout(request)
        
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
        if User.objects.filter(username = username):
            raise myException(ERROR_ACCOUNTREGIST_USER_EXIST)
        user = User.objects.create_user(username, '', password)
        if user:
            device_token = request.POST['device_token']
            if device_token:
                usertoken, created = UserIPhoneToken.objects.get_or_create(device_token = device_token, defaults = {'user' : user})
                if usertoken.user != user:
                    usertoken.user = user
                    usertoken.save()
        return {'uid':user.id}


@csrf_exempt
@apis_json_response_decorator
@commit_on_success
def accountLogout(request):
    pass

@csrf_exempt
@apis_json_response_decorator
@commit_on_success
def getBadgeNum(request):
    if 'id' in request.GET:
        id = request.GET['id']
        party_list = Party.objects.filter(creator = User.objects.get(pk = id))
        return {'badgeNum':PartiesClients.objects.filter(party__in = party_list, is_check = False).count()}
    else:
        return {'badgeNum':0}

@csrf_exempt
@apis_json_response_decorator
@commit_on_success
def profilePage(request, uid):
    user = User.objects.get(pk = id)
    if request.method == 'POST':
#        nickname = 
        pass
    else:
        pass

@csrf_exempt
@apis_json_response_decorator
def getAccountRemaining(request):
    if 'id' in request.GET:
        id = request.GET['id']
        user = User.objects.get(pk = id)
        return {'remaining':user.userprofile.available_sms_count}
    else:
        return {'remaining':0}
