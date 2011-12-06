from APNSWrapper import *
import binascii

def push_notification_to_apple(client_name, badge, deviceToken):
    deviceToken = binascii.unhexlify(deviceToken)
    wrapper = APNSNotificationWrapper('static/certificate/ck.pem', True)
    message = APNSNotification()
    message.token(deviceToken)
    message.alert("Very simple alert")
    message.badge(badge)
    message.sound()
    wrapper.append(message)
    wrapper.notify()
