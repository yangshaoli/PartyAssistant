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
                content = content.replace('\n\r', '<br />')
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
    email = instance.binding_address
    key = instance.key
    subject = u'【爱热闹】帐号绑定确认邮件'
    link = '%s/accounts/email_handle_url/binding/?key=%s' % (DOMAIN_NAME, key)
    content = u'尊敬的爱热闹用户，当您看到这封邮件时，说明您正在进行绑定邮箱的操作。 如果不是您自己进行的操作，请删除本邮件。<br/> 请点击以下链接绑定您的邮箱： <a href="%s" > %s </a>' % (link, link)
    try:
        send_emails(subject, content, SYS_EMAIL_ADDRESS, [email])
    except:
        logger.exception('send sendEmailBingdingmessage error!')

def send_unbinding_email(instance):
    email = instance.binding_address
    key = instance.key
    subject = u'【爱热闹】帐号解除绑定确认邮件'
    link = '%s/accounts/email_handle_url/unbinding/?key=%s' % (DOMAIN_NAME, key)
    content = u'尊敬的爱热闹用户，当您看到这封邮件时，说明您正在进行解除绑定邮箱的操作。 如果不是您自己进行的操作，请删除本邮件。<br/> 请点击以下链接绑定您的邮箱： <a href="%s" > %s </a>' % (link, link)
    try:
        send_emails(subject, content, SYS_EMAIL_ADDRESS, [email])
    except:
        logger.exception('send sendEmailBingdingmessage error!')


def send_forget_pwd_email(instance):
    email = instance.user.userprofile.email
    key = instance.temp_password
    subject = u'【爱热闹】找回密码'
    content = u'尊敬的爱热闹用户，<br> 您的临时密码为: <br> <p style="font-size:22px;">%s</p> <br> 该密码只能使用一次，请尽快登陆我们的应用/网站(<a href="http://www.airenao.com/">http://www.airenao.com</a>)，并修改您的密码。<br>祝您使用愉快<br>爱热闹开发团队' % key
    try:
        send_emails(subject, content, SYS_EMAIL_ADDRESS, [email])
    except:
        logger.exception('send temp password error! username:%s', instance.user.username)

def send_apply_confirm_email(party_client):
    party = party_client.party
    client = party_client.client
#    尊敬的xxx，您刚刚报名参加了xxx发布的活动，请点击以下链查看该活动：
#     http://www.airenao.com/accounts/email_handle_url/binding/?key=3e328929d2bef50cd2c8e0b626c639d7
    content = u'尊敬的' + client.name=='' and client.email or client.name + u'，您刚刚报名参加了' + party.creator.username + u'发布的活动，请点击以下链查看该活动：'
    enroll_link = DOMAIN_NAME + '/parties/%d/enroll/?key=%s' % (party.id, hashlib.md5('%d:%s' % (party.id, client.email)).hexdigest())
    content = content + u'\r\n快来报名：<a href="%s">%s</a>' % (enroll_link, enroll_link)
    subject = u'【爱热闹】报名提醒邮件'
    email = client.email
    try:
        send_emails(subject, content, SYS_EMAIL_ADDRESS, [email])
    except:
        logger.exception('send send_apply_confirm_email error!')