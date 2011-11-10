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
    username = forms.RegexField(regex='^[a-zA-Z0-9]\w*$', min_length=6, max_length=14, 
                    error_messages={'required': u'用户名不能为空', 'invalid': u'用户名格式不正确'})
    email = forms.EmailField(required=False, max_length=75)
    password = forms.CharField(min_length=6, max_length=16, widget=forms.PasswordInput(), 
                    error_messages={'required': u'密码不能为空', 'min_length': u'密码长度至少为6位'})
    confirm_password = forms.CharField(required=False, max_length=16, widget=forms.PasswordInput())
    
    def clean_username(self):
        username = self.cleaned_data['username']
        exists = User.objects.filter(username=username).count() > 0
        if exists:
            raise forms.ValidationError(u'该用户名已存在，请重新输入')
        
        return username
    
    def clean_email(self):
        value = self.cleaned_data['email']
        exists = User.objects.filter(email=value).count() > 0
        if exists:
            raise forms.ValidationError(u'该邮箱已存在，请重新输入')
        return value
    
    def clean(self):
        if ('confirm_password' in self.cleaned_data) and ('password' in self.cleaned_data):
            if (self.cleaned_data['confirm_password'] != self.cleaned_data['password']):
                self._errors["confirm_password"] = ErrorList([u'密码与确认密码不匹配'])
                del self.cleaned_data['password']
                del self.cleaned_data['confirm_password']
                
        return self.cleaned_data
    
class AppRegistrationForm(forms.Form):
    phone = forms.IntegerField()
    
    def clean_phone(self):
        value = self.cleaned_data['phone']
        phone = UserProfile.objects.filter(phone = value)
        if phone:
            raise forms.ValidationError(u'手机号已经注册过了')
        return value
    
class GetPasswordForm(forms.Form):
    email = forms.EmailField(max_length=75, widget=forms.TextInput())

class ChangePasswordForm(forms.Form):
    old_password = forms.CharField(min_length = 6, max_length = 16,widget = forms.PasswordInput())
    new_password = forms.CharField(min_length = 6, max_length = 16,widget = forms.PasswordInput())
    confirm_password = forms.CharField(required = False, max_length = 16,widget = forms.PasswordInput())
    
    def __init__(self, request, *args, **kwargs):
        super(ChangePasswordForm, self).__init__(args, kwargs)
        self.request = request
    
    def clean(self):
        if 'old_password' in self.cleaned_data:
            if not self.request.user.check_password(self.cleaned_data['old_password']):
                self._errors['old_password'] = ErrorList([u'原密码输入错误'])
                del self.cleaned_data['old_password']
        
        if ('confirm_password' in self.cleaned_data) and ('new_password' in self.cleaned_data):
            if (self.cleaned_data['confirm_password'] != self.cleaned_data['new_password']):
                self._errors["confirm_password"] = ErrorList([u'新密码与确认密码不匹配'])
                del self.cleaned_data['password']
                del self.cleaned_data['confirm_password']
                
        return self.cleaned_data
