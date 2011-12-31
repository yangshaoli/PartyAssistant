//
//  GetClientsCountService.h
//  PartyAssistant
//
//  Created by user on 11-12-25.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SynthesizeSingleton.h"
#import "PartyModel.h"
#import "JSON.h"
#import "ASIFormDataRequest.h"

@interface GetClientsCountService : NSObject{
    NSArray* peopleCountArray;
    PartyModel *partyObj;
    
}
@property(nonatomic, retain)NSArray* peopleCountArray;
@property(nonatomic, retain)PartyModel *partyObj;
+ (GetClientsCountService *)sharedGetClientsCountService;
- (void)loadClientCountByPartyId:(NSNumber *)partyId;
- (void)loadClientCount;
- (void)requestFinished:(ASIHTTPRequest *)request;
- (void)requestFailed:(ASIHTTPRequest *)request;
@end
