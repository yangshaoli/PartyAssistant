#coding=utf-8
from django.db import models
from django.contrib.auth.models import User

LIMIT_CHOICES = (
               (u"管理员", u"管理员"),
               (u"临时账户", u"临时账户"),
               (u"子账户", u"子账户"),
               )
ACTION_CHOICES = (
                  (u'新建账户', u'新建账户'),
                  (u'转正账户', u'转正账户'),
                  (u'密码找回', u'密码找回'),
                  )

class Company(models.Model):
    # 全部以用户名（即Email地址）作为name
    name = models.CharField(max_length = 128)
    #最大子账户数
    limited_accounts_count = models.IntegerField()
    
    def __unicode__(self):
        return self.name

class UserProfile(models.Model):
    user = models.OneToOneField(User)
    company = models.ForeignKey(Company)
    password = models.CharField(max_length = 16, blank = True)
    #自己注册的为管理员
    limit = models.CharField(max_length = 16, choices = LIMIT_CHOICES)
    first_login = models.BooleanField(default = True)
    
    def __unicode__(self):
        return self.user.username

#用于忘记密码和激活的临时表
class TempActivateNote(models.Model):
    random_str = models.CharField(max_length = 16, blank = True)
    email = models.EmailField()
    action = models.CharField(max_length = 16, choices = ACTION_CHOICES, blank = True)
    password = models.CharField(max_length = 16, blank = True)
    #待定内容
    aim_limit = models.CharField(max_length = 16, choices = LIMIT_CHOICES)
    #这个设计有问题 应该用ForeignKey
    userprofile = models.ForeignKey(UserProfile, null = True, blank = True)
    
    def __unicode__(self):
        return self.email
