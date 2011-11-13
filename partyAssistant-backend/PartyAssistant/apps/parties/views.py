#coding=utf-8
'''
Created on 2011-10-27

@author: liuxue
'''

from models import Party
from django.shortcuts import render_to_response, redirect, get_object_or_404
from django.core.urlresolvers import reverse
from django.contrib.auth.models import User
from django.template import RequestContext

from forms import CreatePartyForm, InviteForm
from utils.tools.email_tool import send_emails
from settings import SYS_EMAIL_ADDRESS, DOMAIN_NAME
from apps.clients.models import Client, ClientParty

import datetime
from django.contrib.auth.decorators import login_required

def create_party(request):            
    if request.method=='POST':
        form = CreatePartyForm(request.POST)
        if form.is_valid():        
            time = form.cleaned_data['time']
            address=form.cleaned_data['address']
            description=form.cleaned_data['description']  
            limit_num = form.cleaned_data['limit_num']   
            party = Party.objects.create(
                           time=time,
                           address=address,
                           description=description,                           
                           creator=request.user,
                           limit_num=limit_num                                  
                           );
            #判断用户选择的通知方式
            if request.POST['invite_type'] == 'email':
                return redirect(reverse('email_invite', args=[party.id]))
            else: #如果用户选择短信通知
                return redirect(reverse('message_invite'))
        else:
            return render_to_response('parties/create_party.html',{'form':form}, context_instance=RequestContext(request)) 
    else:
        form = CreatePartyForm()
        return render_to_response('parties/create_party.html',{'form':form}, context_instance=RequestContext(request))


def delete_party(request,party_id):
    party=get_object_or_404(Party,pk=party_id)
    clientpartylist = ClientParty.objects.filter(party=party)
    for clientparty in clientpartylist:
        ClientParty.delete(clientparty)
    Party.delete(party)
    return list_party(request)
def delete_party_notice(request,party_id):
    party = get_object_or_404(Party,pk=party_id)
    clientparty_list = ClientParty.objects.filter(party=party)
    for clientparty in clientparty_list:
        client = clientparty.client
        if client.invite_type == 'email':
            title=u'活动取消通知'
            content=u'尊敬的 '+client.name+' :'+' 于'+party.time.strftime('%Y-%m-%d %H:%M')+' 在'+party.address+'的活动取消'
            send_emails(title,content,SYS_EMAIL_ADDRESS,[client.email])
        if client.invite_type == 'phone':
            content=u'尊敬的 '+client.name+' :'+' 于'+party.time.strftime('%Y-%m-%d %H:%M')+' 在'+party.address+'的活动取消'
            print '发送短信 '  
            print content   
    return delete_party(request,party_id) 

def copy_party(request,party_id):#复制party和联系人
    if request.method == 'GET':
        old_party = Party.objects.get(pk=int(party_id))        
        date = datetime.datetime.strftime(old_party.time,'%Y-%m-%d')
        time = datetime.datetime.strftime(old_party.time,'%H:%M:%S')
        return render_to_response('parties/copy_party.html',{'old_party':old_party,'date':date,'time':time,'form':CreatePartyForm()},context_instance=RequestContext(request))
    else :
        old_party = Party.objects.get(pk=int(party_id))
        form = CreatePartyForm(request.POST)
        if form.is_valid():        
            time = form.cleaned_data['time']
            address=form.cleaned_data['address']
            description=form.cleaned_data['description']  
            limit_num = form.cleaned_data['limit_num']   
            new_party=Party.objects.create(
                           time=time,
                           address=address,
                           description=description,                           
                           creator=request.user,
                           limit_num=limit_num                                  
                           );
            #复制联系人
            client_party_list = ClientParty.objects.filter(party=old_party) 
            for client_party in client_party_list:
                ClientParty.objects.create(
                                            client =client_party.client,
                                            party=new_party,
                                            apply_status=u'被邀请'
                                            )       
            return list_party(request)
        else:
            return render_to_response('parties/copy_party.html',{'form':form,'old_party':old_party}, context_instance=RequestContext(request)) 
    

