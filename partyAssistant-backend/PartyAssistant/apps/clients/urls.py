from django.conf.urls.defaults import patterns, url

urlpatterns = patterns('apps.clients.views',
    url(r'^public_enroll/(?P<party_id>\d+)/$', 'public_enroll', name = 'public_enroll'),
    url(r'^invite_enroll/(?P<email>\S+)/(?P<party_id>\d+)/$', 'invite_enroll', name = 'invite_enroll'),
    url(r'^change_apply_status/(?P<party_client_id>\d+)/$','change_apply_status',name='change_apply_status'),
    url(r'^invite_list/(?P<party_id>\d+)/(?P<apply_status>\S+)/$','invite_list',name='invite_list'),
 
)
