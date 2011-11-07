#coding=utf-8
'''
会议内/外的Base页中，每次都需要代入的所有数据的类
'''

from events.models import Meeting
from django.contrib.auth.models import User

from tools.meeting_client_report_tools import meeting_client_statistics_report, meeting_client_sign_in_last

class MeetingDataClass():
    def __init__(self, meeting):
        self.clients_report_data = meeting_client_statistics_report(meeting)
        self.sign_in_data = meeting_client_sign_in_last(meeting)

class UserDataClass():
    def __init__(self, user):
        pass

def set_base_data(obj):
    if isinstance(obj, Meeting):
        data_base = MeetingDataClass(obj)
    elif isinstance(obj, User):
        data_base = UserDataClass(obj)
    return data_base
