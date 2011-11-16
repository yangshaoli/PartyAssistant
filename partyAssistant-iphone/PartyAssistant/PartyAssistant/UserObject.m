//
//  UserObject.m
//  PartyAssistant
//
//  Created by 超 李 on 11-11-4.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "UserObject.h"

@implementation UserObject
@synthesize uID,phoneNum,userName;

- (id)init
{
    self = [super init];
    if (self) {
		self.uID = 0;
        self.phoneNum = @"";
        self.userName = @"";
    }
    
    return self;
}

- (void) encodeWithCoder: (NSCoder *) encoder {
    [encoder encodeObject: [NSNumber numberWithInteger:self.uID] forKey:@"uID"];
	[encoder encodeObject: self.phoneNum forKey:@"phoneNum"];
    [encoder encodeObject: self.userName forKey:@"userName"];
}

- (id) initWithCoder: (NSCoder *) decoder {
    self.uID = [[decoder decodeObjectForKey:@"uID"] integerValue];
	self.phoneNum = [decoder decodeObjectForKey:@"phoneNum"];
	self.userName = [decoder decodeObjectForKey:@"userName"];
	return self;
}

- (void)clearObject{
	self.uID = 0;
    self.phoneNum = @"";
    self.userName = @"";
}
@end
