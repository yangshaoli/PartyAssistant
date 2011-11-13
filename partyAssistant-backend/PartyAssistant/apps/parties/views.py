#coding=utf-8
'''
Created on 2011-10-27

@author: liuxue
'''

from apps.clients.models import Client
from apps.messages.forms import EmailInviteForm
from apps.messages.models import EmailMessage
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
import datetime



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
        form = EmailInviteForm()
    
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
    
    party = Party.objects.get(pk=party_id)
    
    clients = Client.objects.filter(party=party)
    
    return render_to_response('parties/create_party.html',{'form':CreatePartyForm(instance=party)},context_instance=RequestContext(request))
#
#    if request.method == 'GET':
#        old_party = Party.objects.get(pk=int(party_id))        
#        date = datetime.datetime.strftime(old_party.time,'%Y-%m-%d')
#        time = datetime.datetime.strftime(old_party.time,'%H:%M:%S')
#        return render_to_response('parties/copy_party.html',{'old_party':old_party,'date':date,'time':time,'form':CreatePartyForm()},context_instance=RequestContext(request))
#    else :
#        old_party = Party.objects.get(pk=int(party_id))
#        form = CreatePartyForm(request.POST)
#        if form.is_valid():        
#            time = form.cleaned_data['time']
#            address=form.cleaned_data['address']
#            description=form.cleaned_data['description']  
#            limit_num = form.cleaned_data['limit_num']   
#            new_party=Party.objects.create(
#                           time=time,
#                           address=address,
#                           description=description,                           
#                           creator=request.user,
#                           limit_num=limit_num                                  
#                           );
#            #复制联系人
#            client_party_list = PartiesClients.objects.filter(party=old_party) 
#            for client_party in client_party_list:
#                PartiesClients.objects.create(
#                                            client =client_party.client,
#                                            party=new_party,
#                                            apply_status=u'被邀请'
#                                            )       
#            return list_party(request)
#        else:
#            return render_to_response('parties/copy_party.html',{'form':form,'old_party':old_party}, context_instance=RequestContext(request)) 
    

'''
@summary: 处理短信邀请和邮件邀请
@author: chenyang
'''
def message_invite(request):
    form = InviteForm()
    return render_to_response('parties/invite.html',{'form':form, 'title':u'发送短信通知'}, context_instance=RequestContext(request))

#def email_invite(request, party_id):
#    email_subject = u'[PartyAssistant]您收到一个活动邀请'
#    party = Party.objects.get(pk=party_id)
#    if request.method=='POST':
#        form = InviteForm(request.POST)
#        if form.is_valid():
#            addressees = form.cleaned_data['addressee']
#            content = form.cleaned_data['content']
#            for addressee in addressees.split(','):
#                if addressee:
#                #如果带报名提示，则内容中带上报名链接
#                    if request.POST['enroll_link']:
#                        enroll_link = DOMAIN_NAME+'/clients/invite_enroll/'+addressee+'/'+party_id
#                        content = content + u'点击进入报名页面：<a href="%s">%s</a>' % (enroll_link, enroll_link)
#                    send_emails(email_subject, content, SYS_EMAIL_ADDRESS, [addressee])
#                    #将收件人加入clients,状态为'未报名'
#                    if Client.objects.filter(email=addressee, creator=User.objects.get(pk=request.user.id)).count() == 0:
#                        client = Client.objects.create(email=addressee, creator=User.objects.get(pk=request.user.id), invite_type='email')
#                        PartiesClients.objects.create(client=client, party=Party.objects.get(pk=party_id), apply_status=u'未报名')
#            return render_to_response('message.html', context_instance=RequestContext(request))
#    else:
#        form = InviteForm()
#        ctx = {
#            'form':form,
#            'party':party,
#            'invite_num':Client.objects.filter(invite_type='email').count(),
#            'title':u'发送邮件通知'
#        }
#        return render_to_response('parties/invite.html', ctx, context_instance=RequestContext(request))

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
