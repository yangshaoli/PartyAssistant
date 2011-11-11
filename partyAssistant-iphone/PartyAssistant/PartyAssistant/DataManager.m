//
//  DataManager.m
//  PartyTest
//
//  Created by Wang Jun on 11/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DataManager.h"

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

- (NetworkConnectionStatus)validateCheckWithUsrName:(NSString *)name pwd:(NSString *)pwd {
    //1.check network status
    sleep(2);
    return NetWorkConnectionCheckPass;
    if (YES) {
        return NetworkConnectionInvalidate;
    }
    //2.post name and pwd
    //3.get result
    BOOL result = YES;
    if (result) {
        // add method to save user data, like uid and sth else.
        //[self saveUsrData:(NSDic *)jsonValue]
        return NetWorkConnectionCheckPass;
    } else {
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
    //1.check network status
    sleep(2);
    return NetWorkConnectionCheckPass;
    if (YES) {
        return NetworkConnectionInvalidate;
    }
    //2.post usr info
    //3.get result
    BOOL result = YES;
    if (result) {
        // add method to save user data, like uid and sth else.
        //[self saveUsrData:(NSDic *)jsonValue]
        return NetWorkConnectionCheckPass;
    } else {
        return NetWorkConnectionCheckDeny;
    }
}
@end
