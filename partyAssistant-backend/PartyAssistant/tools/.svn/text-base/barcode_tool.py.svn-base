#encoding=utf-8

import barcode
import os

from settings import DOMAIN_NAME, PROJECT_ROOT


def make_code39_file(meeting_client):
    try:
        a = barcode.get_barcode("code39")
        if meeting_client:
            file_name = 'MC' + "%010d" % meeting_client.id
        else:
            file_name = 'MC' + "%010d" % 0
        src_name = r'%(PROJECT_ROOT)s/' % globals() + r'media/barcode_image/code39/M%d/%s' % (meeting_client.meeting.id, file_name)
        jpg_name = r'%(PROJECT_ROOT)s/' % globals() + r'media/barcode_image/code39/M%d/%s.jpg' % (meeting_client.meeting.id, file_name)
        b = a(file_name)
        c = b.save(src_name)
        os.system('rsvg -w 200 -h 80 %s %s' % (c, jpg_name))
        os.system('rm %s' % c)
    except Exception:
        return ''
    return DOMAIN_NAME + r'/media/barcode_image/code39/M%d/%s.jpg' % (meeting_client.meeting.id, file_name)
