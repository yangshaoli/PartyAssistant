//
//  DataManager.m
//  PartyTest
//
//  Created by Wang Jun on 11/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ASIFormDataRequest.h"
#import "DataManager.h"
#import "NSString+SBJSON.h"
#import "Reachability.h"
#import "URLSettings.h"
#import "UserObject.h"
#import "UserObjectService.h"
#import "HTTPRequestErrorMSG.h"

@interface DataManager ()

- (void)saveUsrData:(NSDictionary *)jsonValue;
- (void)saveUsrUID:(NSString *)UID;
- (void)saveUsrName:(NSString *)name;
- (NSInteger)getCurrentUserID;

@end

@implementation DataManager

static DataManager *sharedDataManager = nil;

+ (DataManager *)sharedDataManager {
    @synchronized (self) {
        if (!sharedDataManager) {
            sharedDataManager = [[DataManager alloc] init];
        }
    }
    return sharedDataManager;
}

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}
- (void)showAlertRequestFailed: (NSString *) theMessage{
	UIAlertView *av=[[UIAlertView alloc] initWithTitle:@"Hold on!" message:theMessage delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK",nil];
    [av show];
}
- (NetworkConnectionStatus)validateCheckWithUsrName:(NSString *)name
                                                pwd:(NSString *)pwd {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    //1.check network status
    if([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == kNotReachable) {
        [pool release];
        return NetworkConnectionInvalidate;
    }
    //2.post name and pwd
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:ACCOUNT_LOGIN]];
    [request setPostValue:name forKey:@"username"];
    [request setPostValue:pwd forKey:@"password"];
    [request setPostValue:[DeviceTokenService getDeviceToken] forKey:@"device_token"];
    [request startSynchronous];
    
    NSError *error = [request error];

    //3.get result
    if (!error) {
        // add method to save user data, like uid and sth else.
        //[self saveUsrData:(NSDic *)jsonValue]
        NSLog(@"%@",[[request responseString] JSONValue]);
        if ([request responseStatusCode] == 200) {
            NSString *receivedString = [request responseString];
            NSDictionary *dic = [receivedString JSONValue];
            NSString *description = [dic objectForKey:@"description"];
            if ([description isEqualToString:@"ok"]) {
                dic = [NSMutableDictionary dictionaryWithDictionary:dic];
                [dic setValue:name forKey:@"username"];
                [self saveUsrData:dic];
                [pool release];
                return NetWorkConnectionCheckPass;
            } else {

            }
        }else if([request responseStatusCode] == 404){
            [self showAlertRequestFailed:REQUEST_ERROR_404];
        }else if([request responseStatusCode] == 500){
            [self showAlertRequestFailed:REQUEST_ERROR_500];
        }else if([request responseStatusCode] == 502){
            [self showAlertRequestFailed:REQUEST_ERROR_502];
        } else {
            [self showAlertRequestFailed:REQUEST_ERROR_504];
        } 
        [pool release];
        return NetWorkConnectionCheckDeny;
    } else {
        //show error info
        [pool release];
        return NetWorkConnectionCheckDeny;
    }
}

- (BOOL)networkValidate {
    //check if network connect to internet
    //use Reachibility to check
    return NO;
}

- (void)saveUserData:(NSDictionary *)jsonValue {
    //@"currentUser"
    //@"userId"
}

- (NetworkConnectionStatus)registerUserWithUsrInfo:(NSDictionary *)usrInfo {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    //1.check network status
    if([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == kNotReachable) {
        [pool release];
        return NetworkConnectionInvalidate;
    }
    //2.post usr info
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:
                                    [NSURL URLWithString:ACCOUNT_REGIST]];
    [request setPostValue:[usrInfo objectForKey:@"username"] forKey:@"username"];
    [request setPostValue:[usrInfo objectForKey:@"password"] forKey:@"password"];
    [request setPostValue:[DeviceTokenService getDeviceToken] forKey:@"device_token"];
    [request startSynchronous];
    NSError *error = [request error];
    //3.get result
    if (!error) {
        // add method to save user data, like uid and sth else.
        //[self saveUsrData:(NSDic *)jsonValue]
        if ([request responseStatusCode] == 200) {
            NSString *receivedString = [request responseString];
            NSDictionary *dic = [receivedString JSONValue];
            NSString *description = [dic objectForKey:@"description"];
            NSLog(@"%@",description);
            if ([description isEqualToString:@"ok"]) {
                [self saveUsrData:dic];
                [pool release];
                return NetWorkConnectionCheckPass;
            } else {
                
            }
        }else if([request responseStatusCode] == 404){
            [self showAlertRequestFailed:REQUEST_ERROR_404];
        }else if([request responseStatusCode] == 500){
            [self showAlertRequestFailed:REQUEST_ERROR_500];
        }else if([request responseStatusCode] == 502){
            [self showAlertRequestFailed:REQUEST_ERROR_502];
        } else {
            [self showAlertRequestFailed:REQUEST_ERROR_504];
        }  
        [pool release];
        return NetWorkConnectionCheckDeny;
    } else {
        [pool release];
        return NetWorkConnectionCheckDeny;
    }
}

