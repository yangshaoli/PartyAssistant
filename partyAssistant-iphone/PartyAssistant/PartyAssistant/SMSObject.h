//
//  MsgObject.h
//  PartyAssistant
//
//  Created by 超 李 on 11-10-26.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MessageUI/MessageUI.h>
#import "BaseInfoObject.h"
#import "BaseInfoService.h"
#import "ClientObject.h"
#import "JSON.h"

@interface SMSObject : NSObject
{
    NSInteger smsID;
    NSString *smsContent;
    BOOL _isSendBySelf;
    BOOL _isApplyTips;
    NSArray *receiversArray;
    NSString *receiversArrayJson;
}

@property(nonatomic,assign)NSInteger smsID;
@property(nonatomic,retain)NSString *smsContent;
@property(nonatomic,assign)BOOL _isSendBySelf;
@property(nonatomic,assign)BOOL _isApplyTips;
@property(nonatomic,retain)NSArray *receiversArray;
@property(nonatomic,retain)NSString *receiversArrayJson;

- (void)clearObject;
- (NSString *)setupReceiversArrayData;

@end
