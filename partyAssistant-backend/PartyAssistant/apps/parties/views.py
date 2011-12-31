#coding=utf-8
'''
Created on 2011-10-27

@author: liuxue
'''

from apps.accounts.models import UserProfile
from apps.clients.models import Client
from apps.messages.forms import EmailInviteForm, SMSInviteForm
from apps.messages.models import EmailMessage, SMSMessage, Outbox
from apps.parties.forms import PublicEnrollForm, EnrollForm
from apps.parties.models import PartiesClients
from django.contrib.auth.decorators import login_required
from django.core.paginator import Paginator
from django.core.urlresolvers import reverse
from django.db import transaction
from django.http import HttpResponse
from django.shortcuts import redirect, get_object_or_404
from django.template.response import TemplateResponse
from django.utils import simplejson
from forms import PartyForm
from models import Party
from settings import DOMAIN_NAME
from utils.tools.email_tool import send_emails
from utils.tools.push_notification_to_apple_tool import \
    push_notification_when_enroll
from utils.tools.sms_tool import SHORT_LINK_LENGTH, BASIC_MESSAGE_LENGTH
import datetime
import logging
import time
logger = logging.getLogger('airenao')


@login_required
def create_party(request):
    if request.method == 'POST':
        form = PartyForm(request.POST)
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
            
            return TemplateResponse(request, 'parties/create_party.html', {'form': form})   
                
    else:
        form = PartyForm()
    
    return TemplateResponse(request, 'parties/create_party.html', {'form': form})

@login_required
def delete_party(request, party_id):
    party = get_object_or_404(Party, pk = party_id, creator=request.user)
    party.delete()
    
    return redirect('list_party')

@login_required
def edit_party(request, party_id):
    party = get_object_or_404(Party, id = party_id, creator=request.user)
    
    if request.method == 'POST':
        form = PartyForm(request.POST, instance = party)
        if form.is_valid():
            party = form.save()
            if 'save_send' in request.POST:
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
        else:
            
            return TemplateResponse(request, 'parties/edit_party.html', {'form': form, 'party': party})       
    else:
        if party.start_date:
            party.start_date = datetime.date.strftime(party.start_date, '%Y-%m-%d')
        if party.start_time:
            party.start_time = datetime.time.strftime(party.start_time, '%H:%M')
        form = PartyForm(instance = party)
        
    return TemplateResponse(request, 'parties/edit_party.html', {'form': form, 'party': party})

