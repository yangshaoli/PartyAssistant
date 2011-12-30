from apps.accounts.forms import LoginForm
from django.conf.urls.defaults import patterns, url
from django.contrib.auth import views as auth_views

urlpatterns = patterns('apps.accounts.views',
    url(r'^login/$', auth_views.login, {'template_name': 'accounts/login.html', 'authentication_form':LoginForm }, name = 'login'),
    url(r'^register/$', 'register', name = 'register'),
    url(r'^logout/$', auth_views.logout_then_login, name = 'logout'),
    
    url(r'^profile/$', 'profile', name='profile'),
    url(r'^completeprofile/$', 'profile', {'template_name': 'accounts/completeprofile.html', 'redirected': 'list_party'}, name='completeprofile'),
    url(r'^logout/$', auth_views.logout, {'template_name': 'home.html'}, name='logout'),
    url(r'^change_password/$', 'change_password', name='change_password'), 
    url(r'^get_availbale_sms_count_ajax/$', 'get_availbale_sms_count_ajax', name='get_availbale_sms_count_ajax'), 
    url(r'^buy_sms/$', 'buy_sms', name='buy_sms'), 
    url(r'^bought_success/$', 'bought_success', name='bought_success'),
    url(r'^apply_phone_bingding_ajax/$', 'apply_phone_bingding_ajax', name='apply_phone_bingding_ajax'),
    url(r'^apply_phone_unbingding_ajax/$', 'apply_phone_unbingding_ajax', name='apply_phone_unbingding_ajax'),
    url(r'^validate_phone_bingding_ajax/$', 'validate_phone_bingding_ajax', {'binding_status':'bind'}, name='validate_phone_bingding_ajax'),
    url(r'^validate_phone_unbingding_ajax/$', 'validate_phone_bingding_ajax', {'binding_status':'unbind'}, name='validate_phone_unbingding_ajax'),
    url(r'^ajax_binding/$', 'ajax_binding', name='ajax_binding'),
)
