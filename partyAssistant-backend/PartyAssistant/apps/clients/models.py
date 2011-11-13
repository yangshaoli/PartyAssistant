# -*- coding=utf-8 -*-

from django.db import models
from django.contrib.auth.models import User
from apps.parties.models import Party

APPLY_STATUS = (
    (u'已报名', u'已报名'),
    (u'未报名', u'未报名'),
    (u'不参加', u'不参加'),
)

INVITE_TYPE = (
    ('email', 'email'),
    ('phone', 'phone'),
    ('public', 'public'),
)

class Client(models.Model):
    name = models.CharField(max_length=32)
    phone = models.CharField(max_length=32, blank=True, null=True)
    email = models.EmailField(blank=True, null=True)
    
    creator = models.ForeignKey(User)
    invite_type = models.CharField(max_length=8, blank=True, choices=INVITE_TYPE)
    
    def __unicode__(self):
        return '%s (%s)' % (self.name, self.creator.username)
    
class PartiesClients(models.Model):
    client = models.ForeignKey(Client)
    party = models.ForeignKey(Party)
    apply_status = models.CharField(max_length=16, choices=APPLY_STATUS, default=u'未报名')
