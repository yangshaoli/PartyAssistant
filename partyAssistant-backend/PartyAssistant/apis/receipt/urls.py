'''
Created on 2011-12-7

@author: liwenjian
'''
from django.conf.urls.defaults import patterns, url

urlpatterns = patterns('apis.receipt.views',
    url(r'^verifyReceipt/$', 'verify_receipt'), 
)
