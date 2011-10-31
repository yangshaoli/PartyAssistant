#coding=utf-8

from events.models import ClientInfo, MeetingsClientInfosValues, MeetingsClients, Meeting
from django.utils import simplejson

class Chart():
    
    def __init__(self):
        self.data_list = []
        self.data_title = ''
        self.data = simplejson.dumps(self.data_list)
    
    def set_data(self, key, value):
        if len(key) > 10:
            key = key[:7] + '...'
        try:
            key = key.encode('utf-8')
        except Exception:
            pass
        self.data_list.append([key, value])
        self.data = simplejson.dumps(self.data_list)
        
    def set_title(self, title):
        if len(title) > 20:
            title = title[:17] + '...'
        self.data_title = title

#class ReportColumClass():
#    def __init__(self, order):
#        if order == 1:
#            title = u'参会者报名情况统计'
#            result = [u'已报名人数', u'不报名人数', u'未操作人数']
#        if order == 2:
#            title = u'参会者报名途径统计'
#            result = [u'页面报名人数', u'代报名人数', u'现场报名人数']
#        if order == 3:
#            title = u'参会者报名情况统计'
#            result = [u'已报名人数', u'不报名人数', u'未操作人数']
#        if order == 4:
#            title = u'参会者报名情况统计'
#            result = [u'已报名人数', u'不报名人数', u'未操作人数']

class ClientDataClass():
    def __init__(self):
        self.all_count = 0
        self.apply_count = 0
        self.apply_by_self_count = 0
        self.apply_by_manager_count = 0
        self.apply_by_present_count = 0
        self.not_apply_count = 0
        self.apply_undo_count = 0
        self.approved_count = 0
        self.refuse_count = 0
        self.approve_undo_count = 0
        self.approve_all_count = 0
        self.present_count = 0
        self.not_present_count = 0
        self.present_all_count = 0
    
    def set_data(self, meetingclient_list):
        if meetingclient_list:
            meeting = meetingclient_list[0].meeting
            self.all_count = meetingclient_list.count()
            self.apply_count = meetingclient_list.filter(apply_status = u'已报名').count()
            self.apply_by_self_count = meetingclient_list.filter(join_manner = u'网页报名').count()
            self.apply_by_manager_count = meetingclient_list.filter(join_manner = u'代报名').count()
            self.apply_by_present_count = meetingclient_list.filter(join_manner = u'现场报名').count()
            self.not_apply_count = meetingclient_list.filter(apply_status = u'不报名').count()
            self.apply_undo_count = meetingclient_list.filter(apply_status = u'未报名').count()
            self.approved_count = meetingclient_list.filter(approve_status = u'审批通过').count()
            self.refuse_count = meetingclient_list.filter(approve_status = u'拒绝审批').count()
            if meeting.apply_option:
                self.approve_undo_count = meetingclient_list.filter(approve_status = u'未审批', apply_status = u'已报名').count()
            else:
                self.approve_undo_count = meetingclient_list.filter(approve_status = u'未审批').count()
            self.approve_all_count = self.approved_count + self.refuse_count + self.approve_undo_count
            self.present_count = meetingclient_list.filter(present_status = u'已签到').count()
            if meeting.approve_option:
                self.not_present_count = meetingclient_list.filter(approve_status = u'审批通过', present_status = u'未签到').count()
            elif meeting.apply_option:
                self.not_present_count = meetingclient_list.filter(apply_status = u'已报名', present_status = u'未签到').count()
            else:
                self.not_present_count = meetingclient_list.filter(present_status = u'未签到').count()
            self.present_all_count = self.present_count + self.not_present_count
                
    def set_chart_data(self, order):
        chart = Chart()
        if order == 1:
            print 123
            chart.set_title(u'参会者报名情况统计')
            chart.set_data(u'已报名人数', self.apply_count)
            chart.set_data(u'不报名人数', self.not_apply_count)
            chart.set_data(u'未操作人数', self.apply_undo_count)
        if order == 2:
            chart.set_title(u'参会者报名途径统计')
            chart.set_data(u'页面报名人数', self.apply_by_self_count)
            chart.set_data(u'代报名人数', self.apply_by_manager_count)
            chart.set_data(u'现场报名人数', self.apply_by_present_count)
        if order == 3:
            chart.set_title(u'参会者审批情况统计')
            chart.set_data(u'审批通过人数', self.approved_count)
            chart.set_data(u'拒绝审批人数', self.refuse_count)
            chart.set_data(u'未审批人数', self.approve_undo_count)
        if order == 4:
            chart.set_title(u'参会者签到情况统计')
            chart.set_data(u'签到人数', self.present_count)
            chart.set_data(u'未签到人数', self.not_present_count)
        return chart
