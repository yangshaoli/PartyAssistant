#coding=utf-8

from django import forms
from django.contrib.auth.models import User
from django.forms.util import ErrorList
from django.contrib.auth.forms import AuthenticationForm
from apps.accounts.models import UserProfile

class LoginForm(AuthenticationForm):
    def clean(self):
        pass

class RegistrationForm(forms.Form):
    username = forms.RegexField(regex='^[a-zA-Z0-9]\w*$', min_length=6, max_length=14)
    email = forms.EmailField(required=False, max_length=75)
    password = forms.CharField(min_length=6, max_length=16, widget=forms.PasswordInput())
    confirm_password = forms.CharField(required=False, max_length=16, widget=forms.PasswordInput())
    
    def clean_username(self):
        username = self.cleaned_data['username']
        exists = User.objects.filter(username=username).count() > 0
        if exists:
            raise forms.ValidationError(u'该用户名已存在，请重新输入')
        
        return username
    
    def clean_email(self):
        email = self.cleaned_data['email']
        exists = User.objects.filter(email=email).count() > 0
        if exists:
            raise forms.ValidationError(u'该邮箱已存在，请重新输入')
        
        return email
    
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
    old_password = forms.CharField(min_length=6, max_length=16, widget=forms.PasswordInput())
    new_password = forms.CharField(min_length=6, max_length=16, widget=forms.PasswordInput())
    confirm_password = forms.CharField(required=False, max_length=16, widget=forms.PasswordInput())
    
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
