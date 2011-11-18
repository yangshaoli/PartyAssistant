from django.conf.urls.defaults import patterns, url

urlpatterns = patterns('apps.clients.views',

    url(r'^change_apply_status/$','change_apply_status',name='change_status'),
    url(r'^invite_list/(?P<party_id>\d+)/$','invite_list',name='invite_list'),
    url(r'^invite_list_ajax/(?P<party_id>\d+)/$','invite_list_ajax',name='invite_list_ajax'),
)
