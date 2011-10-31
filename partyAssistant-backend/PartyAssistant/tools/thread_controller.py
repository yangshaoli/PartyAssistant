#coding=utf-8
import threading, time, datetime


from threading import Thread

from tools.exceptions import MyError
from tools.email_tool import send_emails, send_sms
from tools.barcode_tool import make_code39_file

from messages.models import MessageTask, SendMessageDetail, MeetingNotice
from events.models import Event, MeetingsClients, ErrorEvent, MeetingSchedule, SchedulesClients

send_message_event_detail = [u'已报名', u'审批通过', u'拒绝审批']

client_info_tag_list = [u'[参会者姓名]', u'[参会者姓名+称谓]', u'[参会者手机号码]', u'[参会者公司名称]', u'[参会者邮箱]', u'[参会者分组]', u'[参会者条形码(39码)]', u'[参会者条形码(QR码)]']
event_info_tag_list = [u'[会议名称]', u'[会议开始时间]', u'[会议结束时间]', u'[会议地点]', u'[会议类型]', u'[会议备注]', u'[会议状态]', u'[报名网址]', u'[反馈表网址]', u'[查看报名人数网址]', u'[已报名人数]', u'[添加至Google日历]', u'[下载日历文件]']
user_info_tag_list = [u'[用户姓名]', u'[用户公司名称]']
schedule_info_list = [u'[日程标题]', u'[日程内容]', u'[日程开始时间]', u'[日程结束时间]']

def SaveSendingDetail(message_task, client, object_type, status):
    send_sms_detail = SendMessageDetail()
    send_sms_detail.client_id = client.id
    send_sms_detail.object_id = message_task.id
    send_sms_detail.object_type = object_type
    send_sms_detail.status = status
    send_sms_detail.subject = message_task.subject
    send_sms_detail.content = message_task.content
    send_sms_detail.name = client.name
    send_sms_detail.email = client.email
    send_sms_detail.cell_phone = client.cell_phone
    send_sms_detail.company = client.company
#    send_sms_detail.gender = client.gender
    send_sms_detail.group = client.group
    send_sms_detail.send_time = datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    send_sms_detail.save()
    
