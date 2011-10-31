#coding=utf-8
'''
Created on 2011-10-27

@author: liuxue
'''
import datetime
import os
import re
from models import Meeting
from django.db.transaction import commit_on_success
from django.contrib.auth.decorators import login_required, user_passes_test
from django.core.urlresolvers import reverse
from django.http import HttpResponse
from django.shortcuts import render_to_response, get_object_or_404, redirect
from django.utils import simplejson
def index(request):
    print "index"
    if request.method=="POST":
        print ""
def createParty(request):
    '''
    创建活动：需要会议的名称，时间（起始时间，结束时间），地点，创建人
    '''
    if request.method=='POST':
        #get 请求，创建空的会议，创建成功后跳转到创建会议界面
        title=request.POST['title']
        start_time=request.POST['start_time']
        end_time=request.POST['end_time']
        address=request.POST['address']
        remarks=request.POST['remarks']
#        sender_name=request.post['user'].name
        meeting=Meeting.objects.create(
                       title = title,
                       start_time = start_time,
                       end_time = end_time,
                       address = address,
                       remarks = remarks,
                       url = '',
                       status = '',                       
                       created_time = datetime.datetime,
                       last_modified_time = datetime.datetime,
                       creater = ''#没有人登录，暂时设置1                                  
                       );
        return render_to_response('index.html',{'message':'create'});
    else:
        return render_to_response('events/createParty.html')

def modifyParty(request):
    pass

def deleteParty(request):
    meetingid=request.GET['meetingid']
    meeting=get_object_or_404(Meeting,pk=meetingid)
    Meeting.delete(meeting)
    return render_to_response('index.html',{'message','delete'})


def listParty(request):
    pass

def modifyParty_Ajax(request):
    pass

