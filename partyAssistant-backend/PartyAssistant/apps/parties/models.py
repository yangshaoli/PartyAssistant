#coding=utf-8
'''
Created on 2011-10-27

@author: liuxue
'''
from apps.clients.models import Client
from django.contrib.auth.models import User
from django.db import models
import datetime

APPLY_STATUS = (
    (u'已报名', u'已报名'),
    (u'未报名', u'未报名'),
    (u'不参加', u'不参加'),
)

class Party(models.Model):
    creator = models.ForeignKey(User)
    start_time = models.DateTimeField()
    address = models.CharField(max_length=256, blank=True)
    description = models.TextField(blank=True)
    limit_count = models.IntegerField(max_length=3, default=0)
    
    clients = models.ManyToManyField(Client, through='PartiesClients')
    
    created_time = models.DateTimeField(auto_now_add=True)
    last_modified_time = models.DateTimeField(auto_now=True)
    
    def __unicode__(self):
        return '%s %s' % (self.description[:10], datetime.datetime.strftime(self.start_time, '%m-%d %H:%M'))

class PartiesClients(models.Model):
    client = models.ForeignKey(Client)
    party = models.ForeignKey(Party)
    apply_status = models.CharField(max_length=16, choices=APPLY_STATUS, default=u'未报名')
