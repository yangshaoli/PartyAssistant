'''
Created on 2011-11-7

@author: liuxue
'''
from django.conf.urls.defaults import patterns, url

urlpatterns = patterns('apis.accounts.views',
    url(r'^login/$', 'accountLogin', name = 'accountLogin'),
    url(r'^regist/$', 'accountRegist', name = 'accountRegist'),
    url(r'^logout/$', 'accountLogout', name = 'accountLogout'),
)