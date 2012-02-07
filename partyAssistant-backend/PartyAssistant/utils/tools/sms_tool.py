#coding=utf-8
'''
Created on 2011-11-17

@author: liuxue
'''
 
from settings import DOMAIN_NAME, SHORT_DOMAIN_NAME

from utils.tools.short_link_tool import transfer_to_shortlink
from utils.tools.phone_num_tool import regPhoneNum

import hashlib
import logging
import urllib
import urllib2

BASIC_MESSAGE_LENGTH = 65
SHORT_LINK_LENGTH = 18

logger = logging.getLogger('airenao')
SMS_SERVER_NAME = 'http://u.wangxun360.com'
WS_BATCH_SEND = '/ws/BatchSend.aspx'
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
output_message = {#短信返回值的含义
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
def _ws_post_api_request_sendSMS(SMS_SERVER_NAME, WS_INTERFACE, params = {}):
    url = '%s%s' % (SMS_SERVER_NAME, WS_INTERFACE)
    params = urllib.urlencode(params)
    request = urllib2.Request(url, params)
    res = urllib2.urlopen(request).read()
    return res 

def _post_api_request_sendSMS(params = {}):
    params['CorpID'] = CORPID
    params['Pwd'] = PWD
    params['Cell'] = ''
    params['SendTime'] = ''
    
    return _ws_post_api_request_sendSMS(SMS_SERVER_NAME, WS_BATCH_SEND, params)  
 
 
def sms_modem_send_sms(outbox_message, message, party):
    number_of_message = (len(message.content) + (SHORT_LINK_LENGTH if message.is_apply_tips else 0) + BASIC_MESSAGE_LENGTH - 1) / BASIC_MESSAGE_LENGTH
    userprofile = party.creator.get_profile()
    try:
        phone_list = outbox_message.address.split(',')
        if message.is_apply_tips:
            for phone in phone_list:
                content = message.content
                enroll_link = DOMAIN_NAME + '/parties/%d/enroll/?key=%s' % (party.id, hashlib.md5('%d:%s' % (party.id, phone)).hexdigest())
                short_link = transfer_to_shortlink(enroll_link)
                content = u'【爱热闹】%s 快来报名：%s' % (content, short_link)
                data = {'Mobile':regPhoneNum(phone), 'Content':content.encode('gbk')}
                
                #短信扣除
                userprofile.used_sms_count = userprofile.used_sms_count + number_of_message
                userprofile.available_sms_count = userprofile.available_sms_count - number_of_message
                userprofile.save()
                try:
                    res = _post_api_request_sendSMS(data)
                    if res != '1':
                        logger.error(res)
                except:
                    userprofile.used_sms_count = userprofile.used_sms_count - number_of_message
                    userprofile.available_sms_count = userprofile.available_sms_count + number_of_message
                    userprofile.save()
                    logger.info('return avalibale sms count ,user:' + str(party.creator.id) + 'number:' + str(number_of_message))
                    logger.exception('send sms error!')
        else:
            for phone in phone_list:
                content = u'【爱热闹】' + message.content
                data = {'Mobile':regPhoneNum(phone), 'Content':content.encode('gbk')}

                #短信扣除
                userprofile.used_sms_count = userprofile.used_sms_count + number_of_message
                userprofile.available_sms_count = userprofile.available_sms_count - number_of_message
                userprofile.save()
                try:
                    res = _post_api_request_sendSMS(data)
                    if res != '1':
                        logger.error(res)
                except:
                    userprofile.used_sms_count = userprofile.used_sms_count - number_of_message
                    userprofile.available_sms_count = userprofile.available_sms_count + number_of_message
                    userprofile.save()
                    logger.info('return avalibale sms count ,user:' + str(party.creator.id) + 'number:' + str(number_of_message))
                    logger.exception('send sms error!')
    except:
        logger.exception('send sms error!')
    finally:
        outbox_message.delete()

def sendsmsBindingmessage(UserBindingTemp):
    phone = UserBindingTemp.binding_address
    content = u'【爱热闹】' + u'您的手机验证码：' + UserBindingTemp.key
    data = {'Mobile':regPhoneNum(phone) , 'Content':content.encode('gbk')}
    try:
        res = _post_api_request_sendSMS(data)
        if res != '1':
            logger.error(res)
    except:
        logger.exception('send sendsmsBindingmessage error!')

def sendsmsMessage(message):
    phone = message['address']
    if message['content'] == 'bindsuccess':
        message['content'] = u'手机号码绑定成功'
    elif message['content'] == 'unbindsuccess':
        message['content'] = u'手机号码解除绑定成功'
    else:
        return
    content = u'【爱热闹】' + message['content']
    data = {'Mobile':regPhoneNum(phone) , 'Content':content.encode('gbk')}
    try:
        res = _post_api_request_sendSMS(data)
        if res != '1':
            logger.error(res)
    except:
        logger.exception('send sendsmsBingdingmessage error!')        

def send_forget_pwd_sms(instance):
    phone = instance.user.userprofile.phone
    content = u'【爱热闹】您的临时密码为: %s 该密码仅生效一次，请您尽快登录应用/网站，修改您的密码。' % instance.temp_password
    data = {'Mobile':regPhoneNum(phone) , 'Content':content.encode('gbk')}
    try:
        res = _post_api_request_sendSMS(data)
        if res != '1':
            logger.error(res)
    except:
        logger.exception('send sendsmsBindingmessage error!')
