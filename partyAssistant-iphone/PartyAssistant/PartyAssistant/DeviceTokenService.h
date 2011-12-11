//
//  DeviceTokenService.h
//  PartyAssistant
//
//  Created by 超 李 on 11-12-8.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SynthesizeSingleton.h"
#define DEVICETOKENFILE @"DeviceTokenFile"
#define DEVICETOKENKEY @"DeviceTokenKey"

@interface DeviceTokenService : NSObject

+ (NSString *)getDeviceToken;
+ (void)saveDeviceToken:(NSString *)DeviceToken;
+ (void)clearDeviceToken;

@end
