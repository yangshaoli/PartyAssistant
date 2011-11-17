#coding=utf-8
'''
Created on 2011-11-7

@author: liuxue
'''
import datetime

from django.http import HttpResponse
from django.utils import simplejson
from utils.tools.email_tool import send_emails
from settings import SYS_EMAIL_ADDRESS, DOMAIN_NAME
from django.contrib.auth.models import User
from django.db.transaction import commit_on_success
 
from apps.parties.models import Party, PartiesClients
from apps.clients.models import Client
from utils.tools.page_size_setting import LIST_MEETING_PAGE_SIZE
from utils.tools.paginator_tool import process_paginator
from utils.tools.my_exception import myException
from utils.tools.apis_json_response import apis_json_response_decorator
from apps.messages.models import EmailMessage, SMSMessage
import re

from ERROR_MSG_SETTINGS import *

from utils.tools.reg_phone_num import regPhoneNum

re_a = re.compile(r'\d+\-\d+\-\d+ \d+\:\d+\:\d+')

@apis_json_response_decorator
@commit_on_success
def createParty(request):
    if request.method == 'POST' :
        receivers = eval(request.POST['receivers'])
        content = request.POST['content']
        subject = request.POST['subject']
        _isapplytips = request.POST['_isapplytips']
        _isSendBySelf = request.POST['_issendbyself']
        msgType = request.POST['msgType']
        starttime = request.POST['starttime']
        location = request.POST['location']
        description = request.POST['description']
        peopleMaximum = request.POST['peopleMaximum']
        uID = request.POST['uID']
        user = User.objects.get(pk = uID)
        data = {}
        try:
            starttime = datetime.datetime.strptime(re_a.search(starttime).group(), '%Y-%m-%d %H:%M:%S')
        except Exception:
            starttime = None
        if len(location) > 256:
            raise myException(ERROR_CREATEPARTY_LONG_LOCATION)
        #创建活动
        party = Party.objects.create(time = starttime,
                             address = location,
                             description = description,
                             creator = user,
                             limit_num = peopleMaximum,
                             )
        for i in range(len(receivers)):
            receiver = receivers[i]
            if msgType == 'SMS':
