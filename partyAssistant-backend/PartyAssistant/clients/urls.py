from django.conf.urls.defaults import patterns, url

urlpatterns = patterns('clients.views',
    url(r'^public_enroll/(?P<party_id>\d+)/$', 'public_enroll', name = 'public_enroll'),
    url(r'^invite_enroll/(?P<email>\S+)/(?P<party_id>\d+)/$', 'invite_enroll', name = 'invite_enroll'),
    
    url(r'^change_apply_status/$','change_apply_status',name='change_apply_status'),
    url(r'^invite_list/(?P<party_id>\d+)/$','invite_list',name='invite_list'),
    url(r'^apply_list/(?P<party_id>\d+)/$','apply_list',name='apply_list'),
    url(r'^notresponse_list/(?P<party_id>\d+)/$','notresponse_list',name='notresponse_list'),
    url(r'^notapply_list/(?P<party_id>\d+)/$','notapply_list',name='notapply_list'),

)
