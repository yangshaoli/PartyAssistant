'''
Created on 2011-11-7

@author: liuxue
'''
from django.conf.urls.defaults import patterns, url

urlpatterns = patterns('apis.parties.views',
    url(r'^createparty/$', 'createParty', name = 'createParty'),
    url(r'^editparty/$', 'editParty', name = 'editParty'),
    url(r'^partylist/(?P<uid>\d+)/(?P<page>\d+)/$', 'PartyList', name = 'PartyList'),
    url(r'^get_party_msg/(?P<pid>\d+)/$', 'GetPartyMsg', name = 'GetPartyMsg'),
    url(r'^get_party_client_main_count/(?P<pid>\d+)/$', 'GetPartyClientMainCount', name = 'GetPartyClientMainCount'),
    url(r'^get_party_client_seperated_list/(?P<pid>\d+)/(?P<type>\w+)/$', 'GetPartyClientSeperatedList', name = 'GetPartyClientSeperatedList'),
    url(r'^change_client_status/$', 'ChangeClientStatus', name = 'ChangeClientStatus'),
    url(r'^resendmsg/$', 'resendMsg', name = 'resendMsg'),
)
