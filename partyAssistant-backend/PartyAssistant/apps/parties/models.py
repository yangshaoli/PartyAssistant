#coding=utf-8
'''
Created on 2011-10-27

@author: liuxue
'''
from apps.clients.models import Client
from django.contrib.auth.models import User
from django.db import models
from django.db.models import signals
import datetime
import hashlib

APPLY_STATUS = (
    ('apply', 'apply'),
    ('noanswer', 'noanswer'),
    ('reject', 'reject'),
)

INVITE_TYPE = (
    ('email', 'email'),
    ('phone', 'phone')
)

class Party(models.Model):
    creator = models.ForeignKey(User)
    start_date = models.DateField(blank=True, null=True)
    start_time = models.TimeField(blank=True, null=True)
    address = models.CharField(max_length=256, blank=True)
    description = models.TextField()
    limit_count = models.IntegerField(max_length=3, default=0,blank=True)
    
    clients = models.ManyToManyField(Client, through='PartiesClients')
    
    created_time = models.DateTimeField(auto_now_add=True)
    last_modified_time = models.DateTimeField(auto_now=True)
    invite_type = models.CharField(max_length=8, blank=True, null=True, choices=INVITE_TYPE)
    
    def __unicode__(self):
        return '%s %s' % (self.description[:10], datetime.datetime.strftime(self.start_time, '%m-%d %H:%M'))

class PartiesClients(models.Model):
    client = models.ForeignKey(Client)
    party = models.ForeignKey(Party)
    apply_status = models.CharField(max_length=16, choices=APPLY_STATUS, default='noanswer')
    is_check = models.BooleanField(default=True)
    invite_key = models.CharField(max_length=32)

def update_invite_key(sender=None, instance=None, **kwargs):
    party = instance.party
    if party.invite_type == 'email':
        instance.invite_key = hashlib.md5('%d:%s' % (party.id, instance.client.email)).hexdigest()
    else:
        instance.invite_key = hashlib.md5('%d:%s' % (party.id, instance.client.phone)).hexdigest()
    
signals.pre_save.connect(update_invite_key, sender=PartiesClients)
