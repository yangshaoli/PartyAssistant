from apps.accounts import models
from apps.common.models import ShortLink
from django.db.models.signals import post_syncdb
from settings import DOMAIN_NAME

def create_first_ShortLink(sender, **kwargs):
    ShortLink.objects.create(short_link='aaaa', long_link=DOMAIN_NAME)
   
post_syncdb.connect(create_first_ShortLink, sender = models)