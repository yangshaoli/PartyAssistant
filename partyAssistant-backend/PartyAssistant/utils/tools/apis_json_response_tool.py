#encoding = utf-8
from django.utils import simplejson
from django.http import HttpResponse

from utils.structs.my_exception import myException

def apis_json_response_decorator(func):
    def new_func(*args, **kargs):
        try:
            datasource = func(*args, **kargs)
            print datasource
            data = {
                    'status':"ok",
                    'description':"ok",
                    'datasource':datasource
                    }
            data = simplejson.dumps(data)       
            return HttpResponse(data)
        except Exception, e:
            if isinstance(e, myException):
                print e.description
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
