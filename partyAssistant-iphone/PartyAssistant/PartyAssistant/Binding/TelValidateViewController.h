//
//  TelValidateViewController.h
//  PartyAssistant
//
//  Created by Wang Jun on 1/3/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserInfoBindingStatusService.h"

@interface TelValidateViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) IBOutlet UITableView *tableView;

@property (nonatomic, strong) IBOutlet UITableViewCell *inputTelCell;
@property (nonatomic, strong) IBOutlet UITextField *inputCodeTextField;

@property (nonatomic, strong) IBOutlet UITableViewCell *telValidateCell;

@property (nonatomic, strong) IBOutlet UITableViewCell *telResendValidateCell;

@property (nonatomic) BindingStatus pageStatus;

@property (nonatomic) BOOL inSpecialProcess;

@end
