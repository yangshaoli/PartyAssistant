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
    
    BindingStatusObject *userObject = [[UserInfoBindingStatusService sharedUserInfoBindingStatusService] getBindingStatusObject];
    
    NSString *nickName = [bindInfos objectForKey:@"nickname"];
    NSString *email = [bindInfos objectForKey:@"email"];
    NSString *tel = [bindInfos objectForKey:@"phone"];
    
    if (nickName) {
        [userObject setBindedNickname:nickName];
    }
    
    NSString *emailStatus = [bindInfos objectForKey:@"email_binding_status"];
    NSString *telStatus = [bindInfos objectForKey:@"phone_binding_status"];
    
    if (nickName && [nickName length] > 1) {
        [userObject setNicknameBindingStatus:StatusBinded];
    }
    
    if (telStatus) {
        BindingStatus telCurrentStatus = [self translateToLocalStatusFromString:telStatus];
        
        if (telCurrentStatus != StatusBinding) {
            [userObject setBindingTel:@""];
            if (tel) {
                [userObject setBindedTel:tel];
            }
        } else {
            if (tel) {
                [userObject setBindingTel:tel];
            }
        }
        
        [userObject setTelBindingStatus:telCurrentStatus];
    }
    
    if (emailStatus) {
        BindingStatus emailCurrentStatus = [self translateToLocalStatusFromString:emailStatus];
        
        if (emailCurrentStatus != StatusBinding) {
            [userObject setBindingMail:@""];
            if (email) {
                [userObject setBindedMail:email];
            }
        } else {
            if (email) {
                [userObject setBindingMail:email];
            }
        }
        
        [userObject setMailBindingStatus:emailCurrentStatus];
    }
    
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

- (void)showBindOperationFailed: (NSString *) theMessage{
	UIAlertView *av=[[UIAlertView alloc] initWithTitle:@"出错啦！" message:theMessage delegate:self cancelButtonTitle:nil otherButtonTitles:@"好的",nil];
    av.tag = 11112;
    [av show];
}
@end
