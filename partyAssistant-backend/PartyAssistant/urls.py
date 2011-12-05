from django.conf.urls.defaults import patterns, include, url

# Uncomment the next two lines to enable the admin:
from django.contrib import admin
admin.autodiscover()

urlpatterns = patterns('',   
    # Examples:
    url(r'^$', 'PartyAssistant.views.home', name='home'),
    url(r'^m/$', 'PartyAssistant.views.home', name='home'),
    url(r'^m/parties/(?P<party_id>\d+)/enroll/$', 'apps.parties.views.enroll'),
    url(r'^m/clients/invite_list_ajax/(?P<party_id>\d+)/$', 'apps.clients.views.invite_list_ajax'),
    # url(r'^PartyAssistant/', include('PartyAssistant.foo.urls')),

    # Uncomment the admin/doc line below to enable admin documentation:
    url(r'^admin/doc/', include('django.contrib.admindocs.urls')),

    # Uncomment the next line to enable the admin:
    url(r'^admin/', include(admin.site.urls)),
    
    url(r'^$', 'views.home', name='home'),
    url(r'^accounts/', include('apps.accounts.urls')),
    url(r'^clients/', include('apps.clients.urls')),
    url(r'^parties/', include('apps.parties.urls')),
    url(r'^(?P<short_link>[a-zA-Z]+)$', 'apps.common.views.short_link', name='short_link'), 
        
    url(r'^a/',include('apis.urls')),
    url(r'^m/', include('apps.m.urls')), 
)
