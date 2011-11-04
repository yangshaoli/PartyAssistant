//
//  MsgObject.m
//  PartyAssistant
//
//  Created by 超 李 on 11-10-26.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "SMSObject.h"

@implementation SMSObject
@synthesize smsID,smsContent,_isSendBySelf,_isApplyTips,receiversArray;

- (id)init
{
    self = [super init];
    if (self) {
		self.smsID = [NSNumber numberWithInt:-1];
        self.smsContent = @"";
        self._isSendBySelf = YES;
        self._isApplyTips = YES;
        self.receiversArray = nil;
    }
    
    return self;
}

- (void) encodeWithCoder: (NSCoder *) encoder {
    
    [encoder encodeObject: self.smsID forKey:@"smsID"];
	[encoder encodeObject: self.smsContent forKey:@"smsContent"];
	[encoder encodeObject: [NSNumber numberWithBool:self._isSendBySelf] forKey:@"_isSendBySelf"];
	[encoder encodeObject: [NSNumber numberWithBool:self._isApplyTips] forKey:@"_isApplyTips"];
    [encoder encodeObject: self.receiversArray forKey:@"receiversArray"];
}

- (id) initWithCoder: (NSCoder *) decoder {
    self.smsID = [decoder decodeObjectForKey:@"smsID"];
	self.smsContent = [decoder decodeObjectForKey:@"smsContent"];
	self._isSendBySelf = [[decoder decodeObjectForKey:@"_isSendBySelf"] boolValue];
	self._isApplyTips = [[decoder decodeObjectForKey:@"_isApplyTips"] boolValue];
    self.receiversArray = [decoder decodeObjectForKey:@"receiversArray"];
	
	return self;
}

- (void)clearObject{
	self.smsID = [NSNumber numberWithInt:-1];
    self.smsContent = @"";
    self._isSendBySelf = YES;
    self._isApplyTips = YES;
    self.receiversArray = nil;
}

@end
