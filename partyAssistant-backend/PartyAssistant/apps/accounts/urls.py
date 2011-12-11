from apps.accounts.forms import LoginForm
from django.conf.urls.defaults import patterns, url
from django.contrib.auth import views as auth_views

urlpatterns = patterns('apps.accounts.views',
    url(r'^login/$', auth_views.login, {'template_name': 'accounts/login.html', 'authentication_form':LoginForm }, name='login'),
    url(r'^register/$', 'register', name='register'),
    url(r'^logout/$', auth_views.logout_then_login, name='logout'),
    
    url(r'^profile/$', 'profile', name='profile'),
    url(r'^logout/$', auth_views.logout, {'template_name': 'home.html'}, name='logout'),
    url(r'^change_password/$', 'change_password', name='change_password'), 
    url(r'^get_availbale_sms_count_ajax/$', 'get_availbale_sms_count_ajax', name='get_availbale_sms_count_ajax'), 
)
