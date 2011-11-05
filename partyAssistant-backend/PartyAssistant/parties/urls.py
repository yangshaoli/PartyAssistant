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
    url(r'^create_party/$','parties.views.create_party',name='create_party'),
    url(r'^delete_party/$','parties.views.delete_party',name='delete_party'),
    url(r'^copy_party/(?P<party_id>\d+)/$','parties.views.copy_party',name='copy_party'),
    )