def replace_tags_in_email_content(new_content, message_task, client_info_list, meeting_info_list, user_info_tag_list, client, meeting):
    for client_info in client_info_list:
        meeting_client = MeetingsClients.objects.get(meeting = meeting, client = client)
        client_key = 'MC' + str(meeting_client.id).rjust(10, '0')
        if new_content.find(client_info) != -1:
            if client_info == u'[参会者姓名]':
                new_content = new_content.replace(client_info, client.name)
            if client_info == u'[参会者姓名+称谓]':
                if client.gender == u'男':
                    genderStr = u'先生'
                elif client.gender == u'女':
                    genderStr = u'女士'
                else:
                    genderStr = u'先生/女士'
                new_content = new_content.replace(client_info, "%s %s" % (client.name, genderStr))
            if client_info == u'[参会者手机号码]':
                new_content = new_content.replace(client_info, client.cell_phone)
            if client_info == u'[参会者公司名称]':
                new_content = new_content.replace(client_info, client.company)
            if client_info == u'[参会者邮箱]':
                new_content = new_content.replace(client_info, client.email)
            if client_info == u'[参会者分组]':
                new_content = new_content.replace(client_info, client.group)
            if client_info == u'[参会者条形码(39码)]':
                src_name = make_code39_file(meeting_client)
                new_content = new_content.replace(client_info, '<embed src="' + src_name + '" height = "80px" width="200" type ="image/svg+xml" pluginspage ="http://www.adobe.com/svg/viewer/install/"/>')
                #new_content = new_content.replace(client_info, '<iframe  src ="' + src_name + '"  width ="300"  height ="100"></iframe>')
            if client_info == u'[参会者条形码(QR码)]':
                new_content = new_content.replace(client_info, '<img src="http://chart.apis.google.com/chart?cht=qr&chl=' + client_key + '&chs=120x120"></img>')
    for meeting_info in event_info_tag_list:
        if new_content.find(meeting_info) != -1:
            if meeting_info == u'[会议名称]':
                new_content = new_content.replace(meeting_info, meeting.title)
            if meeting_info == u'[会议开始时间]':
                new_content = new_content.replace(meeting_info, str(meeting.start_time.strftime(u'%Y年%m月%d日 %H:%M')))
            if meeting_info == u'[会议结束时间]':
                new_content = new_content.replace(meeting_info, str(meeting.end_time.strftime(u'%Y年%m月%d日 %H:%M')))
            if meeting_info == u'[会议地点]':
                new_content = new_content.replace(meeting_info, meeting.address)
            if meeting_info == u'[会议类型]':
                new_content = new_content.replace(meeting_info, meeting.type)
            if meeting_info == u'[会议备注]':
                new_content = new_content.replace(meeting_info, meeting.remarks.replace('\r\n', '<br>'))
            if meeting_info == u'[已报名人数]':
                if meeting.apply_option:
                    new_content = new_content.replace(meeting_info, len(MeetingsClients.objects.filter(meeting = meeting, apply_status = u'已报名')))
                else:
                    new_content = new_content.replace(meeting_info, len(MeetingsClients.objects.filter(meeting = meeting)))
            if meeting_info == u'[查看报名人数网址]':
                new_content = new_content.replace(meeting_info, meeting.url + 'status/show/')
            if meeting_info == u'[反馈表网址]':
                try:
                    meetingclient = MeetingsClients.objects.get(meeting = meeting, client = client)
                    url = meeting.url[0:-6] + 'feedback/collect/' + meetingclient.client_key
                except Exception:
                    url = u'（对不起，反馈网址只能提供给参加会议的与会者）'
                new_content = new_content.replace(meeting_info, url)
            if meeting_info == u'[报名网址]':
                try:
                    meetingclient = MeetingsClients.objects.get(meeting = meeting, client = client)
                    url = meeting.url + meetingclient.client_key
                except Exception:
                    url = meeting.url
                new_content = new_content.replace(meeting_info, url)
            if meeting_info == u'[会议状态]':
                new_content = new_content.replace(meeting_info, meeting.status)
            if meeting_info == u'[添加至Google日历]':
                try:
                    meetingclient = MeetingsClients.objects.get(meeting = meeting, client = client)
                    url = '<a href="' + meeting.url[0:-6] + 'calendar/add/' + str(meetingclient.id) + '/' + meetingclient.client_key + '">添加至Google日历</a>'
                except Exception:
                    url = '<a href="' + meeting.url[0:-6] + 'calendar/add/' + '">添加至Google日历</a>'
                new_content = new_content.replace(meeting_info, url)
            if meeting_info == u'[下载日历文件]':
                try:
                    meetingclient = MeetingsClients.objects.get(meeting = meeting, client = client)
                    url = '<a href="' + meeting.url[0:-6] + 'calendar/download/' + str(meetingclient.id) + '/' + meetingclient.client_key + '">下载日历文件</a>'
                except Exception:
                    url = '<a href="' + meeting.url[0:-6] + 'calendar/download/' + '">下载日历文件</a>'
                new_content = new_content.replace(meeting_info, url)
    for user_info in user_info_tag_list:
        if new_content.find(user_info) != -1:
            if user_info == u'[用户姓名]':
                new_content = new_content.replace(user_info, meeting.creator.username)
            if user_info == u'[用户公司名称]':
                new_content = new_content.replace(user_info, meeting.company.name)
    if isinstance(message_task, MeetingNotice):
        if message_task.object_type == u'日程':
            if MeetingSchedule.objects.get(pk = message_task.object_id):
                schedule = MeetingSchedule.objects.get(pk = message_task.object_id)
                for schedule_info in schedule_info_list:
                    if new_content.find(schedule_info) != -1:
                        if schedule_info == u'[日程标题]':
                            new_content = new_content.replace(schedule_info, schedule.title)
                        elif schedule_info == u'[日程内容]':
                            new_content = new_content.replace(schedule_info, schedule.content)
                        elif schedule_info == u'[日程开始时间]':
                            new_content = new_content.replace(schedule_info, str(schedule.start_time.strftime('%Y-%m-%d %H:%M')))
                        elif schedule_info == u'[日程结束时间]':
                            new_content = new_content.replace(schedule_info, str(schedule.end_time.strftime('%Y-%m-%d %H:%M')))
    return new_content 

