#coding=utf-8

from apps.parties.models import Party
from django import forms
from django.core.validators import validate_email
import re

class CreatePartyForm(forms.ModelForm):
    limit_count = forms.IntegerField(required=False)
    address = forms.CharField(error_messages={'max_length':u'地址的最大长度不要超过256个字符'}, required=False, max_length=256)
    description = forms.CharField(error_messages={'required':u'这个字段是必填的'}, required=True)
    class Meta:
        model = Party
        fields = ('start_date', 'start_time', 'address', 'description')

    def clean_limit_count(self):
        if self.cleaned_data['limit_count'] == None :
            self.cleaned_data['limit_count'] = 0
        else:
            limit_count = self.cleaned_data['limit_count']
            if limit_count < 1 or limit_count > 999:
                raise forms.ValidationError(u'人数应在1~999之间')
        return self.cleaned_data['limit_count']
        
class InviteForm(forms.Form):
    addressee = forms.CharField(widget=forms.TextInput(), required=True)
    content = forms.CharField(widget=forms.TextInput(), required=True)   
            
class PublicEnrollForm(forms.Form):
    name = forms.CharField(error_messages={'required':u'姓名必填'}, required=True)  
    phone_or_email = forms.CharField(error_messages={'required':u'联系方式必填'}, required=True)
    leave_message = forms.CharField(error_messages={'max_length':u'留言长度不能超过100字符'}, max_length=100, required=False)
    
    def clean_leave_message(self):
        if 'leave_message' in self.cleaned_data:
            leave_message = self.cleaned_data['leave_message']
            if len(leave_message) > 100:
                raise forms.ValidationError(u'留言超过100字符')
            
            return self.cleaned_data['leave_message']
        
    def clean_phone_or_email(self):
        if 'phone_or_email' in self.cleaned_data:
            phone_or_email = self.cleaned_data['phone_or_email']
            print phone_or_email.find('@') == -1
            if phone_or_email.find('@') == -1:
                phone_re = r'1\d{10}'
                invalid_phone = ''
                phone = phone_or_email.strip()
                if phone != '':
                    if not re.search(phone_re, phone):
                        invalid_phone = phone
        
                if invalid_phone:
                    raise forms.ValidationError(u'电话号码 %s 格式错误' % invalid_phone)
        
            else:
                invalid_email = ''
                try:
                    validate_email(phone_or_email)
                except:
                    invalid_email = phone_or_email
        
                if invalid_email:
                    raise forms.ValidationError(u'邮件地址 %s 格式错误' % invalid_email)
            
            return self.cleaned_data['phone_or_email']

class EnrollForm(forms.Form):
    leave_message = forms.CharField(error_messages={'max_length':u'留言长度不能超过100字符'}, max_length=100, required=False)
    
    def clean_leave_message(self):
        if 'leave_message' in self.cleaned_data:
            leave_message = self.cleaned_data['leave_message']
            if len(leave_message) > 100:
                raise forms.ValidationError(u'留言超过100字符')
            
            return self.cleaned_data['leave_message']
