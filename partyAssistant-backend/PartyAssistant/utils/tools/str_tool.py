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
    step = random.randrange(NEXT_KEY_STEP_RANGE[0], NEXT_KEY_STEP_RANGE[1])
    step2 = step / choices_len
    step3 = step % choices_len
    
    index_list[3] = index_list[3] + step3
    index_list[2] = index_list[2] + step2
        
    for i in [3, 2, 1, 0]:
        if index_list[i] > choices_len:
            carry = index_list[i] / choices_len
            index_list[i] = index_list[i] % choices_len
            if i != 0:
                index_list[i - 1] = index_list[i - 1] + carry
            else:
                index_list[i - 1] = (index_list[i - 1] + carry) % choices_len
    
    new_key = [KEY_CHOICES[i] for i in index_list]

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
