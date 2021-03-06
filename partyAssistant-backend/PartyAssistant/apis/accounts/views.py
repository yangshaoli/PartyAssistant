#coding=utf-8
'''
Created on 2011-11-7

@author: liuxue
'''
from django.db import transaction
from django.contrib.auth import authenticate, logout
from django.contrib.auth.models import User
from django.db.transaction import commit_on_success
from django.views.decorators.csrf import csrf_exempt
 
from apps.accounts.models import UserIPhoneToken, AccountTempPassword, UserProfile, UserBindingTemp, UserAndroidToken
from apps.parties.models import PartiesClients, Party

from utils.structs.my_exception import myException
from utils.tools.phone_num_tool import regPhoneNum
from utils.tools.phone_key_tool import generate_phone_code
from utils.tools.apis_json_response_tool import apis_json_response_decorator

import re
import hashlib

from ERROR_MSG_SETTINGS import *
from ERROR_STATUS_SETTINGS import *

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
        username = request.POST['username']
        password = request.POST['password']
        user = authenticate(username = username, password = password)
        if not user:
            user_temp_pwd_list = AccountTempPassword.objects.filter(temp_password = password, user__username = username)
            if user_temp_pwd_list:
                user = user_temp_pwd_list[0].user
                _israndomlogin = "1"
            for user_temp_pwd in user_temp_pwd_list:
                user_temp_pwd.delete()
        else:
            _israndomlogin = "0"
        if user:
            if 'device_token' in request.POST:
                device_token = request.POST['device_token']
                if device_token:
    #                if request.POST['device_type'] == 'iphone':
                    usertoken, created = UserIPhoneToken.objects.get_or_create(device_token = device_token, defaults = {'user' : user})
                    if usertoken.user != user:
                        usertoken.user = user
                        usertoken.save()
                
            if 'clientId' in request.POST:
                clientId = request.POST['clientId']
                if clientId:
    #                if request.POST['device_type'] == 'iphone':
                    clientId, created = UserAndroidToken.objects.get_or_create(device_token = clientId, defaults = {'user' : user})
                    if clientId.user != user:
                        clientId.user = user
                        clientId.save()
            return {
                    'uid':user.id,
                    'name':user.userprofile.true_name,
                     "_israndomlogin":_israndomlogin,
                     "user_remaining":user.userprofile.available_sms_count,
                     "username":user.username
                    }
        else:
            print 'error'
            raise myException(ERROR_ACCOUNTLOGIN_INVALID_PWD)

@csrf_exempt
@apis_json_response_decorator
@commit_on_success
def accountLogout(request):
    if request.method == 'POST':
        if 'device_token' in request.POST:
            device_token = request.POST['device_token']
            user_token_list = UserIPhoneToken.objects.filter(device_token = device_token)
            for user_token in user_token_list:
                user_token.delete()
        if 'clientId' in request.POST:
            clientId = request.POST['clientId']
            user_token_list = UserAndroidToken.objects.filter(device_token = clientId)
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
            if "device_token" in request.POST:
                device_token = request.POST['device_token']
                if device_token:
                    usertoken, created = UserIPhoneToken.objects.get_or_create(device_token = device_token, defaults = {'user' : user})
                    if usertoken.user != user:
                        usertoken.user = user
                        usertoken.save()
            if 'clientId' in request.POST:
                clientId = request.POST['clientId']
                if clientId:
    #                if request.POST['device_type'] == 'iphone':
                    clientId, created = UserAndroidToken.objects.get_or_create(device_token = clientId, defaults = {'user' : user})
                    if clientId.user != user:
                        clientId.user = user
                        clientId.save()
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
def profilePage(request):
    if request.method == 'POST':
        uid = request.POST['uid']
        user = User.objects.get(pk = uid)
        return {
                'nickname':user.userprofile.true_name,
                'remaining_sms_count':user.userprofile.available_sms_count,
                'email':user.userprofile.email,
                'email_binding_status':user.userprofile.email_binding_status,
                'phone':user.userprofile.phone,
                'phone_binding_status':user.userprofile.phone_binding_status,
                }

