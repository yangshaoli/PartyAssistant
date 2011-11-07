'''
Created on 2009-8-14

@author: liwenjian
'''
#from tools.handler404 import handler404
from django.shortcuts import redirect
from django.core.urlresolvers import reverse
from django.db.models.query import QuerySet
from django.db.models.manager import Manager
from django.http import Http404
from django.template import Context, RequestContext, loader
from django import http

def index(request):
    if request.user.is_authenticated():
        return redirect(reverse('list_meeting'))
    else:
        return redirect(reverse('account_login'))
    
def get_object_or_404(request, error_msg, klass, *args, **kwargs):
    """
    Uses get() to return an object, or raises a Http404 exception if the object
    does not exist.

    klass may be a Model, Manager, or QuerySet object. All other passed
    arguments and keyword arguments are used in the get() query.

    Note: Like with get(), an MultipleObjectsReturned will be raised if more than one
    object is found.
    """
    queryset = _get_queryset(klass)
    try:
        return queryset.get(*args, **kwargs)
    except queryset.model.DoesNotExist:
        request.session['error_msg_404'] = error_msg
        raise Http404()
    
def _get_queryset(klass):
    """
    Returns a QuerySet from a Model, Manager, or QuerySet. Created to make
    get_object_or_404 and get_list_or_404 more DRY.
    """
    if isinstance(klass, QuerySet):
        return klass
    elif isinstance(klass, Manager):
        manager = klass
    else:
        manager = klass._default_manager
    return manager.all()

def custom_404(request):
    error_msg_404 = request.session['error_msg_404']
    del request.session['error_msg_404']
    referer = request.META.get('HTTP_REFERER')
    t = loader.get_template('error_404_page.html')# You need to create a 404.html template.
    return http.HttpResponseNotFound(t.render(RequestContext(request, {'referer':referer, 'error_msg_404':error_msg_404, 'request_path': request.path})))