#coding=utf-8
'''
Created on 2011-11-2

@author: liuxue
'''
from django.views.decorators.csrf import csrf_protect
from django.shortcuts import get_object_or_404,render_to_response
from django.template import RequestContext
from models import Client
from models import Client_Party
from parties.models import Party
from django.http import HttpResponse
#更改报名状态 url:/(?P<linkman_id>\d+)/$
#报名-->不报名
def apply2not(request,linkman_id):
    if request.method == 'POST':
        party_id = request.party_id #request 存放当前 的Party
        linkman_party_l=get_object_or_404(Client_Party,linkman_id=linkman_id,party_id=party_id)  
        linkman_party=linkman_party_l[0]
        linkman_party.apply_status=u'未报名'
    return 'ok'

@csrf_protect
def change_apply_status(request):
    if request.method == 'POST':
        client_party = Client_Party.objects.get(pk=int(request.POST['id']))      
        client_party.apply_status = request.POST['apply_status']
        client_party.save()
        print client_party.apply_status
    return HttpResponse("OK")

#不报名-->报名
def not2apply(request,linkman_id):
    pass
#未响应-->报名
def noresponse2apply(request,linkman_id):
    pass
#未响应-->不报名
def noresponse2not(request,linkman_id):
    pass
#受邀人员列表
def invite_list(request,party_id):
#    if request.method == 'POST':
    party = get_object_or_404(Party, pk=1)
    client_party_list=Client_Party.objects.filter(party=party)
    return render_to_response('clients/invite_list.html',{'client_party_list':client_party_list}, context_instance=RequestContext(request)) 

#报名人员列表
def apply_list(request):
    pass
#未向应人员列表
def notresponse_list(request):
    pass
#未报名人员列表
def notapply(request):
    pass

