//
//  WeiboPersonalProfile.m
//  PartyAssistant
//
//  Created by 超 李 on 11-11-24.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "WeiboPersonalProfile.h"

@implementation WeiboPersonalProfile
@synthesize username,password,_isLogin;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
//        self.username = @"";
//        self.password = @"";
//        self._isLogin = NO;
        
        self.username = @"lichao0708@gmail.com";
        self.password = @"woshizhu";
        self._isLogin = NO;
    }
    
    return self;
}

- (void) encodeWithCoder: (NSCoder *) encoder {
    [encoder encodeObject: self.username forKey:@"username"];
    [encoder encodeObject: self.password forKey:@"password"];
	[encoder encodeObject: [NSNumber numberWithBool:self._isLogin] forKey:@"_isLogin"];
}

- (id) initWithCoder: (NSCoder *) decoder {
    self.username = [decoder decodeObjectForKey:@"username"];
    self.password = [decoder decodeObjectForKey:@"password"];
	self._isLogin = [[decoder decodeObjectForKey:@"_isLogin"] boolValue];
    return self;
}

- (void)clearObject{
	self.username = @"";
    self.password = nil;
    self._isLogin = NO;
}

@end
