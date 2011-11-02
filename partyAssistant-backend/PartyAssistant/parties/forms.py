#coding=utf-8

from django import forms
from django.forms.util import ErrorList
import datetime

class CreatePartyForm(forms.Form):
    start_date = forms.DateField(error_messages={'required': u'开始日期不能为空', 'invalid':'请正确输入日期格式，如：2010-01-01'})
    end_date = forms.DateField(error_messages={'required': u'结束日期不能为空', 'invalid':'请正确输入日期格式，如：2010-01-01'})
    start_time = forms.TimeField(error_messages={'required': u'开始时间不能为空', 'invalid':'请正确输入时间格式，如：00:00'})
    end_time = forms.TimeField(error_messages={'required': u'结束时间不能为空', 'invalid':'请正确输入时间格式，如：00:00'})
    description = forms.CharField(widget=forms.Textarea(), required=False)
    address = forms.CharField(widget=forms.TextInput(), required=False)
    limit_num = forms.IntegerField(widget=forms.TextInput(),error_messages={'required':u'请填写限制人数'})    
    def clean(self):
        if 'start_date' in self.cleaned_data and 'end_date' in self.cleaned_data and 'start_time' in self.cleaned_data and 'end_time' in self.cleaned_data:
            start_time = datetime.datetime.strptime('%s %s' % (self.cleaned_data['start_date'].strftime('%Y-%m-%d'), self.cleaned_data['start_time']), '%Y-%m-%d %H:%M:%S')
            end_time   = datetime.datetime.strptime('%s %s' % (self.cleaned_data['end_date'].strftime('%Y-%m-%d'), self.cleaned_data['end_time']), '%Y-%m-%d %H:%M:%S')
            if end_time < start_time:
                self._errors['end_time'] = ErrorList([u'结束时间不能早于开始时间'])
                del self.cleaned_data['end_time']
            elif end_time == start_time:
                self._errors['end_time'] = ErrorList([u'结束时间不能等于开始时间'])
                del self.cleaned_data['end_time']
            else:
                self.cleaned_data['start_time'] = start_time
                self.cleaned_data['end_time'] = end_time 
                   
        if 'limit_num' in self.cleaned_data:
            limit_num = self.cleaned_data['limit_num']
            if limit_num > 999 or limit_num < 0 :
                self._errors['limit_num'] = ErrorList([u'限制人数在0~1000'])
                        
        return self.cleaned_data