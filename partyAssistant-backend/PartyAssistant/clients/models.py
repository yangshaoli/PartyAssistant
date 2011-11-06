#coding=utf-8
'''
Created on 2011-11-2

@author: liuxue
'''
from django.db import models
from parties.models import Party
class Client(models.Model):
    name = models.CharField(max_length = 15)
    mobilephone = models.CharField(max_length = 15)
    email = models.EmailField()
    
class ClientProfile(models.Model): 
    client = models.OneToOneField(Client)
    
    
class ClientParty(models.Model):
    client = models.ForeignKey(Client)
    party   = models.ForeignKey(Party)
    apply_status = models.CharField(max_length = 15)
    