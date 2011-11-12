//
//  URLSettings.h
//  PartyAssistant
//
//  Created by 超 李 on 11-11-4.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#define DOMAIN_NAME @"http://192.168.3.151:8000"

#define CREATE_PARTY [NSString stringWithFormat:@"%@/a/parties/createparty/",DOMAIN_NAME]
#define EDIT_PARTY [NSString stringWithFormat:@"%@/a/parties/editparty/",DOMAIN_NAME]
#define GET_PARTY_LIST [NSString stringWithFormat:@"%@/a/parties/partylist/",DOMAIN_NAME]
#define GET_MSG_IN_COPY_PARTY [NSString stringWithFormat:@"%@/a/parties/get_party_msg/",DOMAIN_NAME]
#define GET_PARTY_CLIENT_MAIN_COUNT [NSString stringWithFormat:@"%@/a/parties/get_party_client_main_count/",DOMAIN_NAME]
#define GET_PARTY_CLIENT_SEPERATED_LIST [NSString stringWithFormat:@"%@/a/parties/get_party_client_seperated_list/",DOMAIN_NAME]
#define CLIENT_STATUS_OPERATOR [NSString stringWithFormat:@"%@/a/parties/change_client_status/",DOMAIN_NAME]
#define RESEND_MSG_TO_CLIENT [NSString stringWithFormat:@"%@/a/parties/resendmsg/",DOMAIN_NAME]
#define CLIENT_APPLY_URL [NSString stringWithFormat:@"%@/clients/public_enroll/",DOMAIN_NAME]