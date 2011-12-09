//
//  UserObject.m
//  PartyAssistant
//
//  Created by 超 李 on 11-11-4.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "UserObject.h"

@implementation UserObject
@synthesize uID,phoneNum,userName,nickName,emailInfo;

- (id)init
{
    self = [super init];
    if (self) {
		self.uID = -1;
        self.phoneNum = @"";
        self.userName = @"";
        self.nickName = @"";
    }
    
    return self;
}

- (void) encodeWithCoder: (NSCoder *) encoder {
    [encoder encodeObject: [NSNumber numberWithInteger:self.uID] forKey:@"uID"];
	[encoder encodeObject: self.phoneNum forKey:@"phoneNum"];
    [encoder encodeObject: self.userName forKey:@"userName"];
    [encoder encodeObject: self.nickName forKey:@"nickName"];
}

- (id) initWithCoder: (NSCoder *) decoder {
    self.uID = [[decoder decodeObjectForKey:@"uID"] integerValue];
	self.phoneNum = [decoder decodeObjectForKey:@"phoneNum"];
	self.userName = [decoder decodeObjectForKey:@"userName"];
    self.nickName = [decoder decodeObjectForKey:@"nickName"];
	return self;
}

- (void)clearObject{
	self.uID = -1;
    self.phoneNum = @"";
    self.userName = @"";
    self.nickName = @"";
}
@end
