//
//  PartyUserRegisterViewController.h
//  PartyTest
//
//  Created by Wang Jun on 11/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface PartyUserRegisterViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, MBProgressHUDDelegate>{
    
    UITableView *_tableView;
    
    UITableViewCell *_phoneNumCell;
    UITableViewCell *_pwdCell;
    UITableViewCell *_pwdCheckCell;
    UITableViewCell *_emailCell;
    
    UITextField *_phoneNumTextField;
    UITextField *_pwdTextField;
    UITextField *_pwdCheckTextField;
    UITextField *_emailTextField;
    
    MBProgressHUD *_HUD;
}

@property (nonatomic, retain) IBOutlet UITableView  *tableView;

@property (nonatomic, retain) IBOutlet UITableViewCell *phoneNumCell;
@property (nonatomic, retain) IBOutlet UITableViewCell *pwdCell;
@property (nonatomic, retain) IBOutlet UITableViewCell *pwdCheckCell;
@property (nonatomic, retain) IBOutlet UITableViewCell *emailCell;

@property (nonatomic, retain) IBOutlet UITextField *phoneNumTextField;
@property (nonatomic, retain) IBOutlet UITextField *pwdTextField;
@property (nonatomic, retain) IBOutlet UITextField *pwdCheckTextField;
@property (nonatomic, retain) IBOutlet UITextField *emailTextField;
@end