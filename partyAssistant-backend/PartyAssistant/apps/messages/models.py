#--*-- coding=utf-8
'''
Created on 2011-11-8

@author: liuxue
'''
from django.db.models import signals
from apps.parties.models import Party
from django.db import models
import thread 
from utils.tools.email_tool import send_email
from utils.tools.sms_tool import sms_modem_send_sms

class BaseMessage(models.Model):
    createtime = models.DateTimeField(auto_now_add = True)
    party = models.ForeignKey(Party)
    is_apply_tips = models.BooleanField(default = True)
    is_send_by_self = models.BooleanField(default = False)
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
    address = models.TextField()
    base_message = models.ForeignKey(BaseMessage)
    
def thread_send_message(sender=None, instance=None, **kwargs):
    if instance.base_message.get_subclass_obj().is_send_by_self:
        return
    
    message = instance.base_message.get_subclass_obj()
    party = message.party
    
    if isinstance(message, EmailMessage):
        thread.start_new_thread(send_email, (instance, message, party))
    else:
        thread.start_new_thread(sms_modem_send_sms, (instance, message, party))
   
signals.post_save.connect(thread_send_message, sender = Outbox)
