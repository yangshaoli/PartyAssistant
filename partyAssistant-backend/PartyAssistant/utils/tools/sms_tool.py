#coding=utf-8
'''
Created on 2011-11-17

@author: liuxue
'''
 
from apps.common.models import ShortLink
from settings import DOMAIN_NAME, SHORT_DOMAIN_NAME
from utils.tools.str_tool import generate_key
import hashlib
import logging
import urllib
import urllib2

logger = logging.getLogger('airenao')
SMS_SERVER_NAME = 'http://u.wangxun360.com'
WS_BATCH_SEND ='/ws/BatchSend.aspx'
CORPID = 'ZLJK00123'
PWD = '659402'


#SMS_SERVER_NAME = 'http://192.168.3.155:8000'
#SEND_SMS_SERVICE_ADDRESS = '%s/sendsms' % SMS_SERVER_NAME 

#def _post_api_request_sendSMS(params):
#    req = urllib2.Request(SEND_SMS_SERVICE_ADDRESS)
#    response = urllib2.urlopen(req, params)
#    result = response.read()
#    res = simplejson.loads(result)
#
#    return res 
output_message={#短信返回值的含义
                '0' : u'发送成功进入审核阶段',
                '1' : u'直接发送成功',
                '-1' : u'帐号未注册',
                '-2' : u'其他错误',
                '-3' : u'帐号或密码错误',
                '-4' : u'一次提交信息不能超过600个手机号码',
                '-5' : u'余额不足，请先充值',
                '-6' : u'定时发送时间不是一个有效的时间格式',
                '-8' : u'发送内容需在3到250字之间',
                '-9' : u'发送号码为空'
                }
#params={
#      'CorpID' : 'ZLJK00123',#帐号, String
#      'Pwd' : '659402',#密码, String
#      'Mobile':'13641115243',#发送手机号码, String
#      'Content':'last',#发送内容, String
#      'Cell':'',#子号, String
#      'SendTime':'' #定时发送时间, String(14)          
#      } 
def _ws_post_api_request_sendSMS(SMS_SERVER_NAME, WS_INTERFACE, params={}):
    url = '%s%s' % (SMS_SERVER_NAME, WS_INTERFACE)
    params = urllib.urlencode(params)
    request = urllib2.Request(url,params)
    res = urllib2.urlopen(request).read()
    return res 

def _post_api_request_sendSMS(params={}):
    params['CorpID'] = CORPID
    params['Pwd'] = PWD
    params['Cell'] = ''
    params['SendTime'] = ''
    
    return _ws_post_api_request_sendSMS(SMS_SERVER_NAME, WS_BATCH_SEND, params)  
 
 
def sms_modem_send_sms(outbox_message, message, party):
    try:
        phone_list = outbox_message.address.split(',')
        if message.is_apply_tips:
            for phone in phone_list:
                content = message.content
                enroll_link = 'http://' + DOMAIN_NAME + '/parties/%d/enroll/?key=%s' % (party.id, hashlib.md5('%d:%s' % (party.id, phone)).hexdigest())
                new_key = generate_key()
                short_link = 'http://' + SHORT_DOMAIN_NAME + '/' + new_key
                content = content + u' 快来报名：%s ' % short_link
                ShortLink.objects.create(short_link=new_key, long_link=enroll_link)
                data = {'Mobile':phone, 'Content':content.encode('gbk')}
                try:
                    res = _post_api_request_sendSMS(data)
                    if res != '1':
                        logger.error(res)
                except:
                    logger.exception('send sms error!')
        else:
            for phone in phone_list:
                content = message.content
                data = {'Mobile':phone, 'Content':content.encode('gbk')}
                try:
                    res = _post_api_request_sendSMS(data)
                    if res != '1':
                        logger.error(res)
                except:
                    logger.exception('send sms error!')
    except:
        logger.exception('send sms error!')
    finally:
        outbox_message.delete()
