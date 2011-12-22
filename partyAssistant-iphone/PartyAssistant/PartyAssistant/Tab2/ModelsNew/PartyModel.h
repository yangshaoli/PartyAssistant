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
    NSInteger partyId;
    NSDictionary *peopleCountDict;
    
}
@property(nonatomic, retain)NSDictionary *peopleCountDict;
@property (nonatomic,retain)UserObject *userObject;
@property (nonatomic,retain)NSMutableArray  *clientsArray;
@property (nonatomic,retain)NSString *contentString;
@property (nonatomic,assign)BOOL isSendByServer;
@property (nonatomic,assign)NSInteger partyId;
@end
