'''
Created on 2010-1-2

@author: liwenjian
'''

from django.core.paginator import Paginator, InvalidPage, EmptyPage

def process_paginator(obj_list, page, page_size):
    paginator = Paginator(obj_list, page_size)
    try:
        obj_list = paginator.page(page)
    except (EmptyPage, InvalidPage):
        obj_list = paginator.page(1)
    
    return obj_list
