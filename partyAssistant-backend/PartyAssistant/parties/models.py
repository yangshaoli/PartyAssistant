#coding=utf-8
'''
Created on 2011-10-27

@author: liuxue
'''
from django.db import models
from django.contrib.auth.models import User

class Party(models.Model):
    time = models.DateTimeField()
    address = models.CharField(max_length=256,blank=True)
    description = models.TextField(blank=True)
    creator = models.ForeignKey(User)
    limit_num = models.IntegerField(max_length=3)
   
    
    