//
//  EmailObject.h
//  PartyAssistant
//
//  Created by 超 李 on 11-11-16.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseInfoObject.h"
#import "BaseInfoService.h"
#import "ClientObject.h"
#import "JSON.h"

@interface EmailObject : NSObject
{
    NSInteger emailID;
    NSString *emailContent;
    NSString *emailSubject;
    BOOL _isSendBySelf;
    BOOL _isApplyTips;
    NSArray *receiversArray;
    NSString *receiversArrayJson;
}

@property(nonatomic,assign)NSInteger emailID;
@property(nonatomic,retain)NSString *emailContent;
@property(nonatomic,retain)NSString *emailSubject;
@property(nonatomic,assign)BOOL _isSendBySelf;
@property(nonatomic,assign)BOOL _isApplyTips;
@property(nonatomic,retain)NSArray *receiversArray;
@property(nonatomic,retain)NSString *receiversArrayJson;

- (void)clearObject;
- (NSString *)setupReceiversArrayData;

@end
