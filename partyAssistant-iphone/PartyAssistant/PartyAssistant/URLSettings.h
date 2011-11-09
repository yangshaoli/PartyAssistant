//
//  URLSettings.h
//  PartyAssistant
//
//  Created by 超 李 on 11-11-4.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#define DOMAIN_NAME @"http://localhost:8000"

#define CREATE_PARTY [NSString stringWithFormat:@"%@/a/parties/createparty/",DOMAIN_NAME]
#define GET_PARTY_LIST [NSString stringWithFormat:@"%@/party/list/",DOMAIN_NAME]
#define GET_MSG_IN_COPY_PARTY [NSString stringWithFormat:@"%@/party/copy/msg/get/",DOMAIN_NAME]
