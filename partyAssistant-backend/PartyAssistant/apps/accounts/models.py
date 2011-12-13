#coding=utf-8
from django.db import models
from django.contrib.auth.models import User
from django.db.models import signals

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

class UserProfile(models.Model):
    user = models.OneToOneField(User)
    password = models.CharField(max_length = 16, blank = True)
    true_name = models.CharField(max_length = 16, blank = True)
    #自己注册的为管理员
    account_type = models.CharField(max_length = 16, choices = ACCOUNT_TYPE_CHOICES)
    first_login = models.BooleanField(default = True)
    phone = models.IntegerField(null = True, blank = True)
    used_sms_count = models.IntegerField(default = 0)
    available_sms_count = models.IntegerField(default = 30)
    
    def __unicode__(self):
        return self.user.username

class UserDeviceTokenBase(models.Model):
    user = models.ForeignKey(User)
    device_token = models.CharField(max_length = 32)
    
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
    
class TempActivateNote(models.Model):
    random_str = models.CharField(max_length = 16, blank = True)
    email = models.EmailField()
    action = models.CharField(max_length = 16, choices = ACTION_CHOICES, blank = True)
    password = models.CharField(max_length = 16, blank = True)
    #待定内容
    aim_limit = models.CharField(max_length = 16, choices = ACCOUNT_TYPE_CHOICES)
    userprofile = models.ForeignKey(UserProfile, null = True, blank = True)
    
    def __unicode__(self):
        return self.email

class ProductionInfo(models.Model):
    production_apple_id = models.CharField(max_length = 128, blank = True)
    pay_money = models.CharField(max_length = 8)
    pay_money_type = models.CharField(max_length = 8)
    items_count = models.IntegerField()


class UserReceiptBase(models.Model):
    user = models.ForeignKey(User)
    buy_time = models.DatetimeField()
    create_time = models.DatetimeField(auto_add = True)

    pre_sms_count = models.IntegerField()
    final_sms_count = models.IntegerField()
#
class UserAppleReceipt(UserReceiptBase):
    apple_production = models.ForeignKey(ProductionInfo)
    device = models.CharField(max_length = 16, default = 'iPhone')
    receipt = models.TextField()
    premium = models.ForeignKey(Premium)

class UserAliReceipt(UserReceiptBase):
    receipt = models.TextField()
    payment = models.CharField(max_length = 16)
    items_count = models.IntegerField()
    premium = models.ForeignKey(Premium)

class Premium(models.Model):
    description = models.TextField()


    
def crerate_user_profile(sender = None, instance = None, created = False, **kwargs):
    if created:
        UserProfile.objects.create(user = instance)
   
signals.post_save.connect(crerate_user_profile, sender = User)
