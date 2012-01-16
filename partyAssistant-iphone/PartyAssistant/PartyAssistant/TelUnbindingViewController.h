//
//  TelUnbindingViewController.h
//  PartyAssistant
//
//  Created by Wang Jun on 1/3/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface TelUnbindingViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) IBOutlet UITableView *tableView;

@property (nonatomic, strong) IBOutlet UITableViewCell *inputTelCell;
@property (nonatomic, strong) IBOutlet UILabel *inputTelLabel;

@property (nonatomic, strong) IBOutlet UITableViewCell *telUnBindingCell;

@property (nonatomic, strong) IBOutlet UITextField *telTextField;
@end
