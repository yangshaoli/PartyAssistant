//
//  WeiboService.h
//  PartyAssistant
//
//  Created by 超 李 on 11-11-24.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WeiboPersonalProfile.h"
#import "WeiBo.h"
#import "SynthesizeSingleton.h"
#import "UserObject.h"
#define WEIBOPERSONALPROFILEFILE @"WeiboPersonalProfileFile"
#define WEIBOPERSONALPROFILEKEY @"UserObjectKey"

@interface WeiboService : NSObject
{
    WeiboPersonalProfile *weiboPersonalProfile;
    UserObject *userObject;
}

@property(nonatomic,retain)WeiboPersonalProfile *weiboPersonalProfile;
@property(nonatomic,retain)UserObject *userObject;

+ (WeiboService *)sharedWeiboService;
- (WeiboPersonalProfile *)getWeiboPersonalProfile;
- (void)saveNickName:(NSString *)nickName;
- (void)saveWeiboPersonalProfile;
- (void)clearWeiboPersonalProfile;

@end
