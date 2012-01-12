#coding=utf-8
from django.contrib.auth.models import User
from django.db import models
from django.db.models import signals
from utils.tools.sms_tool import sendsmsBindingmessage
from utils.tools.email_tool import send_binding_email
import thread

ACCOUNT_TYPE_CHOICES = (
               (u'管理员', u'管理员'),
               (u'临时账户', u'临时账户'),
               (u'子账户', u'子账户'),
               )

ACTION_CHOICES = (
                  (u'新建账户', u'新建账户'),
                  (u'转正账户', u'转正账户'),
                  (u'密码找回', u'密码找回'),
                  )

PAYMENT_TYPE = (
                (u'人民币', u'人民币'),
                (u'美元', u'美元'),
                )
BINDING_STATUS = (
                  ('unbind', 'unbind'),
                  ('bind' , 'bind'),
                  ('waitingbind', 'waitingbind'),
                  ('waiteunbind', 'waiteunbind'),
                  )

class UserProfile(models.Model):
    user = models.OneToOneField(User)
    true_name = models.CharField(max_length = 16, blank = True)
    #自己注册的为管理员
    account_type = models.CharField(max_length = 16, choices = ACCOUNT_TYPE_CHOICES)
    first_login = models.BooleanField(default = True)
    phone = models.CharField(blank = True, max_length = 16)
    phone_binding_status = models.CharField(default = 'unbind', max_length = 16, choices = BINDING_STATUS)
    email = models.CharField(blank = True, max_length = 128)
    email_binding_status = models.CharField(default = 'unbind', max_length = 16, choices = BINDING_STATUS)
    used_sms_count = models.IntegerField(default = 0)
    available_sms_count = models.IntegerField(default = 30)
    
    def __unicode__(self):
        return self.user.username

class UserDeviceTokenBase(models.Model):
    user = models.ForeignKey(User)
    device_token = models.CharField(max_length = 128)
    
    def __unicode__(self):
        return self.user.username
    
    def get_subclass_type(self):
        if hasattr(self, "useriphonetoken"):
            return 'iPhone'
        else:
            return 'Android'

    def get_subclass_obj(self, *args):
        if hasattr(self, "useriphonetoken"):
            return self.useriphonetoken
        else:
            return self.userandroidtoken
    
class UserIPhoneToken(UserDeviceTokenBase):
    device_type = models.CharField(max_length = 16, default = 'iPhone')

class UserAndroidToken(UserDeviceTokenBase):
    device_type = models.CharField(max_length = 16, default = 'Android')
    
class ProductionInfo(models.Model):
    production_apple_id = models.CharField(max_length = 128, blank = True)
    pay_money = models.CharField(max_length = 8)
    pay_money_type = models.CharField(max_length = 8)
    items_count = models.IntegerField()
    
    def __unicode__(self):
        return self.production_apple_id

class Premium(models.Model):
    description = models.TextField()
    
    def __unicode__(self):
        return self.description

class UserReceiptBase(models.Model):
    user = models.ForeignKey(User)
    buy_time = models.DateTimeField(null = True, blank = True)
    create_time = models.DateTimeField(auto_now_add = True)

    pre_sms_count = models.IntegerField()
    final_sms_count = models.IntegerField(null = True, blank = True)
    
    def __unicode__(self):
        return self.user

class UserAppleReceipt(UserReceiptBase):
    apple_production = models.ForeignKey(ProductionInfo)
    device = models.CharField(max_length = 16, default = 'iPhone')
    receipt = models.TextField()
    premium = models.ForeignKey(Premium)
    
    def __unicode__(self):
        return self.user.username

BINDING_TYPE = (
                ('phone', 'phone'),
                ('email', 'email')
                )
class UserBindingTemp(models.Model):
    user = models.ForeignKey(User)
    binding_type = models.CharField(max_length = 8, choices = BINDING_TYPE)
    key = models.CharField(max_length = 32, blank = True, default = '')
    binding_address = models.CharField(max_length = 75, blank = True, default = '')
    created_time = models.DateTimeField(auto_now = True)
    binding_type = models.CharField(max_length = 8, choices = BINDING_TYPE)
   
class UserAliReceipt(UserReceiptBase):
    receipt = models.TextField()
    payment = models.CharField(max_length = 16, null = True, blank = True)
    items_count = models.IntegerField()
    premium = models.ForeignKey(Premium, default = 1)
    totle_fee = models.DecimalField(max_digits = 19, decimal_places = 10, default = 0)
    def __unicode__(self):
        return self.user.username


    
def create_user_profile(sender = None, instance = None, created = False, **kwargs):
    if created:
        UserProfile.objects.create(user = instance)
   
signals.post_save.connect(create_user_profile, sender = User)


def sendBindingMessage(sender = None, instance = None, **kwargs):
    if instance.binding_type == 'phone':
        thread.start_new_thread(sendsmsBindingmessage, (instance,))
        
    if instance.binding_type == 'email':
        thread.start_new_thread(send_binding_email, (instance,))

signals.post_save.connect(sendBindingMessage, sender = UserBindingTemp)

