#--*-- coding=utf-8
'''
Created on 2011-11-8

@author: liuxue
'''
from apps.parties.models import Party
from django.db import models
import datetime
    
class BaseMessage(models.Model):
    createtime = models.DateTimeField(auto_now_add = True)
    party = models.ForeignKey(Party)
    is_apply_tips = models.BooleanField(default = True)
    is_send_by_self = models.BooleanField(default = True)
    last_modified_time = models.DateTimeField(auto_now=True)
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
    
class Outbox(models.Model):
    address = models.EmailField()
    base_message = models.ForeignKey(BaseMessage)
