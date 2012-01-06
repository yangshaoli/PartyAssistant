#--*-- coding=utf-8
'''
Created on 2011-11-13

@author: liwenjian
'''
from django import forms
from django.core.validators import validate_email
import re

class EmailInviteForm(forms.Form):
    client_email_list = forms.CharField(required=True, error_messages={'required':u'邮件地址为必填项'})
    content = forms.CharField(required=True, error_messages={'required':u'邮件内容为必填项'})
    is_apply_tips = forms.BooleanField(required=False)
    
    def clean_client_email_list(self):
        client_email_list = self.cleaned_data['client_email_list']
        email_list = client_email_list.split(',')
        valid_email_list = []
        
        invalid_email = ''
        for email in email_list:
            email = email.strip()
            if email != '':
                try:
                    validate_email(email)
                    if not email in valid_email_list:
                        valid_email_list.append(email)
                except:
                    invalid_email = email
        
        if invalid_email:
            raise forms.ValidationError(u'邮件地址 %s 格式错误' % invalid_email)
        self.cleaned_data['client_email_list'] = ','.join(valid_email_list)
        
        return self.cleaned_data['client_email_list']

class SMSInviteForm(forms.Form):
    client_phone_list = forms.CharField(required=True, error_messages={'required':u'手机号码为必填项'})
    content = forms.CharField(required=True, error_messages={'required':u'短信内容为必填项'})
    is_apply_tips = forms.BooleanField(required=False)
    
    def clean_client_phone_list(self):
        client_phone_list = self.cleaned_data['client_phone_list']
        phone_list = client_phone_list.split(',')
        valid_phone_list = []
        
        phone_re = r'1\d{10}'
        invalid_phone = ''
        for phone in phone_list:
            phone = phone.strip()
            if phone != '':
                if (not re.search(phone_re, phone)) or  len(phone) != 11:
                    invalid_phone = phone
                else:
                    if not phone in valid_phone_list:
                        valid_phone_list.append(phone)
        
        if invalid_phone:
            raise forms.ValidationError(u'手机号码 %s 格式错误' % invalid_phone)
        
        if len(valid_phone_list) == 0:
            raise forms.ValidationError(u'手机号码序列 %s 格式有错误,请注意书写格式及分隔标点' % self.cleaned_data['client_phone_list'])
        
        
        self.cleaned_data['client_phone_list'] = ','.join(valid_phone_list)
        
        return self.cleaned_data['client_phone_list']
