//
//  UserInfoBindingStatusService.m
//  PartyAssistant
//
//  Created by Wang Jun on 1/11/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "UserInfoBindingStatusService.h"

@interface BindingStatusObject ()

- (NSString *)translateStatusCodeToString : (BindingStatus)status;

@end

@implementation BindingStatusObject
@synthesize nicknameBindingStatus;
@synthesize telBindingStatus;
@synthesize mailBindingStatus;
@synthesize bindingNickname;
@synthesize bindingTel;
@synthesize bindingMail;

- (id)init
{
    self = [super init];
    if (self) {
        self.nicknameBindingStatus = StatusNotBind;
        self.telBindingStatus = StatusNotBind;
        self.mailBindingStatus = StatusNotBind;
        self.bindingNickname = @"";
        self.bindingTel = @"";
        self.bindingMail = @"";
    }
    
    return self;
}

- (void) encodeWithCoder: (NSCoder *) encoder {
    [encoder encodeObject: [NSNumber numberWithInteger:self.nicknameBindingStatus] forKey:@"nicknameBindingStatus"];
	[encoder encodeObject: [NSNumber numberWithInteger:self.telBindingStatus] forKey:@"telBindingStatus"];
    [encoder encodeObject: [NSNumber numberWithInteger:self.mailBindingStatus] forKey:@"mailBindingStatus"];
    [encoder encodeObject: self.bindingNickname forKey:@"bindingNickname"];
    [encoder encodeObject: self.bindingTel forKey:@"bindingTel"];
    [encoder encodeObject: self.bindingMail forKey:@"bindingMail"];
}

- (id) initWithCoder: (NSCoder *) decoder {
    self.nicknameBindingStatus = [[decoder decodeObjectForKey:@"nicknameBindingStatus"] integerValue];
	self.telBindingStatus = [[decoder decodeObjectForKey:@"telBindingStatus"] intValue];
	self.mailBindingStatus = [[decoder decodeObjectForKey:@"mailBindingStatus"] intValue];
    self.bindingNickname = [decoder decodeObjectForKey:@"bindingNickname"];
    self.bindingTel = [decoder decodeObjectForKey:@"bindingTel"];
    self.bindingMail = [decoder decodeObjectForKey:@"bindingMail"];
	return self;
}

- (void)clearObject{
    self.nicknameBindingStatus = StatusNotBind;
    self.telBindingStatus = StatusNotBind;
    self.mailBindingStatus = StatusNotBind;
    self.bindingNickname = @"";
    self.bindingTel = @"";
    self.bindingMail = @"";
}

- (NSString *)translateStatusCodeToString : (BindingStatus)status {
    switch (status) {
        case StatusBinding :
            return @"绑定中";
        case StatusVerifyBinding :
            return @"待绑定";
        case StatusUnbinding :
            return @"解绑中";
        case StatusVerifyUnbinding :
            return @"解绑中";
        case StatusBinded :
            return @"已绑定";
        default :
            return @"未知状态";
    }
    return @"未知状态";
}

- (NSString *)nickNameStatusString {
    return [self translateStatusCodeToString:self.nicknameBindingStatus];
}

- (NSString *)telStatusString {
    return [self translateStatusCodeToString:self.telBindingStatus];
}

- (NSString *)mailStatusString {
    return [self translateStatusCodeToString:self.mailBindingStatus];
}
@end

@implementation UserInfoBindingStatusService
@synthesize bindingStatusObject;

SYNTHESIZE_SINGLETON_FOR_CLASS(UserInfoBindingStatusService)
//
//- (id)init
//{
//    self = [super init];
//    if (self) {
//        // Initialization code here.
//    }
//    
//    return self;
//}

- (BindingStatusObject *)getBindingStatusObject {
    if (bindingStatusObject) {
        return bindingStatusObject;
    }
    
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString* documentsDirectory = [paths objectAtIndex:0];
    
    NSString* fullPathToFile = [documentsDirectory stringByAppendingPathComponent:BINDINGSTATUSOBJECTFILE];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:fullPathToFile];
    if (fileExists) {
        NSData *theData = [NSData dataWithContentsOfFile:fullPathToFile];
        NSKeyedUnarchiver *decoder = [[NSKeyedUnarchiver alloc] initForReadingWithData:theData];
        self.bindingStatusObject = [decoder decodeObjectForKey:BINDINGSTATUSOBJECTKEY];
    } else {
        self.bindingStatusObject = [[BindingStatusObject alloc] init];
    }
    
    return self.bindingStatusObject;
}
- (void)saveBindingStatusObject {
    if (!self.bindingStatusObject) {
        return;
    }
    NSMutableData *theData = [NSMutableData data];
    NSKeyedArchiver *encoder = [[NSKeyedArchiver alloc] initForWritingWithMutableData:theData];
    
    [encoder encodeObject:self.bindingStatusObject forKey:BINDINGSTATUSOBJECTKEY];
    [encoder finishEncoding];
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString* documentsDirectory = [paths objectAtIndex:0];
    
    NSString* fullPathToFile = [documentsDirectory stringByAppendingPathComponent:BINDINGSTATUSOBJECTFILE];
    [theData writeToFile:fullPathToFile atomically:YES];
}

- (void)clearBindingStatusObject {
    [self.bindingStatusObject clearObject];
}

- (BindingStatus)nicknameBindingStatus {
    return [[self getBindingStatusObject] nicknameBindingStatus];
}

- (BindingStatus)telBindingStatus {
    return [[self getBindingStatusObject] telBindingStatus];
}

- (BindingStatus)mailBindingStatus {
    return [[self getBindingStatusObject] mailBindingStatus];
}

- (void)setNicknameBindingStatus : (BindingStatus)status {
    [[self getBindingStatusObject] setNicknameBindingStatus:status];
}

- (void)setTelBindingStatus : (BindingStatus)status {
    return [[self getBindingStatusObject] setTelBindingStatus:status];
}

- (void)setMailBindingStatus : (BindingStatus)status {
    return [[self getBindingStatusObject] setMailBindingStatus:status];
}

- (NSString *)nickNameStatusString {
    return [[self getBindingStatusObject] nickNameStatusString];
}

- (NSString *)telStatusString {
    return [[self getBindingStatusObject] telStatusString];
}

- (NSString *)mailStatusString {
    return [[self getBindingStatusObject] mailStatusString];
}

- (NSString *)bindingNickname {
    return [[self getBindingStatusObject] bindingNickname];
}

- (NSString *)bindingTel {
    return [[self getBindingStatusObject] bindingTel];
}

- (NSString *)bindingMail {
    return [[self getBindingStatusObject] bindingMail];
}
@end
