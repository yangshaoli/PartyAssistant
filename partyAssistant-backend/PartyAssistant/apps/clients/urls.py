from django.conf.urls.defaults import patterns, url

urlpatterns = patterns('apps.clients.views',

    url(r'^change_apply_status/(?P<id>\d+)/(?P<applystatus>\w+)/$','change_apply_status',name='change_status'),
    url(r'^invite_list/(?P<party_id>\d+)/$','invite_list',name='invite_list'),
)
