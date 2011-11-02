#coding=utf-8
'''
Created on 2011-10-27

@author: liuxue
'''

from models import Party
from django.shortcuts import render_to_response, get_object_or_404
from forms import CreatePartyForm
from django.template import RequestContext
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
            return render_to_response('list_party.html',{'message':'create success jump to list_party'}, context_instance=RequestContext(request));
        else:
            return render_to_response('events/create_party.html',{'form':form}, context_instance=RequestContext(request)) 
    else:
        form = CreatePartyForm()
        return render_to_response('events/create_party.html',{'form':form}, context_instance=RequestContext(request))

 

def delete_party(request,party_id):
    party=get_object_or_404(Party,pk=party_id)
    Party.delete(party)
    return render_to_response('list_party.html',{'message','delete success jump to list_party'})
 

