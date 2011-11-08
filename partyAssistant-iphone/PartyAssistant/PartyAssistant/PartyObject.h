//
//  PartyObject.h
//  PartyAssistant
//
//  Created by 超 李 on 11-10-26.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseInfoObject.h"
#import "SMSObject.h"

@interface PartyObject : NSObject{
    BaseInfoObject *baseinfoObject;
    SMSObject *smsObject;
    UserObject *userObject;
    NSInteger pID;
}

@property(nonatomic,retain)BaseInfoObject *baseinfoObject;
@property(nonatomic,retain)SMSObject *smsObject;
@property(nonatomic,retain)UserObject *userObject;
@property(nonatomic,assign)NSInteger pID;

@end
