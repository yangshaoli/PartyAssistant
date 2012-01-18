#coding=utf-8
import datetime
import logging

from apps.accounts.forms import *
from apps.accounts.models import *
from decimal import Decimal, InvalidOperation

from django.db.transaction import commit_on_success
from django.contrib.auth import login, authenticate
from django.contrib.auth.decorators import login_required
from django.contrib.auth.models import User
from django.http import HttpResponseRedirect
from django.shortcuts import render_to_response, redirect, HttpResponse
from django.template.context import RequestContext
from django.template.response import TemplateResponse
from django.utils import simplejson

from settings import DOMAIN_NAME, ALIPAY_SELLER_EMAIL
from utils.tools.alipay import Alipay
from utils.tools.phone_key_tool import generate_phone_code
from utils.tools.sms_tool import sendsmsMessage
import logging
import re
import thread
import hashlib
logger = logging.getLogger('airenao')
EMAIL_CONTENT = u'<div>尊敬的爱热闹用户：：<br>您使用了找回密码的功能，您登录系统的临时密码为 %s ，请登录后进入”账户信息“页面修改密码。</div>'

@commit_on_success
def register(request):
    if request.method == 'POST':
        form = RegistrationForm(request.POST)
        if form.is_valid():
            username = form.cleaned_data['username']
            password = form.cleaned_data["password"]
            User.objects.create_user(username = username, email = '', password = password)
            
            # django bug, must authenticate before login
            user = authenticate(username = username, password = password)
            login(request, user)
            
            return redirect('completeprofile')
    else:
        form = RegistrationForm()

    return TemplateResponse(request, 'accounts/register.html', {'form': form})

@login_required
@commit_on_success
def profile(request, template_name = 'accounts/profile.html', redirected = 'profile'):
    if request.method == 'POST':
        if 'ignore' in request.POST:
            return redirect('list_party')
        form = UserProfileForm(request.POST)
        user = request.user
        userprofile = user.get_profile()
        if form.is_valid():
            true_name = form.cleaned_data['true_name']
            
            profile_status = 'success'
            if userprofile.true_name != true_name:
                userprofile.true_name = true_name
                userprofile.save()
            
            return TemplateResponse(request, 'accounts/profile.html', {'form':form,
                                                                       'sms_count':userprofile.available_sms_count,
                                                                       'profile_status':profile_status,
                                                                       'userprofile':userprofile
                                                                       })
            return redirect('profile')
        else:
            user = request.user
            userprofile = user.get_profile()
            sms_count = userprofile.available_sms_count    
            return TemplateResponse(request, template_name, {'form':form, 'sms_count':sms_count, 'profile_status':'', 'userprofile':userprofile})
        
    else:    
        user = request.user
        userprofile = user.get_profile()
        
        email = userprofile.email
        phone = userprofile.phone
        true_name = userprofile.true_name
        sms_count = userprofile.available_sms_count    
        data = {'email':email,
              'phone':phone,
              'true_name':true_name                      
              }
        form = UserProfileForm(data)
        profile_status = ''
        password_status = ''
        if 'password_status' in request.session:
            password_status = request.session['password_status']
            del request.session['password_status']          
        return TemplateResponse(request, template_name, {'form':form, 'userprofile':userprofile, 'sms_count':sms_count, 'profile_status':profile_status, 'password_status':password_status})

@login_required
@commit_on_success
def change_password(request):
    if request.method == 'POST':
        form = ChangePasswordForm(request, request.POST)
        if form.is_valid():
            request.user.set_password(form.cleaned_data['new_password'])
            request.user.save()
            request.session['password_status'] = 'success'
            return redirect('profile')
    else:
        form = ChangePasswordForm(request, None)
    
    return TemplateResponse(request, 'accounts/change_password.html', {'form': form})

@login_required
def get_availbale_sms_count_ajax(request):
    data = {
        'available_count' : request.user.get_profile().available_sms_count          
    }
    return HttpResponse(simplejson.dumps(data))

