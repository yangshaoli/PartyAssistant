#coding=utf-8

from apps.parties.models import Party
from django import forms
from django.forms.widgets import TextInput

class CreatePartyForm(forms.ModelForm):
    class Meta:
        model = Party
        fields = ('start_date', 'start_time', 'address', 'description', 'limit_count')
        widgets = {
            'limit_count': TextInput(attrs={'maxlength':'3'}),
        }

    def clean_limit_count(self):
        if 'limit_count' in self.cleaned_data:
            if self.cleaned_data['limit_count'] == None or self.cleaned_data['limit_count'] > 999:
                self.cleaned_data['limit_count'] = 0
                return self.cleaned_data['limit_count']
        
        return self.cleaned_data['limit_count']

class InviteForm(forms.Form):
    addressee = forms.CharField(widget=forms.TextInput(), required=True)
    content = forms.CharField(widget=forms.TextInput(), required=True)   