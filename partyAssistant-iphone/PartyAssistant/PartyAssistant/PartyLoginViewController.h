//
//  PartyLoginViewController.h
//  PartyTest
//
//  Created by Wang Jun on 11/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "PartyUserNameInputViewController.h"
#import "PartyUserRegisterViewController.h"
@class GlossyButton;

@interface PartyLoginViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, MBProgressHUDDelegate,PartyUserNameInputDelegate,PartyUserRegisterDelegate>{
    UITableView *_tableView;
    GlossyButton    *_loginButton;
    
    UITableViewCell *_userNameTableCell;
    UITableViewCell *_pwdTableCell;
    
    UITextField *_userNameTextField;
    UITextField *_pwdTextField;
    
    MBProgressHUD *_HUD;
    
    BOOL _modal;
    
    UIViewController *_parentVC;
    
    NSMutableArray *partyList;
    
    UITabBarController *appTab;
    
    UIButton *creatTabButton;
    UIButton *listTabButton;
    UIButton *setTabButton;
    
    UIImageView *listPageBarImageView;
    UIImageView *setPageBarImageView;
    UIImageView *creatPageBarImageView;
    UILabel *creatLabel;
    int tabButtonTag;
    
    
}

@property (nonatomic, retain) IBOutlet UITableView  *tableView;
@property (nonatomic, retain) GlossyButton *loginButton;
@property (nonatomic, retain) IBOutlet UITableViewCell *userNameTableCell;
@property (nonatomic, retain) IBOutlet UITableViewCell *pwdTableCell;
@property (nonatomic, retain) IBOutlet UITextField *userNameTextField;
@property (nonatomic, retain) IBOutlet UITextField *pwdTextField;
@property (nonatomic, retain) UIButton *creatTabButton;
@property (nonatomic, retain) UIButton *listTabButton;
@property (nonatomic, retain) UIButton *setTabButton;
@property (nonatomic, retain) UIImageView *listPageBarImageView;
@property (nonatomic, retain) UIImageView *setPageBarImageView;
@property (nonatomic, retain) UIImageView *creatPageBarImageView;
@property (nonatomic, getter = isModal) BOOL modal;
@property (nonatomic, retain) UIViewController *parentVC;
@property (nonatomic, retain) NSMutableArray *partyList;
@property (nonatomic, assign) UITabBarController *appTab;
@property (nonatomic, retain) UILabel *creatLabel;
@property (nonatomic, assign) int tabButtonTag;
@end
