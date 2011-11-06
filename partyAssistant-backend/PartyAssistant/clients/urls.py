from django.conf.urls.defaults import patterns, url

urlpatterns = patterns('clients.views',
    url(r'^public_enroll/(?P<party_id>\d+)/$', 'public_enroll', name = 'public_enroll'),
    url(r'^invite_enroll/(?P<email>\S+)/(?P<party_id>\d+)/$', 'invite_enroll', name = 'invite_enroll'),
)
