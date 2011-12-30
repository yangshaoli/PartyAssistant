from apps.accounts.models import UserProfile, UserDeviceTokenBase, UserIPhoneToken, UserAndroidToken, ProductionInfo, Premium, UserReceiptBase, UserAppleReceipt, UserAliReceipt
from django.contrib import admin

admin.site.register(UserProfile)
admin.site.register(UserDeviceTokenBase)
admin.site.register(UserIPhoneToken)
admin.site.register(UserAndroidToken)
admin.site.register(ProductionInfo)
admin.site.register(Premium)
admin.site.register(UserReceiptBase)
admin.site.register(UserAppleReceipt)
admin.site.register(UserAliReceipt)
