'''
Created on 2010-1-6
test
@author: liwenjian
'''

import datetime

def time_combine(date, time):
    time_str = '%s %s' % (date.strftime('%Y-%m-%d'), time)
    return datetime.datetime.strptime(time_str, '%Y-%m-%d %H:%M:%S')