def replace_tags_in_sms_content(new_content, message_task, client_info_list, meeting_info_list, user_info_tag_list, client, meeting):
    for client_info in client_info_list:
        meeting_client = MeetingsClients.objects.get(meeting = meeting, client = client)
        client_key = 'MC' + str(meeting_client.id).rjust(10, '0')
        if new_content.find(client_info) != -1:
            if client_info == u'[参会者姓名]':
                new_content = new_content.replace(client_info, client.name)
            if client_info == u'[参会者姓名+称谓]':
                if client.gender == u'男':
                    genderStr = u'先生'
                elif client.gender == u'女':
                    genderStr = u'女士'
                else:
                    genderStr = u'先生/女士'
                new_content = new_content.replace(client_info, "%s %s" % (client.name, genderStr))
            if client_info == u'[参会者手机号码]':
                new_content = new_content.replace(client_info, client.cell_phone)
            if client_info == u'[参会者公司名称]':
                new_content = new_content.replace(client_info, client.company)
            if client_info == u'[参会者邮箱]':
                new_content = new_content.replace(client_info, client.email)
            if client_info == u'[参会者分组]':
                new_content = new_content.replace(client_info, client.group)
            if client_info == u'[参会者条形码(39码)]':
                src_name = make_code39_file(meeting_client)
                new_content = new_content.replace(client_info, '<img src="' + src_name + '" height = "80px" width="200" />')
                #new_content = new_content.replace(client_info, '<iframe  src ="' + src_name + '"  width ="300"  height ="100"></iframe>')
            if client_info == u'[参会者条形码(QR码)]':
                new_content = new_content.replace(client_info, '<img src="http://chart.apis.google.com/chart?cht=qr&chl=' + client_key + '&chs=120x120"></img>')
    for meeting_info in event_info_tag_list:
        if new_content.find(meeting_info) != -1:
            if meeting_info == u'[会议名称]':
                new_content = new_content.replace(meeting_info, meeting.title)
            if meeting_info == u'[会议开始时间]':
                new_content = new_content.replace(meeting_info, str(meeting.start_time.strftime(u'%Y年%m月%d日 %H:%M')))
            if meeting_info == u'[会议结束时间]':
                new_content = new_content.replace(meeting_info, str(meeting.end_time.strftime(u'%Y年%m月%d日 %H:%M')))
            if meeting_info == u'[会议地点]':
                new_content = new_content.replace(meeting_info, meeting.address)
            if meeting_info == u'[会议类型]':
                new_content = new_content.replace(meeting_info, meeting.type)
            if meeting_info == u'[会议备注]':
                new_content = new_content.replace(meeting_info, meeting.remarks)
            if meeting_info == u'[已报名人数]':
                if meeting.apply_option:
                    new_content = new_content.replace(meeting_info, len(MeetingsClients.objects.filter(meeting = meeting, apply_status = u'已报名')))
                else:
                    new_content = new_content.replace(meeting_info, len(MeetingsClients.objects.filter(meeting = meeting)))
            if meeting_info == u'[查看报名人数网址]':
                new_content = new_content.replace(meeting_info, meeting.url + 'status/show/')
            if meeting_info == u'[反馈表网址]':
                try:
                    meetingclient = MeetingsClients.objects.get(meeting = meeting, client = client)
                    url = meeting.url[0:-6] + 'feedback/collect/' + meetingclient.client_key
                except Exception:
                    url = u'（对不起，反馈网址只能提供给参加会议的与会者）'
                new_content = new_content.replace(meeting_info, url)
            if meeting_info == u'[报名网址]':
                try:
                    meetingclient = MeetingsClients.objects.get(meeting = meeting, client = client)
                    url = meeting.url + meetingclient.client_key
                except Exception:
                    url = meeting.url
                new_content = new_content.replace(meeting_info, url)
            if meeting_info == u'[会议状态]':
                new_content = new_content.replace(meeting_info, meeting.status)
    for user_info in user_info_tag_list:
        if new_content.find(user_info) != -1:
            if user_info == u'[用户姓名]':
                new_content = new_content.replace(user_info, meeting.creator.username)
            if user_info == u'[用户公司名称]':
                new_content = new_content.replace(user_info, meeting.company.name)
    if isinstance(message_task, MeetingNotice):
        if message_task.object_type == u'日程':
            if MeetingSchedule.objects.get(pk = message_task.object_id):
                schedule = MeetingSchedule.objects.get(pk = message_task.object_id)
                for schedule_info in schedule_info_list:
                    if new_content.find(schedule_info) != -1:
                        if schedule_info == u'[日程标题]':
                            new_content = new_content.replace(schedule_info, schedule.title)
                        elif schedule_info == u'[日程内容]':
                            new_content = new_content.replace(schedule_info, schedule.content)
                        elif schedule_info == u'[日程开始时间]':
                            new_content = new_content.replace(schedule_info, str(schedule.start_time.strftime('%Y-%m-%d %H:%M')))
                        elif schedule_info == u'[日程结束时间]':
                            new_content = new_content.replace(schedule_info, str(schedule.end_time.strftime('%Y-%m-%d %H:%M')))
    return new_content 
