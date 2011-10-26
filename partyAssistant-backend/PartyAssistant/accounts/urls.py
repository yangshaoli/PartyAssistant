from django.conf.urls.defaults import patterns, url
from django.contrib.auth import views as auth_views
from . import views


urlpatterns = patterns('',
    url(r'^login/$',
		auth_views.login, 
		{'template_name': 'accounts/login.html'}, 
		name='login'),

    url(r'^reg_web/$', 
		views.register, 
		name='reg_web'),

    url(r'^logout/$', 
		auth_views.logout,
		{'template_name': 'index.html'}, 
		name='logout'),
	)
