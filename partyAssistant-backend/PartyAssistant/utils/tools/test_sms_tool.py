#coding=utf-8
'''
Created on 2011-11-17

@author: liuxue
'''
 
import logging
import urllib
import urllib2

logger = logging.getLogger('airenao')
SMS_SERVER_NAME = 'http://u.wangxun360.com'
WS_BATCH_SEND ='/ws/BatchSend.aspx'
 
params={
      'CorpID' : 'ZLJK00123',#帐号, String
      'Pwd' : '659402',#密码, String
      'Mobile':'13641115243',#发送手机号码, String
      'Content':'last',#发送内容, String
      'Cell':'',#子号, String
      'SendTime':'' #定时发送时间, String(14)          
      } 
output_message={
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
def p_ws_post_api_request_sendSMS(SMS_SERVER_NAME, WS_INTERFACE, params={}):
    urlp = []
    for key in params.keys():
        urlp.append(key +'='+params[key])
        print key, params[key]
    urlp = '&'.join(urlp)    
    url = '%s%s?%s' % (SMS_SERVER_NAME, WS_INTERFACE, urlp)
    print url
    url = urllib.urlencode(url)
    res = urllib2.urlopen(url).read()
    return res 

def _ws_post_api_request_sendSMS(SMS_SERVER_NAME, WS_INTERFACE, params={}):
       
    url = '%s%s' % (SMS_SERVER_NAME, WS_INTERFACE)
    params = urllib.urlencode(params)
    request = urllib2.Request(url,params)
    res = urllib2.urlopen(request).read()
    return res 

def _post_api_request_sendSMS(params={}):
    params['CorpID'] = 'ZLJK00123'
    params['Pwd'] = '659402'
    params['Cell'] = ''
    params['SendTime'] = ''
    
    return _ws_post_api_request_sendSMS(SMS_SERVER_NAME, WS_BATCH_SEND, params) 
params={
        'Mobile':'13146073660',
        'Content':'汉字所dd撕碎 999了  的司机爱--哭 '.encode('gbk'),  
        }

print _post_api_request_sendSMS(params)









