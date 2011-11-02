#coding=utf-8

from django import forms
from django.contrib.auth.models import User
from django.forms.util import ErrorList

class WebRegistrationForm(forms.Form):
    password = forms.CharField(min_length = 6, max_length = 16,
            error_messages = {
                'required': u'密码不能为空',
                'min_length': u'密码长度至少为6位',
                'max_length': u'密码长度最大为16位'},
                widget = forms.PasswordInput(render_value = False,
                attrs = {'class': 'input-txt1'}))
    confirm_password = forms.CharField(required = False, max_length = 16,widget = forms.PasswordInput(render_value = False))
    # Email在Django中存储的最大长度实际为75位
    email = forms.EmailField(max_length=75, widget=forms.TextInput())
    
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
    
class AppRegistrationForm(forms.Form):
    phone = forms.EmailField(max_length=16)