@login_required
@transaction.commit_on_success
def email_invite(request, party_id):
    party = get_object_or_404(Party, id = party_id, creator = request.user)
    #取得最近20个活动，用来从中获取好友
    recent_parties = Party.objects.filter(invite_type='email').filter(creator=request.user).exclude(id=party.id).order_by('-created_time')
    
    if request.method == 'POST':
        form = EmailInviteForm(request.POST)
        if form.is_valid():
            with transaction.commit_on_success():
                party.invite_type = 'email' #将邀请方式修改为email
                party.save()
                
                email_message, created = EmailMessage.objects.get_or_create(party = party,
                    defaults = {'subject': u'[爱热闹]您收到一个活动邀请', 'content': form.cleaned_data['content'], 'is_apply_tips': form.cleaned_data['is_apply_tips']})
                if not created:
                    email_message.subject = u'[爱热闹]您收到一个活动邀请'
                    email_message.content = form.cleaned_data['content']
                    email_message.is_apply_tips = form.cleaned_data['is_apply_tips']
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
            
            send_status = 'email_fail'
            with transaction.commit_on_success():
                send_message = Outbox(address = form.cleaned_data['client_email_list'], base_message = email_message)
                send_message.save()
                send_status = 'email_success'
             
            request.session['send_status'] = send_status    
            return redirect('list_party')
        else:
            client_data = []
            for client in Client.objects.filter(creator = request.user):
                if client.email:
                    client_data.append(client.email)
            noanswer_client = []
            apply_client = []
            reject_client = []
            parties_clients = PartiesClients.objects.select_related('client').filter(party = party)
            for  party_client in parties_clients :
                if party_client.apply_status == 'noanswer':
                    noanswer_client.append(party_client.client.email)
                if party_client.apply_status == 'apply':
                    apply_client.append(party_client.client.email)
                if party_client.apply_status == 'reject':
                    reject_client.append(party_client.client.email)
            
            noanswer_client = ','.join(noanswer_client)
            apply_client = ','.join(apply_client)
            reject_client = ','.join(reject_client)
            quickadd_client = {'noanswer_client':noanswer_client,
                               'apply_client':apply_client,
                               'reject_client':reject_client
                               }
                      
            return TemplateResponse(request, 'parties/email_invite.html', {'form': form, 'party': party, 'client_data':simplejson.dumps(client_data), 'quickadd_client':quickadd_client, 'recent_parties':recent_parties})
    else:
        apply_status = request.GET.get('apply', 'all')
        if apply_status == 'all':
            clients = PartiesClients.objects.filter(party = party_id).exclude(client__invite_type = 'public')
        else:
            clients = PartiesClients.objects.filter(party = party_id).filter(apply_status = apply_status).exclude(client__invite_type = 'public')
       
        if clients:
            client_email_list = []
            for client in clients:
                client_email_list.append(client.client.email)
            client_email_list = ','.join(client_email_list)
            
            email_message = EmailMessage.objects.get(party = party)
            
            data = {
                'client_email_list': client_email_list,
                'content': email_message.content,
                'is_apply_tips' : email_message.is_apply_tips
            }
            form = EmailInviteForm(initial = data)
        else:
            #生成默认内容
            userprofile = request.user.get_profile()
            creator = userprofile.true_name if userprofile.true_name else request.user.username  
            content = _create_default_content(creator, party.start_date, party.start_time , party.address, party.description)
            data = {
                'client_email_list': '',
                'content': content,
                'is_apply_tips' : True
            }
            form = EmailInviteForm(initial = data)
        client_data = []
        for client in Client.objects.filter(creator = request.user):
            if client.email:
                client_data.append(client.email)
        noanswer_client = []
        apply_client = []
        reject_client = []
        parties_clients = PartiesClients.objects.select_related('client').filter(party = party)
        for  party_client in parties_clients :
            if party_client.apply_status == 'noanswer':
                noanswer_client.append(party_client.client.email)
            if party_client.apply_status == 'apply':
                apply_client.append(party_client.client.email)
            if party_client.apply_status == 'reject':
                reject_client.append(party_client.client.email)
        
        noanswer_client = ','.join(noanswer_client)
        apply_client = ','.join(apply_client)
        reject_client = ','.join(reject_client)
        quickadd_client = {'noanswer_client':noanswer_client,
                           'apply_client':apply_client,
                           'reject_client':reject_client
                           }
        return TemplateResponse(request, 'parties/email_invite.html', {'form': form, 'party': party, 'client_data':simplejson.dumps(client_data), 'quickadd_client':quickadd_client, 'recent_parties':recent_parties})

