//
//  SettingsListTableViewController.h
//  PartyAssistant
//
//  Created by 超 李 on 11-11-22.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WeiboService.h"
#import "WeiboManagerTableViewController.h"
#import "MBProgressHUD.h"

@interface SettingsListTableViewController : UITableViewController<UIAlertViewDelegate, MBProgressHUDDelegate> {
    MBProgressHUD *_HUD;
}

@end
