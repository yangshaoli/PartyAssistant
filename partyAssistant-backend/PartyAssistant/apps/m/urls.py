'''
Created on 2011-11-22

@author: liwenjian
'''
from django.contrib.auth import views as auth_views
from django.conf.urls.defaults import patterns, url

urlpatterns = patterns('',
    url(r'^$', 'apps.main.views.home'),
    url(r'^(?P<short_link>[a-zA-Z0-9]+)$', 'apps.common.views.short_link'),
)

urlpatterns += patterns('apps.accounts.views',
    url(r'^accounts/login/$', auth_views.login, {'template_name': 'accounts/login.html'}),
    url(r'^accounts/register/$', 'register'),
    url(r'^accounts/logout/$', auth_views.logout_then_login),
    
    url(r'^accounts/profile/$', 'profile'),
    url(r'^accounts/logout/$', auth_views.logout, {'template_name': 'home.html'}),
    url(r'^accounts/change_password/$', 'change_password'),
)

urlpatterns += patterns('apps.clients.views',
    url(r'^clients/change_apply_status/(?P<id>\d+)/(?P<applystatus>\w+)/$', 'change_apply_status'),
    url(r'^clients/invite_list/(?P<party_id>\d+)/$', 'invite_list'),
)

urlpatterns += patterns('apps.parties.views',
    url(r'^parties/list/$', 'list_party'),
    url(r'^parties/create_party/$', 'create_party'),
    url(r'^parties/delete_party/(?P<party_id>\d+)/$', 'delete_party'),
    url(r'^parties/edit_party/(?P<party_id>\d+)/$', 'edit_party'),
    url(r'^parties/invite_list_ajax/(?P<party_id>\d+)/$', 'invite_list_ajax'),
    url(r'^parties/(?P<party_id>\d+)/email_invite/$', 'email_invite'),
    url(r'^parties/(?P<party_id>\d+)/sms_invite/$', 'sms_invite'),
    
    url(r'^parties/(?P<party_id>\d+)/enroll/$', 'enroll'),
    url(r'^parties/invite_list_ajax/(?P<party_id>\d+)/$', 'invite_list_ajax'),
)
