#coding=utf-8

from apps.parties.models import Party
from django import forms
from django.core.validators import validate_email

class CreatePartyForm(forms.ModelForm):
    class Meta:
        model = Party
        fields = ('start_time', 'address', 'description', 'limit_count')

class InviteForm(forms.Form):
    addressee = forms.CharField(widget=forms.TextInput(), required=True)
    content = forms.CharField(widget=forms.TextInput(), required=True)
