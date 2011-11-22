#coding=utf-8
'''
Created on 2011-10-27

@author: liuxue
'''

from apps.clients.models import Client
from apps.messages.forms import EmailInviteForm, SMSInviteForm
from apps.messages.models import EmailMessage, SMSMessage, Outbox
from apps.parties.models import PartiesClients
from apps.clients.views import get_client_sum 
from django.contrib.auth.decorators import login_required
from django.db import transaction
from django.shortcuts import render_to_response, redirect, get_object_or_404
from django.template import RequestContext
from django.template.response import TemplateResponse
from forms import CreatePartyForm, InviteForm
from models import Party
from settings import SYS_EMAIL_ADDRESS, DOMAIN_NAME
from utils.tools.email_tool import send_emails
import datetime
import logging
logger = logging.getLogger('airenao')


@login_required
def create_party(request):
    if request.method == 'POST':
        form = CreatePartyForm(request.POST)
        if form.is_valid():
            party = form.save(commit = False)
            party.creator = request.user
            party.save()
            
            if 'sms_invite' in request.POST:
                return redirect('sms_invite', party_id = party.id)
            elif 'email_invite' in request.POST:
                return redirect('email_invite', party_id = party.id)
            else:
                return redirect('list_party')
    else:
        form = CreatePartyForm()
    
    return TemplateResponse(request, 'parties/create_party.html', {'form': form})

@login_required
def delete_party(request, party_id):
    party = get_object_or_404(Party, pk = party_id)
    party.delete()
    
    return redirect('list_party')

@login_required
def edit_party(request, party_id):
    if request.method == 'POST':
        party = get_object_or_404(Party, id = party_id)
        form = CreatePartyForm(request.POST, instance = party)
        if form.is_valid():
            party = form.save()
            if 'save_send' in request.POST:
                if party.invite_type != None:
                    if party.invite_type == 'email':
                        return redirect('email_invite', party_id = party.id)
                    else:
                        return redirect('sms_invite', party_id = party.id)  
            else:
                if 'sms_invite' in request.POST:
                    return redirect('sms_invite', party_id = party.id)
                elif 'email_invite' in request.POST:
                    return redirect('email_invite', party_id = party.id)
                else:
                    return redirect('list_party')
        else :
            return TemplateResponse(request, 'parties/edit_party.html', {'form': form, 'party': party})
                    
    else:
        party = get_object_or_404(Party, id = party_id)
        form = CreatePartyForm(instance = party)
    
        return TemplateResponse(request, 'parties/edit_party.html', {'form': form, 'party': party})

@login_required
@transaction.commit_on_success
def email_invite(request, party_id):
    if request.method == 'POST':
        content = ''
        party = get_object_or_404(Party, id = party_id)
        form = EmailInviteForm(request.POST)
        if form.is_valid():
            with transaction.commit_on_success():
                party.invite_type = 'email' #将邀请方式修改为email
                party.save()
                
                email_message, created = EmailMessage.objects.get_or_create(party = party,
                    defaults = {'subject': u'[爱热闹]您收到一个活动邀请', 'content': form.cleaned_data['content']})
                if not created:
                    email_message.subject = u'[爱热闹]您收到一个活动邀请'
                    email_message.content = form.cleaned_data['content']
                    email_message.save()
                
                client_email_list = form.cleaned_data['client_email_list'].split(',')
                parties_clients = PartiesClients.objects.select_related('client').filter(party = party)
                clients = Client.objects.filter(creator = request.user)
                
                for email in client_email_list:
                    client_temp = None
                    for client in clients:
                        if client.email == email:
                            client_temp = client
                            break
                    
                    if not client_temp:
                        client_temp = Client.objects.create(
                            creator = request.user,
                            name = email,
                            email = email,
                            invite_type = 'email'
                        )
                    
                    party_client_temp = None
                    for party_client in parties_clients:
                        if party_client.client == client_temp:
                            party_client_temp = party_client
                            break
                    
                    if not party_client_temp:
                        party_client = PartiesClients.objects.create(
                            party = party,
                            client = client_temp
                        )
            
            send_email_status = u'邮件发送失败'
            with transaction.commit_on_success():
                send_message = Outbox(address = form.cleaned_data['client_email_list'], base_message = email_message)
                send_message.save()
                send_email_status = u'邮件发送成功'
             
            request.session['send_email_status'] = send_email_status    
            return redirect('list_party')
        else:
            return TemplateResponse(request, 'parties/email_invite.html', {'form': form, 'party': party})

    else:
        party = get_object_or_404(Party, id = party_id)
        client_email_list = []
        content = ''
        #生成默认内容
        content = content + party.creator.username + u'邀请你参加：'
        if party.start_time == None and party.address == '':
            content = content + party.description + u',时间、地点，另行通知。'
        elif party.start_time != None and party.address == u'':
            content = content + datetime.datetime.strftime(party.start_time, '%Y-%m-%d %H:%M') + party.description + u',地点另行通知。'     
        elif party.start_time == None and party.address != '':
            content = content + u'在' + party.address + party.description + u',时间待定。'
        else:  
            content = content + datetime.time.strftime(party.start_time, '%Y-%m-%d %H:%M') + u' ,在' + party.address + u'的活动' + party.description         
           
        form = None  
        apply_status = request.GET.get('apply', 'all')
        if apply_status == 'all':
            clients = PartiesClients.objects.filter(party = party_id).exclude(client__invite_type = 'public')
        else:
            clients = PartiesClients.objects.filter(party = party_id).filter(apply_status = apply_status).exclude(client__invite_type = 'public')
       
        if clients:
            for client in clients:
                client_email_list.append(client.client.email)
            client_email_list = ','.join(client_email_list)
            data = {
                'client_email_list': client_email_list,
                'content': content,
                'is_apply_tips' : True
            }
            form = EmailInviteForm(data)
        else:
            data = {
                'client_email_list': '',
                'content': content,
                'is_apply_tips' : True
            }
            form = EmailInviteForm(data)
    
        return TemplateResponse(request, 'parties/email_invite.html', {'form': form, 'party': party, 'client_data':client_email_list})

