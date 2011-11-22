'''
Created on 2011-11-21

@author: liwenjian
'''
from django.db import models

class ShortLink(models.Model):
    short_link = models.CharField(max_length=32)
    long_link = models.CharField(max_length=256)

    def __unicode__(self):
        return self.short_link
