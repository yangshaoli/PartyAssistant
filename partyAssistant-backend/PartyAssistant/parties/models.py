#coding=utf-8
'''
Created on 2011-10-27

@author: liuxue
'''
from django.db import models
from django.core.urlresolvers import reverse
from django.contrib.auth.models import User

class Party(models.Model):
    start_time = models.DateTimeField()
    end_time = models.DateTimeField(blank = True)
    address = models.CharField(max_length=256)
    description = models.TextField(blank=True)
    creator = models.ForeignKey(User)
    limit_num = models.IntegerField(max_length=3)
    created_time = models.DateTimeField(auto_now_add = True)
    def __unicode__(self):
        return self.id
    
    def get_apply_url(self):
        return reverse('event_apply', args=[self.id])
    