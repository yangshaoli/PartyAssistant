//
//  ClientObject.h
//  PartyAssistant
//
//  Created by 超 李 on 11-10-26.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ClientObject : NSObject
{
    NSInteger cID;
    NSString *cName;
    NSString *cVal;
}

@property(nonatomic, assign)NSInteger cID;
@property(nonatomic, retain)NSString *cName;
@property(nonatomic, retain)NSString *cVal;

@end
