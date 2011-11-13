from django.conf.urls.defaults import patterns, url
from django.contrib.auth import views as auth_views

urlpatterns = patterns('apps.accounts.views',
    url(r'^login/$', auth_views.login, {'template_name': 'accounts/login.html'}, name='login'),
    url(r'^register/$', 'register', name='register'),
    url(r'^logout/$', auth_views.logout_then_login, name='logout'),
    
    url(r'^get_password/$', 'get_password', name='get_password'),
    url(r'^profile/$', 'profile', name='profile'),
    url(r'^activate/(?P<email>\S+)/(?P<random_str>\w+)/$', 'activate', name = 'activate'),
    url(r'^logout/$', auth_views.logout, {'template_name': 'home.html'}, name='logout'),
    url(r'^change_password/$', 'change_password', name='change_password'), 
)
