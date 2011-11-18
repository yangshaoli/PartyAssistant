# -*- coding=utf-8 -*-
'''
@summary: 报名处理，包括公开报名和邮件邀请报名
@author:chenyang
'''
from apps.clients.models import Client
from apps.parties.models import Party, PartiesClients
from django.contrib.auth.models import User
from django.core.urlresolvers import reverse
from django.http import HttpResponse
from django.shortcuts import render_to_response, redirect, get_object_or_404
from django.template import RequestContext
from django.template.response import TemplateResponse
from django.utils import simplejson

#获得报名/未相应/不参加的客户数
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
def invite_list(request, party_id):
    apply_status = request.GET.get('apply', 'all')
    party = Party.objects.get(id=party_id)
    party_clients_list=[]
    if apply_status == 'all':
        party_clients_list = PartiesClients.objects.filter(party=party)
    else:        
        party_clients_list = PartiesClients.objects.filter(party=party).filter(apply_status=apply_status)
    
    #为party_clients添加isnew属性
    is_new = False
    for party_clinet in party_clients_list:
        if party_clinet.is_see_over:
            party_clinet.is_see_over = False
            party_clinet.save()
            party_clinet.isnew = True
            is_new = True
        else:
            party_clinet.isnew = False    
    ctx = {
        'is_new':is_new,   
        'party_clients_list':party_clients_list,
        'party':party,
        'applystatus':apply_status,
        'client_sum':get_client_sum(party_id)
    }
    
    return TemplateResponse(request,'clients/invite_list.html',ctx) 


def invite_list_ajax(request, party_id):
    apply_status = request.GET.get('apply', 'all')
    party = Party.objects.get(id=party_id)
    party_clients_list = []
    party_clients_list_ajax = []
    if apply_status == 'all':
        party_clients_list = PartiesClients.objects.filter(party=party)
    else:        
        party_clients_list = PartiesClients.objects.filter(party=party).filter(apply_status=apply_status)
    
    if party.invite_type == 'email':
        for party_clinet in party_clients_list:
            party_client_ajax = {
                                  'name' : '',
                                  'address':''
                                }    
            party_client_ajax['name'] = party_clinet.client.name
            party_client_ajax['address'] = party_clinet.client.email
            party_clients_list_ajax.append(party_client_ajax)
    elif party.invite_type == 'phone':
        for party_clinet in party_clients_list:
            party_client_ajax = {
                                 'name' : '',
                                 'address':''
                                }   
            party_client_ajax['name'] = party_clinet.client.name
            party_client_ajax['address'] = party_clinet.client.phone
            party_clients_list_ajax.append(party_client_ajax)
    else:
        pass  
              
    returnjson = {
                  'party_clients_list_ajax':party_clients_list_ajax                           
                 }
    returnjson = simplejson.dumps(returnjson)       
    return HttpResponse(returnjson) 