@login_required
@commit_on_success
def buy_sms(request):
    request_url = '/accounts/profile'
    if request.method == 'POST':
        form = BuySMSForm(request.POST)
        if form.is_valid():
            seller_email = ALIPAY_SELLER_EMAIL;
            subject = request.POST.get('subject', '')
            body = request.POST.get('body', '')
            out_trade_no = request.POST.get('out_trade_no', '')
            price = request.POST.get('price', '')
            sms_count = request.POST.get('sms_count', '')
            notify_url = request.POST.get('notify_url', '')
    
            payment_type = request.POST.get('payment_type', '')
            try:
                total_fee = Decimal(price)
            except InvalidOperation:
                total_fee = None
            if seller_email and subject and out_trade_no and total_fee and notify_url and payment_type:
                user = request.user
                #存入UserAliReceipt表
                userprofile = user.get_profile()
                UserAliReceipt.objects.create(user = user, pre_sms_count = userprofile.available_sms_count,
                                                      receipt = out_trade_no, totle_fee = total_fee, items_count = sms_count,
                                                      )
                alipay = Alipay()
                request_url = alipay.create_direct_pay_by_user_url(seller_email, subject, body, out_trade_no, total_fee, notify_url, payment_type)
                return HttpResponseRedirect(request_url)
        else:
            now = datetime.datetime.now()
            out_trade_no = now.strftime('%Y%m%d%H%M%s')
            return render_to_response('accounts/buy_sms.html', {
                'out_trade_no':out_trade_no,
                'domain':DOMAIN_NAME,
                'form':form
                }, context_instance = RequestContext(request))            
    else:
        form = BuySMSForm()
        now = datetime.datetime.now()
        out_trade_no = now.strftime('%Y%m%d%H%M%s')
        return render_to_response('accounts/buy_sms.html', {
            'out_trade_no':out_trade_no,
            'domain':DOMAIN_NAME,
            'form':form
            }, context_instance = RequestContext(request))

@commit_on_success
def bought_success(request):
    if request.method == 'POST':
        total_fee = request.POST.get('total_fee', 0)
        out_trade_no = request.POST.get('out_trade_no', '')
        #处理因用户多次点击购买按钮在数据库中产生相同订单号的记录
        latest_receipt = UserAliReceipt.objects.filter(receipt=out_trade_no).latest('create_time') #相同订单号中的最新一条记录
        userprofile = latest_receipt.user.get_profile()
        userprofile.available_sms_count = int(int(userprofile.available_sms_count) + float(total_fee) * 10 )
        userprofile.save()
        latest_receipt.payment = 'success'
        latest_receipt.save()
        #其他记录设置为支付失败
        other_receipt = UserAliReceipt.objects.filter(receipt=out_trade_no).exclude(id=latest_receipt.id).update(payment='failed')
        return HttpResponse("success", mimetype = "text/html")
    else:
        return HttpResponse("", mimetype = "text/html")

@commit_on_success
@login_required    
def apply_phone_unbingding_ajax(request):#申请手机解绑定
    #是否延时1min
    exist = UserBindingTemp.objects.filter(user = request.user, binding_type = 'phone').count() > 0
    if exist:
        userbindingtemp = UserBindingTemp.objects.filter(user = request.user, binding_type = 'phone').order_by('-id')[0]
        create_time = userbindingtemp.created_time
        now = datetime.datetime.now()
        dt = datetime.timedelta(minutes = 1)
        if (create_time + dt) > now:
            time = (now - create_time).total_seconds()
            time = 60 - int(time)
            return HttpResponse("time:" + str(time))
    
    profile = request.user.get_profile()
    cphone = request.POST.get('phone', '')    
    phone = profile.phone
    bindstatus = profile.phone_binding_status
    
    if  cphone == phone  and bindstatus == 'bind':
        userkey = generate_phone_code()
        userbindingtemp, create = UserBindingTemp.objects.get_or_create(user = request.user, binding_address = phone, binding_type = 'phone', defaults = {'key':userkey})
        if not create:
            userbindingtemp.key = userkey
            userbindingtemp.save()
        
        response = HttpResponse("success")
        
    else:
        response = HttpResponse("flush")
        
    return response

