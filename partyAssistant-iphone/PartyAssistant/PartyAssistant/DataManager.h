//
//  DataManager.h
//  PartyTest
//
//  Created by Wang Jun on 11/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DeviceTokenService.h"

typedef enum {
    NetworkConnectionInvalidate,
    NetWorkConnectionCheckPass,
    NetWorkConnectionCheckDeny
}NetworkConnectionStatus;


@interface DataManager : NSObject

+ (DataManager *)sharedDataManager;
- (NetworkConnectionStatus)validateCheckWithUsrName:(NSString *)name pwd:(NSString *)pwd;
- (NetworkConnectionStatus)registerUserWithUsrInfo:(NSDictionary *)usrInfo;
- (NetworkConnectionStatus)setNickName:(NSString *)nickName;
- (NetworkConnectionStatus)setNickNameForUserWithUID:(NSInteger)uid 
                                     withNewNickName:(NSString *)nickName;
- (BOOL)checkIfUserNameSaved;

@end
