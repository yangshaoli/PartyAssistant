#coding=utf-8
'''
Created on 2011-10-27

@author: liuxue
'''

from apps.clients.models import Client
from apps.messages.forms import EmailInviteForm, SMSInviteForm
from apps.messages.models import EmailMessage, SMSMessage
from apps.parties.models import PartiesClients
from django.contrib.auth.decorators import login_required
from django.db import transaction
from django.shortcuts import render_to_response, redirect, get_object_or_404
from django.template import RequestContext
from django.template.response import TemplateResponse
from forms import CreatePartyForm, InviteForm
from models import Party
from settings import SYS_EMAIL_ADDRESS, DOMAIN_NAME
from utils.tools.email_tool import send_emails
import copy



@login_required
def create_party(request):
    if request.method == 'POST':
        form = CreatePartyForm(request.POST)
        if form.is_valid():
            party = form.save(commit=False)
            party.creator = request.user
            party.save()
            
            if 'sms_invite' in request.POST:
                return redirect('sms_invite', party_id=party.id)
            else:
                return redirect('email_invite', party_id=party.id)
    else:
        form = CreatePartyForm()
    
    return TemplateResponse(request, 'parties/create_party.html', {'form': form})

@login_required
def delete_party(request,party_id):
    party = get_object_or_404(Party,pk=party_id)
    party.delete()
    
    return redirect('list_party')

@login_required
def edit_party(request, party_id):
    party = get_object_or_404(Party, id=party_id)
    
    if request.method == 'POST':
        form = CreatePartyForm(request.POST, instance=party)
        if form.is_valid():
            party = form.save()
            
            if 'sms_invite' in request.POST:
                return redirect('sms_invite', party_id=party.id)
            else:
                return redirect('email_invite', party_id=party.id)
    else:
        form = CreatePartyForm(instance=party)
    
    return TemplateResponse(request, 'parties/edit_party.html', {'form': form, 'party': party})

@login_required
@transaction.commit_on_success
def email_invite(request, party_id):
    party = get_object_or_404(Party, id=party_id)
    
    if request.method == 'POST':
        form = EmailInviteForm(request.POST)
        if form.is_valid():
            email_message, created = EmailMessage.objects.get_or_create(party=party, 
                defaults={'subject': u'[PartyAssistant]您收到一个活动邀请', 'content': form.cleaned_data['content']})
            if not created:
                email_message.subject = u'[PartyAssistant]您收到一个活动邀请'
                email_message.content = form.cleaned_data['content']
                email_message.save()
            
            client_email_list = form.cleaned_data['client_email_list'].split(',')
            parties_clients = PartiesClients.objects.select_related('client').filter(party=party)
            clients = Client.objects.filter(creator=request.user)
            
            for email in client_email_list:
                client_temp = None
                for client in clients:
                    if client.email == email:
                        client_temp = client
                        break
                
                if not client_temp:
                    client_temp = Client.objects.create(
                        creator=request.user, 
                        name=email, 
                        email=email, 
                        invite_type='email'
                    )
                
                party_client_temp = None
                for party_client in parties_clients:
                    if party_client.client == client_temp:
                        party_client_temp = party_client
                        break
                
                if not party_client_temp:
                    party_client = PartiesClients.objects.create(
                        party=party, 
                        client=client_temp
                    )
            
            if form.cleaned_data['is_apply_tips']:
                for email in client_email_list:
                    enroll_link = DOMAIN_NAME + '/clients/invite_enroll/' + email + '/' + party_id
                    email_message.content = email_message.content + u'点击进入报名页面：<a href="%s">%s</a>' % (enroll_link, enroll_link)
                    send_emails(email_message.subject, email_message.content, SYS_EMAIL_ADDRESS, [email])
            else:
                send_emails(email_message.subject, email_message.content, SYS_EMAIL_ADDRESS, client_email_list)
 
            party.invite_type = 'email' #将邀请方式修改为email
            party.save()
 
            return redirect('list_party')
    else:
        client_email_list = []
        content = ''
        
        apply_status = request.GET.get('apply', 'all')
        if apply_status == 'all':
            
            clients = PartiesClients.objects.filter(party=party_id).exclude(client__invite_type='public')
        else:
            clients = PartiesClients.objects.filter(party=party_id).filter(apply_status=apply_status).exclude(client__invite_type='public')
        
        if clients:
            for client in clients:
                client_email_list.append(client.client.email)
            client_email_list = ','.join(client_email_list)

            content = EmailMessage.objects.get(party=party).content
            data = {
            'client_email_list': client_email_list, 
            'content': content,
            'is_apply_tips' : True
        }
            form = EmailInviteForm(data)
        else:
            form = EmailInviteForm()
    
    return TemplateResponse(request, 'parties/email_invite.html', {'form': form, 'party': party})

