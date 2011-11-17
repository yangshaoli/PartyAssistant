from django.conf.urls.defaults import patterns, url

urlpatterns = patterns('apps.parties.views',
    url(r'^list/$','list_party',name='list_party'),   
    url(r'^create_party/$', 'create_party', name='create_party'),
    url(r'^delete_party/(?P<party_id>\d+)/$', 'delete_party', name='delete_party'),
    url(r'^edit_party/(?P<party_id>\d+)/$', 'edit_party', name='edit_party'),
    url(r'^(?P<party_id>\d+)/email_invite/$', 'email_invite',name='email_invite'),
    url(r'^(?P<party_id>\d+)/sms_invite/$', 'sms_invite',name='sms_invite'), 
    
    url(r'^copy_party/(?P<party_id>\d+)/$','copy_party', name='copy_party'),
      
    url(r'^message_invite/$','message_invite',name='message_invite'),
    url(r'^(?P<party_id>\d+)/$','view_party',name='view_party'),
)
