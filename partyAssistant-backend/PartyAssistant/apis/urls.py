'''
Created on 2011-11-7

@author: liuxue
'''
from django.conf.urls.defaults import patterns, url

urlpatterns = patterns('',
    url(r'^parties/creatparty/$', 'parties.views.createPart', name = 'createParty'),
    url(r'^parties/partylist/(?P<uid>\d+)/(?P<page>\d+)/$', 'parties.views.PartList', name = 'PartyList'),

)