def send_message_on_detonate_handler(event):
    if event.type == u"状态变化" and event.object_type == u'MeetingsClients' and event.detail in send_message_event_detail:
        try:
            meeting_client = MeetingsClients.objects.get(pk = event.object_id)
        except Exception:
            raise MyError(u'该会议对应的参会者记录没找到')
        meeting = meeting_client.meeting
        client = meeting_client.client
        if event.detail == u'已报名':
            message_task_list = MessageTask.objects.filter(meeting = meeting, running = True, type = u'事件触发发送' , option = u'参会者报名信息提交后')
        elif event.detail == u'审批通过':
            message_task_list = MessageTask.objects.filter(meeting = meeting, running = True, type = u'事件触发发送' , option = u'审批通过')
        elif event.detail == u'拒绝审批':
            message_task_list = MessageTask.objects.filter(meeting = meeting, running = True, type = u'事件触发发送' , option = u'拒绝审批')
        if message_task_list:
            for message_task in message_task_list:
                subject = message_task.subject
                content = message_task.content
                if message_task.content_type == 'Email':
                    message_task.content = replace_tags_in_email_content(message_task.content, message_task, client_info_tag_list, event_info_tag_list, user_info_tag_list, client, meeting)
                    message_task.subject = replace_tags_in_email_content(message_task.subject, message_task, client_info_tag_list, event_info_tag_list, user_info_tag_list, client, meeting)
                    try:
                        if message_task.sender_name == '':
                            send_emails(message_task.subject, message_task.content, meeting.creator.email, [client.email])
                        else:
                            send_emails(message_task.subject, message_task.content, '"%s"<%s>' % (message_task.sender_name, meeting.creator.email), [client.email])
                        SaveSendingDetail(message_task, client, u'邮件任务', u'发送成功')
                    except Exception:
                        SaveSendingDetail(message_task, client, u'邮件任务', u'发送失败')
                        raise MyError(u'发送失败')
                if message_task.content_type == 'SMS' and client.cell_phone != '':
                    message_task.content = replace_tags_in_sms_content(message_task.content, message_task, client_info_tag_list, event_info_tag_list, user_info_tag_list, client, meeting)
                    message_task.subject = replace_tags_in_sms_content(message_task.subject, message_task, client_info_tag_list, event_info_tag_list, user_info_tag_list, client, meeting)
                    try:
                        send_sms(message_task.content, client.cell_phone)
                        SaveSendingDetail(message_task, client, u'短信任务', u'发送成功')
                    except Exception:
                        SaveSendingDetail(message_task, client, u'短信任务', u'发送失败')
                        raise MyError(u'发送失败')
                message_task.subject = subject
                message_task.content = content
                message_task.status = u'发送完毕'
                message_task.save()
        
