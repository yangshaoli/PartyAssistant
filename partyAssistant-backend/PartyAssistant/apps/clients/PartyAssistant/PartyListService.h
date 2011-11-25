//
//  PartyListService.h
//  PartyAssistant
//
//  Created by 超 李 on 11-11-6.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseInfoObject.h"
#import "SynthesizeSingleton.h"

#define PARTYLISTFILE @"PartyListFile"
#define PARTYLISTKEY @"PartyListKey"

@interface PartyListService : NSObject{
    NSMutableArray *partyList;
}

@property(nonatomic, retain)NSMutableArray *partyList;

+ (PartyListService *)sharedPartyListService;
- (NSArray *)getPartyList;
- (void)savePartyList;
- (NSArray *)addPartyList:(BaseInfoObject *)baseinfo;
- (void)clearPartyList;

@end
