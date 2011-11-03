from django.conf.urls.defaults import patterns, url

# Uncomment the next two lines to enable the admin:
# from django.contrib import admin
# admin.autodiscover()

urlpatterns = patterns('parties.views',   
    # Examples:
    # url(r'^$', 'PartyAssistant.views.home', name='home'),
    # url(r'^PartyAssistant/', include('PartyAssistant.foo.urls')),

    # Uncomment the admin/doc line below to enable admin documin/doc/', include('django.contrientation:
    # url(r'^admb.admindocs.urls')),

    # Uncomment the next line to enable the admin:
    url(r'^create_party/$','create_party',name='create_party'),
    url(r'^delete_party/(?P<id>\d+)/$','delete_party',name='delete_party'),
    url(r'^message_invite/$','message_invite',name='message_invite'),
    url(r'^email_invite/$','email_invite',name='email_invite'),
    url(r'^list/$','list_party',name='list_party'),
)