@commit_on_success
@login_required    
def apply_phone_bingding_ajax(request):#申请手机绑定

    #1.收到手机号码(发送间歇1min)
    #2.产生验证码
    #3.保存到UserBindingTemp 
    phone = request.POST.get('phone', '')
    phone_re = re.compile(r'1\d{10}')
    match = phone_re.search(phone)
    if (not match.group()) or (len(phone) != 11):
        return  HttpResponse("invalidate")
    
    #是否有用户已经绑定，该手机号码
    exist = UserProfile.objects.filter(phone = phone, phone_binding_status = 'bind').count() > 0
    if exist:
        return HttpResponse("used")
    
    #是否延时1min
    user_binding_temp = UserBindingTemp.objects.filter(user = request.user, binding_type = 'phone').order_by('-id')
    if user_binding_temp:
        userbindingtemp = user_binding_temp[0]
        create_time = userbindingtemp.created_time
        now = datetime.datetime.now()
        dt = datetime.timedelta(minutes = 1)
        
        if (create_time + dt) > now:
            time = (now - create_time).total_seconds()
            time = 60 - int(time)
            
            return HttpResponse("time:" + str(time))
    
    userkey = generate_phone_code()
    userbindingtemp, created = UserBindingTemp.objects.get_or_create(user = request.user, binding_type = 'phone', defaults = {'binding_address': phone, 'key':userkey})
    if not created:
        userbindingtemp.binding_address = phone
        userbindingtemp.key = userkey
        userbindingtemp.save()
    
    profile = request.user.get_profile()
    
    profile.phone = userbindingtemp.binding_address
    profile.phone_binding_status = 'waitingbind'
    profile.save()
    
    response = HttpResponse("success")
    
    return response

@commit_on_success
@login_required     
def validate_phone_bingding_ajax(request):#手机绑定验证
    #1.获取验证码
    #2.是否有验证码
    #.绑定/解绑成功
    data = {'status':''}
    userkey = request.POST.get('key', '')
    cphone = request.POST.get('phone', '')
    phone_re = re.compile(r'1\d{10}')
    match = phone_re.search(cphone)
    if (not match.group()) or (len(cphone) != 11):
        data['status'] = 'invalidate'
        
        return  HttpResponse(simplejson.dumps(data))
    
    if userkey == '':
        data['status'] = 'null'
        
        return HttpResponse(simplejson.dumps(data))
    
    user_binding_tmp_list = UserBindingTemp.objects.filter(user = request.user, binding_type = 'phone').order_by('-id')
    if user_binding_tmp_list:
        userbindingtemp = user_binding_tmp_list[0]#避免有多条数据，虽然理论上不存在
        binding_key = userbindingtemp.key
        if userkey == binding_key:
            phone = userbindingtemp.binding_address
            #手机号码和待绑定是否匹配
            if cphone == phone and request.user.get_profile().phone_binding_status == 'waitingbind':
                #是否有用户已经绑定，该手机号码
                exist = UserProfile.objects.filter(phone = phone, phone_binding_status__in = ['bind', 'waitunbind']).count() > 0
                profile = request.user.get_profile()
                if exist:
                    data['status'] = 'used'
                    #如果已经被绑定了，我们应该将这个用户的手机号码清空，多余数据清空
                    profile.phone = ''
                    profile.phone_binding_status = 'unbind'
                else:#绑定操作
                    profile = request.user.get_profile()
                    profile.phone = userbindingtemp.binding_address
                    profile.phone_binding_status = 'bind'
                    data['status'] = 'success'
                    
                profile.save()    
                #删除临时表
                for user_binding_tmp in user_binding_tmp_list:
                    user_binding_tmp.delete()
            else:
                data['status'] = 'flush'                
        else:
            data['status'] = 'wrongkey'
    else :        
        data['status'] = 'notexist'
        
    response = HttpResponse(simplejson.dumps(data))
    
    return response

@commit_on_success
@login_required     
def validate_phone_unbingding_ajax(request):#手机解绑定验证
    #1.获取验证码
    #2.是否有验证码
    #.绑定/解绑成功
    
    userkey = request.POST.get('key', '')
    cphone = request.POST.get('phone', '')
    data = {'status':''}
    if userkey == '':
        data['status'] = 'null'
        
        return HttpResponse(simplejson.dumps(data))
    
    user_binding_tmp_list = UserBindingTemp.objects.filter(user = request.user, binding_type = 'phone').order_by('-id')
    if user_binding_tmp_list:
        userbindingtemp = user_binding_tmp_list[0]#避免有多条数据，虽然理论上不存在
        binding_key = userbindingtemp.key
        if userkey == binding_key:
            phone = userbindingtemp.binding_address
            if cphone == phone and request.user.get_profile().phone_binding_status == 'bind':
                #解除绑定操作
                profile = request.user.get_profile()
                profile.phone = ''
                profile.phone_binding_status = 'unbind'
                #删除临时表
                for user_binding_tmp in user_binding_tmp_list:
                    user_binding_tmp.delete()
                    
                profile.save()
                data['status'] = 'success'
            
            else:
                data['status'] = 'flush'
                
        else:
            data['status'] = 'wrongkey'
    else :        
        data['status'] = 'notexist'
        
    response = HttpResponse(simplejson.dumps(data))
    
    return response

