#coding=utf-8
from apps.messages.models import Outbox
from django.db.models import signals
from django.utils.importlib import import_module
from settings import SYS_EMAIL_ADDRESS
from utils.tools.email_tool import send_emails 
from utils.tools.sms_tool import _post_api_request_sendSMS

import settings
from django.utils import simplejson
import thread
import logging
logger = logging.getLogger('airenao')
def send_email(instance):
    subject = u'[PartyAssistant]您收到一个活动邀请'
    try:
        send_emails(subject, instance.base_message.get_subclass_obj().content, SYS_EMAIL_ADDRESS, [instance.address])
    except Exception, ex: 
        new_e = Exception()
        new_e.error_msg = str(ex)
        logger.error('Email send')
    finally:
        message = instance
        message.delete()
 
    
def sms_modem_send_sms(instance):
    phone = instance.address
    content = instance.base_message.get_subclass_obj().content
    if content:
        data = simplejson.dumps({'phone':phone, 'content':content})
    try:
        res = _post_api_request_sendSMS(data)
        if res['status'] != 'OK':
            new_e = Exception()
            new_e.error_msg = res['msg']
            raise new_e
    except Exception, ex:
        new_e = Exception()
        new_e.error_msg = str(ex)
        logger.error('Email send:')
    finally:
        message = instance
        message.delete()
    
def thread_send_message(sender=None, instance=None, **kwargs):
    if instance.base_message.get_subclass_type() == 'Email':
        thread.start_new_thread(send_email, (instance,))
    else:
        thread.start_new_thread(sms_modem_send_sms, (instance,))    
   
signals.post_save.connect(thread_send_message, sender = Outbox)
