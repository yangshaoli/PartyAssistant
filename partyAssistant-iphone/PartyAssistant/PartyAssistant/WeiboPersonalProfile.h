//
//  WeiboPersonalProfile.h
//  PartyAssistant
//
//  Created by 超 李 on 11-11-24.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WeiboPersonalProfile : NSObject
{
    NSString *username;
    NSString *password;
    BOOL _isLogin;
}

@property(nonatomic, retain)NSString *username;
@property(nonatomic, retain)NSString *password;
@property(nonatomic, assign)BOOL _isLogin;
@end
