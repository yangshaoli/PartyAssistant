from apps.common.models import ShortLink

from utils.tools.str_tool import generate_key

from settings import SHORT_DOMAIN_NAME

def transfer_to_shortlink(longlink):
    while True:
        new_key = generate_key()
        if ShortLink.objects.filter(short_link = new_key).exclude(long_link = longlink).count() == 0:
            break
    shortlink = ShortLink.objects.get_or_create(long_link = longlink, defaults = {"short_link":new_key})[0]
    return "%s/%s" % (SHORT_DOMAIN_NAME, shortlink.short_link)
