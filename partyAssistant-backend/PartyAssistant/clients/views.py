# -*- coding=utf-8 -*-
'''
@summary: 报名处理，包括公开报名和邮件邀请报名
@author:chenyang
'''
from django.shortcuts import render_to_response, redirect, get_object_or_404
from django.contrib.auth.models import User
from django.core.urlresolvers import reverse
from django.template import RequestContext
from django.http import HttpResponse

from clients.models import Client, ClientParty
from parties.models import Party

def public_enroll(request, party_id):
    if request.method=='POST':
        #将用户加入clients,状态为'已报名'
        name = request.POST['name']
        email = request.POST['email']
        phone = request.POST['phone']
        if Client.objects.filter(email=email).count() == 0:
            client = Client.objects.create(name=name, email=email, phone=phone, invite_type='public')
            #TODO 
            ClientParty.objects.create(client=client, party=Party.objects.get(pk=party_id), apply_status=u'已报名') #在UserProfile中写入号码
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
        status = ClientParty.objects.get(client=client, party=party)
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

def change_apply_status(request):
    if request.method == 'POST':
        client_party = ClientParty.objects.get(pk=int(request.POST['id']))      
        client_party.apply_status = request.POST['apply_status']
        client_party.save()
        print client_party.apply_status
    return HttpResponse("OK")


#受邀人员列表
def invite_list(request,party_id):
#    if request.method == 'POST':
    party = get_object_or_404(Party, pk=int(party_id))
    client_party_list=ClientParty.objects.filter(party=party)
    #去除公共报名的人
    for i in range(len(client_party_list)):
        if client_party_list[i].client.invite_type == 'public':
            client_party_list.remove(i)
    return render_to_response('clients/invite_list.html',{'client_party_list':client_party_list}, context_instance=RequestContext(request)) 

#报名人员列表
def enrolled_list(request,party_id):
    party = get_object_or_404(Party, pk=int(party_id))
    client_party_list=ClientParty.objects.filter(party=party,apply_status=u'已报名')
    return render_to_response('clients/apply_list.html',{'client_party_list':client_party_list}, context_instance=RequestContext(request)) 

#未向应人员列表
def noenroll_list(request,party_id):
    party = get_object_or_404(Party, pk=int(party_id))
    client_party_list=ClientParty.objects.filter(party=party,apply_status=u'未报名')
    return render_to_response('clients/notresponse_list.html',{'client_party_list':client_party_list}, context_instance=RequestContext(request)) 

#未报名人员列表
def reject_list(request,party_id):
    party = get_object_or_404(Party, pk=int(party_id))
    client_party_list=ClientParty.objects.filter(party=party,apply_status=u'不参加')
    return render_to_response('clients/notapply_list.html',{'client_party_list':client_party_list}, context_instance=RequestContext(request)) 
