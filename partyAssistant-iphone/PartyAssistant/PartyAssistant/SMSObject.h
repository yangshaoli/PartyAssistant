//
//  MsgObject.h
//  PartyAssistant
//
//  Created by 超 李 on 11-10-26.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SMSObject : NSObject
{
    NSNumber *smsID;
    NSString *smsContent;
    BOOL _isSendBySelf;
    BOOL _isApplyTips;
    NSArray *receiversArray;
}

@property(nonatomic,retain)NSNumber *smsID;
@property(nonatomic,retain)NSString *smsContent;
@property(nonatomic,assign)BOOL _isSendBySelf;
@property(nonatomic,assign)BOOL _isApplyTips;
@property(nonatomic,retain)NSArray *receiversArray;

- (void)clearObject;

@end
