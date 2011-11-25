'''
Created on 2011-10-27

@author: liwenjian
'''
from django.shortcuts import redirect

def home(request):
    return redirect('list_party')
    