@login_required
@transaction.commit_on_success
def sms_invite(request, party_id):
    party = get_object_or_404(Party, id = party_id, creator=request.user)
    #取得最近20个活动，用来从中获取好友
    recent_parties = Party.objects.filter(invite_type='phone').filter(creator=request.user).exclude(id=party.id).order_by('-created_time')
    
    if request.method == 'POST':
        form = SMSInviteForm(request.POST)
        if form.is_valid():
            number_of_message = 1     #每次邀请转换为短信的条数， 默认一条       
            with transaction.commit_on_success():
                party.invite_type = 'phone' #将邀请方式修改为phone
                party.save()
                
                sms_message, created = SMSMessage.objects.get_or_create(party = party,
                    defaults = {'content': form.cleaned_data['content'], 'is_apply_tips': form.cleaned_data['is_apply_tips']})
                if not created:
                    sms_message.content = form.cleaned_data['content']
                    sms_message.is_apply_tips = form.cleaned_data['is_apply_tips']
                    sms_message.save()
                # 计算消息可转换为多少条短信    
                number_of_message = (len(sms_message.content) + (SHORT_LINK_LENGTH if sms_message.is_apply_tips else 0) + BASIC_MESSAGE_LENGTH - 1) / BASIC_MESSAGE_LENGTH
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

            send_status = 'sms_fail'
            sms_count = ''
            with transaction.commit_on_success():
                client_phone_list = form.cleaned_data['client_phone_list'].split(',')
                client_phone_list_len = len(client_phone_list)
                userprofile = request.user.get_profile() 
                sms_count = userprofile.available_sms_count
                will_send_message_num = client_phone_list_len * number_of_message #可能发送的从短信条数
                if will_send_message_num > sms_count:#短信人数*短信数目大于可发送的短信数目
                    will_receive_clients_num = sms_count / number_of_message #将会收到短信的联系人数
                    client_phone_list = client_phone_list[:will_receive_clients_num]
                    userprofile.available_sms_count = userprofile.available_sms_count - number_of_message * will_receive_clients_num
                    userprofile.used_sms_count = userprofile.used_sms_count + number_of_message * will_receive_clients_num
                else:
                    userprofile.available_sms_count = userprofile.available_sms_count - will_send_message_num
                    userprofile.used_sms_count = userprofile.used_sms_count + will_send_message_num
                userprofile.save()
                client_phone_list = ','.join(client_phone_list)  
                send_message = Outbox(address = client_phone_list, base_message = sms_message)
                send_message.save()
                send_status = 'sms_success'
                sms_count = str(userprofile.available_sms_count)
            request.session['sms_count'] = sms_count    
            request.session['send_status'] = send_status 
            return redirect('list_party')
        else:
            client_data = []
            for client in Client.objects.filter(creator = request.user):
                if client.phone:
                    client_data.append(client.phone)
            noanswer_client = []
            apply_client = []
            reject_client = []
            parties_clients = PartiesClients.objects.select_related('client').filter(party = party)
            for  party_client in parties_clients :
                if party_client.apply_status == 'noanswer':
                    noanswer_client.append(party_client.client.phone)
                if party_client.apply_status == 'apply':
                    apply_client.append(party_client.client.phone)
                if party_client.apply_status == 'reject':
                    reject_client.append(party_client.client.phone)
            
            noanswer_client = ','.join(noanswer_client)
            apply_client = ','.join(apply_client)
            reject_client = ','.join(reject_client)
            quickadd_client = {'noanswer_client':noanswer_client,
                               'apply_client':apply_client,
                               'reject_client':reject_client
                               }                    
            return TemplateResponse(request, 'parties/sms_invite.html', {'form': form, 'party': party, 'client_data':simplejson.dumps(client_data), 'quickadd_client':quickadd_client, 'recent_parties':recent_parties})
    else:
        apply_status = request.GET.get('apply', 'all')
        if apply_status == 'all':
            clients = PartiesClients.objects.filter(party = party_id).exclude(client__invite_type = 'public')
        else:
            clients = PartiesClients.objects.filter(party = party_id).filter(apply_status = apply_status).exclude(client__invite_type = 'public')
        
        if clients:
            client_phone_list = []
            for client in clients:
                client_phone_list.append(client.client.phone)
            client_phone_list = ','.join(client_phone_list)

            sms_message = SMSMessage.objects.get(party = party)
            
            data = {
                'client_phone_list': client_phone_list,
                'content': sms_message.content,
                'is_apply_tips' : sms_message.is_apply_tips
            }
            form = SMSInviteForm(initial = data)
        else:
            #生成默认内容
            userprofile = request.user.get_profile()
            creator = userprofile.true_name if userprofile.true_name else request.user.username  
            content = _create_default_content(creator, party.start_date, party.start_time , party.address, party.description)
            data = {
               'client_phone_list': '',
               'content': content,
               'is_apply_tips' : True
            }
            form = SMSInviteForm(initial = data)    
        client_data = []
        for client in Client.objects.filter(creator = request.user):
            if client.phone:
                client_data.append(client.phone)
        noanswer_client = []
        apply_client = []
        reject_client = []
        parties_clients = PartiesClients.objects.select_related('client').filter(party = party)
        for  party_client in parties_clients :
            if party_client.apply_status == 'noanswer':
                noanswer_client.append(party_client.client.phone)
            if party_client.apply_status == 'apply':
                apply_client.append(party_client.client.phone)
            if party_client.apply_status == 'reject':
                reject_client.append(party_client.client.phone)
        
        noanswer_client = ','.join(noanswer_client)
        apply_client = ','.join(apply_client)
        reject_client = ','.join(reject_client)
        quickadd_client = {'noanswer_client':noanswer_client,
                           'apply_client':apply_client,
                           'reject_client':reject_client
                           }        
        return TemplateResponse(request, 'parties/sms_invite.html', {'form': form, 'party': party, 'client_data':simplejson.dumps(client_data), 'quickadd_client':quickadd_client, 'recent_parties':recent_parties})

