#--*-- coding=utf-8
'''
Created on 2011-11-8

@author: liuxue
'''
from django.db import models
from apps.parties.models import Party
class BaseMessage(models.Model):
    receivers = models.TextField()
    
    createtime = models.DateTimeField(auto_now_add = True)
    party = models.ForeignKey(Party)
    apply_tips = models.BooleanField(default = True)
    send_by_self = models.BooleanField(default = True)
    
    def get_subclass_type(self):
        if hasattr(self, "emailmessage"):
            return 'Email'
        else:
            return 'SMS'
        
    def get_subclass_obj(self, *args):
        if hasattr(self, "emailmessage"):
            return self.emailmessage
        else:
            return self.smsmessage

class EmailMessage(BaseMessage):
    subject = models.CharField(max_length = 256)
    content = models.TextField()
    
class SMSMessage(BaseMessage):
    content = models.TextField()