@login_required
@transaction.commit_on_success
def sms_invite(request, party_id):
    if request.method == 'POST':
        party = get_object_or_404(Party, id = party_id)
        content = ''
        form = SMSInviteForm(request.POST)
        if form.is_valid():
            with transaction.commit_on_success():
                party.invite_type = 'phone' #将邀请方式修改为phone
                party.save()
                
                sms_message, created = SMSMessage.objects.get_or_create(party = party,
                    defaults = {'content': form.cleaned_data['content']})
                if not created:
                    sms_message.content = form.cleaned_data['content']
                    sms_message.save()
                
                client_phone_list = form.cleaned_data['client_phone_list'].split(',')
                parties_clients = PartiesClients.objects.select_related('client').filter(party = party)
                clients = Client.objects.filter(creator = request.user)
                
                for phone in client_phone_list:
                    client_temp = None
                    for client in clients:
                        if client.phone == phone.strip():
                            client_temp = client
                            break
                    
                    if not client_temp:
                        client_temp = Client.objects.create(
                            creator = request.user,
                            name = phone,
                            phone = phone,
                            invite_type = 'phone'
                        )
                    
                    party_client_temp = None
                    for party_client in parties_clients:
                        if party_client.client == client_temp:
                            party_client_temp = party_client
                            break
                    
                    if not party_client_temp:
                        party_client = PartiesClients.objects.create(
                            party = party,
                            client = client_temp
                        )
            send_sms_status = u'短信发送失败'
            with transaction.commit_on_success():
                send_message = Outbox(address = form.cleaned_data['client_phone_list'], base_message = sms_message)
                send_message.save()
                send_sms_status = u'短信发送成功'
             
            request.session['send_sms_status'] = send_sms_status
            
            return redirect('list_party')
        else:
            if 'sms_invite_default_content' in request.POST:
                content = request.POST['sms_invite_default_content']
            return TemplateResponse(request, 'parties/sms_invite.html', {'form': form, 'party': party})

    else:
        party = get_object_or_404(Party, id = party_id)
        content = ''
        client_phone_list = []
        #生成默认内容
        content = content + party.creator.username + u'邀请你参加：'
        if party.start_time == None and party.address == '':
            content = content + party.description + u',时间、地点，另行通知。'
        elif party.start_time != None and party.address == u'':
            content = content + datetime.datetime.strftime(party.start_time, '%Y-%m-%d %H:%M') + party.description + u',地点另行通知。'     
        elif party.start_time == None and party.address != '':
            content = content + u'在' + party.address + party.description + u',时间待定。'
        else:  
            content = content + datetime.time.strftime(party.start_time, '%Y-%m-%d %H:%M') + u' ,在' + party.address + u'的活动' + party.description         
        form = None
        apply_status = request.GET.get('apply', 'all')
        if apply_status == 'all':
            clients = PartiesClients.objects.filter(party = party_id).exclude(client__invite_type = 'public')
        else:
            clients = PartiesClients.objects.filter(party = party_id).filter(apply_status = apply_status).exclude(client__invite_type = 'public')
        
        if clients:
            for client in clients:
                client_phone_list.append(client.client.phone)
            client_phone_list = ','.join(client_phone_list)

            content = SMSMessage.objects.get(party = party).content
            data = {
                'client_phone_list': client_phone_list,
                'content': content,
                'is_apply_tips' : True
            }
            form = SMSInviteForm(data)
        else:
            
            data = {
               'client_phone_list': '',
               'content': content,
               'is_apply_tips' : True
            }
            form = SMSInviteForm(data)    
                    
        return TemplateResponse(request, 'parties/sms_invite.html', {'form': form, 'party': party})


