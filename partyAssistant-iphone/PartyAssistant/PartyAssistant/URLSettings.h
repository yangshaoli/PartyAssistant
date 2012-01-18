//
//  URLSettings.h
//  PartyAssistant
//
//  Created by 超 李 on 11-11-4.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

//#define DOMAIN_NAME @"http://192.168.3.151:8000"
#define DOMAIN_NAME @"http://www.airenao.com"
//#define DOMAIN_NAME @"http://127.0.0.1"

//#define DOMAIN_NAME @"http://192.168.1.15:43401"
#define GET_USER_BADGE_NUM [NSString stringWithFormat:@"%@/a/accounts/get_badge_num/",DOMAIN_NAME]
#define CREATE_PARTY [NSString stringWithFormat:@"%@/a/parties/createparty/",DOMAIN_NAME]
#define DELETE_PARTY [NSString stringWithFormat:@"%@/a/parties/deleteparty/",DOMAIN_NAME]
#define EDIT_PARTY [NSString stringWithFormat:@"%@/a/parties/editparty/",DOMAIN_NAME]
#define GET_PARTY_LIST [NSString stringWithFormat:@"%@/a/parties/partylist/",DOMAIN_NAME]
#define GET_MSG_IN_COPY_PARTY [NSString stringWithFormat:@"%@/a/parties/get_party_msg/",DOMAIN_NAME]
#define GET_PARTY_CLIENT_MAIN_COUNT [NSString stringWithFormat:@"%@/a/parties/get_party_client_main_count/",DOMAIN_NAME]
#define GET_PARTY_CLIENT_SEPERATED_LIST [NSString stringWithFormat:@"%@/a/parties/get_party_client_seperated_list/",DOMAIN_NAME]
#define CLIENT_STATUS_OPERATOR [NSString stringWithFormat:@"%@/a/parties/change_client_status/",DOMAIN_NAME]
#define RESEND_MSG_TO_CLIENT [NSString stringWithFormat:@"%@/a/parties/resendmsg/",DOMAIN_NAME]
#define CLIENT_APPLY_URL [NSString stringWithFormat:@"%@/clients/public_enroll/",DOMAIN_NAME]
#define ACCOUNT_LOGIN [NSString stringWithFormat:@"%@/a/accounts/login/",DOMAIN_NAME]
#define ACCOUNT_LOGOUT [NSString stringWithFormat:@"%@/a/accounts/logout/",DOMAIN_NAME]
#define ACCOUNT_REGIST [NSString stringWithFormat:@"%@/a/accounts/regist/",DOMAIN_NAME]
//wxz
#define ACCOUNT_SET_NICKNAME [NSString stringWithFormat:@"%@/a/accounts/nickname/",DOMAIN_NAME]
#define ACCOUNT_SET_PHONENUM [NSString stringWithFormat:@"%@/a/accounts/phoneNum/",DOMAIN_NAME]
#define ACCOUNT_SET_EMAILINFO [NSString stringWithFormat:@"%@/a/accounts/emailInfo/",DOMAIN_NAME]
//wxz
#define ACCOUNT_SET_CHANGEINFO [NSString stringWithFormat:@"%@/a/accounts/changeInfo/",DOMAIN_NAME]
//wj
#define ACCOUNT_REMAINING_COUNT [NSString stringWithFormat:@"%@/a/accounts/get_account_remaining/?id=",DOMAIN_NAME]
#define FORGET_PASSWORD [NSString stringWithFormat:@"%@/a/accounts/forget_password/",DOMAIN_NAME]
#define CHANGE_PASSWORD [NSString stringWithFormat:@"%@/a/accounts/change_password/",DOMAIN_NAME]
#define CHANGE_PASSWORD_RANDOM_LOGIN [NSString stringWithFormat:@"%@/a/accounts/change_password_by_find_pwd/",DOMAIN_NAME]
//binding_url_group wj
//whole profile get
#define PROFILE_GET [NSString stringWithFormat:@"%@/a/accounts/get_profile/",DOMAIN_NAME]

//1.nick name
#define NICK_NAME_BIND [NSString stringWithFormat:@"%@/a/accounts/save_nickname/",DOMAIN_NAME]
//2.phone
#define PHONE_BIND [NSString stringWithFormat:@"%@/a/accounts/bind/phone/",DOMAIN_NAME]
#define PHONE_UNBIND [NSString stringWithFormat:@"%@/a/accounts/unbind/phone/",DOMAIN_NAME]
#define PHONE_VERIFY [NSString stringWithFormat:@"%@/a/accounts/verify/phone/",DOMAIN_NAME]
//3.email
#define EMAIL_BIND [NSString stringWithFormat:@"%@/a/accounts/bind/email/",DOMAIN_NAME]
#define EMAIL_UNBIND [NSString stringWithFormat:@"%@/a/accounts/unbind/email/",DOMAIN_NAME]
#define EMAIL_VERIFY [NSString stringWithFormat:@"%@/a/accounts/verify/phone/",DOMAIN_NAME]

//评分
#define  SCORE_MARK @"http://www.baidu.com"//暂时拿百度测试
//版本号更新
#define  VERSION_UPDATE @"itms://itunes.apple.com/cn/app/bubble-spelling/id476527756?mt=8"