- (NetworkConnectionStatus)logoutUser {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    //1.check network status
    if([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == kNotReachable) {
        [pool release];
        return NetworkConnectionInvalidate;
    }
    //2.post usr info
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:
                                   [NSURL URLWithString:ACCOUNT_LOGOUT]];
    //暂时不需要UID
//    UserObject *userObject = [[UserObjectService sharedUserObjectService] getUserObject];
    
//    [request setPostValue:[NSString stringWithFormat:@"%d", userObject.uID] forKey:@"userID"];
    [request setPostValue:[DeviceTokenService getDeviceToken] forKey:@"device_token"];
    [request startSynchronous];
    NSError *error = [request error];
    //3.get result
    if (!error) {
        // add method to save user data, like uid and sth else.
        //[self saveUsrData:(NSDic *)jsonValue]
        if ([request responseStatusCode] == 200) {
            NSString *receivedString = [request responseString];
            NSDictionary *dic = [receivedString JSONValue];
            NSString *description = [dic objectForKey:@"description"];
            if ([description isEqualToString:@"ok"]) {
                UserObjectService *userObjectService = [UserObjectService sharedUserObjectService];
                UserObject *userData = [userObjectService getUserObject];
                [userData clearObject];
                [userObjectService saveUserObject];
                [pool release];
                return NetWorkConnectionCheckPass;
            } else {
                
            }
        }else if([request responseStatusCode] == 404){
            [self showAlertRequestFailed:REQUEST_ERROR_404];
        }else if([request responseStatusCode] == 500){
            [self showAlertRequestFailed:REQUEST_ERROR_500];
        }else if([request responseStatusCode] == 502){
            [self showAlertRequestFailed:REQUEST_ERROR_502];
        } else {
            [self showAlertRequestFailed:REQUEST_ERROR_504];
        }  
        [pool release];
        return NetWorkConnectionCheckDeny;
    } else {
        [pool release];
        return NetWorkConnectionCheckDeny;
    }
}

- (BOOL)checkIfUserNameSaved {
    UserObjectService *userObjectService = [UserObjectService sharedUserObjectService];
    UserObject *userData = [userObjectService getUserObject];
    if ([userData.nickName isEqualToString:@""] || !userData.nickName) {
        return NO;
    }
    return YES;
}

- (void)saveUsrData:(NSDictionary *)jsonValue {
    NSLog(@"user :%@",jsonValue);
    UserObjectService *userObjectService = [UserObjectService sharedUserObjectService];
    UserObject *userData = [userObjectService getUserObject];
    [userData clearObject];
   
    NSDictionary *datasource = [jsonValue objectForKey:@"datasource"];
    
    NSString *name = [datasource objectForKey:@"name"];
    if (name) {
        userData.nickName = name;
    } else {
        
    }
    
    NSString *uid = [datasource objectForKey:@"uid"];
    if (uid) {
        userData.uID = [uid intValue];
    } else {
        
    }
    
    userData.userName = [jsonValue objectForKey:@"username"];
    
    [userObjectService saveUserObject];
}

- (void)saveUsrName:(NSString *)name {
    
}

- (void)saveUsrUID:(NSString *)UID {
    
}

- (NSInteger)getCurrentUserID {
    UserObjectService *userObjectService = [UserObjectService sharedUserObjectService];
    UserObject *userData = [userObjectService getUserObject];
    return userData.uID;
}

- (NetworkConnectionStatus)setNickName:(NSString *)nickName {
    NSInteger currentUserID = [self getCurrentUserID];
    return [self setNickNameForUserWithUID:currentUserID withNewNickName:nickName];
}

- (NetworkConnectionStatus)setEmailInfo:(NSString *)emailInfo {
    NSInteger currentUserID = [self getCurrentUserID];
    return [self setEmailInfoForUserWithUID:currentUserID withNewEmailInfo:emailInfo];
}

- (NetworkConnectionStatus)setPhoneNum:(NSString *)phoneNum {
    NSInteger currentUserID = [self getCurrentUserID];
    return [self setPhoneNumForUserWithUID:currentUserID withNewPhoneNum:phoneNum];
}


