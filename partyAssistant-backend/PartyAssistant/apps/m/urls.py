'''
Created on 2011-11-22

@author: liwenjian
'''
from django.contrib.auth import views as auth_views
from django.conf.urls.defaults import patterns, url

urlpatterns = patterns('', 
    url(r'^$', 'views.home'), 
    url(r'^(?P<short_link>[a-zA-Z]+)$', 'apps.common.views.short_link'), 
)

urlpatterns += patterns('apps.accounts.views',
    url(r'^login/$', auth_views.login, {'template_name': 'accounts/login.html'}),
    url(r'^register/$', 'register'),
    url(r'^logout/$', auth_views.logout_then_login),
    
    url(r'^get_password/$', 'get_password'),
    url(r'^profile/$', 'profile'),
    url(r'^activate/(?P<email>\S+)/(?P<random_str>\w+)/$', 'activate'),
    url(r'^logout/$', auth_views.logout, {'template_name': 'home.html'}),
    url(r'^change_password/$', 'change_password'), 
)

urlpatterns += patterns('apps.clients.views',
    url(r'^change_apply_status/(?P<id>\d+)/(?P<applystatus>\w+)/$', 'change_apply_status'),
    url(r'^invite_list/(?P<party_id>\d+)/$', 'invite_list'),
    url(r'^invite_list_ajax/(?P<party_id>\d+)/$', 'invite_list_ajax'),
)

urlpatterns += patterns('apps.parties.views',
    url(r'^list/$','list_party'),   
    url(r'^create_party/$', 'create_party'),
    url(r'^delete_party/(?P<party_id>\d+)/$', 'delete_party'),
    url(r'^edit_party/(?P<party_id>\d+)/$', 'edit_party'),
    url(r'^copy_party/(?P<party_id>\d+)/$','copy_party'),
    
    url(r'^(?P<party_id>\d+)/email_invite/$', 'email_invite'),
    url(r'^(?P<party_id>\d+)/sms_invite/$', 'sms_invite'), 
    
    url(r'^(?P<party_id>\d+)/enroll/$', 'enroll'), 
)
