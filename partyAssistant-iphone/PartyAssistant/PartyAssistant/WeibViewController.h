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

@interface WeibViewController : UIViewController
{
    WeiBo *weibo;
    id childView;
}

@property(nonatomic,retain)WeiBo *weibo;
@property(nonatomic,retain)id childView;

- (void)cancelBtnAction;
- (void)sendBtnAction;
@end
