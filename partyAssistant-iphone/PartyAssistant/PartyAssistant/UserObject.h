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
    NSInteger uID;
    NSString *phoneNum;
    NSString *userName;
}

@property(nonatomic, assign)NSInteger uID;
@property(nonatomic, retain)NSString *phoneNum;
@property(nonatomic, retain)NSString *userName;

- (void)clearObject;

@end
