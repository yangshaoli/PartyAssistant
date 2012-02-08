#coding=utf-8
import thread

from apps.accounts.models import UserDeviceTokenBase, UserIPhoneToken, UserAndroidToken
from apps.parties.models import PartiesClients, Party

from utils.tools.push_notification_to_apple_tool import push_notification_to_apple
from utils.tools.push_notification_to_android_tool import push_notification_to_android

def push_notification_when_enroll(party_client, operation):
    thread.start_new_thread(push_notification_when_enroll_thread, (party_client, operation))
    
def push_notification_when_enroll_thread(party_client, operation):
    if isinstance(party_client, PartiesClients):
        party_list = Party.objects.filter(creator = party_client.party.creator)
        badge = PartiesClients.objects.filter(party__in = party_list, is_check = False).count()
        if party_client.client.name:
            client_name = party_client.client.name
        else:
            client_name = party_client.get_contact_info()
        if operation == 'apply':
            msg = u"%s 刚刚了接受您的活动邀请" % client_name
        else:
            msg = u"%s 刚刚拒绝了您的活动邀请" % client_name
#        msg = msg.encode("UTF-8")
        user = party_client.party.creator
        user_device_list = UserDeviceTokenBase.objects.filter(user = user)
        for user_device in user_device_list:
            if user_device.get_subclass_type() == 'iPhone':
                push_notification_to_apple('enroll', badge, user_device.device_token, msg)
            else:
                push_notification_to_android('enroll', badge, user_device.device_token, msg)
