#coding=utf-8
'''
Created on 2011-11-7

@author: liuxue
'''

import datetime
import re

from django.db import transaction
from django.contrib.auth.models import User
from django.db.transaction import commit_on_success
from django.core.urlresolvers import reverse
from django.utils import simplejson
from django.views.decorators.csrf import csrf_exempt

from apps.clients.models import Client
from apps.messages.models import EmailMessage, SMSMessage, Outbox, BaseMessage
from apps.parties.models import Party, PartiesClients

from settings import DOMAIN_NAME
from ERROR_MSG_SETTINGS import *
from ERROR_STATUS_SETTINGS import *

from utils.tools.sms_tool import SHORT_LINK_LENGTH, BASIC_MESSAGE_LENGTH
from utils.structs.my_exception import myException
from utils.tools.apis_json_response_tool import apis_json_response_decorator
from utils.tools.short_link_tool import transfer_to_shortlink



PARTY_COUNT_PER_PAGE = 10

re_a = re.compile(r'\d+\-\d+\-\d+ \d+\:\d+\:\d+')

@apis_json_response_decorator
def createParty(request):
    if request.method == 'POST' :
        receivers = eval(request.POST['receivers'])
        content = request.POST['content']
#        subject = request.POST['subject']
#        _isapplytips = request.POST['_isapplytips'] == '1'
        _issendbyself = request.POST['_issendbyself'] == '1'
#        msgType = request.POST['msgType']
#        starttime = request.POST['starttime']
#        location = request.POST['location']
#        description = request.POST['description']
#        peopleMaximum = request.POST['peopleMaximum']
        uID = request.POST['uID']
#        addressType = request.POST['addressType']
        user = User.objects.get(pk = uID)
        startdate = None
        
        subject = ''
        _isapplytips = True
        msgType = "SMS"
        starttime = ''
        location = ""
        description = content
        peopleMaximum = 0
        
        try:
            startdate = datetime.datetime.strptime(re_a.search(starttime).group(), '%Y-%m-%d %H:%M:%S').date()
        except Exception:
            startdate = None
        try:
            starttime = datetime.datetime.strptime(re_a.search(starttime).group(), '%Y-%m-%d %H:%M:%S').time()
        except Exception:
            starttime = None
#        if len(location) > 256:
#            raise myException(ERROR_CREATEPARTY_LONG_LOCATION)
        # 检测剩余短信余额是否足够
        number_of_message = (len(content) + SHORT_LINK_LENGTH + BASIC_MESSAGE_LENGTH - 1) / BASIC_MESSAGE_LENGTH
        client_phone_list_len = len(receivers)
        userprofile = user.get_profile() 
        sms_count = userprofile.available_sms_count
        will_send_message_num = client_phone_list_len * number_of_message #可能发送的从短信条数
        if will_send_message_num > sms_count:#短信人数*短信数目大于可发送的短信数目
            raise myException(ERROR_SEND_MSG_NO_REMAINING, status = ERROR_STATUS_SEND_MSG_NO_REMAINING, data = {'remaining':sms_count})
        with transaction.commit_on_success():
            #创建活动
            party = Party.objects.create(start_date = startdate,
                                         start_time = starttime,
                                         address = location,
                                         description = description,
                                         creator = user,
                                         limit_count = peopleMaximum,
                                         invite_type = (msgType == "SMS" and 'phone' or 'email')
                                         )
            addressArray = []
            for i in range(len(receivers)):
                receiver = receivers[i]
                
                if msgType == 'SMS':
