#-*- coding: utf-8 -*-

from apps.accounts.forms import GetPasswordForm, ChangePasswordForm, \
    RegistrationForm, UserProfileForm
from apps.accounts.models import UserProfile, TempActivateNote
from django.contrib.auth import login, authenticate
from django.contrib.auth.decorators import login_required
from django.contrib.auth.models import User
from django.core.urlresolvers import reverse
from django.shortcuts import render_to_response, redirect, get_object_or_404, \
    HttpResponse
from django.template.context import RequestContext
from django.template.response import TemplateResponse
from settings import SYS_EMAIL_ADDRESS, DOMAIN_NAME
from utils.tools.email_tool import send_emails
import logging
import random
import datetime
from django.utils import simplejson
logger = logging.getLogger('airenao')
EMAIL_CONTENT = u'<div>尊敬的爱热闹用户：：<br>您使用了找回密码的功能，您登录系统的临时密码为 %s ，请登录后进入”账户信息“页面修改密码。</div>'

def register(request):
    if request.method == 'POST':
        form = RegistrationForm(request.POST)
        if form.is_valid():
            username = form.cleaned_data['username']
            password = form.cleaned_data["password"]
            User.objects.create_user(username=username,email='',  password=password)
            
            # django bug, must authenticate before login
            user = authenticate(username=username, password=password)
            login(request, user)
            
            return redirect('profile')
    else:
        form = RegistrationForm()

    return TemplateResponse(request, 'accounts/register.html', {'form': form})

@login_required
def profile(request):
    if request.method == 'POST':
        form = UserProfileForm(request.POST)
        user = request.user
        userprofile = UserProfile.objects.get(user=user)
        if form.is_valid():
            true_name = form.cleaned_data['true_name']
            phone = form.cleaned_data['phone']
            email = form.cleaned_data['email']
            
            profile_status = ''
            if userprofile.true_name != true_name:
                userprofile.true_name = true_name
                userprofile.save()
                profile_status = u'保存成功'
            if userprofile.phone != phone:
                userprofile.phone = phone
                userprofile.save()
                profile_status = u'保存成功'
            if user.email != email:
                user.email = email
                user.save()
                profile_status = u'保存成功'
            
            if profile_status:
                request.session['profile_status'] = profile_status
            return redirect('profile')
        else:
            user = request.user
            userprofile = UserProfile.objects.get(user=user)
            sms_count = userprofile.available_sms_count    
            return TemplateResponse(request, 'accounts/profile.html', {'form':form, 'sms_count':sms_count})
        
    else:    
        user = request.user
        userprofile = user.get_profile()
        
        email = user.email
        phone = userprofile.phone
        true_name = userprofile.true_nametrue_name = userprofile.true_name
        sms_count = userprofile.available_sms_count    
        data={'email':email,
              'phone':phone,
              'true_name':true_name                      
              }
        form = UserProfileForm(data)
        profile_status = ''
        if 'profile_status' in request.session:
            profile_status = request.session['profile_status']
            del request.session['profile_status']
        return TemplateResponse(request, 'accounts/profile.html', {'form':form, 'sms_count':sms_count, 'profile_status':profile_status})

@login_required
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
def buy_sms(request):
    now = datetime.datetime.now()
    out_trade_no = now.strftime('%Y%m%d%H%M%s')
    return render_to_response('accounts/buy_sms.html', {
        'out_trade_no':out_trade_no,
        'domain':DOMAIN_NAME
        }, context_instance=RequestContext(request))

def bought_success(request):
    if request.method == 'POST':
        total_fee = request.POST.get('total_fee',0)
        print total_fee
        user = request.user
        userprofile = UserProfile.objects.get(user=user)
        userprofile.available_sms_count = userprofile.available_sms_count + total_fee * 10
        return HttpResponse("success", mimetype="text/html")
    else:
        return HttpResponse("", mimetype="text/html")