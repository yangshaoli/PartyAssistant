//
//  PartyModel.m
//  PartyAssistant
//
//  Created by user on 11-12-19.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "PartyModel.h"

@implementation PartyModel
@synthesize userObject;
@synthesize clientsArray;
@synthesize contentString;
@synthesize isSendByServer;
@synthesize partyId;
@synthesize peopleCountDict;
- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}


- (void) encodeWithCoder: (NSCoder *) encoder {
    [encoder encodeObject: self.userObject forKey:@"userObject"];
    [encoder encodeObject: self.clientsArray forKey:@"clientsArray"];
    [encoder encodeObject: self.contentString forKey:@"contentString"];
	[encoder encodeBool: self.isSendByServer forKey:@"isSendByServer"];
	[encoder encodeObject:self.partyId forKey:@"partyId"];
    [encoder encodeObject: self.peopleCountDict forKey:@"peopleCountDict"];
}

- (id) initWithCoder: (NSCoder *) decoder {
    self.userObject = [decoder decodeObjectForKey:@"userObject"];
    self.clientsArray  = [decoder decodeObjectForKey:@"clientsArray"];
	self.contentString = [decoder decodeObjectForKey:@"contentString"];
    self.isSendByServer = [decoder decodeBoolForKey:@"isSendByServer"];
    self.partyId = [decoder decodeObjectForKey:@"partyId"];
    self.peopleCountDict=[decoder decodeObjectForKey:@"peopleCountDict"];
	return self;
}


@end
