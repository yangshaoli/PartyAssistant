#coding=utf-8
'''
Created on 2011-11-7

@author: liuxue
'''
from django.http import HttpResponse
from django.utils import simplejson
from tools.email_tool import send_emails
from settings import SYS_EMAIL_ADDRESS, DOMAIN_NAME
from django.contrib.auth.models import User
from parties.models import Party
from clients.models import ClientParty , Client
def createParty(request):
    if request.method == 'POST' :
        receivers = request.POST['receivers']
        content = request.POST['content']
        subject = request.POST['subject']
        _isapplytips = request.POST['_isapplytips']
        msgType = request.POST['msgType']
        starttime = request.POST['starttime']
        location = request.POST['location']
        description = request.POST['description']
        peopleMaximum = request.POST['peopleMaximum']
        uID = request.POST['uID']
        
        #创建活动
           
        party=Party.objects.create(time=starttime,
                             address=location,
                             description=description,
                             creator=User.objects.get(pk=uID),
                             limit_num=peopleMaximum,
                             )
        #返回状态
        status = 'ok'
        code   = '200'
        description = 'ok'
        data  = {}
        for i in range(receivers):
            receiver = receivers[i]
            ClientParty.objects.create(party=party,
                                       client=Client.objects.get(pk=receiver.cId),
                                       apply_status=u'未报名'
                                       )
         
            
            if msgType == 'SMS':
                print 'send SMS'
                 
            else:
                print 'send Email'
                if _isapplytips:
                    enroll_link = DOMAIN_NAME+'/clients/invite_enroll/'+receiver.cVal+'/'+party.id
                    content = content + u'点击进入报名页面：<a href="%s">%s</a>' % (enroll_link, enroll_link)
                    try :     
                        send_emails(subject, content, SYS_EMAIL_ADDRESS, [receiver.cVal])
                    except:
                        code = '500'
                        data['Email']=u'邮件发送失败'
                        description='fail'
                try :   
                    client = Client.objects.get(pk=receiver.cId)
                    ClientParty.objects.create(client=client, party=party, apply_status=u'未报名') 
                except:
                    code = '404'
                    data['client']="未找到对应联系人"
                    description='fail'    
        returnjson = {'status':status,
                      'code':code,
                      'description':description,
                      'data':data              
                     }                 
          
        returnjson = simplejson.dumps(returnjson)       
        return HttpResponse(returnjson)     
 
