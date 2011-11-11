#coding=utf-8

from django import forms
from django.contrib.auth.models import User
from django.forms.util import ErrorList
from django.contrib.auth.forms import AuthenticationForm
from apps.accounts.models import UserProfile

class LoginForm(AuthenticationForm):
    def clean(self):
        pass

class WebRegistrationForm(forms.Form):
    username = forms.CharField(min_length = 6, max_length = 14)
    email = forms.EmailField(max_length=75, widget=forms.TextInput())
    password = forms.CharField(min_length = 6, max_length = 16,widget = forms.PasswordInput())
    confirm_password = forms.CharField(required = False, max_length = 16,widget = forms.PasswordInput())
    
    def clean_username(self):
        value = self.cleaned_data['username']
        user = User.objects.filter(username = value)
        if user:
            raise forms.ValidationError(u'用户名已经存在，请重新输入')
        return value
    
    def clean_email(self):
        value = self.cleaned_data['email']
        user = User.objects.filter(email = value)
        if user:
            raise forms.ValidationError(u'该邮箱已存在，请重新输入')
        return value
    
    def clean(self):
        if ('confirm_password' in self.cleaned_data) and ('password' in self.cleaned_data):
            if (self.cleaned_data['confirm_password'] != self.cleaned_data['password']):
                self._errors["confirm_password"] = ErrorList([u"两次输入密码不匹配"])
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
    
    
    def clean(self):
        if ('confirm_password' in self.cleaned_data) and ('new_password' in self.cleaned_data):
            if (self.cleaned_data['confirm_password'] != self.cleaned_data['new_password']):
                self._errors["confirm_password"] = ErrorList([u"两次输入密码不匹配"])
                del self.cleaned_data['new_password']
                del self.cleaned_data['confirm_password']
        return self.cleaned_data