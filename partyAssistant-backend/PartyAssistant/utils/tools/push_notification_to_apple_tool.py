from APNSWrapper import *
import binascii

def push_notification_to_apple(operation, badge, deviceToken, **kwargs):
#    deviceToken = binascii.unhexlify(deviceToken)
    wrapper = APNSNotificationWrapper('static/certificate/ck.pem', True)
    message = APNSNotification()
    message.token(deviceToken)
    message.alert("Very simple alert")
    message.badge(badge)
    message.sound()
    property1 = APNSProperty("operation", "unread")
    message.appendProperty(property1)
    wrapper.append(message)
    wrapper.notify()
