//
//  PostWeiboViewController.h
//  PartyAssistant
//
//  Created by 超 李 on 11-11-29.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WBSendView.h"
#import "BaseInfoObject.h"
#import "PartyModel.h"
@interface PostWeiboViewController : UIViewController<WBSendViewDelegate,UIAlertViewDelegate>
{
    WBSendView *sendV;
//    BaseInfoObject *baseinfo;
    PartyModel *partyObj;
    
}

@property(nonatomic, retain)WBSendView *sendV;
//@property(nonatomic, retain)BaseInfoObject *baseinfo;
@property(nonatomic, retain)PartyModel *partyObj;

@end
