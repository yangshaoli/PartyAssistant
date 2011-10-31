# coding=utf-8
import re

from tools.barcode_tool import make_code39_file

from events.models import MeetingSchedule, SchedulesClients, ClientInfo, MeetingsClients, MeetingsClientInfosValues

client_info_tag_list = [u'[参会者姓名]', u'[参会者姓名+称谓]', u'[参会者手机号码]', u'[参会者公司名称]', u'[参会者邮箱]', u'[参会者分组]', u'[参会者条形码(39码)]', u'[参会者条形码(QR码)]']
event_info_tag_list = [u'[会议名称]', u'[会议开始时间]', u'[会议结束时间]', u'[会议地点]', u'[会议类型]', u'[会议备注]', u'[会议状态]', u'[报名网址]', u'[反馈表网址]', u'[查看报名人数网址]', u'[已报名人数]', u'[添加至Google日历]', u'[下载日历文件]']
user_info_tag_list = [u'[用户姓名]', u'[用户公司名称]']
schedule_tag_list = [u'[日程报名按钮]', u'[日程名称]', u'[日程开始时间]', u'[日程结束时间]', u'[日程内容]']
apply_tag_list = [u'[报名信息名称]', u'[报名信息元素]']
button_info_tag_list = [u'[报名按钮]', u'[不报名按钮]']
reg_schedule = re.compile(ur'\[日程循环\].*?\[/日程循环\]', re.S)
reg_apply = re.compile(ur'\[报名信息循环\].*?\[/报名信息循环\]', re.S)
reg_clear_tag = re.compile(ur'\[/?(日程循环|报名信息循环)\]')
def replace_tags_in_preview_content(new_content, meeting, client = ''):
    for client_info in client_info_tag_list:
        if new_content.find(client_info) != -1:
            if client != '':
                if client_info == u'[参会者姓名]':
                    new_content = new_content.replace(client_info, client.name)
                if client_info == u'[参会者姓名+称谓]':
                    if client.gender == u'男':
                        genderStr = u'先生'
                    elif client.gender == u'女':
                        genderStr = u'女士'
                    else:
                        genderStr = u'先生/女士'
                    new_content = new_content.replace(client_info, "%s %s", client.name, genderStr)
                if client_info == u'[参会者手机号码]':
                    new_content = new_content.replace(client_info, client.cell_phone)
                if client_info == u'[参会者公司名称]':
                    new_content = new_content.replace(client_info, client.company)
                if client_info == u'[参会者邮箱]':
                    new_content = new_content.replace(client_info, client.email)
                if client_info == u'[参会者分组]':
                    new_content = new_content.replace(client_info, client.group)
                if client_info == u'[参会者条形码(39码)]':
                    try:
                        meeting_client = MeetingsClients.objects.get(meeting = meeting, client = client)
                        scr_name = make_code39_file(meeting_client)
                    except Exception:
                        src_name = ''
                    new_content = new_content.replace(client_info, '<img src="' + scr_name + '" height = "80px" width="200"/>')
                if client_info == u'[参会者条形码(QR码)]':
                    try:
                        meeting_client = MeetingsClients.objects.get(meeting = meeting, client = client)
                        new_content = new_content.replace(client_info, '<img src="http://chart.apis.google.com/chart?cht=qr&chl=' + meeting_client.client_key + '&chs=120x120"></img>')
                    except Exception:
                        new_content = new_content.replace(client_info, '<img src=""></img>')
            else:
                if client_info == u'[参会者姓名]' or client_info == u'[参会者姓名+称谓]':
                    new_content = new_content.replace(client_info, u'贵宾')
                else:
                    new_content = new_content.replace(client_info, '')
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
            if meeting_info == u'[会议状态]':
                new_content = new_content.replace(meeting_info, meeting.status)
            if meeting_info == u'[查看报名人数网址]':
                new_content = new_content.replace(meeting_info, meeting.url + 'status/show/')
            if meeting_info == u'[已报名人数]':
                if meeting.apply_option:
                    new_content = new_content.replace(meeting_info, len(MeetingsClients.objects.filter(meeting = meeting, apply_status = u'已报名')))
                else:
                    new_content = new_content.replace(meeting_info, len(MeetingsClients.objects.filter(meeting = meeting)))
            if meeting_info == u'[反馈表网址]':
                try:
                    meetingclient = MeetingsClients.objects.get(meeting = meeting, client = client)
                    url = meeting.url[0:-6] + 'feedback/collect/' + meetingclient.client_key
                except Exception, e:
                    url = u'（对不起，反馈网址只能提供给参加会议的与会者）'
                new_content = new_content.replace(meeting_info, url)
            if meeting_info == u'[报名网址]':
                try:
                    meetingclient = MeetingsClients.objects.get(meeting = meeting, client = client)
                    url = meeting.url + meetingclient.client_key
                except Exception:
                    url = meeting.url
                new_content = new_content.replace(meeting_info, url)
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
    
    for button_info in button_info_tag_list:
        if new_content.find(button_info) != -1:
            if client != '':
                meetingclient = MeetingsClients.objects.filter(meeting = meeting, client = client)
                if meetingclient and meetingclient[0].apply_status == u'已报名':
                    apply_button = u"<input type=\"button\" value=\"修改\" onclick=\"apply_ajax();\" class=\"modify-submit\ name=\"input\">"
                elif meetingclient and meetingclient[0].approve_status != u'未审批' or meetingclient[0].present_status != '未签到':
                    apply_button = u"<input type=\"button\" value=\"报名\" disabled onclick=\"apply_ajax();\" class=\"modify-submit\ name=\"input\">"
                else:
                    apply_button = u"<input type=\"button\" value=\"报名\" onclick=\"apply_ajax();\" class=\"modify-submit\ name=\"input\">"
            else:
                apply_button = u"<input type=\"button\" value=\"报名\" onclick=\"apply_ajax();\" class=\"modify-submit\ name=\"input\">"
            if client == "":
                not_apply_button = ''
            else:
                not_apply_button = u"<input name=\"input\" type=\"button\" onclick=\"not_apply()\" value=\"不报名\"/>"
            if button_info == u'[报名按钮]':
                new_content = new_content.replace(button_info, apply_button)
            if button_info == u'[不报名按钮]':
                new_content = new_content.replace(button_info, not_apply_button)
    if reg_schedule.search(new_content) != None:
        schedule_circle_tag = reg_schedule.search(new_content).group()
        schedule_circle = reg_clear_tag.sub("", schedule_circle_tag)
        final_content = ''
        schedule_list = MeetingSchedule.objects.filter(meeting = meeting)
        for schedule in schedule_list:
            temp_content = schedule_circle
            for schedule_tag in schedule_tag_list:
                if temp_content.find(schedule_tag) != -1:
                    if schedule_tag == u'[日程报名按钮]':
                        if client != '' and not SchedulesClients.objects.filter(client = client, schedule = schedule):
                            temp_content = temp_content.replace(schedule_tag, '<input type="checkbox" checked="" value="' + str(schedule.id) + '" id="schedule_' + str(schedule.id) + '" onchange="check_schedule_checked(this)" class="schedule_check" name="schedule_' + str(schedule.id) + '">')
                        else:
                            temp_content = temp_content.replace(schedule_tag, '<input type="checkbox" checked="checked" value="' + str(schedule.id) + '" id="schedule_' + str(schedule.id) + '" onchange="check_schedule_checked(this)" class="schedule_check" name="schedule_' + str(schedule.id) + '">')
                    if schedule_tag == u'[日程名称]':
                        temp_content = temp_content.replace(schedule_tag, schedule.title)
                    if schedule_tag == u'[日程开始时间]':
                        temp_content = temp_content.replace(schedule_tag, str(schedule.start_time))
                    if schedule_tag == u'[日程结束时间]':
                        temp_content = temp_content.replace(schedule_tag, str(schedule.end_time))
                    if schedule_tag == u'[日程内容]':
                        temp_content = temp_content.replace(schedule_tag, schedule.content)
                else:
                    if schedule_tag == u'[日程报名按钮]':
                        temp_content = temp_content.replace(schedule_tag, '<input type="checkbox" checked="checked" style="display:none" value="' + str(schedule.id) + '" id="schedule_' + str(schedule.id) + '" onchange="check_schedule_checked(this)" class="schedule_check" name="schedule_' + str(schedule.id) + '">')
            final_content = final_content + temp_content
        new_content = new_content.replace(schedule_circle_tag, final_content)
    if reg_apply.search(new_content) != None:
        apply_circle_tag = reg_apply.search(new_content).group()
        apply_circle = reg_clear_tag.sub("", apply_circle_tag)
        final_content = ''
        apply_list = ClientInfo.objects.filter(meeting = meeting).order_by('order')
        if client == "":
            for text in [u'姓名', u'邮箱', u'公司', u'手机']:
                temp_content = apply_circle
                for apply_tag in apply_tag_list:
                    if apply_tag == u'[报名信息元素]':
                        temp_content = temp_content.replace(apply_tag, translate_html(text, u'单行文本', '', '', u'是'))
                    if apply_tag == u'[报名信息名称]':
                        temp_content = temp_content.replace(apply_tag, text + u':')
                final_content = final_content + temp_content
            for apply in apply_list:
                temp_content = apply_circle
                if apply.visible == u'是':
                    for apply_tag in apply_tag_list:
                        if apply_tag == u'[报名信息元素]':
                            temp_content = temp_content.replace(apply_tag, translate_html(apply.name, apply.type, apply.option, '', apply.modifiable))
                        if apply_tag == u'[报名信息名称]':
                            temp_content = temp_content.replace(apply_tag, apply.name + u':')
                    final_content = final_content + temp_content
        else:
            #有client的情况下
            meeting_client = MeetingsClients.objects.get(meeting = meeting, client = client)
            #附加信息
            client_info_value_list = MeetingsClientInfosValues.objects.filter(meetings_clients = meeting_client)
            #基本信息
            basic_info = {u'姓名':client.name,
                          u'邮箱':client.email,
                          u'公司':client.company,
                          u'手机':client.cell_phone}
            #先处理基本信息
            for text, value in basic_info.items():
                temp_content = apply_circle
                for apply_tag in apply_tag_list:
                    if apply_tag == u'[报名信息元素]':
                        temp_content = temp_content.replace(apply_tag, translate_html(text, u'单行文本', '', value, u'是'))
                    if apply_tag == u'[报名信息名称]':
                        temp_content = temp_content.replace(apply_tag, text + u':')
                final_content = final_content + temp_content
            if client_info_value_list:
                for client_info_value in client_info_value_list:
                    for apply in apply_list:
                        temp_content = apply_circle
                        if apply.name == client_info_value.name and apply.visible == u'是':
                            for apply_tag in apply_tag_list:
                                if apply_tag == u'[报名信息元素]':
                                    temp_content = temp_content.replace(apply_tag, translate_html(apply.name, apply.type, apply.option, client_info_value.value, apply.modifiable))
                                if apply_tag == u'[报名信息名称]':
                                    temp_content = temp_content.replace(apply_tag, apply.name + u':')
                            final_content = final_content + temp_content
            else:
                for client_info_value in client_info_value_list:
                    for apply in apply_list:
                        temp_content = apply_circle
                        if apply.name == client_info_value.name and apply.visible == u'是':
                            for apply_tag in apply_tag_list:
                                if apply_tag == u'[报名信息元素]':
                                    temp_content = temp_content.replace(apply_tag, translate_html(apply.name, apply.type, apply.option, '', apply.modifiable))
                                if apply_tag == u'[报名信息名称]':
                                    temp_content = temp_content.replace(apply_tag, apply.name + u':')
                            final_content = final_content + temp_content
        new_content = new_content.replace(apply_circle_tag, final_content)
    
    return new_content

