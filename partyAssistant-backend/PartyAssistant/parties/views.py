#coding=utf-8
'''
Created on 2011-10-27

@author: liuxue
'''

from models import Party
from django.shortcuts import render_to_response, get_object_or_404
from forms import CreatePartyForm
from django.template import RequestContext
from django.http import HttpResponse
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

 

def delete_party(request):
    if request.method=='GET':
        return render_to_response('parties/delete_party_test.html',context_instance=RequestContext(request))
    else:
        party=get_object_or_404(Party,pk=request.POST['party_id'])
        Party.delete(party) 
        return HttpResponse("OK")
 

