#coding=utf-8
'''
Created on 2011-11-7

@author: liuxue
'''
from ERROR_MSG_SETTINGS import *
from apps.clients.models import Client
from apps.messages.models import EmailMessage, SMSMessage, Outbox, BaseMessage
from apps.parties.models import Party, PartiesClients
from django.contrib.auth.models import User
from django.db.transaction import commit_on_success
from django.http import HttpResponse
from django.utils import simplejson
from django.views.decorators.csrf import csrf_exempt
from settings import SYS_EMAIL_ADDRESS, DOMAIN_NAME
from utils.tools.apis_json_response import apis_json_response_decorator
from utils.tools.email_tool import send_emails
from utils.tools.my_exception import myException
from utils.tools.page_size_setting import LIST_MEETING_PAGE_SIZE
from utils.tools.paginator_tool import process_paginator
from utils.tools.reg_phone_num import regPhoneNum
import datetime
import re
from datetime import *
 



re_a = re.compile(r'\d+\-\d+\-\d+ \d+\:\d+\:\d+')

@apis_json_response_decorator
@commit_on_success
def createParty(request):
    if request.method == 'POST' :
        receivers = eval(request.POST['receivers'])
        content = request.POST['content']
        subject = request.POST['subject']
        _isapplytips = request.POST['_isapplytips']
        _issendbyself = request.POST['_issendbyself']
        msgType = request.POST['msgType']
        starttime = request.POST['starttime']
        location = request.POST['location']
        description = request.POST['description']
        peopleMaximum = request.POST['peopleMaximum']
        uID = request.POST['uID']
        addressType = request.POST['addressType']
        user = User.objects.get(pk = uID)
        try:
            startdate = datetime.datetime.strptime(re_a.search(starttime).group(), '%Y-%m-%d')
        except Exception:
            startdate = None
        try:
            starttime = datetime.datetime.strptime(re_a.search(starttime).group(), '%H:%M:%S')
        except Exception:
            starttime = None
        if len(location) > 256:
            raise myException(ERROR_CREATEPARTY_LONG_LOCATION)
        #创建活动
        party = Party.objects.create(start_date = startdate,
                                     start_time = starttime,
                                     address = location,
                                     description = description,
                                     creator = user,
                                     limit_count = peopleMaximum,
                                     )
        addressArray = []
        for i in range(len(receivers)):
            receiver = receivers[i]
            
            if msgType == 'SMS':
                client, is_created = Client.objects.get_or_create(phone = receiver['cValue'],
                                                                  name = receiver['cName'],
                                                                  creator = user,
                                                                  )
            else:
                client, is_created = Client.objects.get_or_create(email = receiver['cValue'],
                                                                  name = receiver['cName'],
                                                                  creator = user,
                                                                  )
            PartiesClients.objects.create(
                                          party = party,
                                          client = client,
                                          ) 
            addressArray.append(receiver['cValue'])
        addressString = simplejson.dumps(addressArray)
        if msgType == 'SMS':
            msg, created = SMSMessage.objects.get_or_create(party = party)
            msg.content = content
            msg.is_apply_tips = _isapplytips
            msg.is_send_by_self = _issendbyself
            msg.save()
            Outbox.objects.create(address = addressString, base_message = msg.basemessage_ptr)
        else:
            msg, created = EmailMessage.objects.get_or_create(party = party)
            msg.subject = subject
            msg.content = content
            msg.is_apply_tips = _isapplytips
            msg.is_send_by_self = _issendbyself
            msg.save()
            Outbox.objects.create(address = addressString, base_message = msg.basemessage_ptr)
#        try :
#            pass     
#            #send_emails(subject, content, SYS_EMAIL_ADDRESS, [receiver['cValue']])
#        except:
#            print 'exception'
#            data['Email'] = u'邮件发送失败'
        
        return {'partyId':party.id}

@csrf_exempt
@apis_json_response_decorator
def editParty(request):
    if request.method == 'POST':
        partyID = request.POST['partyID']
        location = request.POST['location']
        starttime = request.POST['starttime']
        peopleMaximum = request.POST['peopleMaximum']
        description = request.POST['description']
        uID = request.POST['uID']
        try:
            startdate = datetime.datetime.strptime(re_a.search(starttime).group(), '%Y-%m-%d')
        except:
            startdate = None               
        try:
            starttime = datetime.datetime.strptime(re_a.search(starttime).group(), '%H:%M:%S')
        except Exception:
            starttime = None
        if len(location) > 256:
            raise myException(ERROR_CREATEPARTY_LONG_LOCATION)
        
        user = User.objects.get(pk = uID)
        try:
            party = Party.objects.get(pk = partyID, creator = user)
        except Exception:
            raise myException(u'您要编辑的会议已被删除')
        party.start_date = startdate
        party.start_time = starttime
        party.descrption = description
        party.address = location
        party.limit_count = peopleMaximum
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
            party = Party.objects.get(pk = pID)
        except Exception, e:
            return 'ok'
        party.delete()