@login_required
@commit_on_success
def email_binding(request):
    if request.method == 'POST':
        email = request.POST.get('email', '')
        if UserProfile.objects.filter(email=email).count() != 0:
            return HttpResponse("email_already_exist")
        if email:
            key = hashlib.md5(email).hexdigest()
            if UserBindingTemp.objects.filter(key = key).count() == 0:
                UserBindingTemp.objects.create(user = request.user, binding_type = 'email', key = key, binding_address = email)
                userprofile = UserProfile.objects.get(user=request.user)
                userprofile.email_binding_status = 'waitingbind'
                userprofile.save()
                return HttpResponse("success")
            else:
                return HttpResponse("record_already_exist")

@commit_on_success
def email_handle_url(request, type):
    key = request.GET.get('key', '')
    if type == 'binding':
        if key:
            try:
                UserBindingTemp.objects.get(key = key)
            except:
                return TemplateResponse(request, 'message.html', {'message': 'noexistkey'})
            else:
                record = UserBindingTemp.objects.get(key = key)
            user = User.objects.get(pk = record.user.id)
            userprofile = user.get_profile()
            userprofile.email = record.binding_address
            userprofile.email_binding_status = 'bind'
            userprofile.save()
            record.delete()
            return HttpResponseRedirect('/accounts/profile')
    if type == 'unbinding':
        if key:
            try:
                UserBindingTemp.objects.get(key = key)
            except:
                return TemplateResponse(request, 'message.html', {'message': 'noexistkey'})
            else:
                record = UserBindingTemp.objects.get(key = key)
            user = User.objects.get(pk = record.user.id)
            userprofile = user.get_profile()
            userprofile.email = ''
            userprofile.email_binding_status = 'unbind'
            userprofile.save()
            record.delete()
            return HttpResponseRedirect('/accounts/profile')

@login_required
@commit_on_success
def unbinding(request):
    if request.method == 'POST':
        email = request.POST.get('email', '')
#        phone = request.POST.get('phone', '')
        if email:
            key = hashlib.md5(email).hexdigest()
            if UserBindingTemp.objects.filter(key = key).count() == 0:
                UserBindingTemp.objects.create(user = request.user, binding_type = 'email', key = key, binding_address = email)
                return HttpResponse("success")
            else:
                return HttpResponse("record_already_exist")

#        if phone:
#            userprofile = UserProfile.objects.get(pk = request.user.id, phone=phone)
#            userprofile.phone = ''
#            userprofile.phone_binding_status = 'unbind'
#        userprofile.save()
        return HttpResponse("success")

        
@commit_on_success
def forget_password(request):
    if request.method == 'POST':
        username = request.POST.get('username','')
        try:
            User.objects.get(username = username)
        except:
            return TemplateResponse(request, 'message.html', {'message': 'noexistusername'})
        else:
            user = User.objects.get(username = username)
        #判断发送方式
        if user.userprofile.phone:
            sending_type = 'sms'
        elif user.userprofile.email:
            sending_type = "email"
        else:
            return TemplateResponse(request, 'message.html', {'message': 'nobinding'})
        
        temp_password = generate_phone_code()
        temp_pwd_data, created = AccountTempPassword.objects.get_or_create(user = user, defaults = {
                                                                                                "temp_password":temp_password,
                                                                                                "sending_type":sending_type,
                                                                                                })
        if not created:
            temp_pwd_data.sending_type = sending_type
            temp_pwd_data.save()
        if sending_type == 'sms' : return TemplateResponse(request, 'message.html', {'message': 'sendtophone'})
        if sending_type == 'email' : return TemplateResponse(request, 'message.html', {'message': 'sendtoemail'})
        
    return TemplateResponse(request, 'accounts/forget_password.html')

@commit_on_success
def reset_password(request):
    if request.method == 'POST':
        form = ResetPasswordForm(request.POST)
        if form.is_valid():
            user = request.session['temp_login']
            user.set_password(form.cleaned_data['password'])
            user.save()
            del request.session['temp_login']
            return redirect('profile')
        else:
            return TemplateResponse(request, 'accounts/reset_password.html', {'form': form})
    else:
        form = ResetPasswordForm()
    
    return TemplateResponse(request, 'accounts/reset_password.html')