@csrf_exempt
@apis_json_response_decorator
@commit_on_success
def saveNickName(request):
    if request.method == 'POST':
        uid = request.POST['uid']
        user = User.objects.get(pk = uid)
        nickname = request.POST['nickname']
        if len(nickname) > 16:
            raise myException(ERROR_PROFILEPAGE_LONG_NAME)
        user.userprofile.true_name = nickname
        user.userprofile.save()
        return {
                'nickname':user.userprofile.true_name,
                'remaining_sms_count':user.userprofile.available_sms_count,
                'email':user.userprofile.email,
                'email_binding_status':user.userprofile.email_binding_status,
                'phone':user.userprofile.phone,
                'phone_binding_status':user.userprofile.phone_binding_status,
                }

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
                user = User.objects.get(userprofile__email = value, userprofile__email_binding_status = 'bind')
            except Exception:
                raise myException(ERROR_FORGETPASSWORD_NO_USER_BY_EMAIL)
            sending_type = 'email'
        elif re_username.match(value):
            try:
                user = User.objects.get(username = value)
            except Exception:
                raise myException(ERROR_FORGETPASSWORD_NO_USER_BY_USERNAME)
            if user.userprofile.phone and user.userprofile.phone_binding_status == 'bind':
                sending_type = 'sms'
                value = user.userprofile.phone
            elif user.userprofile.email and user.userprofile.email_binding_status == 'bind':
                sending_type = "email"
                value = user.userprofile.email
            else:
                raise myException(ERROR_FORGETPASSWORD_NO_USER_BY_USERNAME_NO_BINDING)
        elif re_phone.match(regPhoneNum(value)):
            try:
                user = User.objects.get(userprofile__phone = regPhoneNum(value), userprofile__phone_binding_status = 'bind')
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

@csrf_exempt
@apis_json_response_decorator
def bindContact(request, type):
    if request.method == 'POST':
        value = request.POST['value']
        uid = request.POST['uid']
        try:
            user = User.objects.get(pk = uid)
        except Exception:
            raise myException(ERROR_BINDING_NO_USER)
        if type == 'email':
            userkey = hashlib.md5("%s:%s" % (uid, value)).hexdigest()
        else:
            userkey = generate_phone_code()
        data = {"latest_status":{
                                 'email':user.userprofile.email,
                                 'email_binding_status':user.userprofile.email_binding_status,
                                 'phone':user.userprofile.phone,
                                 'phone_binding_status':user.userprofile.phone_binding_status,
                                 }
                }
        #数据有效性验证
        if type == 'email' and not re_email.match(value):
            raise myException(ERROR_BINDING_INVAILID_EMAIL_FORMMAT)
        if type == 'phone' and not re_phone.match(regPhoneNum(value)):
            raise myException(ERROR_BINDING_INVAILID_PHONE_FORMMAT)
        #用户已经绑定了
        if type == 'email' and user.userprofile.email_binding_status == 'bind':
            if user.userprofile.email == value:
                raise myException('', status = ERROR_STATUS_HAS_BINDED, data = data)
            else:
                raise myException(ERROR_BINDING_BY_EMAIL_DIFFERENT_BINDED, status = ERROR_STATUS_DIFFERENT_BINDED, data = data)
        elif type == 'phone' and user.userprofile.phone_binding_status == 'bind':
            if user.userprofile.email == value:
                raise myException('', status = ERROR_STATUS_HAS_BINDED, data = data)
            else:
                raise myException(ERROR_BINDING_BY_PHONE_DIFFERENT_BINDED, status = ERROR_STATUS_DIFFERENT_BINDED, data = data)
        #被别人绑定
        if type == 'email' and UserProfile.objects.filter(email = value, email_binding_status = 'bind').exclude(user = user).count() != 0:
            raise myException(ERROR_BINDING_BY_EMAIL_HAS_BINDED_BY_OTHER, status = ERROR_STATUS_HAS_BINDED_BY_OTHER , data = data)
        elif  type == 'phone' and UserProfile.objects.filter(phone = value, phone_binding_status = 'bind').exclude(user = user).count() != 0:
            raise myException(ERROR_BINDING_BY_PHONE_HAS_BINDED_BY_OTHER, status = ERROR_STATUS_HAS_BINDED_BY_OTHER , data = data)
        if type == 'phone':
            value = regPhoneNum(value)
        with transaction.commit_on_success():
            profile = user.userprofile
            if type == 'phone':
                profile.phone = value
                profile.phone_binding_status = 'waitingbind'
            else:
                profile.email = value
                profile.email_binding_status = 'waitingbind'
            profile.save()
        with transaction.commit_on_success():
            binding_temp, created = UserBindingTemp.objects.get_or_create(user = user, binding_type = type, defaults = {"binding_address":value, "key":userkey})
            if not created:
                binding_temp.binding_address = value
                binding_temp.key = userkey
                binding_temp.save()
        data = {"latest_status":{
                                 'email':user.userprofile.email,
                                 'email_binding_status':user.userprofile.email_binding_status,
                                 'phone':user.userprofile.phone,
                                 'phone_binding_status':user.userprofile.phone_binding_status,
                                 }
                }
        return data



