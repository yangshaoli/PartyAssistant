#coding=utf-8
from django.shortcuts import render_to_response, redirect, get_object_or_404
from django.contrib.auth.models import User
from django.core.urlresolvers import reverse
from django.template import RequestContext

from clients.models import Client, ClientParty
from parties.models import Party

def public_enroll(request, party_id):
    if request.method=='POST':
        if request.POST['action'] == 'yes':
            #将用户加入clients,状态为'已报名'
            email = request.POST['email']
            phone = request.POST['phone']
            if Client.objects.filter(email=email).count() == 0:
                client = Client.objects.create(email=email, phone=phone, creator=User.objects.get(pk=Party.objects.get(id=party_id).creator_id))
                ClientParty.objects.create(client=client, party=Party.objects.get(pk=party_id), apply_status=u'已报名') #在UserProfile中写入号码
                return render_to_response('message.html', {'message':u'报名成功'}, context_instance=RequestContext(request))
            else:
                return render_to_response('message.html', {'message':u'您已经报名了'}, context_instance=RequestContext(request))
        else:
            
            ClientParty.objects.create(client=client, party=Party.objects.get(pk=party_id), apply_status=u'已报名') #在UserProfile中写入号码
            return render_to_response('message.html', {'message':u'您已经拒绝了这次邀请'}, context_instance=RequestContext(request))
    else:
        party = Party.objects.get(id=party_id)
        ctx = {
               'party' : party
        }    
        return render_to_response('clients/web_enroll.html', ctx, context_instance=RequestContext(request))

def invite_enroll(request, email, party_id):
    if request.method=='POST':
        pass
    else:
        party = Party.objects.get(id=party_id)
        client = Client.objects.get(email=email)
        ctx = {
               'client': client,
               'party' : party
        } 
        return render_to_response('clients/web_enroll.html', ctx, context_instance=RequestContext(request))
