'''
Created on 2011-11-21

@author: liwenjian
'''

def next_key(key):
    new_key = key
    
    choice = ['abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ']
    length = len(key)
    for i in range(length, 0, -1):
        c = new_key[i - 1]
        index = choice.index(c)
        index = index + 1
        if index == length:
            index = 0
            new_key[i - 1] = choice[index]
        else:
            new_key[i - 1] = choice[index]
            break

    return new_key
