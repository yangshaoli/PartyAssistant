#coding=utf-8

from django import forms
from django.contrib.auth.forms import AuthenticationForm
from django.contrib.auth.models import User
from django.forms.util import ErrorList
import re

class LoginForm(AuthenticationForm):
    def clean(self):
        pass

class RegistrationForm(forms.Form):
    username = forms.RegexField(regex='^[a-zA-Z0-9]\w*$', min_length=6, max_length=14, widget=forms.TextInput(attrs={'placeholder':'必填项，输入范围6-14字符'}))
    password = forms.CharField(min_length=6, max_length=16, widget=forms.PasswordInput(attrs={'placeholder':'必填项'}))
    confirm_password = forms.CharField(max_length=16, widget=forms.PasswordInput(attrs={'placeholder':'必填项'}))
    
    def clean_username(self):
        username = self.cleaned_data['username']
        exists = User.objects.filter(username=username).count() > 0
        if exists:
            raise forms.ValidationError(u'该用户名已存在，请重新输入')
        if username[0].isdigit():
            raise forms.ValidationError(u'用户名不能以数字开头')
        return username
    
    def clean(self):
        if ('confirm_password' in self.cleaned_data) and ('password' in self.cleaned_data):
            if (self.cleaned_data['confirm_password'] != self.cleaned_data['password']):
                self._errors["confirm_password"] = ErrorList([u'密码与确认密码不匹配'])
                del self.cleaned_data['password']
                del self.cleaned_data['confirm_password']
                
        return self.cleaned_data
    
class GetPasswordForm(forms.Form):
    email = forms.EmailField(max_length=75, widget=forms.TextInput())

class ChangePasswordForm(forms.Form):
    old_password = forms.CharField(min_length=6, max_length=16, widget=forms.PasswordInput(attrs={'placeholder':'必填项'}))
    new_password = forms.CharField(min_length=6, max_length=16, widget=forms.PasswordInput(attrs={'placeholder':'必填项'}))
    confirm_password = forms.CharField(required=False, max_length=16, widget=forms.PasswordInput(attrs={'placeholder':'必填项'}))
    
    def __init__(self, request, data):
        if request:
            super(ChangePasswordForm, self).__init__(data)
        else:
            super(ChangePasswordForm, self).__init__()
        self.request = request
    
    def clean(self):
        if 'old_password' in self.cleaned_data:
            if not self.request.user.check_password(self.cleaned_data['old_password']):
                self._errors['old_password'] = ErrorList([u'原密码输入错误'])
                del self.cleaned_data['old_password']
        
        if ('confirm_password' in self.cleaned_data) and ('new_password' in self.cleaned_data):
            if (self.cleaned_data['confirm_password'] != self.cleaned_data['new_password']):
                self._errors["confirm_password"] = ErrorList([u'新密码与确认密码不匹配'])
                del self.cleaned_data['new_password']
                del self.cleaned_data['confirm_password']
                
        return self.cleaned_data
    
class UserProfileForm(forms.Form):
    true_name = forms.CharField(widget=forms.TextInput(attrs={'placeholder':u'姓名', 'readonly':'readonly'}), required = False)
    phone = forms.CharField(widget=forms.TextInput(attrs={'placeholder':u'手机号码', 'readonly':'readonly'}), required = False)
    email = forms.EmailField(max_length=75, widget=forms.TextInput(attrs={'placeholder':u'邮件地址', 'readonly':'readonly'}), required = False)
    def clean_phone(self):
        phone = self.cleaned_data['phone']
        if phone == '':
            self.cleaned_data['phone'] = None
            return self.cleaned_data['phone']
        phone_re = r'1\d{10}'
        invalid_phone = ''
        phone = phone.strip()
        if phone != '':
            if not re.search(phone_re, phone):
                invalid_phone = phone

        if invalid_phone:
            raise forms.ValidationError(u'电话号码 %s 格式错误' % invalid_phone)
    
        return self.cleaned_data['phone']
    def clean(self):
        return self.cleaned_data