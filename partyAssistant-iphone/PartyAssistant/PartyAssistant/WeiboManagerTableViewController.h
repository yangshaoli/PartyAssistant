//
//  WeiboManagerTableViewController.h
//  PartyAssistant
//
//  Created by 超 李 on 11-11-29.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WeiBo.h"
#import "WeiboSettings.h"
#import "WeiboService.h"
#import "WeiboPersonalProfile.h"
#import "WeiboLoginViewController.h"
#import "WeiboNavigationController.h"
#import "PartyDetailTableVC.h"
@interface WeiboManagerTableViewController : UITableViewController<WeiboLoginViewControllerDelegate>
{
    WeiBo *weibo;
}
@property(nonatomic,retain)WeiBo *weibo;

@end
