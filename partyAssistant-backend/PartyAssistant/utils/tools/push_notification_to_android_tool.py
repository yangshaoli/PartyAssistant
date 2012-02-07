#coding=utf-8
import os
import urllib2
import urllib

APP_ANDROID_STATIC_KEY = '53fdfe87cb3131ce947bd8b8a65aa252'

def push_notification_to_android(operation, badge, deviceToken, msg, **kwargs):
    param = {
             'app_key':APP_ANDROID_STATIC_KEY,
             'client_ids':deviceToken,
             'msg':msg
             }
    
    url = 'http://www.android-push.com/api/send/?%s' % urllib.urlencode(param)
#    url = url.decode('utf-8')
#    url = 'http://www.android-push.com/api/send/?app_key=%s&client_ids=%s&msg=111' % (APP_ANDROID_STATIC_KEY, deviceToken)
    url = urllib2.unquote(url)
    data = urllib2.urlopen(url)
    res = data.read()