<<<<<<< HEAD
                client, is_created = Client.objects.get_or_create(phone = regPhoneNum(receiver['cValue']),
                                                              name = receiver['cName'],
                                                              creator = user,
                                                              )
            else:
                client, is_created = Client.objects.get_or_create(email = regPhoneNum(receiver['cValue']),
                                                              name = receiver['cName'],
                                                              creator = user,
                                                              )
            ClientParty.objects.create(
                                       party = party,
                                       client = client,
=======
                PartiesClients.objects.create(party = party,
                                           client = Client.objects.get_or_create(phone = regPhoneNum(receiver['cValue']),
                                                                                 name = receiver['cName'],
                                                                                 creator = user,
                                                                                 )[0],
>>>>>>> liuxue
                                       apply_status = u'未报名'
                                       )
            else:
                PartiesClients.objects.create(
                                           party = party,
                                           client = Client.objects.get_or_create(email = receiver['cValue'],
                                                                                 name = receiver['cName'],
                                                                                 creator = user,
                                                                                )[0],
                                            apply_status = u'未报名'
                                            ) 
            if msgType == 'SMS':
                print 'send SMS'
                 
            else:
                if _isapplytips or _isapplytips > 0 :
                    enroll_link = DOMAIN_NAME + '/clients/invite_enroll/' + receiver['cValue'] + '/' + str(party.id)
                    content = content + u'点击进入报名页面：<a href="%s">%s</a>' % (enroll_link, enroll_link)
                EmailMessage.objects.create(
                                            subject = subject,
                                            content = content,
                                            party = party,
                                            _isApplyTips = _isapplytips,
                                            _isSendBySelf = _isSendBySelf
                                            )
                try :
                    pass     
                    #send_emails(subject, content, SYS_EMAIL_ADDRESS, [receiver['cValue']])
                except:
                    print 'exception'
                    data['Email'] = u'邮件发送失败'
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
            starttime = datetime.datetime.strptime(re_a.search(starttime).group(), '%Y-%m-%d %H:%M:%S')
        except Exception:
            starttime = None
        if len(location) > 256:
            raise myException(ERROR_CREATEPARTY_LONG_LOCATION)
        
        user = User.objects.get(pk = uID)
        try:
            party = Party.objects.get(pk = partyID, creator = user)
        except Exception:
            raise myException(u'您要编辑的会议已被删除')
        party.time = starttime
        party.descrption = description
        party.address = location
        party.limit_num = peopleMaximum
        party.save()

def PartyList(request, uid, page = 1):
    status = 'ok'
    code = '200'
    description = 'ok' 
    user = None
    if request.method == 'GET':
        try:
            user = User.objects.get(pk = uid)
        except:
            status = 'fail'
            code = '404'
            if description == 'ok':
                description = u'用户不存在'    
            
    partylist = []
    partyObject = None
    PartyObjectArray = []
    try:
        partylist = Party.objects.filter(creator = user).order_by('-time')  
    except:
        status = "fail"
        code = "404"
        description = u'获取列表失败'  
        dataSource = {
                    'page':page,
                    'partyList':PartyObjectArray
                    }    
        returnjson = {
                    'status':status,
                    'code':code,
                    'description':description,
                    'dataSource':dataSource             
                }
        returnjson = simplejson.dumps(returnjson)       
        return HttpResponse(returnjson)       
    GMT_FORMAT = '%Y-%m-%d %H:%M'
    partylist = process_paginator(partylist, page, LIST_MEETING_PAGE_SIZE)         
        

    for party in partylist:
        try:
            partyObject.starttime = party.time.strftime(GMT_FORMAT)
        except:
            continue
        partyObject.description = party.description
        partyObject.peopleMaximum = party.limit_num
        partyObject.location = party.address
        partyObject.partyId = party.id
        PartyObjectArray.append(partyObject)            

    dataSource = {
                'page':page,
                'partyList':PartyObjectArray
                }    
    returnjson = {
                'status':status,
                'code':code,
                'description':description,
                'dataSource':dataSource             
                }
    returnjson = simplejson.dumps(returnjson)       
    return HttpResponse(returnjson)      


def GetPartyMsg(request, pid):
    status = 'ok'
    code = '200'
    description = 'ok'
    returnjson = {} 
    if request.method == 'GET':
        party = None
        try:
            party = Party.objects.get(pk = pid)
        except:
            status = 'fail'
            code = '404'
            if description == 'ok':
                description = u'用户不存在'    
        ClientObjectArray = []   
        ClientObject = {}
        clientpartylist = PartiesClients.objects.filter(party = party)
        msgType = ''
        client = None
        content = ''
        subject = ''
        _isApplyTips = True
        _isSendBySelf = True
        for clientparty in clientpartylist:
            client = clientparty.client
            ClientObject.cName = client.name
            ClientObject.cVal = client.invite_type
            ClientObject.cId = client.id
            ClientObjectArray.append(ClientObject)
        if client.invite_type == 'email':
            msgType = 'Email'
            print '读取Email'
            emailmessagelist = EmailMessage.objects.filter(party = party).order('-createtime')
            lastet_emailmessage = None
            try:
                lastet_emailmessage = emailmessagelist[0]
            except:
                status = 'fail'
                code = '500'
                if description == 'ok':
                    description = u'获取邮件信息失败，可能没有此信息'        
            subject = lastet_emailmessage.subject
            content = lastet_emailmessage.content
            dataSource = {
                        'msgType':msgType,
                        'receiverArray':ClientObjectArray,
                        'content':content,
                        'subject':subject,
                        '_isApplyTips':_isApplyTips,
                        '_isSendBySelf':_isSendBySelf
                        }    
            returnjson = {
                        'status':status,
                        'code':code,
                        'description':description,
                        'dataSource':dataSource             
                        }

@csrf_exempt
@apis_json_response_decorator
def GetPartyClientMainCount(request, pid):
    try:
        party = Party.objects.get(pk = pid)
    except:
        raise myException(u'您要复制的会议已被删除')
    clientparty_list = ClientParty.objects.filter(party = party)
    all_client_count = clientparty_list.count()
    applied_client_count = clientparty_list.filter(apply_status = u'已报名').count()
    donothing_client_count = clientparty_list.filter(apply_status = u'未报名').count()
    refused_client_count = clientparty_list.filter(apply_status = u'不参加').count()
    print 1
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
        raise myException(u'您要复制的会议已被删除')
    if type == "all":
        clientparty_list = ClientParty.objects.filter(party = party).order_by('apply_status')
    elif type == 'applied':
        clientparty_list = ClientParty.objects.filter(party = party, apply_status = u"已报名")
    elif type == 'refused':
        clientparty_list = ClientParty.objects.filter(party = party, apply_status = u"不参加")
    elif type == 'donothing':
        clientparty_list = ClientParty.objects.filter(party = party, apply_status = u"未报名")
    clientList = []
    for clientparty in clientparty_list:
        if clientparty.client.phone == '':
            cValue = clientparty.client.email
        else:
            cValue = clientparty.client.phone
        if type == 'all':
            dic = {
                   'cName':clientparty.client.name,
                   'cValue':cValue,
                   'cID':clientparty.id,
                   'status':clientparty.apply_status
                   }
        else:
            dic = {
                   'cName':clientparty.client.name,
                   'cValue':cValue,
                   'cID':clientparty.id,
                   }
        clientList.append(dic)
    print clientList
    return {
            'clientList':clientList,
            }

@csrf_exempt
@apis_json_response_decorator
def ChangeClientStatus(request):
    clientparty = ClientParty.objects.get(pk = request.POST['cpID'])
    action = request.POST['cpAction']
    if action == 'apply':
        clientparty.apply_status = u'已报名'
    else:
        clientparty.apply_status = u'不参加'
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
        for i in range(len(receivers)):
            receiver = receivers[i]
            
            if msgType == 'SMS':
                client, is_created = Client.objects.get_or_create(phone = regPhoneNum(receiver['cValue']),
                                                              name = receiver['cName'],
                                                              creator = user,
                                                              )
            else:
                client, is_created = Client.objects.get_or_create(phone = regPhoneNum(receiver['cValue']),
                                                              name = receiver['cName'],
                                                              creator = user,
                                                              )
            ClientParty.objects.get_or_create(
                                              party = party,
                                              client = client,
                                              apply_status = u'未报名'
                                              ) 
            receiversDic = {
                            'addressType':addressType,
                            'addressData':receivers
                            }
            receiversString = simplejson.dumps(receiversDic)
            if msgType == 'SMS':
                msg = SMSMessage.objects.create(receivers = receiversString, content = content, party = party, apply_tips = _isapplytips, send_by_self = _issendbyself)
            else:
                if _isapplytips or _isapplytips > 0 :
                    enroll_link = DOMAIN_NAME + '/clients/invite_enroll/' + receiver['cValue'] + '/' + str(party.id)
                    content = content + u'点击进入报名页面：<a href="%s">%s</a>' % (enroll_link, enroll_link)
                EmailMessage.objects.create(
                                            receivers = receiversString,
                                            subject = subject,
                                            content = content,
                                            party = party,
                                            apply_tips = _isapplytips,
                                            send_by_self = _issendbyself,
                                            )
                try :
                    pass     
                    #send_emails(subject, content, SYS_EMAIL_ADDRESS, [receiver['cValue']])
                except:
                    data['Email'] = u'邮件发送失败'
        return {'partyId':party.id}
