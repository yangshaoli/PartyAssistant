'''
Created on 2011-12-6

@author: liwenjian
'''
from django.shortcuts import redirect
from django.http import HttpResponse

def home(request):
    return redirect('list_party')