def send_notice_message(event):
    if event.type == u'发送' and event.object_type == u'提醒处理':
        notice = MeetingNotice.objects.get(pk = event.object_id)
        meeting = notice.meeting
        meetingclient_list = []
        if notice.notice_type == u'日程提醒':
            if MeetingSchedule.objects.filter(id = event.object_id):
                schedule = MeetingSchedule.objects.filter(id = event.object_id)[0]
                meetingclient_list = SchedulesClients.objects.filter(meeting = meeting, schedule = schedule, approve_status = u'审批通过')
        elif notice.notice_type == u'会议提醒':
            if meeting.apply_option:
                meetingclient_list = MeetingsClients.objects.filter(meeting = meeting, apply_status = u'已报名')
            elif meeting.approve_option:
                meetingclient_list = MeetingsClients.objects.filter(meeting = meeting, approve_status = u'审批通过')
            else:
                meetingclient_list = MeetingsClients.objects.filter(meeting = meeting)
        elif notice.notice_type == u'报名提醒':
            meetingclient_list = MeetingsClients.objects.filter(meeting = meeting, approve_status = u'未报名')
        elif notice.notice_type == u'反馈提醒':
            meetingclient_list = MeetingsClients.objects.filter(meeting = meeting, approve_status = u'已签到')
        if meetingclient_list:
            for meetingclient in meetingclient_list:
                client = meetingclient.client
                content = notice.content
                subject = notice.subject
                if notice.message_type == 'Email':
                    notice.content = replace_tags_in_email_content(notice.content, notice, client_info_tag_list, event_info_tag_list, user_info_tag_list, client, meeting)
                    notice.subject = replace_tags_in_email_content(notice.subject, notice, client_info_tag_list, event_info_tag_list, user_info_tag_list, client, meeting)
                    try:
                        if notice.sender_name == '':
                            send_emails(notice.subject, notice.content, meeting.creator.email, [client.email])
                        else:
                            send_emails(notice.subject, notice.content, '"%s"<%s>' % (notice.sender_name, meeting.creator.email), [client.email])
                        SaveSendingDetail(notice, client, u'邮件——' + notice.notice_type, u'发送成功')
                    except Exception:
                        SaveSendingDetail(notice, client, u'邮件——' + notice.notice_type, u'发送失败')
                        raise MyError(u'发送失败')
                elif notice.message_type == 'SMS' and client.cell_phone != '':
                    notice.content = replace_tags_in_sms_content(notice.content, notice, client_info_tag_list, event_info_tag_list, user_info_tag_list, client, meeting)
                    notice.subject = replace_tags_in_sms_content(notice.subject, notice, client_info_tag_list, event_info_tag_list, user_info_tag_list, client, meeting)
                    try:
                        send_sms(notice.content, client.cell_phone)
                        SaveSendingDetail(notice, client, u'短信——' + notice.notice_type, u'发送成功')
                    except Exception:
                        send_sms_detail = SendMessageDetail()
                        SaveSendingDetail(notice, client, u'短信——' + notice.notice_type, u'发送失败')
                        raise MyError(u'发送失败')
                notice.subject = subject
                notice.content = content
        notice.status = u'发送完毕'
        notice.save()

