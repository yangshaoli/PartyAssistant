#encoding = utf-8
from django.utils import simplejson
from django.http import HttpResponse

from settings import IPHONE_APP_VERSION, ANDROID_APP_VERSION

from utils.structs.my_exception import myException

def apis_json_response_decorator(func):
    def new_func(*args, **kargs):
        try:
            datasource = func(*args, **kargs)
            data = {
                    'status':"ok",
                    'description':"ok",
                    'datasource':datasource,
                    'version':IPHONE_APP_VERSION,
                    'android_version':ANDROID_APP_VERSION,
                    }
            data = simplejson.dumps(data)       
            return HttpResponse(data)
        except Exception, e:
            if isinstance(e, myException):
                print e.description
                print e.data
                data = {
                        'status':e.status,
                        'description':e.description,
                        'datasource':data,
                        'iphone_version':IPHONE_APP_VERSION,
                        'android_version':ANDROID_APP_VERSION,
                        }
                data = simplejson.dumps(data)       
                return HttpResponse(data)
            else:
                print e
                raise e
    return new_func
