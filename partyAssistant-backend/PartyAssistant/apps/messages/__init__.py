#coding=utf-8
from apps.messages.models import Outbox
from django.db.models import signals
from django.utils.importlib import import_module
from settings import SYS_EMAIL_ADDRESS
from utils.tools.email_tool import send_emails, send_sms
import settings
import thread
def send_email(instance):
    subject = u'[PartyAssistant]您收到一个活动邀请'
    send_emails(subject, instance.base_message.get_subclass_obj().content, SYS_EMAIL_ADDRESS, [instance.address])
    message = instance
    message.delete()

def send_sms_(instance):
    send_sms(instance.base_message.get_subclass_obj().content.encode('utf-8'), instance.address )
    message = instance
    message.delete()

    
def thread_send_message(sender=None, instance=None, **kwargs):
    if instance.base_message.get_subclass_type() == 'Email':
        thread.start_new_thread(send_email, (instance,))
    else:
        thread.start_new_thread(send_sms_, (instance,))    
   
signals.post_save.connect(thread_send_message, sender = Outbox)
