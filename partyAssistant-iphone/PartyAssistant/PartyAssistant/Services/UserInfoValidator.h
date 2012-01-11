//
//  UserInfoValidator.h
//  PartyAssistant
//
//  Created by Yang Shaoli on 12-1-11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    ValidatorResultPass=0,
    ValidatorResultIsNull,
    ValidatorResultIllegalLength,
    ValidatorResulIllegalChar,
    ValidatorResultNotStartWithLetter,
} ValidatorResultCode;

@interface UserInfoValidator : NSObject

+ (UserInfoValidator *)sharedUserInfoValidator;

- (ValidatorResultCode)validateUsername:(NSString *)aName;
- (ValidatorResultCode)validatePassword:(NSString *)aPassword;

- (NSString *)getUsernameErrorMessageByCode:(ValidatorResultCode)code;
- (NSString *)getPasswordErrorMessageByCode:(ValidatorResultCode)code;

@end
