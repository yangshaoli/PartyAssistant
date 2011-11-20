'''
Created on 2011-11-13

@author: liwenjian
'''
from django import forms
from django.core.validators import validate_email
import re

class EmailInviteForm(forms.Form):
    client_email_list = forms.CharField(widget=forms.Textarea())
    content = forms.CharField(widget=forms.Textarea())
    is_apply_tips = forms.BooleanField(widget=forms.CheckboxInput(), required=False)
    
    def clean_client_email_list(self):
        client_email_list = self.cleaned_data['client_email_list']
        email_list = client_email_list.split(',')
        
        validate_flag = True
        for email in email_list:
            email = email.strip()
            try:
                validate_email(email)
            except:
                validate_flag = False
                break
        
        if not validate_flag:
            raise forms.ValidationError(u'邮件地址格式错误')
        
        self.cleaned_data['client_email_list'] = ','.join(email_list)
        
        return self.cleaned_data['client_email_list']

class SMSInviteForm(forms.Form):
    client_phone_list = forms.CharField(widget=forms.Textarea())
    content = forms.CharField(widget=forms.Textarea())
    is_apply_tips = forms.BooleanField(required=False)
    
    def clean_client_phone_list(self):
        client_phone_list = self.cleaned_data['client_phone_list']
        phone_list = client_phone_list.split(',')
        
        phone_re = r'1\d{10}'
        validate_flag = True
        for phone in phone_list:
            phone = phone.strip()
            if not re.search(phone_re, phone):
                validate_flag = False
                break
        
        if not validate_flag:
            raise forms.ValidationError(u'电话号码格式错误')
        
        self.cleaned_data['client_phone_list'] = ','.join(phone_list)
        
        return self.cleaned_data['client_phone_list']
