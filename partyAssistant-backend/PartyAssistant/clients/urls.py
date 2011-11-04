from django.conf.urls.defaults import patterns, url

# Uncomment the next two lines to enable the admin:
# from django.contrib import admin
# admin.autodiscover()

urlpatterns = patterns('',   
    # Examples:
    # url(r'^$', 'PartyAssistant.views.home', name='home'),
    # url(r'^PartyAssistant/', include('PartyAssistant.foo.urls')),

    # Uncomment the admin/doc line below to enable admin documin/doc/', include('django.contrientation:
    # url(r'^admb.admindocs.urls')),

    # Uncomment the next line to enable the admin:
    url(r'^change_apply_status/$','clients.views.change_apply_status',name='change_apply_status'),
    url(r'^invite_list/(?P<party_id>\d+)/$','clients.views.invite_list',name='invite_list'),
    url(r'^apply_list/(?P<party_id>\d+)/$','clients.views.apply_list',name='apply_list'),
    url(r'^notresponse_list/(?P<party_id>\d+)/$','clients.views.notresponse_list',name='notresponse_list'),
    url(r'^notapply_list/(?P<party_id>\d+)/$','clients.views.notapply_list',name='notapply_list'),

    )
