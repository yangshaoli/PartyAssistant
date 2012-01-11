//
//  UserInfoValidator.m
//  PartyAssistant
//
//  Created by Yang Shaoli on 12-1-11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "UserInfoValidator.h"
#import "SynthesizeSingleton.h"

#define UserNameMinLength 6
#define UserNameMaxLength 14

#define PasswordMinLength 6
#define PasswordMaxLength 16

@implementation UserInfoValidator
SYNTHESIZE_SINGLETON_FOR_CLASS(UserInfoValidator)

#pragma mark - Validate User Name Method
- (ValidatorResultCode)validateNameLength:(NSString *)aName {
    int length = [aName length];
    if (length <= 0) {
        return ValidatorResultIsNull;
    }
    
    if ((length > UserNameMaxLength) || (length < UserNameMinLength)) {
        return ValidatorResultIllegalLength;
    }
    
    return ValidatorResultPass;
}

- (ValidatorResultCode)validateNameStartWithLetter:(NSString *)aName {
    NSScanner *scanner = [NSScanner scannerWithString:aName];
    NSCharacterSet *numbers = [NSCharacterSet 
                               characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"];
    
    NSString *buffer;
    if (![scanner scanCharactersFromSet:numbers intoString:&buffer]) {
        return ValidatorResultNotStartWithLetter;
    }
            
    return ValidatorResultPass;
}

- (ValidatorResultCode)validateNameIllegallCharactors:(NSString *)aName {
    int length = [aName length];
    NSMutableString *strippedString = [NSMutableString 
                                       stringWithCapacity:length];
    
    NSScanner *scanner = [NSScanner scannerWithString:aName];
    NSCharacterSet *numbers = [NSCharacterSet 
                               characterSetWithCharactersInString:@"0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_"];
    
    while ([scanner isAtEnd] == NO) {
        NSString *buffer;
        if ([scanner scanCharactersFromSet:numbers intoString:&buffer]) {
            [strippedString appendString:buffer];
            
        } else {
            [scanner setScanLocation:([scanner scanLocation] + 1)];
        }
    }
    
    if ([strippedString length] < length) {
        return ValidatorResulIllegalChar;
    }
    
    return ValidatorResultPass;
}

- (ValidatorResultCode)validateUsername:(NSString *)aName {
    ValidatorResultCode result = [self validateNameLength:aName];
    if ( result != ValidatorResultPass) {
        return result;
    }
    
    result = [self validateNameStartWithLetter:aName];
    if ( result != ValidatorResultPass) {
        return result;
    }
    
    result = [self validateNameIllegallCharactors:aName];
    if ( result != ValidatorResultPass) {
        return result;
    }
    
    return ValidatorResultPass;
}

#pragma mark - Validate Password Method
- (ValidatorResultCode)validatePasswordLength:(NSString *)aPassword {
    int length = [aPassword length];
    if (length <= 0) {
        return ValidatorResultIsNull;
    }
    
    if ((length > PasswordMaxLength) || (length < PasswordMinLength)) {
        return ValidatorResultIllegalLength;
    }
    
    return ValidatorResultPass;
}

- (ValidatorResultCode)validatePassword:(NSString *)aPassword {
    ValidatorResultCode result = [self validatePasswordLength:aPassword];
    if ( result != ValidatorResultPass) {
        return result;
    }

    return ValidatorResultPass;
}

#pragma mark - Validate Error Message
- (NSString *)getUsernameErrorMessageByCode:(ValidatorResultCode)code {
    if (code == ValidatorResulIllegalChar) {
        return @"用户名只能输入字母、数字和下划线";
    }
    
    if (code == ValidatorResultIllegalLength) {
        return @"用户名只能输入6-14个字符";
    }
    
    if (code == ValidatorResultIsNull) {
        return @"用户名不能为空";
    }
    
    if (code == ValidatorResultNotStartWithLetter) {
        return @"用户名必须以字母开头";
    }
    
    return @"";
}

- (NSString *)getPasswordErrorMessageByCode:(ValidatorResultCode)code {
    if (code == ValidatorResultIllegalLength) {
        return @"密码长度为6-16个字符，区分大小写";
    }
    
    if (code == ValidatorResultIsNull) {
        return @"密码不能为空";
    }
    
    return @"";
}

@end
