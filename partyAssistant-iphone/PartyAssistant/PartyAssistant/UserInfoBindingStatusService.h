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
}

@property (nonatomic) BindingStatus nicknameBindingStatus;
@property (nonatomic) BindingStatus telBindingStatus;
@property (nonatomic) BindingStatus mailBindingStatus;

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
- (BindingStatus)nicknameBindingStatus;
- (BindingStatus)telBindingStatus;
- (BindingStatus)mailBindingStatus;
- (NSString *)nickNameStatusString;
- (NSString *)telStatusString;
- (NSString *)mailStatusString;
@end
