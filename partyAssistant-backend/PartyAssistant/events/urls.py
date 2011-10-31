from django.conf.urls.defaults import patterns, include, url

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
    url(r'^createparty/$','events.views.createParty',name='creatparty'),
    url(r'^deleteparty/$','events.views.deleteParty',name='deleteparty'),
    url(r'^$','events.views.index'),
)