def translate_html(name, val, option, content, modifiable):
    val_html = ''
        
    if val == u'单行文本':
        if name in [u'姓名' , u'邮箱']:
            val_html = "<input type=\"text\" name=\"" + name + "\" value=\"" + content + "\"><strong class='required'>*</strong>"
        else:
            if modifiable == u'是':
                val_html = "<input type=\"text\" name=\"" + name + "\" value=\"" + content + "\">"
            else:
                val_html = "<input type=\"text\" name=\"" + name + "\" value=\"" + content + "\" disabled=\"disabled\">"
            
    elif val == u'多行文本':
        if modifiable == u'是':
            val_html = "<textarea  name=\"" + name + "\">" + content + "</textarea>"
        else:
            val_html = "<textarea  name=\"" + name + "\" disabled=\"disabled\">" + content + "</textarea>"
    elif  val == u'单选按钮':
        option = option.split("\n")
        if modifiable == u'是':
            if content == '':
                    for op in option:
                        op = op.strip()
                        val_html = val_html + "<input type=\"radio\" name=\"" + name + "\" value=\"" + op + "\" checked=\"checked\"/>" + op + "&nbsp;"
            else:
                for op in option:
                    op = op.strip()
                    if op == content:
                        val_html = val_html + "<input type=\"radio\" name=\"" + name + "\" value=\"" + op + "\" checked=\"checked\"/>" + op + "&nbsp;"
                    else:
                        val_html = val_html + "<input type=\"radio\" name=\"" + name + "\" value=\"" + op + "\" />" + op + "&nbsp;"
        else:
            if content == '':
                    for op in option:
                        op = op.strip()
                        val_html = val_html + "<input type=\"radio\" name=\"" + name + "\" value=\"" + op + "\" checked=\"checked\" disabled=\"disabled\" />" + op + "&nbsp;"
            else:
                for op in option:
                    op = op.strip()
                    if op == content:
                        val_html = val_html + "<input type=\"radio\" name=\"" + name + "\" value=\"" + op + "\" checked=\"checked\" disabled=\"disabled\" />" + op + "&nbsp;"
                    else:
                        val_html = val_html + "<input type=\"radio\" name=\"" + name + "\" value=\"" + op + "\" disabled=\"disabled\" />" + op + "&nbsp;"
    elif val == u'多选按钮':
        option = option.split("\n")
        if modifiable == u'是':
            for op in option:
                op = op.strip()
                if content == '':
                    val_html = val_html + "<input type=\"checkbox\" name=\"" + name + "\" value=\"" + op + "\"/>" + op + "&nbsp;"
                else:
                    if type(content) != list:
                        content = content.split('\n')
                    for con in content:
                        con.strip()
                    if op in content:
                        val_html = val_html + "<input type=\"checkbox\" check=\"checked\" name=\"" + name + "\" value=\"" + op + "\"/>" + op + "&nbsp;"
                    else:
                        val_html = val_html + "<input type=\"checkbox\" name=\"" + name + "\" value=\"" + op + "\"/>" + op + "&nbsp;"
        else:
            for op in option:
                op = op.strip()
                if content == '':
                    val_html = val_html + "<input type=\"checkbox\" name=\"" + name + "\" value=\"" + op + "\" disabled=\"disabled\" />" + op + "&nbsp;"
                else:
                    if type(content) != list:
                        content = content.split('\n')
                    for con in content:
                        con.strip()
                    if op in content:
                        val_html = val_html + "<input type=\"checkbox\" check=\"checked\" name=\"" + name + "\" value=\"" + op + "\" disabled=\"disabled\" />" + op + "&nbsp;"
                    else:
                        val_html = val_html + "<input type=\"checkbox\" name=\"" + name + "\" value=\"" + op + "\" disabled=\"disabled\" />" + op + "&nbsp;"
    elif val == u'时间':
        if modifiable == u'是':
            val_html = "<input type=\"text\" id=\"time_" + name + "\" name=\"" + name + "\" value=\"" + content + "\" class=\"mytime\" /> "
        else:
            val_html = "<input type=\"text\" id=\"time_" + name + "\" name=\"" + name + "\" value=\"" + content + "\" class=\"mytime\" disabled=\"disabled\" /> "
    elif val == u"下拉列表":
        if modifiable == u'是':
            if content == "":
                val_html = "<select id=\"selectitem\">"
            else:
                val_html = "<select id=\"selectitem\" value=\"" + content + "\">"
        else:
            if content == "":
                val_html = "<select id=\"selectitem\" disabled=\"disabled\" >"
            else:
                val_html = "<select id=\"selectitem\" value=\"" + content + "\" disabled=\"disabled\" >"
                
        option = option.split("\n")
        for op in option:
            op = op.strip()
            val_html = val_html + "<option name=\"" + name + "\" value=\"" + op + "\">" + op + "</option>"
        val_html = val_html + "</select><input type=\"hidden\" id=\"selectvalue\" name=\"" + name + "\" />"
    return val_html

