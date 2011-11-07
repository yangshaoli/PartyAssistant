#encoding=utf-8

import hashlib

def md5_encryption(src):
    m = hashlib.md5()
    m.update(src)
    dest = m.hexdigest()
    return dest
