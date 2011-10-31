#coding=utf-8
'''
Created on 2011-10-27

@author: liuxue
'''
from django.db import models
from django.core.urlresolvers import reverse
from django.contrib.auth.models import User

class Meeting(models.Model):
    title = models.CharField('title', max_length=256)
    start_time = models.DateTimeField()
    end_time = models.DateTimeField()
    address = models.CharField(max_length=256)
    remarks = models.TextField(blank=True)
    url = models.CharField('url', max_length=128)
    created_time = models.DateTimeField(auto_now_add=True)
    last_modified_time = models.DateTimeField(auto_now=True)
    sender_name = models.CharField(max_length=256, blank=True)
    creater = models.ForeignKey(User)
    def __unicode__(self):
        return self.title
    
    def get_apply_url(self):
        return reverse('event_apply', args=[self.id])
    
class UserProfile(models.Model):
    user = models.OneToOneField(User)
    password = models.CharField(max_length = 16, blank = True)
    first_login = models.BooleanField(default = True)
    
    def __unicode__(self):
        return self.user.username
