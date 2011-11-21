'''
Created on 2011-11-21

@author: liwenjian
'''

def next_key(key):
    new_key = key
    
    choice = ['abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ']
    length = len(key)
    finish = False
    for i in range(length, 0, -1) and not finish:
        c = new_key[i - 1]
        index = choice.index(c)
        index = index + 1
        if index == length:
            index = 0
        else:
            finish = True
        
        new_key[i - 1] = choice[index]

    return new_key
