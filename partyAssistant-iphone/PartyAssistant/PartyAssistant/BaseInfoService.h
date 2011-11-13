//
//  BaseInfoObjectServices.h
//  PartyAssistant
//
//  Created by 超 李 on 11-10-26.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseInfoObject.h"
#import "SynthesizeSingleton.h"
#define BASEINFOOBJECTFILE @"BaseInfoObjectFile"
#define BASEINFOOBJECTKEY @"BaseInfoObject"

@interface BaseInfoService : NSObject{
    BaseInfoObject *baseinfoObject;
}


@property (nonatomic, retain) BaseInfoObject *baseinfoObject;

+ (BaseInfoService *)sharedBaseInfoService;
- (BaseInfoObject *)getBaseInfo;
- (void)saveBaseInfo;
- (void)reorganizeData;
- (void)clearBaseInfo;


@end
