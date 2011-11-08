'''
Created on 2011-11-7

@author: liuxue
'''
from django.conf.urls.defaults import patterns, url, include

urlpatterns = patterns('',
#    url(r'^accounts/', include('apis.accounts.urls')),
#    url(r'^clients/', include('apis.clients.urls')),
    url(r'^parties/', include('apis.parties.urls')),
)
