//
//  NicknameManageTableViewController.h
//  PartyAssistant
//
//  Created by 超 李 on 11-12-5.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserObject.h"
#import "UserObjectService.h"
#import "UITableViewControllerExtra.h"

@interface NicknameManageTableViewController : UITableViewController
{
    UITextField *nicknameTextField;
}
@property(nonatomic,retain)UITextField *nicknameTextField;
@end
