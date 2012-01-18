//
//  WeiboLoginViewController.h
//  PartyAssistant
//
//  Created by 超 李 on 11-11-25.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WeiBo.h"
#import "WeiboSettings.h"
#import "WeiboRetweetView.h"
#import "WeiboLoginWebView.h"
#import "WeiboService.h"
#import "PostWeiboViewController.h"
#import "BaseInfoObject.h"
#import "PartyModel.h"
#ifndef IBOutlet
#define IBOutlet
#endif

@protocol WeiboLoginViewControllerDelegate <NSObject>
@optional
-(void)WeiboDidLoginSuccess;

@end

@interface WeiboLoginViewController : UIViewController<UIWebViewDelegate,WBSessionDelegate,WBSendViewDelegate,WBRequestDelegate,UIAlertViewDelegate>
{
    WeiBo *weibo;
    id childView;
    BOOL isOnlyLogin;
    BaseInfoObject *baseinfo;
    PartyModel *partyObj;
    id<WeiboLoginViewControllerDelegate> delegate;
}

@property(nonatomic,retain)id<WeiboLoginViewControllerDelegate> delegate;
@property(nonatomic,retain)WeiBo *weibo;
@property(nonatomic,retain)id childView;
@property(nonatomic,assign)BOOL isOnlyLogin;
@property(nonatomic,retain)BaseInfoObject *baseinfo;
@property(nonatomic,retain)PartyModel *partyObj;

- (IBAction)cancelBtnAction:(id)sender;
- (void)WeiboLogin;
@end
