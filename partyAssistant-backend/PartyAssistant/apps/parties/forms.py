#coding=utf-8

from apps.parties.models import Party
from django import forms
from django.core.validators import validate_email
from django.forms.widgets import TextInput, TimeInput, DateInput, Textarea
import re

class CreatePartyForm(forms.ModelForm):
    limit_count = forms.CharField(required=False, widget=forms.TextInput(attrs={'maxlength':'3', 'placeholder':u'无限制'}))
    address = forms.CharField(error_messages={'max_length':u'地址的最大长度不要超过256个字符'}, required=False, max_length=256, widget=forms.TextInput(attrs={'placeholder':u'可选填，最大长度为256'}))
    class Meta:
        model = Party
        fields = ('start_date', 'start_time', 'address', 'description')
        widgets = {
            'start_time' : TimeInput(attrs={'placeholder':u'选填项', 'class':'input-txt3 mys TimePker', 'autocomplete':'off'}),
            'start_date' : DateInput(attrs={'placeholder':u'选填项', 'class':'input-txt3 mys', 'style':'width:150px'}),
            'address'    : TextInput(attrs={'placeholder':u'可选填，主要作用是进行地图定位', 'style':'width=315px'}),
            'description': Textarea( attrs={'cols':'70', 'rows':'13'}),
        }

    def clean_limit_count(self):
        if 'limit_count' in self.cleaned_data:
            if self.cleaned_data['limit_count'] == None or self.cleaned_data['limit_count'] > 999:
                self.cleaned_data['limit_count'] = 0
            else:
                limit_count = self.cleaned_data['limit_count']
                if limit_count < 0 or limit_count > 999:
                    raise forms.ValidationError(u'人数应在0~999之间')
            return self.cleaned_data['limit_count']
class InviteForm(forms.Form):
    addressee = forms.CharField(widget=forms.TextInput(), required=True)
    content = forms.CharField(widget=forms.TextInput(), required=True)   
            
class PublicEnrollForm(forms.Form):
    name = forms.CharField( widget=forms.TextInput(attrs={'placeholder':'必填项，输入范围6-14字符'}), required=True)  
    phone_or_email = forms.CharField(widget=forms.TextInput(attrs={'placeholder':u'手机号码或邮件地址'}), required=True)
    leave_message = forms.CharField(widget=forms.Textarea(attrs={'placeholder':u'不可超过100字', 'cols':'20', 'rows':'5'}), required=False)
    
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
    leave_message = forms.CharField(widget=forms.Textarea(attrs={'placeholder':u'不可超过100字', 'cols':'20', 'rows':'5', 'default':''}), required=False)
    
    def clean_leave_message(self):
        if 'leave_message' in self.cleaned_data:
            leave_message = self.cleaned_data['leave_message']
            if len(leave_message) > 100:
                raise forms.ValidationError(u'留言超过100字符')
            
            return self.cleaned_data['leave_message']
