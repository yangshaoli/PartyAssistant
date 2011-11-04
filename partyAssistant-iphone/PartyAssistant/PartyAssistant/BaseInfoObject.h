//
//  BaseInfoObject.h
//  PartyAssistant
//
//  Created by 超 李 on 11-10-26.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BaseInfoObject : NSObject{
    NSString *starttimeStr;
    NSDate *starttimeDate;
    NSString *location;
    NSString *description;
    NSNumber *peopleMaximum;
    NSNumber *userId;
    NSNumber *partyId;
}

@property(nonatomic, retain)NSString *starttimeStr;
@property(nonatomic, retain)NSDate *starttimeDate;
@property(nonatomic, retain)NSString *location;
@property(nonatomic, retain)NSString *description;
@property(nonatomic, retain)NSNumber *peopleMaximum;
@property(nonatomic, retain)NSNumber *userId;
@property(nonatomic, retain)NSNumber *partyId;


- (void)clearObject;
- (void)formatDateToString;
@end
