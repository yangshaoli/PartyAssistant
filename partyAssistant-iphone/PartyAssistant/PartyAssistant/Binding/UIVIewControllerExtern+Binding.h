//
//  UIVIewControllerExtern+Binding.h
//  PartyAssistant
//
//  Created by Wang Jun on 1/12/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserInfoBindingStatusService.h"
@interface UIViewController (Binding)

- (void)saveProfileDataFromResult :(NSDictionary *)result;

- (BOOL)validateEmailCheck : (NSString *)email;

- (BOOL)validatePhoneCheck : (NSString *)phone;

- (BindingStatus)translateToLocalStatusFromString:(NSString *)statusString;

@end
