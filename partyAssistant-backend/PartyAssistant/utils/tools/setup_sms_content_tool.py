

def setup_sms_content_from_party(party, parties_clients):
    description = party.description
    start_date = party.start_date
    start_time = party.start_time
    address = party.address
    
    if parties_clients:
        link = ''
    else:
        link = transfer_to_shortlink(DOMAIN_NAME + reverse('enroll', args = [party.id]) + '?key=%s' % parties_clients.key)
    
    tail = u'时间：%s 地点：%s 在%s报名【爱热闹】' % (time_str, location, link)
