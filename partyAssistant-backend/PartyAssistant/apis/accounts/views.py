#coding=utf-8
'''
Created on 2011-11-7

@author: liuxue
'''

from django.contrib.auth import authenticate, logout
from django.contrib.auth.models import User
from django.db.transaction import commit_on_success
from django.views.decorators.csrf import csrf_exempt
 
from apps.accounts.models import UserIPhoneToken, AccountTempPassword
from apps.parties.models import PartiesClients, Party

from utils.structs.my_exception import myException
from utils.tools.phone_num_tool import regPhoneNum
from utils.tools.phone_key_tool import generate_phone_code
from utils.tools.apis_json_response_tool import apis_json_response_decorator
import re

from ERROR_MSG_SETTINGS import *

re_username_string = re.compile(r'^[a-zA-Z]+')
re_username = re.compile(r'^[a-zA-Z]+\w+$')
re_a = re.compile(r'\d+\-\d+\-\d+ \d+\:\d+\:\d+')
re_email = re.compile(
    r"(^[-!#$%&'*+/=?^_`{}|~0-9A-Z]+(\.[-!#$%&'*+/=?^_`{}|~0-9A-Z]+)*"  # dot-atom
    r'|^"([\001-\010\013\014\016-\037!#-\[\]-\177]|\\[\001-011\013\014\016-\177])*"' # quoted-string
    r')@(?:[A-Z0-9](?:[A-Z0-9-]{0,61}[A-Z0-9])?\.)+[A-Z]{2,6}\.?$', re.IGNORECASE)
re_phone = re.compile(r'1\d{10}')

@csrf_exempt
@apis_json_response_decorator
@commit_on_success
def accountLogin(request):
    if request.method == 'POST':
        user = authenticate(username = request.POST['username'], password = request.POST['password'])
        if user:
            device_token = request.POST['device_token']
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
        device_token = request.POST['device_token']
        user_token_list = UserIPhoneToken.objects.filter(device_token = device_token)
        for user_token in user_token_list:
            user_token.delete()
        if request.user:
            logout(request)
        
@csrf_exempt
@apis_json_response_decorator
@commit_on_success
def accountRegist(request):
    if request.method == 'POST':
        username = request.POST['username']
        password = request.POST['password']
        if username == '':
            raise myException(ERROR_ACCOUNTREGIST_USERNAME_BLANK)
        if password == '':
            raise myException(ERROR_ACCOUNTREGIST_PWD_BLANK)
        if len(username) > 14 or len(username) < 6:
            raise myException(ERROR_ACCOUNTREGIST_USERNAME_LENTH_WRONG)
        if len(password) > 16 or len(password) < 6:
            raise myException(ERROR_ACCOUNTREGIST_PWD_LENTH_WRONG)
        if not re_username_string.match(username):
            raise myException(ERROR_ACCOUNTREGIST_USERNAME_INVALID_FORMAT_HEAD)
        if not re_username.match(username):
            raise myException(ERROR_ACCOUNTREGIST_USERNAME_INVALID_FORMAT_STRING)
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

@csrf_exempt
@commit_on_success
@apis_json_response_decorator
def forgetPassword(request):
    if request.method == 'POST' and 'value' in request.POST:
        value = request.POST['value']
        if re_email.match(value):
            try:
                user = User.objects.get(userprofile__email = value)
            except Exception:
                raise myException(ERROR_FORGETPASSWORD_NO_USER_BY_EMAIL)
            sending_type = 'email'
        elif re_username.match(value):
            try:
                user = User.objects.get(username = value)
            except Exception:
                raise myException(ERROR_FORGETPASSWORD_NO_USER_BY_USERNAME)
            if user.userprofile.phone:
                sending_type = 'sms'
                value = user.userprofile.phone
            elif user.userprofile.email:
                sending_type = "email"
                value = user.userprofile.email
            else:
                raise myException(ERROR_FORGETPASSWORD_NO_USER_BY_USERNAME_NO_BINDING)
        elif re_phone.match(regPhoneNum(value)):
            try:
                user = User.objects.get(userprofile__phone = regPhoneNum(value))
            except Exception:
                raise myException(ERROR_FORGETPASSWORD_NO_USER_BY_SMS)
            sending_type = 'sms'
        else:
            raise myException(ERROR_FORGETPASSWORD_NO_USER_BY_USERNAME)
        temp_password = generate_phone_code()
        temp_pwd_data, created = AccountTempPassword.objects.get_or_create(user = user, defaults = {
                                                                                                    "temp_password":temp_password,
                                                                                                    "sending_type":sending_type,
                                                                                                    })
        if not created:
            temp_pwd_data.sending_type = sending_type
            temp_pwd_data.save()
