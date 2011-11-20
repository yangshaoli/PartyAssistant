#--*-- coding=utf-8
'''
Created on 2010-1-19

@author: liwenjian
'''

from django.conf import settings
from django.core import mail
from settings import SYS_EMAIL_ADDRESS, DOMAIN_NAME
import hashlib
import logging
import re
import urllib
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


def send_email(outbox_message):
    subject = u'[PartyAssistant]您收到一个活动邀请'
    try:
        party = outbox_message.base_message.party
        address_list = outbox_message.address.split(',')
        if outbox_message.is_apply_tips:
            party = outbox_message.base_message.party
            content = outbox_message.base_message.get_subclass_obj().content
            for address in address_list:
                enroll_link = DOMAIN_NAME + '/parties/%d/enroll/?key=%s' % (party.id, hashlib.md5('%d:%s' % (party.id, address)).hexdigest())
                content = '%s\n\r\n\r点击进入报名页面：<a href="%s">%s</a>' % (content, enroll_link, enroll_link)
                send_emails(subject, content, SYS_EMAIL_ADDRESS, [address])
        else:
            send_emails(subject, outbox_message.base_message.get_subclass_obj().content, 
                        SYS_EMAIL_ADDRESS, address_list)
    except:
        logger.exception('send email error!')
    finally:
        outbox_message.delete()
