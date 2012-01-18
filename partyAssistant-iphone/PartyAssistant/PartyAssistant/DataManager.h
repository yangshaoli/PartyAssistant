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
    NetWorkConnectionCheckDeny,
    NetworkConnection
}NetworkConnectionStatus;


@interface DataManager : NSObject
{
    BOOL isRandomLoginSelf;
}
@property(nonatomic,assign)BOOL isRandomLoginSelf;
+ (DataManager *)sharedDataManager;
- (NSString *)validateCheckWithUsrName:(NSString *)name pwd:(NSString *)pwd;
- (NSString *)registerUserWithUsrInfo:(NSDictionary *)usrInfo;
- (NSString *)logoutUser;
- (NetworkConnectionStatus)setNickName:(NSString *)nickName;
- (NetworkConnectionStatus)setEmailInfo:(NSString *)emailInfo;
- (NetworkConnectionStatus)setPhoneNum:(NSString *)phoneNum;
- (NetworkConnectionStatus)setNickNameForUserWithUID:(NSInteger)uid 
                                     withNewNickName:(NSString *)nickName;
- (NetworkConnectionStatus)setPhoneNumForUserWithUID:(NSInteger)uid 
                                     withNewPhoneNum:(NSString *)phoneNum;

- (NetworkConnectionStatus)setEmailInfoForUserWithUID:(NSInteger)uid 
                                      withNewEmailInfo:(NSString *)emailInfo;
- (BOOL)checkIfUserNameSaved;

@end
