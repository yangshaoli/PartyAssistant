#--*-- coding=utf-8
'''
Created on 2010-1-19

@author: liwenjian
'''

from django.core import mail
from settings import SYS_EMAIL_ADDRESS, DOMAIN_NAME
import hashlib
import logging

logger = logging.getLogger('airenao')

def send_emails(subject, content, from_address, to_list):
    connection = mail.get_connection()
    tmp_flag = True
    while tmp_flag:
        try:
            connection.open()
            tmp_flag = False
        except Exception:
            pass
    email1 = mail.EmailMessage(subject, content, from_address, to_list, connection = connection)
    email1.content_subtype = "html"
    email1.send()
    connection.close()

def send_email(outbox_message, message, party):
    subject = u'[爱热闹]您收到一个活动邀请'
    try:
        address_list = outbox_message.address.split(',')
        if message.is_apply_tips:
            for address in address_list:
                enroll_link = DOMAIN_NAME + '/parties/%d/enroll/?key=%s' % (party.id, hashlib.md5('%d:%s' % (party.id, address)).hexdigest())
                content = message.content
                content = content.replace('\n\r','<br />')
                content = content + u'\r\n快来报名：<a href="%s">%s</a>' % (enroll_link, enroll_link)
                send_emails(subject, content, SYS_EMAIL_ADDRESS, [address])
        else:
            send_emails(subject, message.content, 
                        SYS_EMAIL_ADDRESS, address_list)
    except:
        logger.exception('send email error!')
    finally:
        outbox_message.delete()

def send_binding_email(instance):
    email =  instance.binding_address
    key = instance.key
    subject = u'[爱热闹]确认帐号绑定邮件'
    content = u'尊敬的爱热闹用户，当您看到这封邮件时，说明您正在进行绑定邮箱的操作。 如果不是您自己进行的操作，请删除本邮件。<br/> 请点击以下链接绑定您的邮箱： %s/accounts/email_binding/?key=%s' % (DOMAIN_NAME, key)
    try:
        send_emails(subject, content, SYS_EMAIL_ADDRESS, [email])
    except:
        logger.exception('send sendsmsBingdingmessage error!')