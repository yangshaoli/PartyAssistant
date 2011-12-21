#encoding=utf-8
'''
Created on 2011-12-7

@author: liwenjian
'''
from utils.tools.apis_json_response_tool import apis_json_response_decorator
from django.db.transaction import commit_on_success
from django.views.decorators.csrf import csrf_exempt
from django.contrib.auth.models import User

from apps.accounts.models import ProductionInfo, Premium, UserReceiptBase, UserAppleReceipt, UserAliReceipt

from utils.structs.my_exception import myException
import json
import datetime
import urllib

@commit_on_success
@csrf_exempt
@apis_json_response_decorator
def verify_receipt(request):
    if request.method == 'POST':
        user = User.objects.get(pk = request.POST['user-ID'])
        
        url = 'https://sandbox.itunes.apple.com/verifyReceipt'
#        url = 'https://buy.itunes.apple.com/verifyReceipt'
        data = {
            'receipt-data': request.POST['receipt-data']
        }
        
        conn = urllib.urlopen(url, json.dumps(data))
        resp = conn.read()
        
        data = json.loads(resp)
        status = data['status']
        print status
        print type(status)
        if str(status) == "0":
            receipt = data["receipt"]
            receipt_str = json.dumps(receipt)
            print data
            product_id = receipt["product_id"]
            purchase_date = receipt["original_purchase_date"][:19]
            purchase_date = datetime.datetime.strptime(purchase_date, "%Y-%m-%d %H:%M:%S") + datetime.timedelta(hours = 8)
            production_info = ProductionInfo.objects.get(production_apple_id = product_id)
            pay_money = production_info.pay_money
            pay_money_type = production_info.pay_money_type
            items_count = production_info.items_count
            apple_receipt_list = UserAppleReceipt.objects.filter(receipt = receipt_str)
            if apple_receipt_list:
                raise myException(u'重复的收据')
            else:
                UserAppleReceipt.objects.create(
                                                user = user,
                                                receipt = receipt_str,
                                                buy_time = purchase_date,
                                                pre_sms_count = user.userprofile.available_sms_count,
                                                final_sms_count = user.userprofile.available_sms_count + items_count,
                                                apple_production = production_info,
                                                premium = Premium.objects.latest('pk'),
                                                )
        return json.loads(resp)
    else:
        raise myException('Bad Request')
