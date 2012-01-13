#coding=utf-8

from django import forms
from django.contrib.auth import authenticate, login
from django.contrib.auth.forms import AuthenticationForm
from django.contrib.auth.models import User
from django.forms.util import ErrorList
from django.shortcuts import redirect, HttpResponse

from apps.accounts.models import AccountTempPassword

class LoginForm(AuthenticationForm):
    username = forms.CharField(error_messages = {'required': u'用户名不能为空'}, max_length = 30)
    password = forms.CharField(error_messages = {'required': u'密码不能为空'})
    

    def clean(self):
        username = self.cleaned_data.get('username')
        password = self.cleaned_data.get('password')
        if username and password:
            self.user_cache = authenticate(username = username, password = password)
            if self.user_cache is None:
                #临时密码登录
                user_temp_pwd_list = AccountTempPassword.objects.filter(temp_password = password, user__username = username)
                if user_temp_pwd_list:
                    user = user_temp_pwd_list[0].user
                    #login(self.request, user)
                    self.request.session['temp_login'] = user
                    
                    #删除临时密码
                    for user_temp_pwd in user_temp_pwd_list:
                        user_temp_pwd.delete()
                        
                    raise forms.ValidationError("")
                else:
                    raise forms.ValidationError("请输入正确的用户名、密码")
                

                
            elif not self.user_cache.is_active:
                raise forms.ValidationError("该账户未激活")
        self.check_for_test_cookie()
        return self.cleaned_data

class RegistrationForm(forms.Form):
    username = forms.RegexField(error_messages = {'required': u'用户名不能为空', 'min_length':u'至少是6个字符', 'max_length':u'最多是14个字符', 'invalid':u'用户名请以字母开头'}, regex = '^[a-zA-Z]\w*$', min_length = 6, max_length = 14)
    password = forms.CharField(error_messages = {'required': u'密码不能为空', 'min_length':u'至少是6个字符', 'max_length':u'最多是16个字符'}, min_length = 6, max_length = 16)
    confirm_password = forms.CharField(error_messages = {'required': u'确认密码不能为空', 'min_length':u'至少是6个字符', 'max_length':u'最多是16个字符'}, max_length = 16)
    
    def clean_username(self):
        username = self.cleaned_data['username']
        exists = User.objects.filter(username = username).count() > 0
        if exists:
            raise forms.ValidationError(u'该用户名已被使用，请重新输入')
#        if username[0].isdigit():
#            raise forms.ValidationError(u'用户名不能以数字开头')
        return username
    
    def clean(self):
        if ('confirm_password' in self.cleaned_data) and ('password' in self.cleaned_data):
            if (self.cleaned_data['confirm_password'] != self.cleaned_data['password']):
                self._errors["confirm_password"] = ErrorList([u'密码与确认密码不匹配'])
                del self.cleaned_data['password']
                del self.cleaned_data['confirm_password']
                
        return self.cleaned_data
    
class GetPasswordForm(forms.Form):
    email = forms.EmailField(max_length = 75, widget = forms.TextInput())

class ChangePasswordForm(forms.Form):
    old_password = forms.CharField(error_messages = {'required': u'原始密码不能为空', 'min_length':u'至少是6个字符', 'max_length':u'最多是16个字符'}, min_length = 6, max_length = 16)
    new_password = forms.CharField(error_messages = {'required': u'新密码不能为空', 'min_length':u'至少是6个字符', 'max_length':u'最多是16个字符'}, min_length = 6, max_length = 16)
    confirm_password = forms.CharField(error_messages = {'required': u'新密码不能为空', 'min_length':u'至少是6个字符', 'max_length':u'最多是16个字符'}, required = False, max_length = 16)
    
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

class ResetPasswordForm(forms.Form):
    password = forms.CharField(error_messages = {'required': u'新密码不能为空', 'min_length':u'至少是6个字符', 'max_length':u'最多是16个字符'}, min_length = 6, max_length = 16)
    confirm_password = forms.CharField(error_messages = {'required': u'确认密码不能为空', 'min_length':u'至少是6个字符', 'max_length':u'最多是16个字符'}, max_length = 16)
    
    def clean(self):
  
        if ('confirm_password' in self.cleaned_data) and ('password' in self.cleaned_data):
            if (self.cleaned_data['confirm_password'] != self.cleaned_data['password']):
                self._errors["confirm_password"] = ErrorList([u'新密码与确认密码不匹配'])
                del self.cleaned_data['password']
                del self.cleaned_data['confirm_password']
        return self.cleaned_data


class UserProfileForm(forms.Form):
    true_name = forms.CharField(required = False, error_messages = {'max_length':u'最多是14个字符'}, max_length = 14)
    #phone = forms.RegexField(required = False, regex = '1\d{10}', error_messages = {'invalid':u'手机号码不规范'})
    #email = forms.EmailField(max_length = 75, required = False, error_messages = {'max_length':u'邮箱地址不要超过75字符'})
    
    #def clean_phone(self):
    #   if self.cleaned_data['phone'] == '' :
    #        return None
    #    else :
    #       return str(self.cleaned_data['phone'])

class BuySMSForm(forms.Form):
    sms_count = forms.IntegerField()
    
    def clean_sms_count(self):
        if self.cleaned_data['sms_count'] == None or self.cleaned_data['sms_count'] <= 0:
            self._errors['sms_count'] = ErrorList([u'购买信息数量至少为1条'])
        if self.cleaned_data['sms_count'] > 999999999:
            self._errors['sms_count'] = ErrorList([u'一次性最大购买数量不可超过999,999,999条'])    
        return self.cleaned_data['sms_count']
