#-*- coding: utf-8 -*-

from django.shortcuts import redirect, render_to_response
from django.template.context import RequestContext
from django.views.decorators.csrf import csrf_exempt

from accounts.forms import WebRegistrationForm, AppRegistrationForm
from accounts.models import TempActivateNote
from tools.email_tool import send_emails

import random

from settings import DOMAIN_NAME,  SYS_EMAIL_ADDRESS

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
            web_address = DOMAIN_NAME + '/accounts/account_activate/' + email + '/' + t[0].random_str
            EMAIL_CONTENT_TEMP_PATH = '%(PROJECT_ROOT)s/templates/accounts/activate_email_content.html' % globals()
            myfile = open(EMAIL_CONTENT_TEMP_PATH)  
            email_content = myfile.read().replace(u'[激活网址]', web_address)
            #发送激活邮件
            try:
                send_emails(email_subject, email_content, SYS_EMAIL_ADDRESS, [email])
                return render_to_response('accounts/account_operation_success.html', context_instance = RequestContext(request))
            except Exception:
                return render_to_response('accounts/account_operation_fail.html', context_instance = RequestContext(request))
    else:
        form = WebRegistrationForm()
    return render_to_response('accounts/registration.html', {'form': form},context_instance = RequestContext(request))

def app_register(request):
    if request.method == 'POST':
        form = AppRegistrationForm(request.POST)
        if form.is_valid():
            phone = form.cleaned_data['phone']
            
    else:
	    return render_to_response('accounts/register.html',{'form' : WebRegistrationForm()}, context_instance = RequestContext(request))
