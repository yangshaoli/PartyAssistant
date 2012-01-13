//
//  UIVIewControllerExtern+Binding.m
//  PartyAssistant
//
//  Created by Wang Jun on 1/12/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "UIVIewControllerExtern+Binding.h"
#import "UserInfoBindingStatusService.h"

@implementation UIViewController (Binding) 

- (void)saveProfileDataFromResult :(NSDictionary *)result {
    NSDictionary *dataSource = [result objectForKey:@"datasource"];
    NSDictionary *bindInfos = [dataSource objectForKey:@"latest_status"];
    
    if (!bindInfos) {
        bindInfos = dataSource;
        if (!dataSource) {
            return;
        }
    }
    
    NSLog(@"bindInfos: %@",bindInfos);
    
    NSString *email = [bindInfos objectForKey:@"email"];
    NSString *tel = [bindInfos objectForKey:@"phone"];
    NSString *nickName = [bindInfos objectForKey:@"nickname"];
    
    BindingStatusObject *userObject = [[UserInfoBindingStatusService sharedUserInfoBindingStatusService] getBindingStatusObject];
    [userObject setBindedTel:tel];
    [userObject setBindedMail:email];
    if (nickName) {
        [userObject setBindedNickname:nickName];
    }
    
    NSString *emailStatus = [bindInfos objectForKey:@"email_binding_status"];
    NSString *telStatus = [bindInfos objectForKey:@"phone_binding_status"];
    
    if (nickName && [nickName length] > 1) {
        [userObject setNicknameBindingStatus:StatusBinded];
    }
    
    [userObject setTelBindingStatus:[self translateToLocalStatusFromString:telStatus]];
    [userObject setMailBindingStatus:[self translateToLocalStatusFromString:emailStatus]];
    
    [[UserInfoBindingStatusService sharedUserInfoBindingStatusService] saveBindingStatusObject];
}

- (BOOL)validateEmailCheck : (NSString *)email {
    return YES;
}

- (BOOL)validatePhoneCheck : (NSString *)phone {
    return YES;
}

- (BindingStatus)translateToLocalStatusFromString:(NSString *)statusString {
    if ([statusString isEqualToString:@"bind"]) {
        return StatusBinded;
    } else if ([statusString isEqualToString:@"unbind"]) {
        return StatusNotBind;
    } else if ([statusString isEqualToString:@"waitingbind"]) {
        return StatusBinding;
    } else if ([statusString isEqualToString:@""]) {
        return StatusNotBind;
    }
    return StatusUnknown;
}
@end
