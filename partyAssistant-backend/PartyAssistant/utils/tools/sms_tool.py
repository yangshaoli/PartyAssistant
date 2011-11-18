'''
Created on 2011-11-17

@author: liuxue
'''
 
from django.utils import simplejson

import urllib2 
import logging
logger = logging.getLogger('airenao')
SMS_SERVER_NAME = 'http://192.168.3.155:8000'
SEND_SMS_SERVICE_ADDRESS = '%s/sendsms' % SMS_SERVER_NAME 

def _post_api_request_sendSMS(params):
    req = urllib2.Request(SEND_SMS_SERVICE_ADDRESS)
    response = urllib2.urlopen(req, params)
    result = response.read()
    res = simplejson.loads(result)

    return res 
 
def sms_modem_send_sms(instance):
    phones = instance.address.split(',')
    content = instance.base_message.get_subclass_obj().content
    for phone in phones:
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
            logger.error('SMS send:')
    message = instance
    message.delete()