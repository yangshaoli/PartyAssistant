'''
Created on 2011-11-13

@author: liwenjian
'''
from django import forms
from django.core.validators import validate_email

class EmailInviteForm(forms.Form):
    client_email_list = forms.CharField(widget=forms.Textarea())
    content = forms.CharField(widget=forms.Textarea())
    is_apply_tips = forms.BooleanField()
    
    def clean_client_email_list(self):
        client_email_list = self.cleaned_data['client_email_list']
        email_list = client_email_list.split(',')
        
        validate_flag = True
        for email in email_list:
            email = email.strip()
            try:
                validate_email(email)
            except:
                validate_flag = False
                break
        
        if not validate_flag:
            raise forms.ValidationError(u'email list error.')
        
        return client_email_list
