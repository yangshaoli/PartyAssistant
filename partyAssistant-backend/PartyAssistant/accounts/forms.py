#coding=utf-8

from django import forms
from django.contrib.auth import authenticate
from django.contrib.auth.models import User
from django.forms.util import ErrorList
import re

field_re = re.compile(r'[\w]+')

class LoginForm(forms.Form):
    username = forms.CharField(error_messages = {'required': u'用户名不能为空'},
                                                widget = forms.TextInput(attrs = {'class': 'input-txt1'}))
    #render_value=False使render时该栏不显示上次输入内容
    password = forms.CharField(error_messages = {'required': u'密码不能为空'},
                                               widget = forms.PasswordInput(render_value = False,
                                               attrs = {'class': 'input-txt1'}))
    
    def clean(self):
        if 'username' in self.cleaned_data and 'password' in self.cleaned_data:
            if not User.objects.filter(username = self.cleaned_data['username']):
                self._errors["username"] = ErrorList([u"该用户未注册"])
            else:
                user = authenticate(username = self.cleaned_data['username'],
                                    password = self.cleaned_data['password'])
                if user is not None:
                    if not user.is_active:
                        #子账户未激活状态和被停用状态暂时用“未启用”提醒  ——by 10-9-14
                        if user.userprofile.limit == u'管理员':
                            self._errors["username"] = ErrorList([u"该用户未激活"])
                        else:
                            self._errors["username"] = ErrorList([u"该用户未启用"])
                else:
                    self._errors["password"] = ErrorList([u"用户名或密码错误"])
            del self.cleaned_data['password']
        return self.cleaned_data

class RegistrationForm(forms.Form):
    password = forms.CharField(
            min_length = 6, max_length = 16,
            error_messages = {
                'required': u'密码不能为空',
                'min_length': u'密码长度至少为6位',
                'max_length': u'密码长度最大为16位'},
                widget = forms.PasswordInput(render_value = False,
                attrs = {'class': 'input-txt1'}))
    confirm_password = forms.CharField(required = False, max_length = 16,
    widget = forms.PasswordInput(render_value = False,
    attrs = {'class': 'input-txt1'}))
    # Email在Django中存储的最大长度实际为75位
    email = forms.EmailField(max_length = 75,
    widget = forms.TextInput(attrs = {'class': 'input-txt1'}),
    error_messages = {
        'required': u'邮箱不能为空',
        'invalid': u'邮箱格式不正确',
        'max_length':u'邮箱的最大长度为75位'})
    
#    def clean_username(self):
#        value = self.cleaned_data['username']
#        
#        if not field_re.search(value):
#            raise forms.ValidationError(u'用户名格式不正确，只能输入字母，数字，下划线')
#        
#        user = User.objects.filter(username=value)
#        if user:
#            raise forms.ValidationError(u'该用户名已存在，请重新输入')
#        
#        return value
    
    def clean_email(self):
        value = self.cleaned_data['email']
        user = User.objects.filter(username = value)
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

class ForgetPasswordForm(forms.Form):
    email = forms.EmailField(max_length = 75,
                             widget = forms.TextInput(attrs = {'class': 'input-txt1'}),
                             error_messages = {'required': u'邮箱不能为空',
                                                         'invalid': u'邮箱格式不正确',
                                                         'max_length':u'邮箱的最大长度为75位'})
    def clean_email(self):
        value = self.cleaned_data['email']
        user = User.objects.filter(username = value)
        if not user:
            raise forms.ValidationError(u'该用户不存在')
        
        return value
    
