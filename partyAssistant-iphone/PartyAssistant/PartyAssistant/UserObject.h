//
//  UserObject.h
//  PartyAssistant
//
//  Created by 超 李 on 11-11-4.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserObject : NSObject
{
    NSNumber *uID;
    NSString *phoneNum;
}

@property(nonatomic, retain)NSNumber *uID;
@property(nonatomic, retain)NSString *phoneNum;

@end
