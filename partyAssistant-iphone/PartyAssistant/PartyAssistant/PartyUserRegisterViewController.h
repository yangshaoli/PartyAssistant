//
//  PartyUserRegisterViewController.h
//  PartyTest
//
//  Created by Wang Jun on 11/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
@protocol PartyUserRegisterDelegate <NSObject>

- (void)autoLogin;//自动登录
@end

@interface PartyUserRegisterViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, MBProgressHUDDelegate>{
    
    UITableView *_tableView;

//username
//pwd
//name
    
    UITableViewCell *_userNameCell;
    UITableViewCell *_pwdCell;
    
    //UITableViewCell *_nickNameCell;
    
    UITextField *_userNameTextField;
    UITextField *_pwdTextField;
    //UITextField *_nickNameTextField;
    id<PartyUserRegisterDelegate> delegate;
    
    MBProgressHUD *_HUD;
}

@property (nonatomic, retain) IBOutlet UITableView  *tableView;

@property (nonatomic, retain) IBOutlet UITableViewCell *userNameCell;
@property (nonatomic, retain) IBOutlet UITableViewCell *pwdCell;
//@property (nonatomic, retain) IBOutlet UITableViewCell *nickNameCell;

@property (nonatomic, retain) IBOutlet UITextField *userNameTextField;
@property (nonatomic, retain) IBOutlet UITextField *pwdTextField;
//@property (nonatomic, retain) IBOutlet UITextField *nickNameTextField;
@property (nonatomic, retain) id<PartyUserRegisterDelegate> delegate;
- (IBAction)autoLogin;
@end