from apps.messages.models import EmailMessage, SMSMessage, BaseMessage
from django.contrib import admin

admin.site.register(EmailMessage)
admin.site.register(SMSMessage)
admin.site.register(BaseMessage)
