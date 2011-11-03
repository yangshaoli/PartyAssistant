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
    url(r'^apply2not/(?P<linkman_id>\d+)/$','clients.views.apply2not',name='apply2not'),
    url(r'^change_apply_status/$','clients.views.change_apply_status',name='change_apply_status'),
    url(r'^invite_list/(?P<party_id>\d+)/$','clients.views.invite_list',name='invite_list'),
    )
