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
#import "NotificationSettings.h"

#define INVALID_NETWORK @"无法连接网络，请检查网络状态！"
#define SERVER_CONNECTION_ERROR @"与服务器连接异常！请稍后重试！"
#define SERVER_OPERATION_ERROR @"操作失败！"

@interface DataManager ()

- (void)saveUsrData:(NSDictionary *)jsonValue;
- (void)saveUsrUID:(NSString *)UID;
- (void)saveUsrName:(NSString *)name;
- (NSInteger)getCurrentUserID;

@end

@implementation DataManager
@synthesize isRandomLoginSelf;
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
	UIAlertView *av=[[UIAlertView alloc] initWithTitle:@"出错啦!" message:theMessage delegate:self cancelButtonTitle:nil otherButtonTitles:@"好的",nil];
    [av show];
}
- (void)getVersionFromRequestDic:(NSDictionary *)result{
    NSUserDefaults *versionDefault=[NSUserDefaults standardUserDefaults];
    NSUserDefaults *isUpdateVersionDefault=[NSUserDefaults standardUserDefaults];
    NSString *preVersionString=[versionDefault objectForKey:@"airenaoIphoneVersion"];
    NSString *newVersionString = [result objectForKey:@"iphone_version"];
    if(preVersionString==nil||[preVersionString isEqualToString:@""]){
        [versionDefault setObject:newVersionString forKey:@"airenaoIphoneVersion"];
        //NSLog(@"前版本为空");
        return;
    }else{
        if(newVersionString==nil&&[newVersionString isEqualToString:@""]){
            return;
        }else{
            //NSLog(@"DAYIN  ,preVersionString:%@....newVersionString:%@",preVersionString,newVersionString);
            if([newVersionString floatValue]>[preVersionString floatValue]){
                [versionDefault setObject:newVersionString forKey:@"airenaoIphoneVersion"];
                [isUpdateVersionDefault setBool:YES forKey:@"isUpdateVersion"];
            }else{
                [isUpdateVersionDefault setBool:NO forKey:@"isUpdateVersion"];
            }
        }
        
    }
    
    
    
}

