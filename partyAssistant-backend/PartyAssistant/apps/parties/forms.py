#coding=utf-8

from django import forms
from django.forms.util import ErrorList
import datetime

class CreatePartyForm(forms.Form):
    date = forms.DateField(error_messages={'required': u'开始日期不能为空', 'invalid':'请正确输入日期格式，如：2010-01-01'})
    time = forms.TimeField(error_messages={'required': u'开始时间不能为空', 'invalid':'请正确输入时间格式，如：00:00'})
    description = forms.CharField(widget=forms.Textarea(), required=False)
    address = forms.CharField(widget=forms.TextInput(), required=False,max_length=256 ,error_messages={'max_length':u'地址信息不可超过256字符'})
    limit_num = forms.IntegerField(widget=forms.TextInput(),error_messages={'required':u'请填写限制人数'})    
    def clean(self):


        if 'limit_num' in self.cleaned_data:
            limit_num = self.cleaned_data['limit_num']
            if limit_num > 999 or limit_num < 0 :
                self._errors['limit_num'] = ErrorList([u'限制人数在0~1000'])

        if 'date' in self.cleaned_data and 'time' in self.cleaned_data:
            time = datetime.datetime.strptime('%s %s' % (self.cleaned_data['date'].strftime('%Y-%m-%d'), self.cleaned_data['time']), '%Y-%m-%d %H:%M:%S')
            self.cleaned_data['time'] = time                                 
        return self.cleaned_data


class InviteForm(forms.Form):
    addressee = forms.CharField(widget=forms.TextInput(), required=True)
    content = forms.CharField(widget=forms.TextInput(), required=True)
