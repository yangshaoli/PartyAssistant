//
//  PartyListService.h
//  PartyAssistant
//
// 
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PartyModel.h"
#import "SynthesizeSingleton.h"

#define PARTYLISTFILE @"PartyListFile"
#define PARTYLISTKEY @"PartyListKeyNew"

@interface PartyListService : NSObject{
    NSMutableArray *partyList;
}

@property(nonatomic, retain)NSMutableArray *partyList;

+ (PartyListService *)sharedPartyListService;
- (NSMutableArray *)getPartyList;
- (void)savePartyList;
- (NSMutableArray *)addPartyList:(PartyModel *)partyObj;
- (void)clearPartyList;
- (NSString *)filePathString;
@end
