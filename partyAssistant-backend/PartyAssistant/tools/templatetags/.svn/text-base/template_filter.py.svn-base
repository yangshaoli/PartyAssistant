#coding=utf-8
from __future__ import division
from django import template

register = template.Library()

#django自定义过滤器

@register.filter(name = 'paginator_url')
def paginator_url(value, arg):
    return value.replace('(?P<page>\d+)', str(arg))

@register.filter(name = 'truncate_string')
def truncate_string(value, arg):
    length = int(arg)
    if value != None:
        if len(value) <= length:
            return value
        else:
            return value[:length] + '...'

@register.filter(name = 'split_string')
def split_string(value, arg):
    string_list = value.split(' ')
    new_string_list = []
    for string in string_list:
        if len(string) > int(arg):
            index = 0
            while index < len(string):
                new_string_list.append(string[index:index + int(arg)])
                index = index + int(arg)
        else:
            new_string_list.append(string)
            
    return ' '.join(new_string_list)

@register.filter(name = 'mode_operation')
def mode_operation(value, arg):
    return int(value) % int(arg)

@register.filter(name = 'copy_backslash')
def copy_backslash(value):
    value = value.replace('\\', '\\\\')
    value = value.replace('\'', '\\\'')
    value = value.replace('"', "\\\"")
    return value

@register.filter(name = 'count_percent')
def count_percent(value, arg):
    try:
        if int(value) == 0 and int(arg) == 0:
            return "0.00%"
        return format(int(value) / int(arg), '%')[:-5] + '%'
    except Exception:
        return u'无法计算'
