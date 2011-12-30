import datetime
import logging

from apps.accounts.forms import GetPasswordForm, ChangePasswordForm, \
    RegistrationForm, UserProfileForm, BuySMSForm
from apps.accounts.models import UserAliReceipt, UserBindingTemp
from datetime import datetime, timedelta
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

from apps.accounts.models import UserProfile, UserAliReceipt, UserBindingTemp
from apps.accounts.forms import ChangePasswordForm, RegistrationForm, UserProfileForm, BuySMSForm
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
def profile(request, template_name='accounts/profile.html', redirected='profile'):
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
                                                                       'profile_status':profile_status
                                                                       })
#            return redirect('profile')
        else:
            user = request.user
            userprofile = user.get_profile()
            sms_count = userprofile.available_sms_count    
            return TemplateResponse(request, template_name, {'form':form, 'sms_count':sms_count,'profile_status':''})
        
    else:    
        user = request.user
        userprofile = user.get_profile()
        
        email = user.email
        phone = userprofile.phone
        true_name = userprofile.true_name
        sms_count = userprofile.available_sms_count    
        data = {'email':email,
              'phone':phone,
              'true_name':true_name                      
              }
        form = UserProfileForm(data)
        profile_status = ''
        return TemplateResponse(request, template_name, {'form':form, 'sms_count':sms_count, 'profile_status':profile_status})

@login_required
@commit_on_success
def change_password(request):
    if request.method == 'POST':
        form = ChangePasswordForm(request, request.POST)
        if form.is_valid():
            request.user.set_password(form.cleaned_data['new_password'])
            request.user.save()
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

def bought_success(request):
    if request.method == 'POST':
#        total_fee = request.POST.get('total_fee', 0)
        out_trade_no = request.POST.get('out_trade_no', '')
        receipt = UserAliReceipt.objects.get(receipt=out_trade_no)
        userprofile = receipt.user.get_profile()
        userprofile.available_sms_count = userprofile.available_sms_count + receipt.item_count
        userprofile.save()
        return HttpResponse("success", mimetype = "text/html")
    else:
        return HttpResponse("", mimetype="text/html")

@login_required    
def apply_phone_unbingding_ajax(request):#申请手机解绑定
    phone = request.user.get_profile().phone
    
    userkey = generate_phone_code()
    userbindingtemp = UserBindingTemp.objects.get_or_create(user=request.user, binding_address=phone, bingding_type='phone')
    userbindingtemp.key = userkey
    userbindingtemp.save()
    
    profile = request.get_profile()
    profile.phone = userbindingtemp.binding_address
    profile.phone_binding_status = 'waitingunbind'
    profile.save()
    
    response = HttpResponse("success")
    return response

@login_required    
def apply_phone_bingding_ajax(request, phone):#申请手机绑定

    #1.收到手机号码(翻送间歇1min，重新获取/重i才能输入手机号码)cookie中,手机号码已经被使用
    #2.产生验证码
    #3.保存到UserBindingTemp 

    phone = phone
    phone_re = r'1\d{10}'
    if not re.search(phone_re, phone):
        return  HttpResponse("invalidate")
    #是否有用户已经绑定，该手机号码
    exist = UserProfile.objects.filter(phone = phone, phone_binding_status = 'bind').count() > 0
    if exist:
        return HttpResponse("used")
    
    userkey = generate_phone_code()
    userbindingtemp = UserBindingTemp.objects.get_or_create(user=request.user, bingding_type='phone')
    userbindingtemp.binding_address = phone
    userbindingtemp.key = userkey
    userbindingtemp.save()
    
    profile = request.get_profile()
    profile.phone = userbindingtemp.binding_address
    profile.phone_binding_status = 'waitingbind'
    profile.save()
    
    response = HttpResponse("success")
    return response

@login_required     
def validate_phone_bingding_ajax(request, key, binding_status='bind'):#手机绑定验证
    #1.获取验证码
    #2.是否有验证码
    #.绑定/解绑成功
    userkey = key
    data={'status':''}
    exists = UserBindingTemp.objects.filter(user=request.user, bingding_type='phone').count > 0
    if exists:
        userbindingtemp = UserBindingTemp.objects.filter(user=request.user, bingding_type='phone').orderby('-id')[0]#避免有多条数据，虽然理论上不存在
        bingding_key = userbindingtemp.key
        if userkey == bingding_key:
            phone = userbindingtemp.binding_address
            #是否有用户已经绑定，该手机号码
            exist = UserProfile.objects.filter(phone = phone, phone_binding_status = 'bind').count() > 0
            if exist:
                data['status'] = 'used'    
            else:#绑定操作
                profile = request.get_profile()
                profile.phone = userbindingtemp.binding_address
                profile.phone_binding_status = binding_status
                profile.save()
                #删除临时表
                userbindingtemp.delete()
                #短信通知用户，绑定成功
                message = {'phone':'' , 'content':''}
                message['phone'] = userbindingtemp.bingding_address
                if binding_status == 'bind':
                    message['content'] = 'bindsuccess'
                else:
                    message['content'] = 'unbindsuccess'
                thread.start_new_thread(sendsmsMessage,(message))
                
                data['status'] = 'success'
        else:
            data['status'] = 'wrongkey'    
    else :        
        data['status'] = 'notexist'
        
    return HttpResponse(simplejson.dumps(data))

def ajax_binding(request):
    if request.method == 'POST':
        email = request.POST.get('email', '')
        if email:
            key =  hashlib.md5(email).hexdigest()
            if UserBindingTemp.objects.filter(key=key).count() == 0:
                UserBindingTemp.objects.create(user=request.user, binding_type='email', key=key, binding_address=email)
                return HttpResponse("success")
            else:
                return HttpResponse("record_already_exist")
    else:
        key = request.GET.get('key','')
        if key:
            try:
                UserBindingTemp.objects.get(key=key)
            except:
                return TemplateResponse(request, 'message.html', {'message': 'noexistkey'})
            else:
                record = UserBindingTemp.objects.get(key=key)
            user = User.objects.get(pk=record.user.id)
            user.email = record.binding_address
            user.save()
            record.delete()
            return HttpResponseRedirect('/accounts/profile')
