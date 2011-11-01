#coding=utf-8
import re
from settings import PROJECT_ROOT

re_en = re.compile(r'\A[a-zA-Z]+')
def name_split(name):
    if re_en.match(name):
        first_name = ''
    else:
        if not  name[0].isalpha():
            first_name = ''
        else:
            first_name = name[0]
            try:
                file = open('%(PROJECT_ROOT)s/media/pinyin_tmp/pinyin.txt' % globals(), 'r+')
                bytes = file.read()
                lines = bytes.split('\n')
                for line in lines:
                    if line.find(name[0]) != -1:
                        res = line.split(":")[0]
                        first_name = res.strip()[0:len(res) - 2]
            except Exception:
                pass
    return first_name
