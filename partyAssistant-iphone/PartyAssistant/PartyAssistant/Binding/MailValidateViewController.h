//
//  MailValidateViewController.h
//  PartyAssistant
//
//  Created by Wang Jun on 1/11/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserInfoBindingStatusService.h"

@interface MailValidateViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) IBOutlet UITableView *tableView;

@property (nonatomic, strong) IBOutlet UITableViewCell *inputMailCell;
@property (nonatomic, strong) IBOutlet UITextField *inputMailTextField;

@property (nonatomic, strong) IBOutlet UITableViewCell *mailValidateCell;

@property (nonatomic, strong) IBOutlet UITableViewCell *mailResendValidateCell;

@property (nonatomic) BindingStatus pageStatus;

@end