#coding=utf-8
'''
Created on 2010-1-6

@author: RenRongzhe
'''
from django.shortcuts import get_object_or_404
from events.models import Meeting, MeetingsClients
from feedback.models import MeetingFeedback, MeetingsClientFeedbackValues, MeetingFeedbackQuestion

def meeting_client_statistics_report(meeting):
    meeting_client_count = MeetingsClients.objects.filter(meeting = meeting).count()
    apply_client_count = MeetingsClients.objects.filter(meeting = meeting, apply_status = u'已报名').count()
    present_client_count = MeetingsClients.objects.filter(meeting = meeting, present_status = u'已签到').count()
    approve_client_count = MeetingsClients.objects.filter(meeting = meeting, approve_status = u'审批通过').count()
    meeting_feedback = MeetingFeedback.objects.get(meeting = meeting, object_type = u'会议', object_id = meeting.id)
    meeting_feedback_question_list = MeetingFeedbackQuestion.objects.filter(meeting_feedback = meeting_feedback)
    meeting_client_feedback_value_list = MeetingsClientFeedbackValues.objects.filter(meeting_feedback = meeting_feedback)
    client_list = []
    anonymous_value_count = 0
    for meeting_client_feedback_value in meeting_client_feedback_value_list:
        if meeting_client_feedback_value.meetings_clients:
            if meeting_client_feedback_value.meetings_clients.client.name not in client_list:
                client_list.append(meeting_client_feedback_value.meetings_clients.client.name)
        else:
            anonymous_value_count = anonymous_value_count + 1
    if len(meeting_feedback_question_list) != 0:
        anonymous_client_count = anonymous_value_count / len(meeting_feedback_question_list)
        feedback_client_count = len(client_list) + anonymous_client_count
    else:
        feedback_client_count = 0
    statistics_data_dictionary = {'meeting_client_count': meeting_client_count,
                                  'present_client_count': present_client_count,
                                  'approve_client_count': approve_client_count,
                                  'apply_client_count': apply_client_count,
                                  'feedback_client_count':feedback_client_count}
    return statistics_data_dictionary

def meeting_client_sign_in_last(meeting):
    if meeting.apply_option:
        meeting_client_list = MeetingsClients.objects.filter(meeting = meeting, apply_status = u'已报名').order_by('-sign_in_time')
        if len(meeting_client_list) > 5:
            meeting_client_sign_in_last_list = meeting_client_list[:5]
        else:
            meeting_client_sign_in_last_list = meeting_client_list
        return meeting_client_sign_in_last_list
