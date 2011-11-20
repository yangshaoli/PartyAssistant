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

#获得报名/未相应/不参加的客户数
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
def change_apply_status(request):
    if request.method == 'GET':
        apply_status = request.GET['applystatus']
        client_party = PartiesClients.objects.get(pk=int(request.GET['party_client_id']))      
        client_party.apply_status = apply_status
        client_party.save()        
        party = client_party.party
        apply_status = request.GET['next']#当前的页面状态 即是 show_status状态
        if apply_status == 'all':
            party_clients_list = PartiesClients.objects.filter(party=party)
        else:        
            party_clients_list = PartiesClients.objects.filter(party=party).filter(apply_status=apply_status)
    
        return TemplateResponse(request,'clients/invite_list.html',{'party_clients_list':party_clients_list,'party':party,'applystatus':apply_status}) 


#受邀人员列表
@login_required
def invite_list(request, party_id):
    party = get_object_or_404(Party, id=party_id)
    party_clients_list = PartiesClients.objects.filter(party=party)
    
    party_clients = {
        'apply': {
            'is_new': False, 
            'client_count': 0
        }, 
        'noanswer': {
            'is_new': False, 
            'client_count': 0
        }, 
        'reject': {
            'is_new': False, 
            'client_count': 0
        }
    }
    
    for party_client in party_clients_list:
        if party_client.apply_status == 'apply':
            party_clients['apply']['client_count'] = party_clients['apply']['client_count'] + 1
            if party_client.is_new:
                party_clients['apply']['is_new'] = True
        elif party_client.apply_status == 'noanswer':
            party_clients['noanswer']['client_count'] = party_clients['noanswer']['client_count'] + 1
            if party_client.is_new:
                party_clients['noanswer']['is_new'] = True
        if party_client.apply_status == 'reject':
            party_clients['reject']['client_count'] = party_clients['reject']['client_count'] + 1
            if party_client.is_new:
                party_clients['reject']['is_new'] = True
    
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
            'name' : party_client.client.name, 
            'address': party.invite_type == 'email' and party_client.client.email or party_client.client.phone, 
            'is_new': party_client.is_new
        }    
        party_clients_data.append(party_client_data)
        
        if party_client.is_new:
            party_client.is_new = False
            party_client.save()
    
    return HttpResponse(simplejson.dumps(party_clients_data)) 
