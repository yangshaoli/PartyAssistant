#-*- coding: utf-8 -*-

from django.shortcuts import render_to_response, redirect, get_object_or_404, HttpResponse
from django.template.context import RequestContext
from django.contrib.auth.models import User
from django.core.urlresolvers import reverse
from apps.accounts.forms import WebRegistrationForm, AppRegistrationForm, GetPasswordForm, ChangePasswordForm
from apps.accounts.models import UserProfile
from utils.tools.email_tool import send_emails

import random
import hashlib

from settings import  SYS_EMAIL_ADDRESS

EMAIL_CONTENT = u'<div>尊敬的爱热闹用户：：<br>您使用了找回密码的功能，您登录系统的临时密码为 %s ，请登录后进入”账户信息“页面修改密码。</div>'

def web_register(request):
    if request.method == 'POST':
        form = WebRegistrationForm(request.POST)
        if form.is_valid():
            username = form.cleaned_data['username']
            password = form.cleaned_data["password"]
            email = form.cleaned_data['email']
            User.objects.create_user(username, email, password)
            return render_to_response('accounts/web_register_success.html', {'form': form},context_instance = RequestContext(request))
        else:
            return render_to_response('accounts/web_register.html', {'form': form}, context_instance = RequestContext(request))
    else:
        form = WebRegistrationForm()
    return render_to_response('accounts/web_register.html', {'form': form},context_instance = RequestContext(request))


def app_register(request):
    if request.method == 'POST':
        form = AppRegistrationForm(request.POST)
        if form.is_valid():
            phone = form.cleaned_data['phone']
            user = User.objects.create_user(str(phone), '', hashlib.sha1(str(phone)))
            UserProfile.objects.create(user=user, phone=phone, account_type=u'管理员') #在UserProfile中写入号码
            return render_to_response('accounts/web_register_success.html', context_instance = RequestContext(request))
    else:
        return render_to_response('accounts/app_register.html',{'form' : AppRegistrationForm()}, context_instance = RequestContext(request))

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

def profile(request):
    if request.method == 'POST':
        form = ChangePasswordForm(request.POST)
        if form.is_valid():
            old_password = form.cleaned_data['old_password']
            new_password = form.cleaned_data['new_password']
            user = User.objects.get(pk=request.user.id)
            if user.check_password(old_password):#检查旧密码
                user.set_password(new_password)
                return render_to_response('message.html', {'message':u'密码修改成功'}, context_instance = RequestContext(request))
            else:
                return render_to_response('message.html', {'message':u'原密码输入错误'}, context_instance = RequestContext(request))
        else:
            return render_to_response('accounts/profile.html', {'form': form}, context_instance = RequestContext(request))
    else:
        form = ChangePasswordForm()
        return render_to_response('accounts/profile.html', {'form': form},context_instance = RequestContext(request))