#                    client = Client.objects.get_or_create(phone = receiver['cValue'],
#                                                                      name = receiver['cName'],
#                                                                      creator = user,
#                                                                      )[0]
                    client_list = Client.objects.filter(phone = receiver['cValue'],
                                                        name = receiver['cName'],
                                                        creator = user
                                                        )
                    if client_list:
                        client = client_list[0]
                    else:
                        empty_name_client_list = Client.objects.filter(phone = receiver['cValue'],
                                                                       name = '',
                                                                       creator = user
                                                                       )
                        if empty_name_client_list:
                            client = empty_name_client_list[0]
                            client.name = receiver['cName']
                            client.save()
                        else:
                            client = Client.objects.create(phone = receiver['cValue'],
                                                           name = receiver['cName'],
                                                           creator = user,
                                                           invite_type = 'phone'
                                                           )
                    
                else:
                    client_list = Client.objects.filter(email = receiver['cValue'],
                                                        name = receiver['cName'],
                                                        creator = user
                                                        )
                    if client_list:
                        client = client_list[0]
                    else:
                        empty_name_client_list = Client.objects.filter(email = receiver['cValue'],
                                                                       name = '',
                                                                       creator = user
                                                                       )
                        if empty_name_client_list:
                            client = empty_name_client_list[0]
                            client.name = receiver['cName']
                            client.save()
                        else:
                            client = Client.objects.create(email = receiver['cValue'],
                                                           name = receiver['cName'],
                                                           creator = user,
                                                           invite_type = 'phone'
                                                           )
                PartiesClients.objects.create(
                                              party = party,
                                              client = client,
                                              ) 
                addressArray.append(receiver['cValue'])
            addressString = simplejson.dumps(addressArray)
            if msgType == 'SMS':
                msg = SMSMessage.objects.get_or_create(party = party)[0]
                msg.content = content
                msg.is_apply_tips = _isapplytips
                msg.is_send_by_self = _issendbyself
                msg.save()
            else:
                msg = EmailMessage.objects.get_or_create(party = party)[0]
                msg.subject = subject
                msg.content = content
                msg.is_apply_tips = _isapplytips
                msg.is_send_by_self = _issendbyself
                msg.save()
        
        if not msg.is_send_by_self:
            with transaction.commit_on_success():
                if addressArray:
                    addressString = ','.join(addressArray)
                    Outbox.objects.create(address = addressString, base_message = msg)
        return {
                'partyId':party.id,
                'applyURL':transfer_to_shortlink(DOMAIN_NAME + reverse('enroll', args = [party.id])),
                'sms_count_remaining':user.userprofile.available_sms_count,
                }

@csrf_exempt
@apis_json_response_decorator
def editParty(request):
    if request.method == 'POST':
        partyID = request.POST['partyID']
#        location = request.POST['location']
#        starttime = request.POST['starttime']
#        peopleMaximum = request.POST['peopleMaximum']
        description = request.POST['description']
        uID = request.POST['uID']
#        startdate = None
        
        location = ''
#        starttime = ''
#        peopleMaximum = 0
#        try:
#            startdate = datetime.datetime.strptime(re_a.search(starttime).group(), '%Y-%m-%d %H:%M:%S').date()
#        except:
#            startdate = None               
#        try:
#            starttime = datetime.datetime.strptime(re_a.search(starttime).group(), '%Y-%m-%d %H:%M:%S').time()
#        except Exception:
#            starttime = None
        if len(location) > 256:
            raise myException(ERROR_CREATEPARTY_LONG_LOCATION)
        
        user = User.objects.get(pk = uID)
        try:
            party = Party.objects.get(pk = partyID, creator = user)
        except Exception:
            raise myException(u'您要编辑的会议已被删除')
#        party.start_date = startdate
#        party.start_time = starttime
        party.description = description
#        party.address = location
#        party.limit_count = peopleMaximum
        party.save()
        
@csrf_exempt
@commit_on_success
@apis_json_response_decorator
def deleteParty(request):
    if request.method == 'POST':
        pID = request.POST['pID']
        uID = request.POST['uID']
        user = User.objects.get(pk = uID)
        try:
            party = Party.objects.get(pk = pID, creator = user)
        except Exception:
            return 'ok'
        party.delete()

@csrf_exempt
@apis_json_response_decorator
def PartyList(request, uid, start_id = 0):
    user = User.objects.get(pk = uid)
    PartyObjectArray = []
    if str(start_id) == "0":
        partylist = Party.objects.filter(creator = user).order_by('-created_time')[:PARTY_COUNT_PER_PAGE]
    else:
        partylist = Party.objects.filter(creator = user, pk__lt = start_id).order_by('-created_time')[:PARTY_COUNT_PER_PAGE]