@login_required
def list_party(request):
    party_list = Party.objects.filter(creator = request.user).order_by('-id')
    for party in party_list:
        party.enroll_url = DOMAIN_NAME + reverse('enroll', args = [party.id])
        party_clients = PartiesClients.objects.select_related('client').filter(party = party)
        client_counts = {
            'invite': 0,
            'apply': 0,
            'new_add_apply':0,
            'noanswer':0,
            'reject':0,
            'new_add_reject':0,
        }
        for party_client in party_clients:
            if party_client.client.invite_type != 'public':
                client_counts['invite'] = client_counts['invite'] + 1
            if party_client.apply_status == 'apply':
                client_counts['apply'] = client_counts['apply'] + 1
            if party_client.apply_status == 'apply' and party_client.is_check == False:
                client_counts['new_add_apply'] = client_counts['new_add_apply'] + 1 
            if party_client.apply_status == 'noanswer':
                client_counts['noanswer'] = client_counts['noanswer'] + 1
            if party_client.apply_status == 'reject':
                client_counts['reject'] = client_counts['reject'] + 1 
            if party_client.apply_status == 'reject' and party_client.is_check == False:
                client_counts['new_add_reject'] = client_counts['new_add_reject'] + 1
          
        party.client_counts = client_counts
        
    send_status = ''    
    if 'send_status' in request.session:
        send_status = request.session['send_status']
        del request.session['send_status']  
    sms_count =''    
    if 'sms_count' in request.session:
        sms_count = request.session['sms_count']
        del request.session['sms_count']          
    #分页
    paginator = Paginator(party_list, 10)
    page = request.GET.get('page', 1)

    party_list = paginator.page(page)
    
    return TemplateResponse(request, 'parties/list.html', {'party_list': party_list, 'send_status':send_status, 'sms_count':sms_count})

def _public_enroll(request, party_id):
    party = get_object_or_404(Party, id = party_id, creator=request.user)
    creator = party.creator
    
    if request.method == 'POST':
        #将用户加入clients,状态为'已报名'
        form = PublicEnrollForm(request.POST)
        if form.is_valid():
            name = request.POST['name']
            email = ''
            phone = ''
            if form.cleaned_data['phone_or_email'].find('@') > 0:
                email = form.cleaned_data['phone_or_email']
            else:
                phone = form.cleaned_data['phone_or_email']
             
            BOOL_EMAIL_NONE = Client.objects.filter(creator = creator).filter(email = email).exclude(email = '').count() == 0 #Email 方式，查无此人    
            BOOL_PHONE_NONE = Client.objects.filter(creator = creator).filter(phone = phone).exclude(phone = '').count() == 0 #Phone 方式，查无此人        
            client = None
            create = False
            if  BOOL_EMAIL_NONE and BOOL_PHONE_NONE :  #未受邀状态
                client, create = Client.objects.get_or_create(name = name, creator = creator, email = email, phone = phone)
            elif BOOL_EMAIL_NONE and (not BOOL_PHONE_NONE) : #存在 phone 记录 ，但无 Email 记录
                client = get_object_or_404(Client, phone = phone)  
            elif (not BOOL_EMAIL_NONE) and BOOL_PHONE_NONE : #存在 email 记录 ，但无 phone 记录
                client = get_object_or_404(Client, email = email)
            else:
                logger.exception('public enroll exception!')
            #有人数限制
            if party.limit_count != 0 :
                if PartiesClients.objects.filter(party = party, apply_status = 'apply').count() >= party.limit_count:
                    return TemplateResponse(request, 'message.html', {'message': 'late'})
                    
#            if Client.objects.filter(creator = creator).filter(party = party).filter(email = email).exclude(email = '').count() == 0 \
#                and Client.objects.filter(creator = creator).filter(party = party).filter(phone = phone).exclude(phone = '').count() == 0:
#                if party.limit_count != 0:#有人数限制
#                    if PartiesClients.objects.filter(party = party, apply_status = 'apply').count() >= party.limit_count:
#                        return TemplateResponse(request, 'message.html', {'message': u'来晚了，下次早点吧'})
#                client = Client.objects.create(name = name, creator = creator, email = email, phone = phone, invite_type = 'public')
#                party_client = PartiesClients.objects.create(client = client, party = party, apply_status = u'apply', is_check = False, leave_message = form.cleaned_data['leave_message'])
                
