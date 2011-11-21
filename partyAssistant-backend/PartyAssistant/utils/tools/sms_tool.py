#coding=utf-8
'''
Created on 2011-11-17

@author: liuxue
'''
 
from apps.common.models import ShortLink
from django.utils import simplejson
from settings import DOMAIN_NAME
from utils.str_util import next_key
import hashlib
import logging
import urllib2

logger = logging.getLogger('airenao')
SMS_SERVER_NAME = 'http://192.168.3.155:8000'
SEND_SMS_SERVICE_ADDRESS = '%s/sendsms' % SMS_SERVER_NAME 

def _post_api_request_sendSMS(params):
    req = urllib2.Request(SEND_SMS_SERVICE_ADDRESS)
    response = urllib2.urlopen(req, params)
    result = response.read()
    res = simplejson.loads(result)

    return res 
 
def sms_modem_send_sms(outbox_message_id):
    from apps.messages.models import Outbox
    outbox_message = Outbox.objects.get(pk=outbox_message_id)
    try:
        message = outbox_message.base_message.get_subclass_obj()
        phone_list = outbox_message.address.split(',')
        if message.is_apply_tips:
            link_count = ShortLink.objects.all().count()
            if link_count > 0:
                last_key = ShortLink.objects.all()[-1]
            else:
                last_key = 'airenao'
            
            party = message.party
            for phone in phone_list:
                content = message.content
                enroll_link = DOMAIN_NAME + '/parties/%d/enroll/?key=%s' % (party.id, hashlib.md5('%d:%s' % (party.id, phone)).hexdigest())
                last_key = next_key(last_key)
                short_link = DOMAIN_NAME + '/' + last_key
                content = content + u'\r\n快来报名：%s' % short_link
                ShortLink.objects.create(short_link=short_link, long_link=enroll_link)
                data = simplejson.dumps({'phone':phone, 'content':content})
                try:
                    res = _post_api_request_sendSMS(data)
                    if res['status'] != 'OK':
                        logger.error(res['msg'])
                except:
                    logger.exception('send sms error!')
        else:
            for phone in phone_list:
                content = message.content
                data = simplejson.dumps({'phone':phone, 'content':content})
                try:
                    res = _post_api_request_sendSMS(data)
                    if res['status'] != 'OK':
                        logger.error(res['msg'])
                except:
                    logger.exception('send sms error!')
    except:
        logger.exception('send sms error!')
    finally:
        outbox_message.delete()
