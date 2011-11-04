//
//  SMSObjectService.h
//  PartyAssistant
//
//  Created by 超 李 on 11-11-3.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SMSObject.h"
#import "SynthesizeSingleton.h"
#define SMSOBJECTFILE @"SMSObjectFile"
#define SMSOBJECTKEY @"SMSObjectKey"

@interface SMSObjectService : NSObject
{
    SMSObject *smsObject;
}

@property(nonatomic,retain)SMSObject *smsObject;

+ (SMSObjectService *)sharedSMSObjectService;
- (SMSObject *)getSMSObject;
- (void)saveSMSObject;
- (void)clearSMSObject;

@end
