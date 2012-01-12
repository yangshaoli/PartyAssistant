//
//  UserInfoBindingStatusService.h
//  PartyAssistant
//
//  Created by Wang Jun on 1/11/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SynthesizeSingleton.h"
#define BINDINGSTATUSOBJECTFILE @"BindingStatusObjectFile"
#define BINDINGSTATUSOBJECTKEY @"BindingStatusObjectKey"

typedef enum {
    StatusNotBind,
    StatusBinding,
    StatusVerifyBinding,
    StatusUnbinding,
    StatusVerifyUnbinding,
    StatusBinded,
    StatusUnknown
}BindingStatus;

@interface BindingStatusObject : NSObject {
    BindingStatus nicknameBindingStatus;
    BindingStatus telBindingStatus;
    BindingStatus mailBindingStatus;
    
    NSString *bindingNickname;
    NSString *bindingTel;
    NSString *bindingMail;
}

@property (nonatomic) BindingStatus nicknameBindingStatus;
@property (nonatomic) BindingStatus telBindingStatus;
@property (nonatomic) BindingStatus mailBindingStatus;

@property (nonatomic, strong) NSString *bindingNickname;
@property (nonatomic, strong) NSString *bindingTel;
@property (nonatomic, strong) NSString *bindingMail;


- (NSString *)nickNameStatusString;
- (NSString *)telStatusString;
- (NSString *)mailStatusString;
@end

@interface UserInfoBindingStatusService : NSObject {
    BindingStatusObject *bindingStatusObject;
}

@property(nonatomic,strong) BindingStatusObject *bindingStatusObject;

+ (UserInfoBindingStatusService *)sharedUserInfoBindingStatusService;
- (BindingStatusObject *)getBindingStatusObject;
- (void)saveBindingStatusObject;
- (void)clearBindingStatusObject;
//status code
- (BindingStatus)nicknameBindingStatus;
- (BindingStatus)telBindingStatus;
- (BindingStatus)mailBindingStatus;
//status to string
- (NSString *)nickNameStatusString;
- (NSString *)telStatusString;
- (NSString *)mailStatusString;
//binding data
- (NSString *)bindingNickname;
- (NSString *)bindingTel;
- (NSString *)bindingMail;

@end
