//
//  EmailObject.m
//  PartyAssistant
//
//  Created by 超 李 on 11-11-16.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "EmailObject.h"

@implementation EmailObject
@synthesize emailID,emailSubject,emailContent,_isSendBySelf,_isApplyTips,receiversArray,receiversArrayJson;

- (id)init
{
    self = [super init];
    if (self) {
		self.emailID = -1;
        self.emailSubject = @"";
        self.emailContent = @"";
        self._isSendBySelf = YES;
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
		self.emailID = -1;
        self.emailSubject = @"";
        self.emailContent = @"";
        self._isSendBySelf = YES;
        self._isApplyTips = YES;
        self.receiversArray = nil;
    }
    if ([self.emailContent isEqualToString:@""]) {
        if (baseinfo == nil) {
            BaseInfoService *s = [BaseInfoService sharedBaseInfoService];
            baseinfo = [s getBaseInfo];
        }
        
    }
    
    return self;
}

- (void) encodeWithCoder: (NSCoder *) encoder {
    self.receiversArrayJson = [self setupReceiversArrayData];
    [encoder encodeObject: [NSNumber numberWithInteger: self.emailID] forKey:@"emailID"];
    [encoder encodeObject: self.emailSubject forKey:@"emailSubject"];
	[encoder encodeObject: self.emailContent forKey:@"emailContent"];
	[encoder encodeObject: [NSNumber numberWithBool:self._isSendBySelf] forKey:@"_isSendBySelf"];
	[encoder encodeObject: [NSNumber numberWithBool:self._isApplyTips] forKey:@"_isApplyTips"];
    [encoder encodeObject: self.receiversArray forKey:@"receiversArray"];
    [encoder encodeObject: self.receiversArrayJson  forKey:@"receiversArrayJson"];
}

- (id) initWithCoder: (NSCoder *) decoder {
    self.emailID = [[decoder decodeObjectForKey:@"emailID"] integerValue];
    self.emailSubject = [decoder decodeObjectForKey:@"emailSubject"];
	self.emailContent = [decoder decodeObjectForKey:@"emailContent"];
	self._isSendBySelf = [[decoder decodeObjectForKey:@"_isSendBySelf"] boolValue];
	self._isApplyTips = [[decoder decodeObjectForKey:@"_isApplyTips"] boolValue];
    self.receiversArray = [decoder decodeObjectForKey:@"receiversArray"];
    self.receiversArrayJson = [decoder decodeObjectForKey:@"receiversArrayJson"];
	
	return self;
}

- (void)clearObject{
	self.emailID = -1;
    self.emailSubject = @"";
    self.emailContent = @"";
    self._isSendBySelf = YES;
    self._isApplyTips = YES;
    self.receiversArray = nil;
    self.receiversArrayJson = nil;
}

- (NSString *)setupReceiversArrayData
{
    NSMutableArray *nArray = [[NSMutableArray alloc] initWithCapacity:[self.receiversArray count]];
    for (int i=0; i<[receiversArray count]; i++) {
        ClientObject *client = [self.receiversArray objectAtIndex:i];
        NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInteger:client.cID],@"cID",client.cName,@"cName",client.cVal,@"cValue", nil];
        [nArray addObject:dic];
    }
    return [nArray JSONRepresentation];
}
@end