#                #向组织者的所有MoblieDevice发送推送
#                push_notification_when_enroll(party_client, 'apply')
                
            if create:
                client.invite_type = 'public'
                client.save()
            client.name = name 
            client.save()    
            
            party_client, create = PartiesClients.objects.get_or_create(client = client, party = party)            
            leave_message = form.cleaned_data['leave_message']
            if leave_message:
                party_client.leave_message = party_client.leave_message + ',' + leave_message + ' ' + time.strftime('%Y-%m-%d %H:%M:%S', time.localtime(time.time()))
                 
            party_client.apply_status = 'apply'
            party_client.is_check = False    
            party_client.save()
            push_notification_when_enroll(party_client, 'apply') 
            if request.META['PATH_INFO'][0:3] == '/m/':
                return TemplateResponse(request, 'm/message.html', {'title':u'报名成功', 'message': 'publicenrollsucess'})
            else:    
                return TemplateResponse(request, 'message.html', {'message': 'publicenroll'})
        else:
            data = {
            'party': party,
            'client_count': _get_client_count(party),
            'form':form
                   }
            return TemplateResponse(request, 'parties/enroll.html', data)
    else:
        form = PublicEnrollForm()
        invite_message = ''
        if party.invite_type == 'email':
            invite_message = 'email'
        else:
            invite_message = 'phone'
        userprofile = party.creator.get_profile()
        party.creator.username = userprofile.true_name if userprofile.true_name else party.creator.username    
        data = {
            'party': party,
            'client_count': _get_client_count(party),
            'form':form,
            'invite_message':invite_message
        }
        return TemplateResponse(request, 'parties/enroll.html', data)

def _invite_enroll(request, party_id, invite_key):
    party = get_object_or_404(Party, id = party_id, creator = request.user)
    party_client = get_object_or_404(PartiesClients, invite_key = invite_key)
    party_client.is_check = False
    client = party_client.client
    
    if request.method == 'POST':
        form = EnrollForm(request.POST) 
        if form.is_valid():
            #保存client的姓名
            if client.invite_type == 'email':
                if request.POST.get('name'):
                    client.name = request.POST.get('name')
                else:
                    if not client.name:
                        client.name = client.email  
            else:
                if request.POST.get('name'):
                    client.name = request.POST.get('name')
                else:
                    if not client.name:
                        client.name = client.phone  
            client.save()
               
            if 'yes' in request.POST: #如果点击参加
                if party.limit_count != 0:#有人数限制
                    if len(PartiesClients.objects.filter(party = party, apply_status = 'apply')) >= party.limit_count:
                        return TemplateResponse(request, 'message.html', {'message': 'late'})

                party_client.apply_status = u'apply'
                leave_message = form.cleaned_data['leave_message']
                if leave_message:
                    party_client.leave_message = party_client.leave_message + ',' + leave_message + ' ' + time.strftime('%Y-%m-%d %H:%M:%S', time.localtime(time.time()))
                              
                party_client.save()
                
                #向组织者的所有MoblieDevice发送推送
                push_notification_when_enroll(party_client, 'apply')
                
                return TemplateResponse(request, 'message.html', {'message': u'apply'})
            else:
                party_client.apply_status = u'reject'
                leave_message = form.cleaned_data['leave_message']
                if leave_message:
                    party_client.leave_message = party_client.leave_message + ',' + leave_message + ' ' + time.strftime('%Y-%m-%d %H:%M:%S', time.localtime(time.time()))
              
                party_client.save()
                
                #向组织者的所有MoblieDevice发送推送
                push_notification_when_enroll(party_client, 'reject')
                
                return TemplateResponse(request, 'message.html', {'message': 'reject'})
        else:
            data = {
                'client': client,
                'party': party,
                'client_count': _get_client_count(party),
                'form' : form,
                'key' : request.GET.get('key','')
             }
            return TemplateResponse(request, 'parties/enroll.html', data)
    else:
        userprofile = party.creator.get_profile()
        party.creator.username = userprofile.true_name if userprofile.true_name else party.creator.username
        data = {
            'client': client,
            'party': party,
            'client_count': _get_client_count(party),
            'form' : EnrollForm(),
            'key' : request.GET.get('key','')
        }
        
        return TemplateResponse(request, 'parties/enroll.html', data)
        
