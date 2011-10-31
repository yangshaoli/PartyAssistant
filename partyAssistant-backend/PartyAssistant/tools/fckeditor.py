'''
Created on 2009-12-9

@author: liwenjian
'''

from django.http import HttpResponse
from settings import LIBS_ROOT, PROJECT_ROOT

import sys
sys.path.append(LIBS_ROOT + 'fckeditor/editor/filemanager/connectors/py')

from connector import FCKeditorConnector
from upload import FCKeditorQuickUpload

def connector(request):
    try:
        company_id = str(request.user.userprofile.company.id)
    except Exception:
        company_id = '0'
    request.environ['DOCUMENT_ROOT'] = PROJECT_ROOT
    fckeditorConnector = FCKeditorConnector(request.environ)
    fckeditorConnector.company_id = company_id
    data = fckeditorConnector.doResponse()
    return HttpResponse(data)

def uploader(request):
    try:
        company_id = str(request.user.userprofile.company.id)
    except Exception:
        company_id = '0'
    request.environ['DOCUMENT_ROOT'] = PROJECT_ROOT
    fckeditorQuickUpload = FCKeditorQuickUpload(request.environ)
    fckeditorQuickUpload.company_id = company_id
    data = fckeditorQuickUpload.doResponse()
    return HttpResponse(data)

