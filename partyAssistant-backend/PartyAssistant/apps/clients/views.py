# -*- coding=utf-8 -*-
'''
@summary: 报名处理，包括公开报名和邮件邀请报名
@author:chenyang
'''
from django.http import HttpResponse
from django.shortcuts import get_object_or_404
from django.template.response import TemplateResponse
from django.utils import simplejson
from django.contrib.auth.decorators import login_required

from apps.parties.models import Party, PartiesClients
from apps.clients.models import Client


##获得报名/未响应/不参加的客户数
#def get_client_sum(party_id):
#    party = Party.objects.get(id = party_id)
#    client_sum = {
#        'apply':PartiesClients.objects.filter(party = party).filter(apply_status = 'apply').count(),
#        'noanswer':PartiesClients.objects.filter(party = party).filter(apply_status = 'noanswer').count(),
#        'reject':PartiesClients.objects.filter(party = party).filter(apply_status = 'reject').count(),
#    }
#    return client_sum


'''
@author: liuxue
'''
@login_required
def change_apply_status(request, id, applystatus):
    client_party = PartiesClients.objects.get(pk = id, creator = request.user)
    client_party.apply_status = applystatus
    client_party.save()        
    return HttpResponse('ok') 


#受邀人员列表
@login_required
def invite_list(request, party_id):
    party = get_object_or_404(Party, id = party_id, creator = request.user)
    party_clients_list = PartiesClients.objects.filter(party = party)
    
    party_clients = {
        'apply': {
            'is_check': True,
            'client_count': 0
        },
        'noanswer': {
            'is_check': True,
            'client_count': 0
        },
        'reject': {
            'is_check': True,
            'client_count': 0
        }
    }
    
    for party_client in party_clients_list:
        if party_client.apply_status == 'apply':
            party_clients['apply']['client_count'] = party_clients['apply']['client_count'] + 1
            if not party_client.is_check:
                party_clients['apply']['is_check'] = False
        elif party_client.apply_status == 'noanswer':
            party_clients['noanswer']['client_count'] = party_clients['noanswer']['client_count'] + 1
            if not party_client.is_check:
                party_clients['noanswer']['is_check'] = False
        if party_client.apply_status == 'reject':
            party_clients['reject']['client_count'] = party_clients['reject']['client_count'] + 1
            if not party_client.is_check:
                party_clients['reject']['is_check'] = False
    
    return TemplateResponse(request, 'clients/invite_list.html', {'party': party, 'party_clients': party_clients}) 

