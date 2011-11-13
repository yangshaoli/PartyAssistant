from django.conf.urls.defaults import patterns, url

urlpatterns = patterns('apps.parties.views',   
    url(r'^create_party/$','create_party', name='create_party'),
    url(r'^delete_party/(?P<party_id>\d+)/$','delete_party', name='delete_party'),
    url(r'^edit_party/(?P<party_id>\d+)/$','edit_party', name='edit_party'),
    url(r'^email_invite/(?P<party_id>\d+)/$','email_invite',name='email_invite'),
    
    url(r'^copy_party/(?P<party_id>\d+)/$','copy_party', name='copy_party'),
    
    url(r'^delete_party_notice/(?P<party_id>\d+)/$','delete_party_notice',name='delete_party_notice'),
    
    
    url(r'^message_invite/$','message_invite',name='message_invite'),
    
    url(r'^list/$','list_party',name='list_party'),
    url(r'^(?P<party_id>\d+)/$','view_party',name='view_party'),
)
