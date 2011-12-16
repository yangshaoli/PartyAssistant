'''
Created on 2011-11-21

@author: liwenjian
'''

def next_key(key):
    new_key = list(key)
    
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
