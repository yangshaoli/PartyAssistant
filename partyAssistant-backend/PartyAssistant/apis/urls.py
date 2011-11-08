'''
Created on 2011-11-7

@author: liuxue
'''
from django.conf.urls.defaults import patterns, url

urlpatterns = patterns('',
    url(r'^parties/creatparty/$', 'apis.parties.views.createParty', name = 'createParty'),
    url(r'^parties/partylist/$', 'apis.parties.views.PartyList', name = 'PartyList'),

)