#    GMT_FORMAT = '%Y-%m-%d %H:%M:%S'
    for party in partylist:
        partyObject = {}
        partyObject['description'] = party.description
        partyObject['partyId'] = party.id
        partyObject['shortURL'] = transfer_to_shortlink(DOMAIN_NAME + reverse('enroll', args = [party.id]))
        partyObject['type'] = party.invite_type
        
        #各个活动的人数情况
        party_clients = PartiesClients.objects.select_related('client').filter(party = party)
        client_counts = {
            'appliedClientcount': 0,
            'newAppliedClientcount':0,
            'donothingClientcount':0,
            'refusedClientcount':0,
            'newRefusedClientcount':0,
        }
        for party_client in party_clients:
            if party_client.apply_status == 'apply':
                client_counts['appliedClientcount'] += 1
            if party_client.apply_status == 'apply' and party_client.is_check == False:
                client_counts['newAppliedClientcount'] += 1 
            if party_client.apply_status == 'noanswer':
                client_counts['donothingClientcount'] += 1
            if party_client.apply_status == 'reject':
                client_counts['refusedClientcount'] += 1 
            if party_client.apply_status == 'reject' and party_client.is_check == False:
                client_counts['newRefusedClientcount'] += 1
        partyObject['clientsData'] = client_counts
        
        PartyObjectArray.append(partyObject)
    party_list = Party.objects.filter(creator = user)
    unreadCount = PartiesClients.objects.filter(party__in = party_list, is_check = False).count()
    if partylist:
        return {
                'lastID':partylist[partylist.count() - 1].id,
                'partyList':PartyObjectArray,
                'unreadCount':unreadCount,
                }
    else:
        return {
                'lastID':start_id,
                'unreadCount':unreadCount,
                'partyList':[]
                }

@csrf_exempt
@apis_json_response_decorator
def fullPartyList(request, uid, start_id = 0):
    user = User.objects.get(pk = uid)
    PartyObjectArray = []
    if str(start_id) == "0":
        partylist = Party.objects.filter(creator = user).order_by('-created_time')[:PARTY_COUNT_PER_PAGE]
    else:
        partylist = Party.objects.filter(creator = user, pk__lt = start_id).order_by('-created_time')[:PARTY_COUNT_PER_PAGE]
#    GMT_FORMAT = '%Y-%m-%d %H:%M:%S'
    for party in partylist:
        partyObject = {}
        partyObject['description'] = party.description
        partyObject['partyId'] = party.id
        partyObject['shortURL'] = transfer_to_shortlink(DOMAIN_NAME + reverse('enroll', args = [party.id]))
        partyObject['type'] = party.invite_type
        
        #各个活动的人数情况
        party_clients = PartiesClients.objects.select_related('client').filter(party = party)
        client_counts = {
            'appliedClientcount': 0,
            'newAppliedClientcount':0,
            'donothingClientcount':0,
            'refusedClientcount':0,
            'newRefusedClientcount':0,
            'clientArray':[]
        }
        for party_client in party_clients:
            clientObjectDict = {}
            if party.invite_type == 'email':
                cValue = party_client.client.email
            else:
                cValue = party_client.client.phone
            is_checked = party_client.is_check
            dict = {
                   'cName':party_client.client.name,
                   'cValue':cValue,
                   'isCheck':is_checked,
                   'backendID':party_client.id,
                   'status':party_client.apply_status,
                   "msg":party_client.leave_message
                   }
            client_counts['clientArray'].append(dict)
            if party_client.apply_status == 'apply':
                client_counts['appliedClientcount'] += 1
            if party_client.apply_status == 'apply' and party_client.is_check == False:
                client_counts['newAppliedClientcount'] += 1 
            if party_client.apply_status == 'noanswer':
                client_counts['donothingClientcount'] += 1
            if party_client.apply_status == 'reject':
                client_counts['refusedClientcount'] += 1 
            if party_client.apply_status == 'reject' and party_client.is_check == False:
                client_counts['newRefusedClientcount'] += 1
        partyObject['clientsData'] = client_counts
        
        PartyObjectArray.append(partyObject)
    party_list = Party.objects.filter(creator = user)
    unreadCount = PartiesClients.objects.filter(party__in = party_list, is_check = False).count()
    if partylist:
        return {
                'lastID':partylist[partylist.count() - 1].id,
                'partyList':PartyObjectArray,
                'unreadCount':unreadCount,
                }
    else:
        return {
                'lastID':start_id,
                'unreadCount':unreadCount,
                'partyList':[]
                }

