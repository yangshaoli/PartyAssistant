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
from settings import SYS_EMAIL_ADDRESS
from utils.tools.email_tool import send_emails
import logging
import random
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
            UserProfile.objects.create(user=user)
            login(request, user)
            
            return redirect('list_party')
    else:
        form = RegistrationForm()

    return TemplateResponse(request, 'accounts/register.html', {'form': form})

def activate(request, email , random_str):
    note = get_object_or_404(TempActivateNote, email = email, random_str = random_str, action = u'新建账户')
    if User.objects.filter(username = email):
        note.delete()
        return HttpResponse(u'用户已存在')
    user = User.objects.create_user(email, email, password=note.password)
    UserProfile.objects.create(user=user, account_type=note.aim_limit )
    note.delete()
    return redirect(reverse('create_party'))

def get_password(request):
    email_subject = u'爱热闹取回密码'
    random_password = ''.join(random.sample([chr(i) for i in range(48, 57) + range(65, 90) + range(97, 122)], 16))
    if request.method == 'POST':
        form = GetPasswordForm(request.POST)
        if form.is_valid():
            email = form.cleaned_data['email']
            email_content = EMAIL_CONTENT % (random_password)
            #重新设置用户密码
            user = User.objects.get(email=email)
            user.set_password(random_password)
            user.save()
            send_emails(email_subject, email_content, SYS_EMAIL_ADDRESS, [email])
            return render_to_response('message.html', {'message':u'新密码已发送到您的邮箱'}, context_instance = RequestContext(request))
        else:
            return render_to_response('message.html', {'message':u'邮箱错误，密码取回失败'}, context_instance = RequestContext(request))
    else:
        form = GetPasswordForm()
        return render_to_response('accounts/get_password.html', {'form': form},context_instance = RequestContext(request))

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
            tag = False
            if userprofile.true_name != true_name:
                userprofile.true_name = true_name
                userprofile.save()
                tag = True
            if userprofile.phone != phone:
                userprofile.phone = phone
                userprofile.save()
                tag = True
            if user.email != email:
                user.email = email
                user.save()
                tag = True
            
            profile_status = ''
            if tag:
                profile_status = u'保存成功'
            
            sms_count = userprofile.available_sms_count
            
            return TemplateResponse(request, 'accounts/profile.html', {'form':form, 'sms_count':sms_count, 'profile_status':profile_status})
        else:
            user = request.user
            userprofile = UserProfile.objects.get(user=user)
            sms_count = userprofile.available_sms_count    
            return TemplateResponse(request, 'accounts/profile.html', {'form':form, 'sms_count':sms_count})
        
    else:    
        user = request.user
        userprofile, created = UserProfile.objects.get_or_create(user=user)
        
        email = user.email
        phone = userprofile.phone
        true_name = userprofile.true_nametrue_name = userprofile.true_name
        sms_count = userprofile.available_sms_count    
        data={'email':email,
              'phone':phone,
              'true_name':true_name                      
              }
        form = UserProfileForm(data)
        return TemplateResponse(request, 'accounts/profile.html', {'form':form, 'sms_count':sms_count})

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
    userprofile = UserProfile.objects.get(user=request.user)
    data={'available_count' : userprofile.available_sms_count          
          }
    return HttpResponse(simplejson.dumps(data))
    pass