def delete_party_notice(request, party_id):
    party = get_object_or_404(Party, pk = party_id)
    PartiesClients_list = PartiesClients.objects.filter(party = party)
    for PartiesClients in PartiesClients_list:
        client = PartiesClients.client
        if client.invite_type == 'email':
            title = u'活动取消通知'
            content = u'尊敬的 ' + client.name + ' :' + ' 于' + party.time.strftime('%Y-%m-%d %H:%M') + ' 在' + party.address + '的活动取消'
            send_emails(title, content, SYS_EMAIL_ADDRESS, [client.email])
        if client.invite_type == 'phone':
            content = u'尊敬的 ' + client.name + ' :' + ' 于' + party.time.strftime('%Y-%m-%d %H:%M') + ' 在' + party.address + '的活动取消'
    return delete_party(request, party_id) 


@login_required
def list_party(request):
    party_list = Party.objects.filter(creator = request.user).order_by('-id')[0:10] 
    
    for party in party_list:
        party_clients = PartiesClients.objects.select_related('client').filter(party = party)
        client = {
            'invite': [],
            'apply': [],
            'new_add_apply':[],
            'noanswer':[],
            'reject':[],
            'new_add_reject':[],
            'count':{}
        }
        for party_client in party_clients:
            if party_client.client.invite_type != 'public':
                client['invite'].append(party_client)
            if party_client.apply_status == 'apply':
                client['apply'].append(party_client)
            if party_client.apply_status == 'apply' and party_client.is_check == False:
                client['new_add_apply'].append(party_client)
            if party_client.apply_status == 'noanswer':
                client['noanswer'].append(party_client)
            if party_client.apply_status == 'reject':
                client['reject'].append(party_client)
            if party_client.apply_status == 'reject' and party_client.is_check == False:
                client['new_add_reject'].append(party_client)
        party.client = client  
        party.client['count'] = _get_client_count(party)
        print party.client['count']
        
    send_email_status = ''    
    if 'send_email_status' in request.session:
        send_email_status = request.session['send_email_status']
        del request.session['send_email_status']        
    send_sms_status = ''    
    if 'send_sms_status' in request.session:
        send_sms_status = request.session['send_sms_status']  
        del request.session['send_sms_status']
        
    return TemplateResponse(request, 'parties/list.html', {'party_list': party_list, 'send_email_status':send_email_status, 'send_sms_status':send_sms_status})

def _public_enroll(request, party_id):
    party = get_object_or_404(Party, id = party_id)
    creator = party.creator
    
    if request.method == 'POST':
        #将用户加入clients,状态为'已报名'
        name = request.POST['name']
        email = request.POST['email']
        phone = request.POST['phone']
        if Client.objects.filter(creator = creator).filter(email = email).count() == 0 \
            and Client.objects.filter(creator = creator).filter(phone = phone).count() == 0:
            client = Client.objects.create(name = name, email = email, phone = phone, invite_type = 'public')
            PartiesClients.objects.create(client = client, party = party, apply_status = u'apply')
            return TemplateResponse(request, 'message.html', {'message': u'报名成功'})
        else:
            return TemplateResponse(request, 'message.html', {'message':u'您已经报名了'})
    else:
        data = {
            'party': party,
            'client_count': _get_client_count(party)
        }
        if request.META['PATH_INFO'][0:3] == '/m/':
            return TemplateResponse(request, 'm/enroll.html', data)
        else:
            return TemplateResponse(request, 'parties/enroll.html', data)

def _invite_enroll(request, party_id, invite_key):
    party = get_object_or_404(Party, id = party_id)
    party_client = get_object_or_404(PartiesClients, invite_key = invite_key)
    party_client.is_check = False
    client = party_client.client
    
    if request.method == 'POST':
        if request.POST['action'] == 'yes': #如果点击参加
            party_client.apply_status = u'apply'
            party_client.save()
            return TemplateResponse(request, 'message.html', {'message': u'报名成功'})
        else:
            party_client.apply_status = u'reject'
            party_client.save()
            return TemplateResponse(request, 'message.html', {'message':u'您已经拒绝了这次邀请'})
    else:
        data = {
            'client': client,
            'party': party,
            'client_count': _get_client_count(party)
        }
        
        if request.META['PATH_INFO'][0:3] == '/m/':
            return TemplateResponse(request, 'm/enroll.html', data)
        else:
            return TemplateResponse(request, 'parties/enroll.html', data)
        
def enroll(request, party_id):
    invite_key = request.GET.get('key', '')
    if invite_key:
        return _invite_enroll(request, party_id, invite_key)
    else:
        return _public_enroll(request, party_id)

def _get_client_count(party):
    client_count = {
        'apply': 0,
        'noanswer': 0,
        'reject': 0
    }
    
    parties_clients = PartiesClients.objects.filter(party = party)
    for party_client in parties_clients:
        if party_client.apply_status == 'apply':
            client_count['apply'] = client_count['apply'] + 1
        elif party_client.apply_status == 'noanswer':
            client_count['noanswer'] = client_count['noanswer'] + 1
        else:
            client_count['reject'] = client_count['reject'] + 1
    
    return client_count
