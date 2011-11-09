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
 
from apps.parties.models import Party
from apps.clients.models import ClientParty , Client
from utils.tools.page_size_setting import LIST_MEETING_PAGE_SIZE
from utils.tools.paginator_tool import process_paginator
from apps.messages.models import EmailMessage, SMSMessage
import re

from utils.tools.reg_phone_num import regPhoneNum

re_a = re.compile(r'\d+\-\d+\-\d+ \d+\:\d+\:\d+')

@commit_on_success
def createParty(request):
    print 'i am in'
    status = 'ok'
    code = '200'
    description = 'ok' 
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
        try:
            user = User.objects.get(pk = uID)
        except Exception, e:
            print "A"
        if starttime:
            starttime = datetime.datetime.strptime(re_a.search(starttime).group(), '%Y-%m-%d %H:%M:%S')
        #创建活动
       	party = Party.objects.create(time = starttime,
                             address = location,
                             description = description,
                             creator = user,
                             limit_num = peopleMaximum,
                             )
        data = {}
        for i in range(len(receivers)):
            receiver = receivers[i]
            if msgType == 'SMS':
                ClientParty.objects.create(party = party,
                                           client = Client.objects.get_or_create(phone = regPhoneNum(receiver['cValue']),
                                                                                 name = receiver['cName'],
                                                                                 creator = user,
                                                                                 )[0],
                                       apply_status = u'未报名'
                                       )
            else:
                ClientParty.objects.create(
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
                print 'send Email'
                if _isapplytips or _isapplytips > 0 :
                    enroll_link = DOMAIN_NAME + '/clients/invite_enroll/' + receiver.cVal + '/' + party.id
                    content = content + u'点击进入报名页面：<a href="%s">%s</a>' % (enroll_link, enroll_link)
                EmailMessage.objects.create(
                                            subject = subject,
                                            content = content,
                                            party = party,
                                            _isApplyTips = _isapplytips,
                                            _isSendBySelf = _isSendBySelf
                                            )
                try :     
                    send_emails(subject, content, SYS_EMAIL_ADDRESS, [receiver.cVal])
                except:
                    data['Email'] = u'邮件发送失败'
                    
                try :   
                    client = Client.objects.get(pk = receiver.cId)                     
                except:
                    code = '404'
                    data['client'] = u"未找到对应联系人"
                    description = u'未找到联系人'
                    returnjson = {'status':status,
                      'code':code,
                      'description':description,
                      'data':data              
                     }
                    returnjson = simplejson.dumps(returnjson)       
                    return HttpResponse(returnjson)      
        returnjson = {'status':status,
                      'code':code,
                      'description':description,
                      'data':data              
                     }                 
          
        returnjson = simplejson.dumps(returnjson)       
        return HttpResponse(returnjson)     
    return HttpResponse('Bad Request')

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
        clientpartylist = ClientParty.objects.filter(party = party)
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

        else:
            msgType = 'SMS'   
            smsmessagelist = SMSMessage.objects.filter(party = party).order('-createtime')
            lastet_smsmessage = None
            try:
                lastet_smsmessage = smsmessagelist[0]
            except:
                status = 'fail'
                code = '500'
                if description == 'ok':
                    description = u'获取邮件信息失败，可能没有此信息'      
            subject = ''
            content = lastet_smsmessage.content
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
            returnjson = simplejson.dumps(returnjson)       
        return HttpResponse(returnjson)      

        
