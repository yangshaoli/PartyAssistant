//
//  WeiboSettings.h
//  PartyAssistant
//
//  Created by 超 李 on 11-11-25.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//
#import "URLSettings.h"

#define WEIBOPRIVATEAPPKEY @"999433557"
#define WEIBOPRIVATEAPPSECRETE @"8ebb477102459b3387da43686b21c963"

#define WEIBO_DEFAULT_URL [NSString stringWithFormat:@"%@/parties/party_id/enroll/", DOMAIN_NAME]
#define WEIBO_DEFAULT_CONTENT [NSString stringWithFormat:@"我使用@我们爱热闹 发布了一个活动！大家快来报名：%@",WEIBO_DEFAULT_URL]

