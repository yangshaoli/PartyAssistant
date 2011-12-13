'''
Created on 2011-12-7

@author: liwenjian
'''
from utils.tools.apis_json_response_tool import apis_json_response_decorator
from django.db.transaction import commit_on_success
from django.views.decorators.csrf import csrf_exempt
from django.contrib.auth.models import User
from utils.structs.my_exception import myException
import json
import urllib

@commit_on_success
@csrf_exempt
@apis_json_response_decorator
def verify_receipt(request):
    if request.method == 'POST':
        user = User.objects.get(pk = request.POST['uid'])
        
        url = 'https://sandbox.itunes.apple.com/verifyReceipt'
        data = {
            'receipt-data': request.POST['receipt-data']
        }
        
        conn = urllib.urlopen(url, json.dumps(data))
        resp = conn.read()
    
        return json.loads(resp)
    else:
        raise myException('Bad Request')
