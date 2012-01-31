//
//  PartyModel.h
//  PartyAssistant
//
//  Created by user on 11-12-19.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserObject.h"
@interface PartyModel : NSObject{
    UserObject *userObject;
    NSMutableArray  *clientsArray;//收件人
    NSString   *contentString;//活动内容
    BOOL isSendByServer;//是否服务器发送
    NSNumber *partyId;
    NSDictionary *peopleCountDict;
    BOOL isnewApplied;
    BOOL isnewRefused;
    NSString *shortURL;
    NSString *type;
   
}
@property(nonatomic, retain)NSDictionary *peopleCountDict;
@property (nonatomic,retain)UserObject *userObject;
@property (nonatomic,retain)NSMutableArray  *clientsArray;
@property (nonatomic,retain)NSString *contentString;
@property (nonatomic,assign)BOOL isSendByServer;
@property (nonatomic,assign)BOOL isnewApplied;
@property (nonatomic,assign)BOOL isnewRefused;
@property(nonatomic, retain)NSNumber *partyId;
@property (nonatomic,retain)NSString *shortURL;
@property (nonatomic,retain)NSString *type;

@end
