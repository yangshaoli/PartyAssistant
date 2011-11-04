//
//  UserObjectService.h
//  PartyAssistant
//
//  Created by 超 李 on 11-11-4.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserObject.h"
#import "SynthesizeSingleton.h"
#define USEROBJECTFILE @"UserObjectFile"
#define USEROBJECTKEY @"UserObjectKey"

@interface UserObjectService : NSObject
{
    UserObject *userObject;
}

@property(nonatomic,retain)UserObject *userObject;

+ (UserObjectService *)sharedUserObjectService;
- (UserObject *)getUserObject;
- (void)saveUserObject;
- (void)clearUserObject;
@end
