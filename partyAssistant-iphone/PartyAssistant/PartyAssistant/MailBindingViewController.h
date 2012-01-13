//
//  MailBindingViewController.h
//  PartyAssistant
//
//  Created by Wang Jun on 1/3/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface MailBindingViewController : UIViewController <UITableViewDelegate, UITableViewDataSource,UIAlertViewDelegate>

@property (nonatomic, strong) IBOutlet UITableView *tableView;

@property (nonatomic, strong) IBOutlet UITableViewCell *inputMailCell;
@property (nonatomic, strong) IBOutlet UITextField *inputMailTextField;

@property (nonatomic, strong) IBOutlet UITableViewCell *mailBindingCell;

@end
