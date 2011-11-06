#coding=utf-8
'''
Created on 2011-11-2

@author: liuxue
'''
from django.views.decorators.csrf import csrf_protect
from django.shortcuts import get_object_or_404,render_to_response
from django.template import RequestContext
from models import ClientParty
from parties.models import Party
from django.http import HttpResponse
#更改报名状态 url:/(?P<linkman_id>\d+)/$

@csrf_protect
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
    return render_to_response('clients/invite_list.html',{'client_party_list':client_party_list}, context_instance=RequestContext(request)) 

#报名人员列表
def apply_list(request,party_id):
    party = get_object_or_404(Party, pk=int(party_id))
    client_party_list=ClientParty.objects.filter(party=party,apply_status=u'报名')
    return render_to_response('clients/apply_list.html',{'client_party_list':client_party_list}, context_instance=RequestContext(request)) 

#未向应人员列表
def notresponse_list(request,party_id):
    party = get_object_or_404(Party, pk=int(party_id))
    client_party_list=ClientParty.objects.filter(party=party,apply_status=u'未响应')
    return render_to_response('clients/notresponse_list.html',{'client_party_list':client_party_list}, context_instance=RequestContext(request)) 

#未报名人员列表
def notapply_list(request,party_id):
    party = get_object_or_404(Party, pk=int(party_id))
    client_party_list=ClientParty.objects.filter(party=party,apply_status=u'未报名')
    return render_to_response('clients/notapply_list.html',{'client_party_list':client_party_list}, context_instance=RequestContext(request)) 