@csrf_exempt
@commit_on_success
@apis_json_response_decorator
def unbindContact(request, type):
    if request.method == 'POST':
        value = request.POST['value']
        uid = request.POST['uid']
        try:
            user = User.objects.get(pk = uid)
        except Exception:
            raise myException(ERROR_BINDING_NO_USER)
        if type == 'email':
            userkey = hashlib.md5(value).hexdigest()
        else:
            userkey = generate_phone_code()
        data = {"latest_status":{
                                 'email':user.userprofile.email,
                                 'email_binding_status':user.userprofile.email_binding_status,
                                 'phone':user.userprofile.phone,
                                 'phone_binding_status':user.userprofile.phone_binding_status,
                                 }
                }
        # 确定当前用户状态是已绑定
        if (type == 'email' and user.userprofile.email_binding_status != 'bind')\
            or (type == 'phone' and user.userprofile.phone_binding_status != 'bind'):
            raise myException(ERROR_UNBINDING, status = ERROR_STATUS_DIFFERENT_UNBINDED, data = data)
        # 确定app端的绑定信息是用户最新的绑定信息
        if (type == 'email' and user.userprofile.email != value)or(type == 'phone' and user.userprofile.phone != value):
            raise myException(ERROR_UNBINDING, status = ERROR_STATUS_DIFFERENT_UNBINDED, data = data)
        # 发送验证码
        binding_temp, created = UserBindingTemp.objects.get_or_create(user = user, binding_type = type, defaults = {"binding_address":value, "key":userkey})
        if not created:
            binding_temp.binding_addres = value
            binding_temp.key = userkey
            binding_temp.save()
        data = {"latest_status":{
                                 'email':user.userprofile.email,
                                 'email_binding_status':user.userprofile.email_binding_status,
                                 'phone':user.userprofile.phone,
                                 'phone_binding_status':user.userprofile.phone_binding_status,
                                 }
                }
        return data