@login_required
@transaction.commit_on_success
def sms_invite(request, party_id):
    party = get_object_or_404(Party, id=party_id)
    
    if request.method == 'POST':
        form = SMSInviteForm(request.POST)
        if form.is_valid():
            sms_message, created = SMSMessage.objects.get_or_create(party=party, 
                defaults={'content': form.cleaned_data['content']})
            if not created:
                sms_message.content = form.cleaned_data['content']
                sms_message.save()
            
            client_phone_list = form.cleaned_data['client_phone_list'].split(',')
            parties_clients = PartiesClients.objects.select_related('client').filter(party=party)
            clients = Client.objects.filter(creator=request.user)
            
            for phone in client_phone_list:
                client_temp = None
                for client in clients:
                    if client.phone == phone.strip():
                        client_temp = client
                        break
                
                if not client_temp:
                    client_temp = Client.objects.create(
                        creator=request.user, 
                        name=phone, 
                        email=phone, 
                        invite_type='phone'
                    )
                
                party_client_temp = None
                for party_client in parties_clients:
                    if party_client.client == client_temp:
                        party_client_temp = party_client
                        break
                
                if not party_client_temp:
                    party_client = PartiesClients.objects.create(
                        party=party, 
                        client=client_temp
                    )
            
            # TODO: generate shot link and send sms message
            if form.cleaned_data['is_apply_tips']:
                for phone in client_phone_list:
                    pass
            else:
                pass
            
            party.invite_type = 'phone' #将邀请方式修改为phone
            party.save()
            
            return redirect('list_party')
    else:
        form = SMSInviteForm()
    
    return TemplateResponse(request, 'parties/email_invite.html', {'form': form, 'party': party})


def delete_party_notice(request,party_id):
    party = get_object_or_404(Party,pk=party_id)
    PartiesClients_list = PartiesClients.objects.filter(party=party)
    for PartiesClients in PartiesClients_list:
        client = PartiesClients.client
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
    old_party = Party.objects.get(pk=party_id)
    new_party = copy.deepcopy(old_party)
    new_party.id = None
    new_party.save()
    old_message = EmailMessage.objects.get(party=old_party)
    new_message = copy.deepcopy(old_message)
    new_message.id = None
    new_message.party = new_party
    new_message.save()
    
    clients = PartiesClients.objects.filter(party=party_id).exclude(client__invite_type='public')
    for client in clients:
        c = PartiesClients.objects.create(client_id=client.id, party=new_party,apply_status='noanwser')
        c.save()

    return render_to_response('parties/edit_party.html',{'form':CreatePartyForm(instance=new_party), 'party':new_party},context_instance=RequestContext(request))

def message_invite(request):
    form = InviteForm()
    return render_to_response('parties/invite.html',{'form':form, 'title':u'发送短信通知'}, context_instance=RequestContext(request))

@login_required
def list_party(request):
    party_list = Party.objects.filter(creator=request.user)
    return TemplateResponse(request, 'parties/list.html', {'party_list': party_list})

def view_party(request, party_id):
    party = Party.objects.get(pk=party_id)
    client = {
        u'invite' : PartiesClients.objects.filter(party=party_id).exclude(client__invite_type='public'), #Client.objects.exclude(invite_type='public'),
        u'apply' : PartiesClients.objects.filter(party=party_id,apply_status='apply'),
        u'noanswer' : PartiesClients.objects.filter(party=party_id,apply_status='noanswer'),
        u'reject' : PartiesClients.objects.filter(party=party_id,apply_status='reject'),
    }
    ctx = {
        'party' : party,
        'client': client,
    }
    
    return render_to_response('parties/show.html', ctx ,context_instance=RequestContext(request))
