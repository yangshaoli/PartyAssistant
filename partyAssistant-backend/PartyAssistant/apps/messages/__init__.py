# -*- coding:utf-8 -*-
from django.db.models import signals
from apps.messages.models import Outbox
from utils.tools.email_tool import send_emails
from settings import SYS_EMAIL_ADDRESS
import thread

def send_email(instance):
    subject = u'[PartyAssistant]您收到一个活动邀请'
    send_emails(subject, instance.email.content, SYS_EMAIL_ADDRESS, [instance.address])
    message = instance
    message.delete()
    
def thread_send_message(sender=None, instance=None, **kwargs):
    thread.start_new_thread(send_email, (instance,))
   
signals.post_save.connect(thread_send_message, sender = Outbox)