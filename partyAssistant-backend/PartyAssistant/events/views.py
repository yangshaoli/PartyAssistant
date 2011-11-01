#coding=utf-8
'''
Created on 2011-10-27

@author: liuxue
'''

from django.contrib.auth.models import User
from models import Meeting
from django.shortcuts import render_to_response, get_object_or_404
from forms import createPartyForm
from tools.datetime_tool import time_combine
DEBUG = True
def createParty(request):
    '''
    创建活动：需要会议的名称，时间（起始时间，结束时间），地点，创建人
    '''
    print request.user
    if DEBUG:
        #设置假的request.user ，设置DEBUG切换状态大
        if 'AnonymousUser' == str(request.user):
            request.user=User.objects.get(pk=1) 
            
    if request.method=='POST':
        form = createPartyForm(request.POST)
        if form.is_valid():        
            start_time = time_combine(form.cleaned_data['start_date'],
                                      str(form.cleaned_data['start_time']))
            end_time = time_combine(form.cleaned_data['end_date'],
                                    str(form.cleaned_data['end_time']))
            address=form.cleaned_data['address']
            remarks=form.cleaned_data['remarks']  
            Meeting.objects.create(
                           start_time = start_time,
                           end_time = end_time,
                           address = address,
                           remarks = remarks,                           
                           creater = request.user                                 
                           );
            #完成后跳转位置  暂时用index。html               
            return render_to_response('index.html',{'message':'create'});
        else:
            return render_to_response('events/createParty.html',{'form':form}) 
    else:
        form = createPartyForm()
        return render_to_response('events/createParty.html',{'form':form})

 

def deleteParty(request):
    meetingid=request.GET['meetingid']
    meeting=get_object_or_404(Meeting,pk=meetingid)
    Meeting.delete(meeting)
    return render_to_response('index.html',{'message','delete'})
 

