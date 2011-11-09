'''
Created on 2011-11-7

@author: liuxue
'''
from django.conf.urls.defaults import patterns, url

urlpatterns = patterns('apis.parties.views',
    url(r'^parties/creatparty/$', 'createParty', name = 'createParty'),
    url(r'^parties/partylist/(?P<uid>\d+)/(?P<page>\d+)/$', 'PartyList', name = 'PartyList'),
    url(r'^parties/GetPartyMsg/(?P<pid>\d+)/$', 'GetPartyMsg', name = 'GetPartyMsg'),
)