- (NSString *)validateCheckWithUsrName:(NSString *)name
                                                pwd:(NSString *)pwd {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    //1.check network status
    if([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == kNotReachable) {
        [pool release];
        return INVALID_NETWORK;
        //return NetworkConnectionInvalidate;
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
            [self getVersionFromRequestDic:dic];
            NSString *description = [dic objectForKey:@"description"];
            NSString *status = [dic objectForKey:@"status"];
            NSDictionary *datasourceDic=[dic objectForKey:@"datasource"];
            BOOL isRandomLogin=[[datasourceDic objectForKey:@"_israndomlogin"] boolValue];
            if(isRandomLogin){
                self.isRandomLoginSelf=YES;
            }else{
                self.isRandomLoginSelf=NO; 
            }
            if ([status isEqualToString:@"ok"]) {
                dic = [NSMutableDictionary dictionaryWithDictionary:dic];
                [dic setValue:name forKey:@"username"];
                [self saveUsrData:dic];
                [pool release];
                return nil;
            } else {
                 //[self showAlertRequestFailed:description];
                if (description) {
                    return description;
                } else {
                    return SERVER_CONNECTION_ERROR;
                }
            }
        }else if([request responseStatusCode] == 404){
            //[self showAlertRequestFailed:REQUEST_ERROR_404];
            return REQUEST_ERROR_404;
        }else if([request responseStatusCode] == 500){
            //[self showAlertRequestFailed:REQUEST_ERROR_500];
            return REQUEST_ERROR_500;
        }else if([request responseStatusCode] == 502){
            //[self showAlertRequestFailed:REQUEST_ERROR_502];
            return REQUEST_ERROR_502;
        } else {
            //[self showAlertRequestFailed:REQUEST_ERROR_504];
            return REQUEST_ERROR_504;
        } 
        [pool release];
        //return NetWorkConnectionCheckDeny;
        return SERVER_CONNECTION_ERROR;
    } else {
        //show error info
        [pool release];
        //return NetWorkConnectionCheckDeny;
        return SERVER_CONNECTION_ERROR;
    }
    
    return SERVER_CONNECTION_ERROR;
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

- (NSString *)registerUserWithUsrInfo:(NSDictionary *)usrInfo {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    //1.check network status
    if([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == kNotReachable) {
        [pool release];
        //return NetworkConnectionInvalidate;
        return INVALID_NETWORK;
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
            [self getVersionFromRequestDic:dic];
            NSString *status = [dic objectForKey:@"status"];   
            NSLog(@"%@",description);
            if ([status isEqualToString:@"ok"]) {
                NSMutableDictionary *info = [NSMutableDictionary dictionaryWithDictionary:dic];
                [info setValue:[usrInfo objectForKey:@"username"] forKey:@"username"];
                [self saveUsrData:info];
                [pool release];
                //return NetWorkConnectionCheckPass;
                return nil;
            } else {
                if (description) {
                    return description;
                } else {
                    return SERVER_CONNECTION_ERROR;
                }
            }
        }else if([request responseStatusCode] == 404){
            //[self showAlertRequestFailed:REQUEST_ERROR_404];
            return REQUEST_ERROR_404;
        }else if([request responseStatusCode] == 500){
            //[self showAlertRequestFailed:REQUEST_ERROR_500];
            return REQUEST_ERROR_500;
        }else if([request responseStatusCode] == 502){
            //[self showAlertRequestFailed:REQUEST_ERROR_502];
            return REQUEST_ERROR_502;
        } else {
            //[self showAlertRequestFailed:REQUEST_ERROR_504];
            return REQUEST_ERROR_504;
        }  
        [pool release];
        return SERVER_CONNECTION_ERROR;
    } else {
        [pool release];
        return SERVER_CONNECTION_ERROR;
    }
}

- (void)clearPartyListData {
    NSString *partyListPath = [NSString stringWithFormat:@"%@/Documents/partylistofpre20.plist", NSHomeDirectory()];
    NSFileManager* fm = [NSFileManager defaultManager];
    NSMutableArray *getArrayFromFile;
    if(![fm fileExistsAtPath:partyListPath]) {
        getArrayFromFile = [[NSMutableArray alloc] initWithCapacity:0];
    } else {
        getArrayFromFile = [[NSMutableArray alloc] initWithContentsOfFile:partyListPath];
    }
    
    [getArrayFromFile removeAllObjects];
    
    [getArrayFromFile  writeToFile:partyListPath  atomically:YES];
}

- (NSString *)logoutUser {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    //1.check network status
    if([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == kNotReachable) {
        [pool release];
        //return NetworkConnectionInvalidate;
        return INVALID_NETWORK;
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
                [self clearPartyListData];
                [[NSNotificationCenter defaultCenter] postNotificationName:USER_LOGOUT_NOTIFICATION object:nil];
                [pool release];
                //return NetWorkConnectionCheckPass;
                return nil;
            } else {
                if (description) {
                   return description; 
                } else {
                    return SERVER_OPERATION_ERROR;
                }
            }
        }else if([request responseStatusCode] == 404){
            //[self showAlertRequestFailed:REQUEST_ERROR_404];
            return REQUEST_ERROR_404;
        }else if([request responseStatusCode] == 500){
            //[self showAlertRequestFailed:REQUEST_ERROR_500];
            return REQUEST_ERROR_500;
        }else if([request responseStatusCode] == 502){
            //[self showAlertRequestFailed:REQUEST_ERROR_502];
            return REQUEST_ERROR_502;
        } else {
            //[self showAlertRequestFailed:REQUEST_ERROR_504];
            return REQUEST_ERROR_504;
        }  
        [pool release];
        //return NetWorkConnectionCheckDeny;
        return SERVER_CONNECTION_ERROR;
    } else {
        [pool release];
        //return NetWorkConnectionCheckDeny;
        return SERVER_CONNECTION_ERROR;
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
    
    NSString *userName = [jsonValue objectForKey:@"username"];
    if (userName) {
        userData.userName = userName;
    }
    
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
