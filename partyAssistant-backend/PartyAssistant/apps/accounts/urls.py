from django.conf.urls.defaults import patterns, url
from django.contrib.auth import views as auth_views

urlpatterns = patterns('apps.accounts.views',
    url(r'^login/$',auth_views.login,{'template_name': 'accounts/login.html'}, name='login'),
    url(r'^web_register/$', 'web_register', name='web_register'),
    url(r'^app_register/$', 'app_register', name='app_register'),
    url(r'^get_password/$', 'get_password', name='get_password'),
    url(r'^profile/$', 'profile', name='profile'),
    url(r'^logout/$', auth_views.logout, {'next_page': '/accounts/login'}, name='logout'),
)