@csrf_exempt
@apis_json_response_decorator
def GetPartyMsg(request, pid):
    try:
        party = Party.objects.get(pk = pid)
    except:
        raise myException(u'您要复制的会议已被删除')
    message = BaseMessage.objects.filter(party = party).order_by('-createtime')[0]
    messageType = message.get_subclass_type()
    #receivers = simplejson.loads(message.receivers)
    partiesclients_list = PartiesClients.objects.filter(party = party)
    receivers = []
    for partiesclients in partiesclients_list:
        dict = {}
        if messageType == 'SMS':
            dict['cVal'] = partiesclients.client.phone
        else:
            dict['cVal'] = partiesclients.client.email
        dict['cName'] = partiesclients.client.name
        dict['backendID'] = partiesclients.id
        receivers.append(dict)
    subObj = message.get_subclass_obj()
    if messageType == 'SMS':
        subject = ''
        content = subObj.content
    else:
        subject = subObj.subject
        content = subObj.content

    return {
            'msgType':messageType,
            'receiverArray':receivers,
            'receiverType':'iphone',
            'content':content,
            'subject':subject,
            '_isApplyTips':message.is_apply_tips,
            '_isSendBySelf':message.is_send_by_self
            }

@csrf_exempt
@apis_json_response_decorator
def GetPartyClientMainCount(request, pid):
    try:
        party = Party.objects.get(pk = pid)
    except:
        raise myException(u'您要复制的会议已被删除')
#    clientparty_list = PartiesClients.objects.filter(party = party)
#    all_client_count = clientparty_list.count()
#    applied_client_count = clientparty_list.filter(apply_status = u'apply').count()
#    donothing_client_count = clientparty_list.filter(apply_status = u'noanswer').count()
#    refused_client_count = clientparty_list.filter(apply_status = u'reject').count()
    #各个活动的人数情况
    party_clients = PartiesClients.objects.select_related('client').filter(party = party)
    client_counts = {
                     'party_content':'',
                    'allClientcount':0,
                    'appliedClientcount': 0,
                    'newAppliedClientcount':0,
                    'donothingClientcount':0,
                    'refusedClientcount':0,
                    'newRefusedClientcount':0,
                    }
    for party_client in party_clients:
#        if party_client.client.invite_type != 'public':
        client_counts['allClientcount'] += 1
        if party_client.apply_status == 'apply':
            client_counts['appliedClientcount'] += 1
        if party_client.apply_status == 'apply' and party_client.is_check == False:
            client_counts['newAppliedClientcount'] += 1 
        if party_client.apply_status == 'noanswer':
            client_counts['donothingClientcount'] += 1
        if party_client.apply_status == 'reject':
            client_counts['refusedClientcount'] += 1 
        if party_client.apply_status == 'reject' and party_client.is_check == False:
            client_counts['newRefusedClientcount'] += 1
    client_counts['party_content'] = party.description
    return client_counts

@csrf_exempt
@apis_json_response_decorator
def GetPartyClientSeperatedList(request, pid, type):
    try:
        party = Party.objects.get(pk = pid)
    except:
        raise myException(u'该会议已被删除')
    if type == "all":
        clientparty_list = PartiesClients.objects.select_related('client').filter(party = party).order_by('apply_status').order_by('is_check').order_by('client')
    elif type == 'applied':
        clientparty_list = PartiesClients.objects.select_related('client').filter(party = party, apply_status = u"apply").order_by('is_check').order_by('client')
    elif type == 'refused':
        clientparty_list = PartiesClients.objects.select_related('client').filter(party = party, apply_status = u"reject").order_by('is_check').order_by('client')
    elif type == 'donothing':
        clientparty_list = PartiesClients.objects.select_related('client').filter(party = party, apply_status = u"noanswer").order_by('is_check').order_by('client')
    clientList = []
    for clientparty in clientparty_list:
        if party.invite_type == 'email':
            cValue = clientparty.client.email
        else:
            cValue = clientparty.client.phone
        if 'read' in request.GET:
            if not clientparty.is_check:
                clientparty.is_check = True
                clientparty.save()
                is_checked = False
            else:
                is_checked = True
        else:
            is_checked = clientparty.is_check
        dic = {
               'cName':clientparty.client.name,
               'cValue':cValue,
               'isCheck':is_checked,
               'backendID':clientparty.id,
               'status':clientparty.apply_status,
               "msg":clientparty.leave_message
               }
        clientList.append(dic)
    party_list = Party.objects.filter(creator = party.creator)
    unreadCount = PartiesClients.objects.filter(party__in = party_list, is_check = False).count()
    return {
            'clientList':clientList,
            'unreadCount':unreadCount,
            }

