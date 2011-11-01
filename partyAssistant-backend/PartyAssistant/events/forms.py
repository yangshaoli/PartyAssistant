#coding=utf-8

from django import forms
from django.forms.util import ErrorList
from tools.datetime_tool import time_combine

class createPartyForm(forms.Form):
    start_date = forms.DateField(widget=forms.TextInput(attrs={'class': 'input-txt3 mys'}),
                                     error_messages={'required': u'会议开始日期不能为空', 'invalid':'请正确输入日期格式，如：2010-01-01'})
    end_date = forms.DateField(widget=forms.TextInput(attrs={'class': 'input-txt3'}),
                                   error_messages={'required': u'会议结束日期不能为空', 'invalid':'请正确输入日期格式，如：2010-01-01'})
    start_time = forms.TimeField(widget=forms.TextInput(attrs={'class': 'input-txt3 mys TimePker', 'autocomplete':'off'}), error_messages={'required': u'会议开始时间不能为空', 'invalid':'请正确输入时间格式，如：00:00'})
    end_time = forms.TimeField(widget=forms.TextInput(attrs={'class': 'input-txt3 mys TimePker', 'autocomplete':'off'}), error_messages={'required': u'会议结束时间不能为空', 'invalid':'请正确输入时间格式，如：00:00'})
    remarks = forms.CharField(widget=forms.Textarea(attrs={'class': 'textarea-remark2'}), required=False)
    address = forms.CharField(widget=forms.TextInput(attrs={'class': 'textarea-remark2'}), required=False)
    limit_num=forms.IntegerField(widget=forms.TextInput(),error_messages={'required':u'请填写限制人数'})    
    def clean(self):
        if 'start_date' in self.cleaned_data and 'end_date' in self.cleaned_data and 'start_time' in self.cleaned_data and 'end_time' in self.cleaned_data:
            start_time = time_combine(self.cleaned_data['start_date'],
                                      str(self.cleaned_data['start_time']))
            end_time = time_combine(self.cleaned_data['end_date'],
                                    str(self.cleaned_data['end_time']))
            if end_time < start_time:
                self._errors['end_time'] = ErrorList([u'会议结束时间不能早于会议开始时间'])
                del self.cleaned_data['end_time']
            elif end_time == start_time:
                self._errors['end_time'] = ErrorList([u'会议结束时间不能等于会议开始时间'])
                del self.cleaned_data['end_time']
                       
        return self.cleaned_data