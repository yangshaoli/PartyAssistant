'''
Created on 2011-12-7

@author: liwenjian
'''
from utils.tools.apis_json_response_tool import apis_json_response_decorator

@apis_json_response_decorator
def verify_receipt(request):
    return {'status': 0}
