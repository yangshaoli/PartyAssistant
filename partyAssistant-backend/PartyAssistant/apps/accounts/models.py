#coding=utf-8
from django.db import models
from django.contrib.auth.models import User

ACCOUNT_TYPE_CHOICES = (
               (u'管理员', u'管理员'),
               (u'临时账户', u'临时账户'),
               (u'子账户', u'子账户'),
               )

ACTION_CHOICES = (
                  (u'新建账户', u'新建账户'),
                  (u'转正账户', u'转正账户'),
                  (u'密码找回', u'密码找回'),
                  )

class UserProfile(models.Model):
    user = models.OneToOneField(User)
    password = models.CharField(max_length=16, blank=True)
    account_type = models.CharField(max_length=16, choices=ACCOUNT_TYPE_CHOICES)
    first_login = models.BooleanField(default=True)
    phone = models.IntegerField(null=True, blank=True)
    
    def __unicode__(self):
        return self.user.username
