#coding=utf-8

from apps.parties.models import Party
from django import forms
from django.forms.widgets import TextInput, TimeInput, DateInput, Textarea

class CreatePartyForm(forms.ModelForm):
    class Meta:
        model = Party
        fields = ('start_date', 'start_time', 'address', 'description', 'limit_count')
        widgets = {
            'limit_count': TextInput(attrs={'maxlength':'3', 'placeholder':u'无限制'}),
            'start_time' : TimeInput(attrs={'placeholder':u'选填项,格式如8：00', 'class':'input-txt3 mys TimePker', 'autocomplete':'off'}),
            'start_date' : DateInput(attrs={'placeholder':u'选填项,格式如2008-08-08', 'class':'input-txt3 mys', 'style':'width:150px'}),
            'address'    : TextInput(attrs={'placeholder':u'可选填，主要作用是进行地图定位', 'style':'width=315px'}),
            'description': Textarea( attrs={'placeholder':u'必填项', 'cols':'70', 'rows':'13'}),
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