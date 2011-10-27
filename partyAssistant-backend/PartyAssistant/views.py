'''
Created on 2011-10-27

@author: liwenjian
'''
from django.template.response import TemplateResponse

def home(request):
    return TemplateResponse(request, 'home.html')
    