def edit_party(request,party_id):
    if request.method=='GET':
        party = Party.objects.get(pk=party_id)
        date = datetime.datetime.strftime(party.time,'%Y-%m-%d')
        time = datetime.datetime.strftime(party.time,'%H:%M')
        form = CreatePartyForm()
        return render_to_response('parties/edit_party.html',{'form':form,'party':party,'date':date,'time':time}, context_instance=RequestContext(request));
    else :
        party = Party.objects.get(pk=party_id)
        form = CreatePartyForm(request.POST)
        date = datetime.datetime.strftime(party.time,'%Y-%m-%d')
        time = datetime.datetime.strftime(party.time,'%H:%M:%S')
        if form.is_valid():        
            party.time = form.cleaned_data['time']
            party.address=form.cleaned_data['address']
            party.description=form.cleaned_data['description']  
            party.limit_num = form.cleaned_data['limit_num']     
            party.save()          
            return list_party(request)
        else:
            return render_to_response('parties/edit_party.html',{'form':form,'party':party}, context_instance=RequestContext(request));

'''
@summary: 处理短信邀请和邮件邀请
@author: chenyang
'''
def message_invite(request):
    form = InviteForm()
    return render_to_response('parties/invite.html',{'form':form, 'title':u'发送短信通知'}, context_instance=RequestContext(request))

def email_invite(request, party_id):
    email_subject = u'[PartyAssistant]您收到一个活动邀请'
    party = Party.objects.get(pk=party_id)
    if request.method=='POST':
        form = InviteForm(request.POST)
        if form.is_valid():
            addressees = form.cleaned_data['addressee']
            content = form.cleaned_data['content']
            for addressee in addressees.split(','):
                if addressee:
                #如果带报名提示，则内容中带上报名链接
                    if request.POST['enroll_link']:
                        enroll_link = DOMAIN_NAME+'/clients/invite_enroll/'+addressee+'/'+party_id
                        content = content + u'点击进入报名页面：<a href="%s">%s</a>' % (enroll_link, enroll_link)
                    send_emails(email_subject, content, SYS_EMAIL_ADDRESS, [addressee])
                    #将收件人加入clients,状态为'未报名'
                    if Client.objects.filter(email=addressee, creator=User.objects.get(pk=request.user.id)).count() == 0:
                        client = Client.objects.create(email=addressee, creator=User.objects.get(pk=request.user.id), invite_type='email')
                        ClientParty.objects.create(client=client, party=Party.objects.get(pk=party_id), apply_status=u'未报名')
            return render_to_response('message.html', context_instance=RequestContext(request))
    else:
        form = InviteForm()
        ctx = {
            'form':form,
            'party':party,
            'invite_num':Client.objects.filter(invite_type='email').count(),
            'title':u'发送邮件通知'
        }
        return render_to_response('parties/invite.html', ctx, context_instance=RequestContext(request))

'''
@summary: 显示活动列表，活动详细
@author: chenyang
'''
@login_required
def list_party(request):
    party_list = Party.objects.all()
    ctx = {
        'party_list' : party_list
    }
    return render_to_response('parties/list.html', ctx ,context_instance=RequestContext(request))

def show_party(request, party_id):
    party = Party.objects.get(pk=party_id)
    date = datetime.datetime.strftime(party.time,'%Y-%m-%d')
    time = datetime.datetime.strftime(party.time,'%H:%M')
    client = {
        u'invite' : Client.objects.exclude(invite_type='public'),
        u'enrolled' : ClientParty.objects.filter(party=party_id,apply_status=u'已报名'),
        u'noenroll' : ClientParty.objects.filter(party=party_id,apply_status=u'未报名'),
        u'reject' : ClientParty.objects.filter(party=party_id,apply_status=u'不参加'),
    }
    ctx = {
        'party' : party,
        'client': client,
        'date'  : date,
        'time'  : time
    }
    return render_to_response('parties/show.html', ctx ,context_instance=RequestContext(request))
