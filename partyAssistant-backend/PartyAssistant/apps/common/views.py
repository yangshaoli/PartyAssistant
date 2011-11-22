'''
Created on 2011-11-21

@author: liwenjian
'''
from apps.common.models import ShortLink
from django.shortcuts import get_object_or_404, redirect

def short_link(request, short_link):
    link = get_object_or_404(ShortLink, short_link=short_link)
    return redirect(link.long_link)
