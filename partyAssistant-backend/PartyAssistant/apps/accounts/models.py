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

#class UserReceiptBase(models.Model):
#    user = models.ForeignKey(User)
#    receipt = models.TextField()
#    buy_time = models.DatetimeField()
#    create_time = models.DatetimeField(auto_add = True)
#    pay_money = models.CharField(max_length = 8)
#    pay_money_type = models.CharField(max_length = 8)
#    pre_sms_count = models.IntegerField()
#    added_sms_count = models.IntegerField()
#
#class UserIPhoneReceipt(UserReceiptBase):
#    device = models.CharField(max_length = 16,default = 'iPhone')
#    account_name = models.EmailField()


    
def crerate_user_profile(sender = None, instance = None, created = False, **kwargs):
    if created:
        UserProfile.objects.create(user = instance)
   
signals.post_save.connect(crerate_user_profile, sender = User)
