from django.conf.urls.defaults import patterns, url

urlpatterns = patterns('apps.parties.views',
    url(r'^list/$','list_party',name='list_party'),   
    url(r'^create_party/$', 'create_party', name='create_party'),
    url(r'^delete_party/(?P<party_id>\d+)/$', 'delete_party', name='delete_party'),
    url(r'^edit_party/(?P<party_id>\d+)/$', 'edit_party', name='edit_party'),
    url(r'^(?P<party_id>\d+)/email_invite/$', 'email_invite',name='email_invite'),
    url(r'^(?P<party_id>\d+)/sms_invite/$', 'sms_invite',name='sms_invite'), 
    url(r'^(?P<party_id>\d+)/enroll/$', 'enroll', name='enroll'), 
)

urlpatterns += patterns('apps.parties.views',
    url(r'^change_apply_status/(?P<party_client_id>\d+)/(?P<applystatus>\w+)/$','change_apply_status',name='change_status'),
    url(r'^(?P<party_id>\d+)/invite_list/$','invite_list',name='invite_list'),
    url(r'^invite_list_ajax/(?P<party_id>\d+)/$','invite_list_ajax',name='invite_list_ajax'),
    url(r'^ajax_get_client_list/(?P<party_id>\d+)/$','ajax_get_client_list',name='ajax_get_client_list'),
)