#def send_feedback_message(event):
#    if event.type == u'发送' and event.object_type == 'MeetingFeedback':
#        feedback = MeetingFeedback.objects.get(pk=event.object_id)
#        meeting = feedback.meeting
#        meetingclient_list = MeetingsClients.objects.filter(meeting=meeting, present_status=u'已签到')
#        if feedback.object_type == u'会议':
#            try:
#                object = Meeting.objects.get(id=feedback.object_id)
#                url = DOMAIN_NAME + '/events/' + str(meeting.id) + '/feedback/collect/'
#            except Exception:
#                raise MyError('Meeting Can Not Found')
#        elif feedback.object_type == u'日程':
#            try:
#                object = MeetingSchedule.objects.get(id=feedback.object_id)
#                url = DOMAIN_NAME + '/events/' + str(meeting.id) + '/schedule/' + str(object.id) + '/feedback/collect/'
#            except Exception:
#                raise MyError('MeetingSchedule Can Not Found')
#        
#        if meetingclient_list:
#            for meetingclient in meetingclient_list:
#                client = meetingclient.client
#                new_url = url + meetingclient.client_key + '/'
#                subject = u'EventManager系统提醒：您所参加的' + feedback.object_type + u'——' + object.title + u'——需要填写意见反馈表'
#                content = u'尊敬的' + client.name + u':<br>&nbsp;&nbsp;&nbsp;&nbsp;您所参加的'\
#                        + feedback.object_type + u'——' + object.title + u'——需要您抽出宝贵的几分钟时间填写您对该' \
#                        + feedback.object_type + u'的反馈建议，请您积极参与。<br>&nbsp;&nbsp;&nbsp;&nbsp;反馈的邮件地址为：'\
#                        + u'<link href=\'' + new_url + '\'>' + new_url + '</link>'
#                try:
#                    send_emails(subject, content, meeting.creator.email, [client.email])
#                    send_email_detail = SendMessageDetail()
#                    send_email_detail.client_id = client.id
#                    send_email_detail.object_id = feedback.id
#                    send_email_detail.object_type = 'Feedback'
#                    send_email_detail.subject = subject
#                    send_email_detail.content = content
#                    send_email_detail.status = u'已发送成功'
#                    send_email_detail.cell_phone = client.cell_phone
#                    send_email_detail.name = client.name
#                    send_email_detail.email = client.email
#                    send_email_detail.company = client.company
#                    send_email_detail.gender = client.gender
#                    send_email_detail.group = client.group
#                    send_email_detail.send_time = datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')
#                    send_email_detail.save()
#                except Exception:
#                    send_email_detail = SendMessageDetail()
#                    send_email_detail.client_id = client.id
#                    send_email_detail.object_id = feedback.id
#                    send_email_detail.object_type = 'Feedback'
#                    send_email_detail.cell_phone = client.cell_phone
#                    send_email_detail.status = u'发送失败'
#                    send_email_detail.subject = subject
#                    send_email_detail.content = content
#                    send_email_detail.name = client.name
#                    send_email_detail.email = client.email
#                    send_email_detail.company = client.company
#                    send_email_detail.gender = client.gender
#                    send_email_detail.group = client.group
#                    send_email_detail.send_time = datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')
#                    send_email_detail.save()
#                    raise MyError('Send Failed')
       
