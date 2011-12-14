//
//  DeviceDetection.h
//  PartyAssistant
//
//  Created by Wang Jun on 12/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sys/utsname.h>

enum {
    MODEL_UNKNOWN,
    MODEL_IPHONE_SIMULATOR,
    MODEL_IPOD_TOUCH,
    MODEL_IPOD_TOUCH_2G,
    MODEL_IPOD_TOUCH_3G,
    MODEL_IPOD_TOUCH_4G,
    MODEL_IPHONE,
    MODEL_IPHONE_3G,
    MODEL_IPHONE_3GS,
    MODEL_IPHONE_4G,
    MODEL_IPAD
};

@interface DeviceDetection : NSObject

+ (uint) detectDevice;
+ (int) detectModel;

+ (NSString *) returnDeviceName:(BOOL)ignoreSimulator;
+ (BOOL) isIPodTouch;
+ (BOOL) isOS4;
+ (BOOL) canSendSms;
+ (NSString *) platform;

@end
