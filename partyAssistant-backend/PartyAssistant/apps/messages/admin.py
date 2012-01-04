from apps.messages.models import BaseMessage, EmailMessage, SMSMessage, Outbox
from django.contrib import admin

admin.site.register(BaseMessage)
admin.site.register(EmailMessage)
admin.site.register(SMSMessage)
admin.site.register(Outbox)