- (NetworkConnectionStatus)setNickNameForUserWithUID:(NSInteger)uid 
                                     withNewNickName:(NSString *)nickName{
    NSAssert(uid > 0, @"非法的输入uid值：%d", uid);
    NSAssert(nickName, @"nickname不能为空！");
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSString *userID = [NSString stringWithFormat:@"%d",uid];
    //1.check network status
    if([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == kNotReachable) {
        [pool release];
        return NetworkConnectionInvalidate;
    }
    //2.post usr info
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:
                                   [NSURL URLWithString:ACCOUNT_SET_CHANGEINFO]];
    [request setPostValue:userID forKey:@"uId"];
    [request setPostValue:nickName forKey:@"nickName"];
    [request startSynchronous];
    NSError *error = [request error];
    //3.get result
    if (!error) {
        // add method to save user data, like uid and sth else.
        //[self saveUsrData:(NSDic *)jsonValue]
        if ([request responseStatusCode] == 200) {
            NSString *receivedString = [request responseString];
            NSDictionary *dic = [receivedString JSONValue];
            NSString *description = [dic objectForKey:@"description"];
            if ([description isEqualToString:@"ok"]) {
                [self saveUsrData:dic];
                [pool release];
                return NetWorkConnectionCheckPass;
            } else {
                
            }
        }else if([request responseStatusCode] == 404){
            [self showAlertRequestFailed:REQUEST_ERROR_404];
        }else if([request responseStatusCode] == 500){
            [self showAlertRequestFailed:REQUEST_ERROR_500];
        }else if([request responseStatusCode] == 502){
            [self showAlertRequestFailed:REQUEST_ERROR_502];
        } else {
            [self showAlertRequestFailed:REQUEST_ERROR_504];
        }  
        [pool release];
        return NetWorkConnectionCheckDeny;
    } else {
        [pool release];
        return NetWorkConnectionCheckDeny;
    }
}
- (NetworkConnectionStatus)setPhoneNumForUserWithUID:(NSInteger)uid 
                                     withNewPhoneNum:(NSString *)phoneNum{
    NSAssert(uid > 0, @"非法的输入uid值：%d", uid);
    NSAssert(phoneNum, @"phoneNum不能为空！");
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSString *userID = [NSString stringWithFormat:@"%d",uid];
    //1.check network status
    if([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == kNotReachable) {
        [pool release];
        return NetworkConnectionInvalidate;
    }
    //2.post usr info
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:
                                   [NSURL URLWithString:ACCOUNT_SET_CHANGEINFO]];
    [request setPostValue:userID forKey:@"uId"];
    [request setPostValue:phoneNum forKey:@"phoneNum"];
    [request startSynchronous];
    NSError *error = [request error];
    //3.get result
    if (!error) {
        // add method to save user data, like uid and sth else.
        //[self saveUsrData:(NSDic *)jsonValue]
        if ([request responseStatusCode] == 200) {
            NSString *receivedString = [request responseString];
            NSDictionary *dic = [receivedString JSONValue];
            NSString *description = [dic objectForKey:@"description"];
            if ([description isEqualToString:@"ok"]) {
                [self saveUsrData:dic];
                [pool release];
                return NetWorkConnectionCheckPass;
            } else {
                
            }
        }else if([request responseStatusCode] == 404){
            [self showAlertRequestFailed:REQUEST_ERROR_404];
        }else if([request responseStatusCode] == 500){
            [self showAlertRequestFailed:REQUEST_ERROR_500];
        }else if([request responseStatusCode] == 502){
            [self showAlertRequestFailed:REQUEST_ERROR_502];
        } else {
            [self showAlertRequestFailed:REQUEST_ERROR_504];
        }  
        [pool release];
        return NetWorkConnectionCheckDeny;
    } else {
        [pool release];
        return NetWorkConnectionCheckDeny;
    }
}

- (NetworkConnectionStatus)setEmailInfoForUserWithUID:(NSInteger)uid 
                                     withNewEmailInfo:(NSString *)emailInfo{
    NSAssert(uid > 0, @"非法的输入uid值：%d", uid);
    NSAssert(emailInfo, @"emailInfo不能为空！");
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSString *userID = [NSString stringWithFormat:@"%d",uid];
    //1.check network status
    if([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == kNotReachable) {
        [pool release];
        return NetworkConnectionInvalidate;
    }
    //2.post usr info
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:
                                   [NSURL URLWithString:ACCOUNT_SET_CHANGEINFO]];
    [request setPostValue:userID forKey:@"uId"];
    [request setPostValue:emailInfo forKey:@"emailInfo"];
    [request startSynchronous];
    NSError *error = [request error];
    //3.get result
    if (!error) {
        // add method to save user data, like uid and sth else.
        //[self saveUsrData:(NSDic *)jsonValue]
        if ([request responseStatusCode] == 200) {
            NSString *receivedString = [request responseString];
            NSDictionary *dic = [receivedString JSONValue];
            NSString *description = [dic objectForKey:@"description"];
            if ([description isEqualToString:@"ok"]) {
                [self saveUsrData:dic];
                [pool release];
                return NetWorkConnectionCheckPass;
            } else {
                
            }
        }else if([request responseStatusCode] == 404){
            [self showAlertRequestFailed:REQUEST_ERROR_404];
        }else if([request responseStatusCode] == 500){
            [self showAlertRequestFailed:REQUEST_ERROR_500];
        }else if([request responseStatusCode] == 502){
            [self showAlertRequestFailed:REQUEST_ERROR_502];
        } else {
            [self showAlertRequestFailed:REQUEST_ERROR_504];
        }  
        [pool release];
        return NetWorkConnectionCheckDeny;
    } else {
        [pool release];
        return NetWorkConnectionCheckDeny;
    }
}


@end
