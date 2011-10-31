#coding=utf-8
import gdata.calendar
import atom
import gdata.calendar.service

import time, datetime, re, os, dummy

from settings import DOMAIN_NAME

from django.shortcuts import redirect, get_object_or_404
from django.utils import simplejson
from django.core.urlresolvers import reverse
from django.shortcuts import redirect

from events.models import MeetingsClients




def InsertSingleEvent(authsub_token, id, title, content, where, start_time = None, end_time = None):
    event = gdata.calendar.CalendarEventEntry()
    event.title = atom.Title(text = title)
    event.content = atom.Content(text = content)
    event.where.append(gdata.calendar.Where(value_string = where))

    
    if start_time is None:
        # Use current time for the start_time and have the event last 1 hour
        start_time = time.strftime('%Y-%m-%dT%H:%M:%S', time.localtime())
        end_time = time.strftime('%Y-%m-%dT%H:%M:%S', time.localtime(time.time() + 3600))
    else:
        start_time = time.strftime('%Y-%m-%dT%H:%M:%S', start_time)
        end_time = time.strftime('%Y-%m-%dT%H:%M:%S', end_time)
    event.when.append(gdata.calendar.When(start_time = start_time, end_time = end_time))
    calendar_service = gdata.calendar.service.CalendarService()
    calendar_service.auth_token = authsub_token
    calendar_service.SetAuthSubToken(authsub_token)
    calendar_service.UpgradeToSessionToken()
#    calendar_service.email = 'lichao@cn-acg.com'
#    calendar_service.password = 'woshizhu'
#    calendar_service.source = 'Google-Calendar_Python_Sample-1.0'
#    calendar_service.ProgrammaticLogin()
    feed = calendar_service.GetCalendarListFeed()
    try:
        new_event = calendar_service.InsertEvent(event, '/calendar/feeds/default/private/full')
        status = '200'
    except Exception, e:
        status = e[0]['status']
    return status

def GetAuthSubUrl(id):
    meeting_id = id.split('/')[0]
    meeting_client_id = int(id.split('/')[1])
    meeting_client = get_object_or_404(MeetingsClients, id = meeting_client_id)
    next = DOMAIN_NAME + '/events/' + meeting_id + '/apply/add_to_calendar?client_key=' + meeting_client.client_key
    scope = 'http://www.google.com/calendar/feeds/'
    secure = False
    session = True
    calendar_service = gdata.calendar.service.CalendarService()
    return calendar_service.GenerateAuthSubURL(next, scope, secure, session);

def GCalender_setup_json_data(meeting, meetingclient = ''):
    if meeting.start_time is None:
        # Use current time for the start_time and have the event last 1 hour
        start_time = time.strftime('%Y-%m-%dT%H:%M:%S.000', time.localtime())
        end_time = time.strftime('%Y-%m-%dT%H:%M:%S.000', time.localtime(time.time() + 3600))
    else:
        start_time = datetime.datetime.strftime(meeting.start_time, '%Y-%m-%dT%H:%M:%S000')
        end_time = datetime.datetime.strftime(meeting.end_time, '%Y-%m-%dT%H:%M:%S000')
    if meetingclient:
        data = {
                "title": meeting.title,
                "content": "会议的相关页面：" + meeting.url + meetingclient.client_key,
                "location": meeting.address,
                "start_time": start_time,
                "end_time": end_time
                }
    else:
        data = {"title":  meeting.title,
                "content": "会议的相关页面：" + meeting.url ,
                "location": meeting.address,
                "start_time": start_time,
                "end_time": end_time
                }
    data_json = simplejson.dumps(data)
    return data_json

'''
    生成文件，新建
'''
def Calender_setup_ics_file(meeting, meetingclient = ''):
    FILE_PATH = 'icalendar_files/'
    start_time = datetime.datetime.strftime(meeting.start_time, '%Y%m%dT%H%M%S')
    end_time = datetime.datetime.strftime(meeting.end_time, '%Y%m%dT%H%M%S')
    present_time = datetime.datetime.strftime(datetime.datetime.now(), '%Y%m%dT%H%M%S')
    data = {
            u'[开始时间]':start_time,
            u'[结束时间]':end_time,
            u'[邀请人姓名]':meeting.company.name,
            u'[邀请人邮箱]':meeting.creator.email,
            u'[日历地址]':meeting.address,
            u'[日历标题]':meeting.title,
            u'[当前时间]':present_time,
            }
    if meetingclient:
        myfile = open(FILE_PATH + "examples/icalendar.ics", 'r')  
        old_content = myfile.read()
        myfile.close()
        content = "会议的相关页面：" + meeting.url + meetingclient.client_key
        data.update({u'[日历内容]':content})
        data.update({u'[被邀请人姓名]':meetingclient.client.name})
        data.update({u'[被邀请人邮箱]':meetingclient.client.email})
        for key, value in data.items():
            old_content = old_content.replace(key, value)
        folder_name = datetime.datetime.strftime(datetime.datetime.now(), '%Y%m%d')
        personal_folder_name = 'MID' + str(meeting.id) + 'MCID' + str(meetingclient.id)
        file_path = FILE_PATH + folder_name + r'/' + personal_folder_name + '/' + meeting.title + '.ics'
        try:
            os.makedirs(FILE_PATH + folder_name + r'/' + personal_folder_name)
        except Exception, e:
            pass
        f = open(file_path, "w") 
        f.write(old_content)
        f.close()
    else:
        myfile = open(FILE_PATH + "examples/icalendar_noclient.ics", 'r')  
        old_content = myfile.read()
        myfile.close()
        content = "会议的相关页面：" + meeting.url
        data.update({u'[日历内容]':content})
        for key, value in data.items():
            old_content = old_content.replace(key, value)
        folder_name = r'meeting/' + str(meeting.id)
        file_path = FILE_PATH + folder_name + '/' + meeting.title + '.ics'
        try:
            os.makedirs(r'icalendar_files/' + folder_name)
        except Exception, e:
            pass
        f = open(file_path, "w")
        f.write(old_content)
        f.close()
    file_path = DOMAIN_NAME + r'/' + file_path
    print file_path
    return file_path