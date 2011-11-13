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


def public_enroll(request, party_id):
    if request.method=='POST':
        #将用户加入clients,状态为'已报名'
        name = request.POST['name']
        email = request.POST['email']
        phone = request.POST['phone']
        if Client.objects.filter(email=email).count() == 0:
            client = Client.objects.create(name=name, email=email, phone=phone, invite_type='public')
            #TODO 
            PartiesClients.objects.create(client=client, party=Party.objects.get(pk=party_id), apply_status=u'已报名') #在UserProfile中写入号码
            return render_to_response('message.html', {'message':u'报名成功'}, context_instance=RequestContext(request))
        else:
            return render_to_response('message.html', {'message':u'您已经报名了'}, context_instance=RequestContext(request))
        
    else:
        party = Party.objects.get(id=party_id)
        ctx = {
               'party' : party
        }    
        return render_to_response('clients/web_enroll.html', ctx, context_instance=RequestContext(request))

def invite_enroll(request, email, party_id):
    if request.method=='POST':
        client = Client.objects.get(email=email)
        party = Party.objects.get(pk=party_id)
        status = PartiesClients.objects.get(client=client, party=party)
        if request.POST['action'] == 'yes': #如果点击参加
            status.apply_status = u'已报名'
            status.save()
            return render_to_response('message.html', {'message':u'报名成功'}, context_instance=RequestContext(request))
        else:
            status.apply_status = u'不参加'
            status.save()
            return render_to_response('message.html', {'message':u'您已经拒绝了这次邀请'}, context_instance=RequestContext(request))

    else:
        party = Party.objects.get(id=party_id)
        client = Client.objects.get(email=email,creator=party.creator)
        ctx = {
               'client': client,
               'party' : party
        } 
        return render_to_response('clients/web_enroll.html', ctx, context_instance=RequestContext(request))

'''
@author: liuxue
'''

def change_apply_status(request,party_client_id):
    if request.method == 'GET':
        client_party = PartiesClients.objects.get(pk=party_client_id)      
        client_party.apply_status = request.GET['applystatus']
        client_party.save()
        return invite_list(request,client_party.party.id,request.GET['next'])    
    return invite_list(client_party.party.id,'all')


#受邀人员列表
def invite_list(request,party_id,invite_type):
    party = Party.objects.get(id=party_id)
    if invite_type == 'all':
        party_clients_list = PartiesClients.objects.filter(party=party)
    else:        
        party_clients_list = PartiesClients.objects.filter(party=party).filter(invite_type=invite_type)
    
    return TemplateResponse(request,'clients/invite_list.html',{'party_clients_list':party_clients_list,'party':party}) 
















