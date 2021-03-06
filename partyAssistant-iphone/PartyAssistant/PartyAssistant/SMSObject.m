//
//  MsgObject.m
//  PartyAssistant
//
//  Created by 超 李 on 11-10-26.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "SMSObject.h"

@implementation SMSObject
@synthesize smsID,smsContent,_isSendBySelf,_isApplyTips,receiversArray,receiversArrayJson;

- (id)init
{
    self = [super init];
    if (self) {
		self.smsID = -1;
        self.smsContent = @"";
        if ([MFMessageComposeViewController canSendText]) {
            self._isSendBySelf = YES;
        } else {
            self._isSendBySelf = NO;
        }
        self._isApplyTips = YES;
        self.receiversArray = nil;
        self.receiversArrayJson = nil;
    }
    
    return self;
}

- (id)initWithDefaultContent:(BaseInfoObject *)baseinfo
{
    self = [super init];
    if (self) {
		self.smsID = -1;
        self.smsContent = @"";
        if ([MFMessageComposeViewController canSendText]) {
            self._isSendBySelf = YES;
        } else {
            self._isSendBySelf = NO;
        }
        self._isApplyTips = YES;
        self.receiversArray = nil;
    }
    if ([self.smsContent isEqualToString:@""]) {
        if (baseinfo == nil) {
            BaseInfoService *s = [BaseInfoService sharedBaseInfoService];
            baseinfo = [s getBaseInfo];
        }
        
    }
    
    return self;
}

- (void) encodeWithCoder: (NSCoder *) encoder {
    self.receiversArrayJson = [self setupReceiversArrayData];
    [encoder encodeObject: [NSNumber numberWithInteger: self.smsID] forKey:@"smsID"];
	if (smsContent) {
        [encoder encodeObject: self.smsContent forKey:@"smsContent"];
    } else {
        [encoder encodeObject:@"" forKey:@"smsContent"];
    }
    
	[encoder encodeObject: [NSNumber numberWithBool:self._isSendBySelf] forKey:@"_isSendBySelf"];
	[encoder encodeObject: [NSNumber numberWithBool:self._isApplyTips] forKey:@"_isApplyTips"];
    if (receiversArray) {
        [encoder encodeObject: self.receiversArray forKey:@"receiversArray"];
    } else {
        [encoder encodeObject:[NSArray array] forKey:@"receiversArray"];
    }
    [encoder encodeObject: self.receiversArrayJson  forKey:@"receiversArrayJson"];
}

- (id) initWithCoder: (NSCoder *) decoder {
    self.smsID = [[decoder decodeObjectForKey:@"smsID"] integerValue];
	self.smsContent = [decoder decodeObjectForKey:@"smsContent"];
	self._isSendBySelf = [[decoder decodeObjectForKey:@"_isSendBySelf"] boolValue];
	self._isApplyTips = [[decoder decodeObjectForKey:@"_isApplyTips"] boolValue];
    self.receiversArray = [decoder decodeObjectForKey:@"receiversArray"];
    self.receiversArrayJson = [decoder decodeObjectForKey:@"receiversArrayJson"];
	
	return self;
}

- (void)clearObject{
	self.smsID = -1;
    self.smsContent = @"";
    if ([MFMessageComposeViewController canSendText]) {
        self._isSendBySelf = YES;
    } else {
        self._isSendBySelf = NO;
    }
    self._isApplyTips = YES;
    self.receiversArray = nil;
    self.receiversArrayJson = nil;
}

- (NSString *)setupReceiversArrayData
{
    NSMutableArray *nArray = [[NSMutableArray alloc] initWithCapacity:[self.receiversArray count]];
    for (int i=0; i<[receiversArray count]; i++) {
        ClientObject *client = [self.receiversArray objectAtIndex:i];
        NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:client.cID],@"cId",client.cName,@"cName",client.cVal,@"cValue", nil];
        [nArray addObject:dic];
    }
    return [nArray JSONRepresentation];
}
@end
