//
//  MailUnbindingViewController.h
//  PartyAssistant
//
//  Created by Wang Jun on 1/3/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MailUnbindingViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) IBOutlet UITableView *tableView;

@property (nonatomic, strong) IBOutlet UITableViewCell *inputMailCell;
@property (nonatomic, strong) IBOutlet UILabel *mailInfoTitleLabel;

@property (nonatomic, strong) IBOutlet UITableViewCell *mailUnBindingCell;
@property (nonatomic, strong) IBOutlet UITextField *mailTextField;

@end
