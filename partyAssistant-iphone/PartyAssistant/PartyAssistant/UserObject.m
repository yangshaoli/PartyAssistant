//
//  UserObject.m
//  PartyAssistant
//
//  Created by 超 李 on 11-11-4.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "UserObject.h"
#import "ASIHTTPRequest.h"
#import "URLSettings.h"
#import "SBJsonParser.h"

@implementation UserObject
@synthesize uID,phoneNum,userName,nickName,emailInfo,leftSMSCount;

- (id)init
{
    self = [super init];
    if (self) {
		self.uID = -1;
        self.phoneNum = @"";
        self.userName = @"";
        self.nickName = @"";
        self.leftSMSCount = @"";
    }
    
    return self;
}

- (void) encodeWithCoder: (NSCoder *) encoder {
    [encoder encodeObject: [NSNumber numberWithInteger:self.uID] forKey:@"uID"];
	[encoder encodeObject: self.phoneNum forKey:@"phoneNum"];
    [encoder encodeObject: self.userName forKey:@"userName"];
    [encoder encodeObject: self.nickName forKey:@"nickName"];
    [encoder encodeObject: self.leftSMSCount forKey:@"leftSMSCount"];
}

- (id) initWithCoder: (NSCoder *) decoder {
    self.uID = [[decoder decodeObjectForKey:@"uID"] integerValue];
	self.phoneNum = [decoder decodeObjectForKey:@"phoneNum"];
	self.userName = [decoder decodeObjectForKey:@"userName"];
    self.nickName = [decoder decodeObjectForKey:@"nickName"];
    self.leftSMSCount = [decoder decodeObjectForKey:@"leftSMSCount"];
	return self;
}

- (void)clearObject{
	self.uID = -1;
    self.phoneNum = @"";
    self.userName = @"";
    self.nickName = @"";
    self.leftSMSCount = @"";
}

- (void)updateRemaining {
    if (self.uID == -1) {
        return;
    } else {
        NSString *requestURL = [NSString stringWithFormat:@"%@%d",ACCOUNT_REMAINING_COUNT,self.uID];
        ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:requestURL]];
        [request setDelegate:self];
        [request setDidFinishSelector:@selector(remainCountRequestDidFinish:)];
        [request setDidFailSelector:@selector(remainCountRequestDidFail:)];
        [request startSynchronous];
    }
} 

- (void)remainCountRequestDidFinish:(ASIHTTPRequest *)request {
    NSString *response = [request responseString];
    SBJsonParser *parser = [[SBJsonParser alloc] init];
	NSDictionary *result = [parser objectWithString:response];
    if ([request responseStatusCode] == 200) {
        NSNumber *remainCount = [[result objectForKey:@"datasource"] objectForKey:@"remaining"];
        self.leftSMSCount = [remainCount stringValue];
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"RefreshSMSLeftCount" object:nil]];
    }
}

- (void)remainCountRequestDidFail:(ASIHTTPRequest *)request {
    NSError *error = [request error];
}
@end
