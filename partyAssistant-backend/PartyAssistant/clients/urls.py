from django.conf.urls.defaults import patterns, url

urlpatterns = patterns('clients.views',
    url(r'^public_enroll/(?P<party_id>\d+)/$', 'public_enroll', name = 'public_enroll'),
    url(r'^invite_enroll/(?P<email>\S+)/(?P<party_id>\d+)/$', 'invite_enroll', name = 'invite_enroll'),
    
    url(r'^change_apply_status/$','change_apply_status',name='change_apply_status'),
    url(r'^invite_list/(?P<party_id>\d+)/$','invite_list',name='invite_list'),
    url(r'^enrolled_list/(?P<party_id>\d+)/$','enrolled_list',name='enrolled_list'),
    url(r'^noenroll_list/(?P<party_id>\d+)/$','noenroll_list',name='noenroll_list'),
    url(r'^reject_list/(?P<party_id>\d+)/$','reject_list',name='reject_list'),

)