def enroll(request, party_id):
    try:
        get_object_or_404(Party, id = party_id, creator=request.user)
    except :
        return TemplateResponse(request, 'message.html', {'message':u'partynotexist'}) 
    invite_key = request.GET.get('key', '')
    if not invite_key:
        invite_key = request.POST.get('key', '')
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

@login_required
def change_apply_status(request, party_client_id, applystatus):
    client_party = PartiesClients.objects.get(pk = party_client_id)      
    client_party.apply_status = applystatus
    client_party.save()        
    return HttpResponse('ok') 

@login_required
def invite_list(request, party_id):
    party = get_object_or_404(Party, id = party_id, creator=request.user)
    party_clients_list = PartiesClients.objects.filter(party = party)
    
    party_clients = {
        'apply': {
            'is_check': True,
            'client_count': 0
        },
        'noanswer': {
            'is_check': True,
            'client_count': 0
        },
        'reject': {
            'is_check': True,
            'client_count': 0
        }
    }
    
    for party_client in party_clients_list:
        if party_client.apply_status == 'apply':
            party_clients['apply']['client_count'] = party_clients['apply']['client_count'] + 1
            if not party_client.is_check:
                party_clients['apply']['is_check'] = False
        elif party_client.apply_status == 'noanswer':
            party_clients['noanswer']['client_count'] = party_clients['noanswer']['client_count'] + 1
            if not party_client.is_check:
                party_clients['noanswer']['is_check'] = False
        if party_client.apply_status == 'reject':
            party_clients['reject']['client_count'] = party_clients['reject']['client_count'] + 1
            if not party_client.is_check:
                party_clients['reject']['is_check'] = False
    
    return TemplateResponse(request, 'clients/invite_list.html', {'party': party, 'party_clients': party_clients}) 


#生成默认内容
def _create_default_content(creator, start_date, start_time , address, description):
    content = creator + u'邀请你参加：' + description 
    address_content = u'，' + u'地点：' + (address if address != "" else u'待定') 
    if start_date == None and start_time == None:
        if address == "":
            content += u'，' + u'具体安排待定'
        else:
            content += address_content
    if start_date != None and start_time == None:
        content += address_content + u'，' + u'日期:' + datetime.date.strftime(start_date, '%Y-%m-%d') + u'，时间暂定'
    if start_date == None and start_time != None:
        content += address_content + u'，' + u'日期暂定' + u'，' + u'时间:' + datetime.time.strftime(start_time, '%H:%M')
    if start_date != None and start_time != None:
        content += address_content + u'，' + u'具体时间：' + datetime.date.strftime(start_date, '%Y-%m-%d') + ' ' + datetime.time.strftime(start_time, '%H:%M')        
    content += u'。'
    return content

@login_required
def invite_list_ajax(request, party_id):
    party_clients_datas , party_clients_list = _invite_list(request, party_id)
    for party_client in party_clients_list:
        if not party_client.is_check:
            party_client.is_check = True
            party_client.save()
    
    return HttpResponse(simplejson.dumps(party_clients_datas))

def ajax_get_client_list(request, party_id):
    party_clients_datas , party_clients_list = _invite_list(request, party_id) 
    party = get_object_or_404(Party, id = party_id, creator = request.user)
    client_count = _get_client_count(party)
    data = {
            'party_clients_datas' : party_clients_datas,
            'client_count' : client_count
            }
    return HttpResponse(simplejson.dumps(data))

def _invite_list(request, party_id):
    apply_status = request.GET.get('apply', 'all')
    party = get_object_or_404(Party, id = party_id, creator=request.user)
    
    if apply_status == 'all':
        party_clients_list = PartiesClients.objects.select_related('client').filter(party = party)
    else:
        party_clients_list = PartiesClients.objects.select_related('client').filter(party = party).filter(apply_status = apply_status)
    
    party_clients_datas = []
    for party_client in party_clients_list:
        party_client_data = {
            'id' : party_client.id,
            'client_id' : party_client.client.id,
            'name' : party_client.client.name,
            'address': party.invite_type == 'email' and party_client.client.email or party_client.client.phone,
            'is_check': party_client.is_check,
            'leave_message' : party_client.leave_message
        }    
        party_clients_datas.append(party_client_data)
        
    return  party_clients_datas, party_clients_list    
