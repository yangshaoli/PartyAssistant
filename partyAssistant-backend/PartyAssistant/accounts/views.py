#-*- coding: utf-8 -*-

from django.shortcuts import render_to_response, redirect, get_object_or_404, HttpResponse
from django.template.context import RequestContext
from django.views.decorators.csrf import csrf_exempt
from django.contrib.auth.models import User
from django.core.urlresolvers import reverse
from accounts.forms import WebRegistrationForm, AppRegistrationForm
from accounts.models import UserProfile, TempActivateNote
from tools.email_tool import send_emails

import random
import hashlib

from settings import DOMAIN_NAME,  SYS_EMAIL_ADDRESS

EMAIL_CONTENT = u'<div>尊敬的用户：<br>感谢您注册我们的网站，您可以通过点击<a href=" %s ">[ %s ]</a>来激活您的帐号。</div>'

def web_register(request):
    email_subject = u'AIMeeting注册激活邮件'
    if request.method == 'POST':
        form = WebRegistrationForm(request.POST)
        if form.is_valid():
            email = form.cleaned_data['email']
            password = form.cleaned_data["password"]
            random_str = ''.join(random.sample([chr(i) for i in range(48, 57) + range(65, 90) + range(97, 122)], 16))
            t = TempActivateNote.objects.get_or_create(email = email, action = u'新建账户' , aim_limit = u'管理员', defaults = {'password':password, 'random_str':random_str })
            if not t[1]:
                t[0].password = password
                t[0].save()
            #读出Email文件的内容，用于发送激活邮件
            web_address = DOMAIN_NAME + '/accounts/activate/' + email + '/' + t[0].random_str
            email_content = EMAIL_CONTENT % (web_address, web_address)
            #发送激活邮件
            try:
                send_emails(email_subject, email_content, SYS_EMAIL_ADDRESS, [email])
                return render_to_response('accounts/web_register_success.html', context_instance = RequestContext(request))
            except Exception:
                return render_to_response('accounts/web_register_fail.html', context_instance = RequestContext(request))
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

def activate(request, email , random_str):
    note = get_object_or_404(TempActivateNote, email = email, random_str = random_str, action = u'新建账户')
    if User.objects.filter(username = email):
        note.delete()
        return HttpResponse(u'用户已存在')
    user = User.objects.create_user(email, email, password=note.password)
    UserProfile.objects.create(user=user, account_type=note.aim_limit )
    note.delete()
    return redirect(reverse('create_party'))