@csrf_exempt
@apis_json_response_decorator
def PartyList(request, uid, page = 1):
    user = User.objects.get(pk = uid)
    PartyObjectArray = []
    partylist = Party.objects.filter(creator = user).order_by('-created_time')  
    GMT_FORMAT = '%Y-%m-%d %H:%M'
    partylist = process_paginator(partylist, page, LIST_MEETING_PAGE_SIZE).object_list
    for party in partylist:
        partyObject = {}
        try:
            party.start_time = datetime.combine(party.start_date, party.start_time)
            partyObject['starttime'] = party.start_time.strftime(GMT_FORMAT)
        except Exception, e:
            partyObject['starttime'] = None
        partyObject['description'] = party.description
        partyObject['peopleMaximum'] = party.limit_count
        partyObject['location'] = party.address
        partyObject['partyId'] = party.id
        PartyObjectArray.append(partyObject) 
    return {
            'page':page,
            'partyList':PartyObjectArray
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
    print 1
    subObj = message.get_subclass_obj()
    print 2
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
    clientparty_list = PartiesClients.objects.filter(party = party)
    all_client_count = clientparty_list.count()
    applied_client_count = clientparty_list.filter(apply_status = u'apply').count()
    donothing_client_count = clientparty_list.filter(apply_status = u'noanswer').count()
    refused_client_count = clientparty_list.filter(apply_status = u'reject').count()
    return {
            'allClientcount':all_client_count,
            'appliedClientcount':applied_client_count,
            'refusedClientcount':refused_client_count,
            'donothingClientcount':donothing_client_count,
            }

@csrf_exempt
@apis_json_response_decorator
def GetPartyClientSeperatedList(request, pid, type):
    try:
        party = Party.objects.get(pk = pid)
    except:
        raise myException(u'该会议已被删除')
    if type == "all":
        clientparty_list = PartiesClients.objects.filter(party = party).order_by('apply_status')
    elif type == 'applied':
        clientparty_list = PartiesClients.objects.filter(party = party, apply_status = u"apply")
    elif type == 'refused':
        clientparty_list = PartiesClients.objects.filter(party = party, apply_status = u"reject")
    elif type == 'donothing':
        clientparty_list = PartiesClients.objects.filter(party = party, apply_status = u"noanswer")
    clientList = []
    for clientparty in clientparty_list:
        if not clientparty.client.phone:
            cValue = clientparty.client.email
        else:
            cValue = clientparty.client.phone
        if type == 'all':
            dic = {
                   'cName':clientparty.client.name,
                   'cValue':cValue,
                   'backendID':clientparty.id,
                   'status':clientparty.apply_status
                   }
        else:
            dic = {
                   'cName':clientparty.client.name,
                   'cValue':cValue,
                   'backendID':clientparty.id,
                   }
        clientList.append(dic)
    return {
            'clientList':clientList,
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
        subject = request.POST['subject']
        _isapplytips = request.POST['_isapplytips']
        _issendbyself = request.POST['_issendbyself']
        msgType = request.POST['msgType']
        partyID = request.POST['partyID']
        uID = request.POST['uID']
        addressType = request.POST['addressType']
        user = User.objects.get(pk = uID)
        try:
            party = Party.objects.get(pk = partyID, creator = user)
        except Exception:
            raise myException(u'该会议会议已被删除')
        addressArray = []
        for i in range(len(receivers)):
            receiver = receivers[i]
            
            if msgType == 'SMS':
                client, is_created = Client.objects.get_or_create(phone = receiver['cValue'],
                                                              name = receiver['cName'],
                                                              creator = user,
                                                              )
            else:
                client, is_created = Client.objects.get_or_create(phone = receiver['cValue'],
                                                              name = receiver['cName'],
                                                              creator = user,
                                                              )
            PartiesClients.objects.get_or_create(
                                              party = party,
                                              client = client,
                                              apply_status = u'noanswer'
                                              ) 
#            receiversDic = {
#                            'addressType':addressType,
#                            'addressData':receivers
#                            }
#            receiversString = simplejson.dumps(receiversDic)
            addressArray.append(receiver['cValue'])
        addressString = simplejson.dumps(addressArray)
        if msgType == 'SMS':
            msg, created = SMSMessage.objects.get_or_create(party = party)
            msg.content = content
            msg.is_apply_tips = _isapplytips
            msg.is_send_by_self = _issendbyself
            msg.save()
            Outbox.objects.create(address = addressString, base_message = msg.basemessage_ptr)
        else:
            msg, created = EmailMessage.objects.get_or_create(party = party)
            msg.subject = subject
            msg.content = content
            msg.is_apply_tips = _isapplytips
            msg.is_send_by_self = _issendbyself
            msg.save()
            Outbox.objects.create(address = addressString, base_message = msg.basemessage_ptr)
        return {'partyId':party.id}