def send_message_not_on_detonate_handler(event):
    if event.type == u"发送" and event.object_type == u'任务处理':
        message_task = MessageTask.objects.get(pk = event.object_id)
        content = message_task.content
        subject = message_task.subject
        meeting = message_task.meeting
        client_id_list = eval(message_task.client_group.split(':')[1])
        meetingclient_list_list = MeetingsClients.objects.filter(pk__in = client_id_list)
        for meetingclient in meetingclient_list_list:
            client = meetingclient.client
            meeting = meetingclient.meeting
            if message_task.content_type == 'Email':
                message_task.content = replace_tags_in_email_content(message_task.content, message_task, client_info_tag_list, event_info_tag_list, user_info_tag_list, client, meeting)
                message_task.subject = replace_tags_in_email_content(message_task.subject, message_task, client_info_tag_list, event_info_tag_list, user_info_tag_list, client, meeting)
                try:
                    if message_task.sender_name == '':
                        send_emails(message_task.subject, message_task.content, meeting.creator.email, [client.email])
                    else:
                        send_emails(message_task.subject, message_task.content, '"%s"<%s>' % (message_task.sender_name, meeting.creator.email), [client.email])
                    SaveSendingDetail(message_task, client, u'邮件任务', u'发送成功')
                except MyError, e:
                    SaveSendingDetail(message_task, client, u'邮件任务', u'发送失败')
                    raise MyError(e.value)
            if message_task.content_type == 'SMS' and client.cell_phone != '':
                message_task.content = replace_tags_in_sms_content(message_task.content, message_task, client_info_tag_list, event_info_tag_list, user_info_tag_list, client, meeting)
                message_task.subject = replace_tags_in_sms_content(message_task.subject, message_task, client_info_tag_list, event_info_tag_list, user_info_tag_list, client, meeting)
                try:
                    send_sms(message_task.content, client.cell_phone)
                    SaveSendingDetail(message_task, client, u'短信任务', u'发送成功')
                except MyError, e:
                    SaveSendingDetail(message_task, client, u'短信任务', u'发送失败')
                    raise MyError(e.value)
            message_task.subject = subject
            message_task.content = content
        message_task.status = u'发送完毕'
        message_task.times += 1
        message_task.last_sending_time = datetime.datetime.now()
        if message_task.type != u'循环发送':
            message_task.running = False
        
        message_task.save()

class  EventDispatcherSingleton:
    instance = None
    
    def __init__(self):
        if EventDispatcherSingleton.instance is None:
            EventDispatcherSingleton.instance = EventDispatcherSingleton.EventDispatcherImpl()
            EventDispatcherSingleton.instance.setDaemon(True)
            EventDispatcherSingleton.instance.start()
            
    class EventDispatcherImpl(threading.Thread):
        dispatcher_map = {
                          u'状态变化': ['send_message_on_detonate_handler'],
                          u'发送':['send_message_not_on_detonate_handler', 'send_notice_message'],
                        }
        def __init__(self):
            Thread.__init__(self)

        def run(self):
#            pylucene_helper.attach_thread()
            while True:
                event_list = Event.objects.all()
                for event in event_list:
                    flag = True
                    if event.type in self.dispatcher_map:
                        for handler in self.dispatcher_map[event.type]:
                            try:
                                if event.current_func == '' or event.current_func == handler:
                                    eval(handler)(event)
                            except MyError, e:
                                print datetime.datetime.now(), 'Catch an exception—— ', e
                                
                                flag = False
                                event.current_func = handler
                                event.error_info = e.value
                                event.error_count = event.error_count + 1
                                event.save()
                                if event.error_count > 10:
                                    error_event = ErrorEvent.objects.create(object_id = event.object_id,
                                                                            object_type = event.object_type,
                                                                            type = event.type,
                                                                            detail = event.detail,
                                                                            error_info = event.error_info,
                                                                            current_func = event.current_func)
                                    event.delete()
                                break
                    if flag:
                        event.delete()
                time.sleep(1)

