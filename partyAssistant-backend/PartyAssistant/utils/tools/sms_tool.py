'''
Created on 2011-11-17

@author: liuxue
'''
 
from django.utils import simplejson

import urllib2 
SMS_SERVER_NAME = 'http://192.168.3.155:8000'
SEND_SMS_SERVICE_ADDRESS = '%s/sendsms' % SMS_SERVER_NAME 

def _post_api_request_sendSMS(params):
    req = urllib2.Request(SEND_SMS_SERVICE_ADDRESS)
    response = urllib2.urlopen(req, params)
    result = response.read()
    res = simplejson.loads(result)

    return res 
 
