#!/usr/bin/env python
import string
from settings import PROJECT_ROOT

def name_to_pinyin(str):
    name_pinyin_string = ''
    name_pinyin_list = []
    try:
        file = open('%(PROJECT_ROOT)s/media/pinyin_tmp/pinyin.txt' % globals(), 'r+')
    except:
        pass
    finally:
        bytes = file.read()
        lines = bytes.split('\n')
        for c in str.decode('utf-8'):
            if c == u' ':
                continue
            if c == u'-':
                continue
            if c in string.letters:
                continue
            if c in string.digits:
                continue
            result_list = find_its_pinyin(c, lines)
            if result_list:
                if name_pinyin_list == []:
                    name_pinyin_list = result_list
                else:
                    name_pinyin_list = map(''.join, [[x, y]for x in name_pinyin_list for y in result_list])
        file.close()
        name_pinyin_string = ','.join(name_pinyin_list)
        if len(name_pinyin_string) > 256:
            name_pinyin_string = name_pinyin_string[0:256]
        return name_pinyin_string
        
def find_its_pinyin(x, lines):
    result_list = []
    for line in lines:
        if line.find(x) != -1:
            res = line.split(":")[0]
            result = res.strip()[0:len(res) - 2]
            if result not in result_list:
                result_list.append(result)
    return result_list
    
    
def name_to_acronym(str):
    name_acronym_string = ''
    name_acronym_list = []
    first_name_acronym_string = ''
    try:
        file = open('%(PROJECT_ROOT)s/media/pinyin_tmp/pinyin.txt' % globals(), 'r+')
    except:
        pass
    finally:
        bytes = file.read()
        lines = bytes.split('\n')
        for c in str.decode('utf-8'):
            if c == u' ':
                continue
            if c == u'-':
                continue
            if c in string.letters:
                continue
            if c in string.digits:
                continue
            result_list = find_its_acronym(c, lines)
            if result_list:
                if name_acronym_list == []:
                    name_acronym_list = result_list
                else:
                    name_acronym_list = map(''.join, [[x, y]for x in name_acronym_list for y in result_list])
        for item in name_acronym_list:
            if first_name_acronym_string == '':
                first_name_acronym_string = item[0]
            else:
                first_name_acronym_string = first_name_acronym_string + ',' + item[0]
        file.close()
        name_acronym_string = first_name_acronym_string + ',' + ','.join(name_acronym_list)
        if len(name_acronym_string) > 64:
            name_acronym_string = name_acronym_string[0:64]
        return name_acronym_string
    
def find_its_acronym(x, lines):
    result_list = []
    for line in lines:
        if line.find(x) != -1:
            res = line.split(":")[0]
            result = res[0]
            if result not in result_list:
                result_list.append(result)
    return result_list
