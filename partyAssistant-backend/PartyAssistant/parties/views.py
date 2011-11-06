#coding=utf-8
'''
Created on 2011-10-27

@author: liuxue
'''
from django.views.decorators.csrf import csrf_protect
from models import Party
from django.shortcuts import render_to_response, get_object_or_404
from forms import CreatePartyForm
from django.template import RequestContext
from clients.models import Client_Party
def create_party(request):            
    if request.method=='POST':
        form = CreatePartyForm(request.POST)
        if form.is_valid():        
            time = form.cleaned_data['time']
            address=form.cleaned_data['address']
            description=form.cleaned_data['description']  
            limit_num = form.cleaned_data['limit_num']   
            Party.objects.create(
                           time=time,
                           address=address,
                           description=description,                           
                           creator=request.user,
                           limit_num=limit_num                                  
                           );
            return render_to_response('list_party.html',{'message':'create success jump to list_party'}, context_instance=RequestContext(request));
        else:
            return render_to_response('parties/create_party.html',{'form':form}, context_instance=RequestContext(request)) 
    else:
        form = CreatePartyForm()
        return render_to_response('parties/create_party.html',{'form':form}, context_instance=RequestContext(request))

 

def delete_party(request,party_id):          
    party=get_object_or_404(Party,pk=party_id)
    Party.delete(party) 
    return render_to_response('list_party.html',{'message':'create success jump to list_party'}, context_instance=RequestContext(request));
        
@csrf_protect
def copy_party(request,party_id):#复制party和联系人
    if request.method == 'GET':
        print"_____"        
        print party_id
        old_party = Party.objects.get(pk=int(party_id))
        print old_party 
        return render_to_response('parties/copy_party.html',{'old_party':old_party,'party_id':party_id,'form':CreatePartyForm()},context_instance=RequestContext(request))
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
            client_party_list = Client_Party.objects.filter(party=old_party) 
            for client_party in client_party_list:
                Client_Party.objects.create(
                                            client =client_party.client,
                                            party=new_party,
                                            apply_status=u'未响应'
                                            )       
            return render_to_response('list_party.html',{'message':'create success jump to list_party'}, context_instance=RequestContext(request));
        else:
            return render_to_response('parties/copy_party.html',{'form':form,'party_id':party_id,'old_party':old_party}, context_instance=RequestContext(request)) 
    

def modify_party(request,party_id):
    if request.method=='GET':
        party = Party.objects.get(pk=party_id)
        form = CreatePartyForm()
        return render_to_response('parties/modify_party.html',{'form':form,'party_id':party_id,'party':party}, context_instance=RequestContext(request));
    else :
        party = Party.objects.get(pk=party_id)
        form = CreatePartyForm(request.POST)
        if form.is_valid():        
            party.time = form.cleaned_data['time']
            party.address=form.cleaned_data['address']
            party.description=form.cleaned_data['description']  
            party.limit_num = form.cleaned_data['limit_num']               
            return render_to_response('list_party.html',{'message':'create success jump to list_party'}, context_instance=RequestContext(request));
        else:
            return render_to_response('parties/modify_party.html',{'form':form,'party_id':party_id,'party':party}, context_instance=RequestContext(request));
        