#encoding = utf-8
from django.utils import simplejson
from django.http import HttpResponse

from utils.tools.my_exception import myException

def apis_json_response_decorator(func):
    def new_func(*args):
        try:
            datasource = func(*args)
            data = {
                    'status':"ok",
                    'description':"ok",
                    'datasource':datasource
                    }
            data = simplejson.dumps(data)       
            return HttpResponse(data)
        except Exception, e:
            if isinstance(e, myException):
                data = {
                        'status':e.status,
                        'description':e.description,
                        'datasource':{}
                        }
                data = simplejson.dumps(data)       
                return HttpResponse(data)
            else:
                print e
                raise e
    return new_func