@csrf_exempt
@commit_on_success
@apis_json_response_decorator
def verifyContact(request, type):
    if request.method == 'POST':
        value = request.POST['value']
        uid = request.POST['uid']
        userkey = request.POST['verifier']
        try:
            user = User.objects.get(pk = uid)
        except Exception:
            raise myException(ERROR_BINDING_NO_USER)
        data = {"latest_status":{
                                 'email':user.userprofile.email,
                                 'email_binding_status':user.userprofile.email_binding_status,
                                 'phone':user.userprofile.phone,
                                 'phone_binding_status':user.userprofile.phone_binding_status,
                                 }
                }
        # 确定当前用户状态是等待绑定状态或者是已绑定状态
        if (type == 'email' and user.userprofile.email_binding_status == 'unbind')\
            or (type == 'phone' and user.userprofile.phone_binding_status == 'unbind'):
            raise myException(ERROR_VERIFY, status = ERROR_STATUS_INVALID_VERIFIER, data = data)
        # 确定app端的绑定信息是用户最新的绑定信息
        if (type == 'email' and user.userprofile.email != value)or(type == 'phone' and user.userprofile.phone != value):
            raise myException(ERROR_VERIFY, status = ERROR_STATUS_INVALID_VERIFIER, data = data)
        # 确定app端的绑定邮箱/手机号未被别的用户使用
        if type == 'email' and UserProfile.objects.filter(email = value, email_binding_status = 'bind').exclude(user = user).count() != 0:
            raise myException(ERROR_VERIFYING_BY_EMAIL_HAS_BINDED_BY_OTHER, status = ERROR_STATUS_HAS_BINDED_BY_OTHER, data = data)
        elif  type == 'phone' and UserProfile.objects.filter(phone = value, phone_binding_status = 'bind').exclude(user = user).count() != 0:
            raise myException(ERROR_VERIFYING_BY_PHONE_HAS_BINDED_BY_OTHER, status = ERROR_STATUS_HAS_BINDED_BY_OTHER, data = data)
        
        # 确定app端绑定操作是否已经被正常操作过了
        if (type == 'email' and user.userprofile.email_binding_status == 'bind' and user.userprofile.email == value)\
            or (type == 'phone' and user.userprofile.phone_binding_status == 'bind' and user.userprofile.phone == value):
            return data
        
        #开始解绑
        binding_temp = UserBindingTemp.objects.filter(user = user, binding_type = type, binding_address = value, key = userkey)
        if not binding_temp:
            raise myException(ERROR_VERIFYING_WRONG_VERIFIER, status = ERROR_STATUS_WRONG_VERIFIER, data = data)
        if type == 'email':
            if user.userprofile.email_binding_status == 'waitingbind':
                user.userprofile.email_binding_status = 'bind'
                user.userprofile.save()
            elif user.userprofile.email_binding_status == 'bind':
                user.userprofile.email_binding_status = 'unbind'
                user.userprofile.email = ''
                user.userprofile.save()
        elif type == 'phone':
            if user.userprofile.phone_binding_status == 'waitingbind':
                user.userprofile.phone_binding_status = 'bind'
                user.userprofile.save()
            elif user.userprofile.phone_binding_status == 'bind':
                user.userprofile.phone_binding_status = 'unbind'
                user.userprofile.phone = ''
                user.userprofile.save()
        for binding in binding_temp:
            binding.delete()
        data = {"latest_status":{
                                 'email':user.userprofile.email,
                                 'email_binding_status':user.userprofile.email_binding_status,
                                 'phone':user.userprofile.phone,
                                 'phone_binding_status':user.userprofile.phone_binding_status,
                                 }
                }
        return data
    
@csrf_exempt
@commit_on_success
@apis_json_response_decorator
def changePassword(request):
    if request.method == 'POST':
        uid = request.POST['uID']
        originalpassword = request.POST['originalpassword']
        newpassword = request.POST['newpassword']
        user = User.objects.get(pk = uid)
        if newpassword == '':
            raise myException(ERROR_ACCOUNTREGIST_PWD_BLANK)
        if len(newpassword) > 16 or len(newpassword) < 6:
            raise myException(ERROR_ACCOUNTREGIST_PWD_LENTH_WRONG)
        if user.check_password(originalpassword):
            user.set_password(newpassword)
            user.save()
        else:
            raise myException(ERROR_CHANGE_PWD_WRONG_PWD)

@csrf_exempt
@commit_on_success
@apis_json_response_decorator
def changePasswordByFinePWD(request):
    if request.method == 'POST':
        uid = request.POST['uID']
        newpassword = request.POST['newpassword']
        user = User.objects.get(pk = uid)
        if newpassword == '':
            raise myException(ERROR_ACCOUNTREGIST_PWD_BLANK)
        if len(newpassword) > 16 or len(newpassword) < 6:
            raise myException(ERROR_ACCOUNTREGIST_PWD_LENTH_WRONG)
        user.set_password(newpassword)
        user.save()

@csrf_exempt
@commit_on_success
@apis_json_response_decorator
def bindDevice(request):
    if request.method == 'POST':
        user = User.objects.get(pk = request.POST['uid'])
        device_token = request.POST['device_token']
        if device_token:
            usertoken, created = UserIPhoneToken.objects.get_or_create(device_token = device_token, defaults = {'user' : user})
            if usertoken.user != user:
                usertoken.user = user
                usertoken.save()
@csrf_exempt
@commit_on_success
@apis_json_response_decorator              
def checkPurchase(request):
    if request.method == 'POST':
        version = request.POST['version']
        if version == '1.0':
            return 1
        else:
            return 0
    return 0
