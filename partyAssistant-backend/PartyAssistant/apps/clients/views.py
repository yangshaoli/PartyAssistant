# -*- coding=utf-8 -*-
'''
@summary: 报名处理，包括公开报名和邮件邀请报名
@author:chenyang
'''
from apps.parties.models import Party, PartiesClients
from django.http import HttpResponse
from django.shortcuts import get_object_or_404
from django.template.response import TemplateResponse
from django.utils import simplejson
from django.contrib.auth.decorators import login_required

#获得报名/未响应/不参加的客户数
@login_required
def get_client_sum(party_id):
    party = Party.objects.get(id=party_id)
    client_sum = {
        'apply':PartiesClients.objects.filter(party=party).filter(apply_status='apply').count(),
        'noanswer':PartiesClients.objects.filter(party=party).filter(apply_status='noanswer').count(),
        'reject':PartiesClients.objects.filter(party=party).filter(apply_status='reject').count(),
    }
    return client_sum


'''
@author: liuxue
'''
@login_required
def change_apply_status(request, id, applystatus):
    client_party = PartiesClients.objects.get(pk=id)      
    client_party.apply_status = applystatus
    client_party.save()        

    return HttpResponse('ok') 


#受邀人员列表
@login_required
def invite_list(request, party_id):
    party = get_object_or_404(Party, id=party_id)
    party_clients_list = PartiesClients.objects.filter(party=party)
    
    party_clients = {
        'apply': {
            'is_check': False, 
            'client_count': 0
        }, 
        'noanswer': {
            'is_check': False, 
            'client_count': 0
        }, 
        'reject': {
            'is_check': False, 
            'client_count': 0
        }
    }
    
    for party_client in party_clients_list:
        if party_client.apply_status == 'apply':
            party_clients['apply']['client_count'] = party_clients['apply']['client_count'] + 1
            if party_client.is_check:
                party_clients['apply']['is_check'] = True
        elif party_client.apply_status == 'noanswer':
            party_clients['noanswer']['client_count'] = party_clients['noanswer']['client_count'] + 1
            if party_client.is_check:
                party_clients['noanswer']['is_check'] = True
        if party_client.apply_status == 'reject':
            party_clients['reject']['client_count'] = party_clients['reject']['client_count'] + 1
            if party_client.is_check:
                party_clients['reject']['is_check'] = True
    
    return TemplateResponse(request,'clients/invite_list.html', {'party': party, 'party_clients': party_clients}) 

@login_required
def invite_list_ajax(request, party_id):
    apply_status = request.GET.get('apply', 'all')
    party = get_object_or_404(Party, id=party_id)
    
    if apply_status == 'all':
        party_clients_list = PartiesClients.objects.select_related('client').filter(party=party)
    else:
        party_clients_list = PartiesClients.objects.select_related('client').filter(party=party).filter(apply_status=apply_status)
    
    party_clients_data = []
    for party_client in party_clients_list:
        party_client_data = {
            'id' : party_client.id,
            'name' : party_client.client.name, 
            'address': party.invite_type == 'email' and party_client.client.email or party_client.client.phone, 
            'is_check': party_client.is_check
        }    
        party_clients_data.append(party_client_data)
        
        if not party_client.is_check:
            party_client.is_check = True
            party_client.save()
    
    return HttpResponse(simplejson.dumps(party_clients_data))
