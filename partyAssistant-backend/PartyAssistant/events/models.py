#coding=utf-8
'''
Created on 2011-10-27

@author: liuxue
'''
from django.db import models
from django.core.urlresolvers import reverse
from django.contrib.auth.models import User

class Meeting(models.Model):
    start_time = models.DateTimeField()
    end_time = models.DateTimeField()
    address = models.CharField(max_length=256)
    remarks = models.TextField(blank=True)
    url = models.CharField('url', max_length=128)
    creater = models.ForeignKey(User)
    def __unicode__(self):
        return self.title
    
    def get_apply_url(self):
        return reverse('event_apply', args=[self.id])
    