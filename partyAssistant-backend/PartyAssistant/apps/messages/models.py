#--*-- coding=utf-8
'''
Created on 2011-11-8

@author: liuxue
'''
from apps.parties.models import Party
from django.db import models
import datetime

class EmailMessage(models.Model):
    party = models.ForeignKey(Party)
    subject = models.TextField()
    content = models.TextField()
    is_apply_tips = models.BooleanField(default=True)
    
    last_modified_time = models.DateTimeField(auto_now=True)
    
    def __unicode__(self):
        return '%s %s' % (self.party.description[:10], datetime.datetime.strftime(self.party.start_time, '%m-%d %H:%M'))
    
class SMSMessage(models.Model):
    content = models.TextField()
    createtime = models.DateTimeField(auto_now_add=True)
    party = models.ForeignKey(Party)
    _isApplyTips = models.BooleanField()
    _isSendBySelf = models.BooleanField()    