@csrf_exempt
@apis_json_response_decorator
def ChangeClientStatus(request):
    clientparty = PartiesClients.objects.get(pk = request.POST['cpID'])
    action = request.POST['cpAction']
    if action == 'apply':
        clientparty.apply_status = u'apply'
    else:
        clientparty.apply_status = u'reject'
    clientparty.save()
    return 'ok'

@csrf_exempt
@apis_json_response_decorator
def resendMsg(request):
    if request.method == "POST":
        receivers = eval(request.POST['receivers'])
        content = request.POST['content']
#        subject = request.POST['subject']
#        _isapplytips = request.POST['_isapplytips'] == '1'
        _issendbyself = request.POST['_issendbyself'] == '1'
#        msgType = request.POST['msgType']
        partyID = request.POST['partyID']
        uID = request.POST['uID']
#        addressType = request.POST['addressType']
        user = User.objects.get(pk = uID)
        
        subject = ''
        _isapplytips = True
        msgType = "SMS"
        
        try:
            party = Party.objects.get(pk = partyID, creator = user)
        except Exception:
            raise myException(u'该会议会议已被删除')
        
        # 检测剩余短信余额是否足够
        number_of_message = (len(content) + SHORT_LINK_LENGTH + BASIC_MESSAGE_LENGTH - 1) / BASIC_MESSAGE_LENGTH
        client_phone_list_len = len(receivers)
        userprofile = user.get_profile() 
        sms_count = userprofile.available_sms_count
        will_send_message_num = client_phone_list_len * number_of_message #可能发送的从短信条数
        if will_send_message_num > sms_count:#短信人数*短信数目大于可发送的短信数目
            raise myException(ERROR_SEND_MSG_NO_REMAINING, status = ERROR_STATUS_SEND_MSG_NO_REMAINING, data = {'remaining':sms_count})
        
        with transaction.commit_on_success():
            addressArray = []
            for i in range(len(receivers)):
                receiver = receivers[i]
                
                if msgType == 'SMS':
                    client_list = Client.objects.filter(phone = receiver['cValue'],
                                                        creator = user
                                                        )
                    if client_list:
                        client = client_list[0]
                        if client.name == '':
                            client.name = receiver['cName']
                            client.save()
                    else:
                        client = Client.objects.create(phone = receiver['cValue'],
                                                       name = receiver['cName'],
                                                       creator = user,
                                                       invite_type = 'phone'
                                                       )
                else:
                    client_list = Client.objects.filter(email = receiver['cValue'],
                                                        creator = user
                                                        )
                    if client_list:
                        client = client_list[0]
                        if client.name == '':
                            client.name = receiver['cName']
                            client.save()
                    else:
                        client = Client.objects.create(email = receiver['cValue'],
                                                       name = receiver['cName'],
                                                       creator = user,
                                                       invite_type = 'phone'
                                                       )
                PartiesClients.objects.get_or_create(
                                                  party = party,
                                                  client = client,
                                                  defaults = {
                                                              "apply_status":'noanswer'
                                                              }
                                                  ) 
                addressArray.append(receiver['cValue'])
    
            if msgType == 'SMS':
                msg = SMSMessage.objects.get_or_create(party = party)[0]
                msg.content = content
                msg.is_apply_tips = _isapplytips
                msg.is_send_by_self = _issendbyself
                msg.save()
            else:
                msg = EmailMessage.objects.get_or_create(party = party)[0]
                msg.subject = subject
                msg.content = content
                msg.is_apply_tips = _isapplytips
                msg.is_send_by_self = _issendbyself
                msg.save()
        
        if not msg.is_send_by_self:
            with transaction.commit_on_success():
                if addressArray:
                    addressString = ','.join(addressArray)
                    Outbox.objects.create(address = addressString, base_message = msg)
        
        return {
                'partyId':party.id,
                'applyURL':transfer_to_shortlink(DOMAIN_NAME + reverse('enroll', args = [party.id])),
                'sms_count_remaining':user.userprofile.available_sms_count,
                }