class PasswordModifyByForgetPSWForm(forms.Form):
    new_password = forms.CharField(min_length = 6, max_length = 16,
                                   error_messages = {'required': u'新密码不能为空',
                                                   'min_length': u'新密码长度至少为6位',
                                                   'max_length': u'新密码长度最大为16位'},
                                   widget = forms.PasswordInput(render_value = False,
                                                              attrs = {'class': 'input-txt1'}))
    confirm_password = forms.CharField(required = False, max_length = 16,
                                       widget = forms.PasswordInput(render_value = False,
                                                                  attrs = {'class': 'input-txt1'}))

    def clean(self):
        if ('confirm_password' in self.cleaned_data) and ('new_password' in self.cleaned_data):
            if (self.cleaned_data['confirm_password'] != self.cleaned_data['new_password']):
                self._errors["confirm_password"] = ErrorList([u"两次输入密码不匹配"])
                del self.cleaned_data['new_password']
                del self.cleaned_data['confirm_password']
            
        return self.cleaned_data
    
class PasswordModifyForm(forms.Form):
    username = forms.CharField(max_length = 64, widget = forms.TextInput(attrs = {'class': 'input-txt1'}))
    old_password = forms.CharField(
                                   error_messages = {'required': u'密码不能为空',
                                                   },
                                   widget = forms.PasswordInput(render_value = False,
                                                              attrs = {'class': 'input-txt1'}))
    new_password = forms.CharField(min_length = 6, max_length = 16,
                                   error_messages = {'required': u'新密码不能为空',
                                                   'min_length': u'新密码长度至少为6位',
                                                   'max_length': u'新密码长度最大为16位'},
                                   widget = forms.PasswordInput(render_value = False,
                                                              attrs = {'class': 'input-txt1'}))
    confirm_password = forms.CharField(required = False, max_length = 16,
                                       widget = forms.PasswordInput(render_value = False,
                                                                  attrs = {'class': 'input-txt1'}))
    
    def clean(self):
        if 'username' in self.cleaned_data and 'old_password' in self.cleaned_data:
            user = authenticate(username = self.cleaned_data['username'],
                                password = self.cleaned_data['old_password'])
            if not user:
                self._errors["old_password"] = ErrorList([u"输入旧密码不正确"])
            else:
                if user.userprofile.limit == u'临时账户':
                    self._errors["old_password"] = ErrorList([u"您是临时客户，没有权限修改密码"])
        if ('confirm_password' in self.cleaned_data) and ('new_password' in self.cleaned_data):
            if (self.cleaned_data['confirm_password'] != self.cleaned_data['new_password']):
                self._errors["confirm_password"] = ErrorList([u"两次输入密码不匹配"])
                del self.cleaned_data['new_password']
                del self.cleaned_data['confirm_password']
            
        return self.cleaned_data

class AddLimitedAccountForm(forms.Form):
    email = forms.EmailField(max_length = 64, widget = forms.TextInput(attrs = {'class': 'input-txt1'}),
                             error_messages = {'required': u'邮箱不能为空',
                                             'invalid': u'邮箱格式不正确',
                                             'max_length':u'邮箱的最大长度为64位'})

class AccountToFormalForm(forms.Form):
    email = forms.EmailField(max_length = 75, widget = forms.TextInput(attrs = {'class': 'input-txt1'}),
                             error_messages = {'required': u'邮箱不能为空',
                                               'invalid': u'邮箱格式不正确',
                                               'max_length':u'邮箱的最大长度为75位'})
    new_password = forms.CharField(min_length = 6, max_length = 16,
                                   error_messages = {'min_length': u'新密码长度至少为6位',
                                                     'max_length': u'新密码长度最大为16位'},
                                   widget = forms.PasswordInput(render_value = False,
                                                              attrs = {'class': 'input-txt1'}))
    confirm_password = forms.CharField(max_length = 16,
                                       widget = forms.PasswordInput(render_value = False,
                                                                  attrs = {'class': 'input-txt1'}))
    
    def clean(self):
        value = self.cleaned_data['email']
        user = User.objects.filter(username = value)
        if user:
            self._errors["email"] = ErrorList([u"该邮箱已存在，请重新输入"])
        
        return self.cleaned_data
