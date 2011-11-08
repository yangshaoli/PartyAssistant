//
//  PartyObject.m
//  PartyAssistant
//
//  Created by 超 李 on 11-10-26.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "PartyObject.h"

@implementation PartyObject
@synthesize baseinfoObject,smsObject,userObject,pID;

- (id)initWithBaseInfoObject:(BaseInfoObject *)baseinfo SMSObject:(SMSObject *)sms UserObject:(UserObject *)user pId:(NSInteger)pid
{
    self = [super init];
    if (self) {
        self.baseinfoObject = baseinfo;
        self.smsObject = sms;
        self.userObject = user;
        self.pID = pid;
    }
    
    return self;
}

@end
