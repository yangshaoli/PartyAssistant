#coding=utf-8
'''
Created on 2011-10-27

@author: liuxue
'''

from models import Party
from django.shortcuts import render_to_response, redirect, get_object_or_404
from django.core.urlresolvers import reverse
from django.template import RequestContext

from forms import CreatePartyForm, InviteForm
from tools.email_tool import send_emails
from settings import SYS_EMAIL_ADDRESS

def create_party(request):            
    if request.method=='POST':
        form = CreatePartyForm(request.POST)
        if form.is_valid():        
            start_time = form.cleaned_data['start_time']
            end_time = form.cleaned_data['end_time']
            address=form.cleaned_data['address']
            description=form.cleaned_data['description']  
            limit_num = form.cleaned_data['limit_num']   
            Party.objects.create(
                           start_time=start_time,
                           end_time=end_time,
                           address=address,
                           description=description,                           
                           creator=request.user,
                           limit_num=limit_num                                  
                           );
            #判断用户选择的通知方式
            if request.POST['invite_type'] == 'email':
                return redirect(reverse('email_invite'))
            else:
                return redirect(reverse('message_invite'))
        else:
            return render_to_response('parties/create_party.html',{'form':form}, context_instance=RequestContext(request)) 
    else:
        form = CreatePartyForm()
        return render_to_response('parties/create_party.html',{'form':form}, context_instance=RequestContext(request))


def delete_party(request,party_id):
    party=get_object_or_404(Party,pk=party_id)
    Party.delete(party)
    return render_to_response('list_party.html',{'message','delete success jump to list_party'})
 
def message_invite(request):
    form = InviteForm()
    return render_to_response('parties/invite.html',{'form':form, 'title':u'发送短信通知'}, context_instance=RequestContext(request))

def email_invite(request):
    email_subject = u'[PartyAssistant]您收到一个活动邀请'
    
    if request.method=='POST':
        form = InviteForm(request.POST)
        if form.is_valid():
            addressees = form.cleaned_data['addressee']
            content = form.cleaned_data['content']
            for addressee in addressees.split(','):
                send_emails(email_subject, content, SYS_EMAIL_ADDRESS, [addressee])
            return render_to_response('message.html', context_instance=RequestContext(request))
    else:
        form = InviteForm()
        return render_to_response('parties/invite.html',{'form':form , 'title':u'发送邮件通知'}, context_instance=RequestContext(request))

def list_party(request):
    party_list = Party.objects.all()
    ctx = {
        'party_list' : party_list
        
    }
    return render_to_response('parties/list.html', ctx ,context_instance=RequestContext(request))

def show_party(request, id):
    pass