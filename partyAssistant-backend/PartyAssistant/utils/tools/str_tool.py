'''
Created on 2011-11-21

@author: liwenjian
'''
from apps.common.models import ShortLink
import random
from apps.common.views import short_link

KEY_CHOICES = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
NEXT_KEY_STEP_RANGE = (2900, 3100)

def next_key(key):
    new_key = list(key)[0:4]
    index_list = [KEY_CHOICES.index(c) for c in new_key]
    choices_len = len(KEY_CHOICES)
    
    choice = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
    length = len(choice)
    for i in range(len(new_key), 0, -1):
        c = new_key[i - 1]
        index = choice.index(c)
        index = index + 1
        if index == length:
            index = 0
            new_key[i - 1] = choice[index]
        else:
            new_key[i - 1] = choice[index]
            break

    return ''.join(new_key)

def generate_key():
    last_key = ShortLink.objects.all().order_by('-id')[0].short_link
    
    while True:
        new_key = next_key(last_key)
        
        exists = ShortLink.objects.filter(short_link=new_key).count() > 0
        if exists:
            new_key = new_key + random.choice(KEY_CHOICES)
        else:
            return new_key
        
        exists = ShortLink.objects.filter(short_link=new_key).count() > 0
        if not exists:
            return new_key
