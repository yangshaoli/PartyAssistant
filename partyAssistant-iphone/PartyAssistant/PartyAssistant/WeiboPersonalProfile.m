//
//  WeiboPersonalProfile.m
//  PartyAssistant
//
//  Created by 超 李 on 11-11-24.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "WeiboPersonalProfile.h"

@implementation WeiboPersonalProfile
@synthesize nickname;

- (id)init
{
    self = [super init];
    if (self) {
        self.nickname = @"";
    }
    
    return self;
}

- (void) encodeWithCoder: (NSCoder *) encoder {
    [encoder encodeObject: self.nickname forKey:@"nickname"];
}

- (id) initWithCoder: (NSCoder *) decoder {
    self.nickname = [decoder decodeObjectForKey:@"nickname"];
    return self;
}

- (void)clearObject{
	self.nickname = @"";
}

@end
