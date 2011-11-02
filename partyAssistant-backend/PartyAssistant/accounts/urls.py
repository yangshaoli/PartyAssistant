from django.conf.urls.defaults import patterns, url
from django.contrib.auth import views as auth_views

urlpatterns = patterns('accounts.views',
    url(r'^login/$',auth_views.login,{'template_name': 'accounts/login.html'}, name='login'),
    url(r'^web_register/$', 'web_register', name='web_register'),
    url(r'^app_register/$', 'app_register', name='app_register'),
    url(r'^activate/(?P<email>\S+)/(?P<random_str>\w+)/$', 'activate', name = 'activate'),
    url(r'^logout/$', auth_views.logout, {'template_name': 'index.html'}, name='logout'),
)
