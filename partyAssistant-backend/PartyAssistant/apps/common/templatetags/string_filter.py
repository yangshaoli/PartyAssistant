'''
Created on 2011-11-20

@author: liwenjian
'''
from django import template
from django.template.defaultfilters import stringfilter

register = template.Library()

@register.filter
def truncatestring(value, arg):
    try:
        length = int(arg)
    except ValueError:
        return value
    
    if len(value) < length:
        return value
    else:
        return value[0:length] + '...'
truncatestring.is_safe = True
truncatestring = stringfilter(truncatestring)
