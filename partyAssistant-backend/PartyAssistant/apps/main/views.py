'''
Created on 2011-12-6

@author: liwenjian
'''
from django.shortcuts import redirect

def home(request):
    return redirect('list_party')
