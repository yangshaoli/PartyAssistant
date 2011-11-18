#--*-- coding=utf-8
'''
Created on 2010-1-19

@author: liwenjian
'''

from django.conf import settings
from django.core import mail
import re, urllib
from settings import SYS_EMAIL_ADDRESS
import logging
logger = logging.getLogger('airenao')
email_re = re.compile(
    r"(^[-!#$%&'*+/=?^_`{}|~0-9A-Z]+(\.[-!#$%&'*+/=?^_`{}|~0-9A-Z]+)*"  # dot-atom
    r'|^"([\001-\010\013\014\016-\037!#-\[\]-\177]|\\[\001-011\013\014\016-\177])*"' # quoted-string
    r')@(?:[A-Z0-9](?:[A-Z0-9-]{0,61}[A-Z0-9])?\.)+[A-Z]{2,6}\.?$', re.IGNORECASE)  # domain

error_re = re.compile('Invalid Parameter')
def send_emails(subject, content, from_address, to_list):
    connection = mail.get_connection()
    tmp_flag = True
    while tmp_flag:
        try:
            a = connection.open()
            tmp_flag = False
        except Exception:
            pass
    email1 = mail.EmailMessage(subject, content, from_address, to_list, connection = connection)
    email1.content_subtype = "html"
    m = email1.send()
    connection.close()
    
def get_str(s):
    try:
        return s.encode('gb2312', 'ignore')
    except:
        try:
            return s.decode('utf8').encode('gb2312', 'ignore')
        except:
            return s
        
def send_sms(content, to_num):
    url = 'http://www.xunsai.net:8000/'
    data_dict = {'user' : settings.SMS_ISP_USERNAME,
                 'password' : settings.SMS_ISP_PASSWORD,
                 'phonenumber' : to_num,
                 'text' : content,
                 'charset' : 'utf-8'}

    conn = urllib.urlopen(url, urllib.urlencode(data_dict))
    file_content = conn.read()


def send_email(instance):
    subject = u'[PartyAssistant]您收到一个活动邀请'
    try:
        send_emails(subject, instance.base_message.get_subclass_obj().content, SYS_EMAIL_ADDRESS, instance.address)
    except Exception, ex: 
        new_e = Exception()
        new_e.error_msg = str(ex)
        logger.error('Email send')
    finally:
        message = instance
        message.delete()