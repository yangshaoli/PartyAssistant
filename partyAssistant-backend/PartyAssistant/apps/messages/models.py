#--*-- coding=utf-8
'''
Created on 2011-11-8

@author: liuxue
'''
from django.db import models
from django.contrib.auth.models import User
from apps.parties.models import Party
class EmailMessage(models.Model):
    subject = models.CharField(max_length=256)
    content = models.TextField()
    createtime = models.DateTimeField(auto_now_add=True)
    party = models.ForeignKey(Party)
    _isApplyTips = models.BooleanField()
    _isSendBySelf = models.BooleanField()
    
class SMSMessage(models.Model):
    content = models.TextField()
    createtime = models.DateTimeField(auto_now_add=True)
    party = models.ForeignKey(Party)
    _isApplyTips = models.BooleanField()
    _isSendBySelf = models.BooleanField()    