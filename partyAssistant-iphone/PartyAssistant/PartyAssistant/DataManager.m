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
                dic = [NSMutableDictionary dictionaryWithDictionary:dic];
                [dic setValue:name forKey:@"username"];
                [self saveUsrData:dic];
                [pool release];
                return NetWorkConnectionCheckPass;
            } else {

            }
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
                                   [NSURL URLWithString:ACCOUNT_SET_NICKNAME]];
    [request setPostValue:userID forKey:@"uid"];
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
        } 
        [pool release];
        return NetWorkConnectionCheckDeny;
    } else {
        [pool release];
        return NetWorkConnectionCheckDeny;
    }
}
@end
