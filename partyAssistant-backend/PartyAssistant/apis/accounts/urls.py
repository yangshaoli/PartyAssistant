'''
Created on 2011-11-7

@author: liuxue
'''
from django.conf.urls.defaults import patterns, url

urlpatterns = patterns('apis.accounts.views',
    url(r'^login/$', 'accountLogin', name = 'accountLogin'),
    url(r'^logout/$', 'accountLogout', name = 'accountLogout'),
    url(r'^regist/$', 'accountRegist', name = 'accountRegist'),
    url(r'^logout/$', 'accountLogout', name = 'accountLogout'),
    url(r'^get_badge_num/$', 'getBadgeNum', name = 'getBadgeNum'),
    url(r'^get_account_remaining/$', 'getAccountRemaining', name = 'getAccountRemaining'),
    url(r'^forget_password/$', 'forgetPassword', name = 'forgetPassword'),
    url(r'^get_profile/$', 'profilePage', name = 'profilePage'),
    url(r'^save_nickname/$', 'saveNickName', name = 'saveNickName'),
    url(r'^bind/phone/$', 'bindContact', {'type':'phone'}, name = 'bindPhone'),
    url(r'^bind/email/$', 'bindContact', {'type':'email'}, name = 'bindEmail'),
    url(r'^unbind/phone/$', 'unbindContact', {'type':'phone'}, name = 'unbindPhone'),
    url(r'^unbind/email/$', 'unbindContact', {'type':'email'}, name = 'unbindEmail'),
    url(r'^verify/phone/$', 'verifyContact', {'type':'phone'}, name = 'verifyPhone'),
    url(r'^verify/email/$', 'verifyContact', {'type':'email'}, name = 'verifyEmail'),
)
