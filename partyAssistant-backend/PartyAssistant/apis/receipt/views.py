'''
Created on 2011-12-7

@author: liwenjian
'''
from utils.tools.apis_json_response_tool import apis_json_response_decorator
import json
import urllib

@apis_json_response_decorator
def verify_receipt(request):
    url = 'https://sandbox.itunes.apple.com/verifyReceipt'
    data = {
        'receipt-data': request.POST['receipt-data']
    }
    
    conn = urllib.urlopen(url, json.dumps(data))
    resp = conn.read()
    
    return json.loads(resp)