class EventCreateThreadSingleton:
    instance = None
    
    def __init__(self):
        if EventCreateThreadSingleton.instance is None:
            EventCreateThreadSingleton.instance = EventCreateThreadSingleton.EventCreateThread()
            EventCreateThreadSingleton.instance.setDaemon(True)
            EventCreateThreadSingleton.instance.start()
            
    class EventCreateThread(threading.Thread):
        def run(self):
            while True:
                sleep_time = 60
    #            pylucene_helper.attach_thread()
                current_time = datetime.datetime.now()
                earlier_time = datetime.datetime.now() - datetime.timedelta(seconds = sleep_time)
                
# 定时任务处理
                message_task_list_on_fixed = MessageTask.objects.filter(type = u"定时发送", deleted = False, running = True)
                if message_task_list_on_fixed:
                    for message_task in message_task_list_on_fixed:
                        send_time = datetime.datetime.strptime(message_task.option, '%Y-%m-%d %H:%M:%S')
                        if send_time > earlier_time and send_time <= current_time:
                            event = Event()
                            event.object_id = message_task.id
                            event.object_type = u'任务处理'
                            event.type = u'发送'
                            event.detail = u'定时发送'
                            event.save()
                            message_task.status = u'正在发送'
#                            message_task.times += 1
                            message_task.last_sending_time = datetime.datetime.now()
                            message_task.save()
                
# 循环任务处理
                message_task_list_on_circle = MessageTask.objects.filter(type = u"循环发送", deleted = False, running = True)
                if message_task_list_on_circle:
                    for message_task in message_task_list_on_circle:
                        data_get = message_task.option.split(',')
                        start_date = datetime.datetime.strptime(data_get[0], "%Y-%m-%d")
                        end_date = datetime.datetime.strptime(data_get[1], "%Y-%m-%d")
                        send_time = datetime.datetime.strptime(data_get[2], '%H:%M:%S').time()
                        circle_day = int(data_get[3])
                        if end_date.date() < current_time.date():
                            message_task.running = False
                            message_task.save()
                        else:
                            if send_time >= earlier_time.time() and send_time < current_time.time():
                                status = True
                                i = 0
                                while status:
                                    send_day = (start_date + datetime.timedelta(days = circle_day * i)).date()
                                    if send_day >= earlier_time.date() and send_day <= current_time.date():
                                        event = Event()
                                        event.object_id = message_task.id
                                        event.object_type = u'任务处理'
                                        event.type = u'发送'
                                        event.detail = u'循环发送'
                                        event.save()
                                        message_task.status = u'正在发送'
#                                        message_task.times += 1
                                        message_task.last_sending_time = datetime.datetime.now()
                                        message_task.save()
                                        break
                                    elif send_day > current_time.date() or send_day > end_date.date():
                                        status = False
                                    else:
                                        i = i + 1
                                del i
                            
                            
# 提醒任务处理
                notice_list = MeetingNotice.objects.filter(deleted = False, running = True)
                for notice in notice_list:
                    if notice.send_time > earlier_time and notice.send_time < current_time:
                        event = Event()
                        event.object_id = notice.id
                        event.object_type = u'提醒处理'
                        event.type = u'发送'
                        event.detail = notice.object_type
                        event.save()
                        notice.status = u'发送中'
#                        notice.times += 1
                        notice.last_sending_time = datetime.datetime.now()
                        notice.save()

# 反馈任务处理
#                feedback_list = MeetingFeedback.objects.filter(status=u'已启用')
#                for feedback in feedback_list:
#                    if feedback.send_time > earlier_time and feedback.send_time < current_time:
#                        event = Event()
#                        event.object_id = feedback.id
#                        event.object_type = 'MeetingFeedback'
#                        event.type = u'自动发送邮件'
#                        event.detail = u'已审批'
#                        event.save()
                time.sleep(sleep_time)
def main():
    print '--------------  ', datetime.datetime.now(), '  Start the Thread  ------------------'
    EventDispatcherSingleton()
    EventCreateThreadSingleton()
#    SendMessagesOnCircleTimeThreadSingleton()
    while True:
        time.sleep(5)
