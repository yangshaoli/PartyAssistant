//
//  BindingListViewController.h
//  PartyAssistant
//
//  Created by Wang Jun on 1/3/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "UserInfoBindingStatusService.h"

@interface BindingListViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    
}

@property (nonatomic, strong) IBOutlet UITableView *tableView;

@property (nonatomic, strong) IBOutlet UITableViewCell *nameBindingCell;
@property (nonatomic, strong) IBOutlet UITableViewCell *telBindingCell;
@property (nonatomic, strong) IBOutlet UITableViewCell *mailBindingCell;
 
@property (nonatomic, strong) IBOutlet UILabel *userIDLabel;

@property (nonatomic, strong) IBOutlet UILabel *userAccountLabel;

@property (nonatomic, strong) IBOutlet UILabel *nameBindingStatusLabel;
@property (nonatomic, strong) IBOutlet UILabel *telBindingStatusLabel;
@property (nonatomic, strong) IBOutlet UILabel *mailBindingStatusLabel;

@property (nonatomic, strong) IBOutlet UILabel *nameBindingInfoLabel;
@property (nonatomic, strong) IBOutlet UILabel *mailBindingInfoLabel;
@property (nonatomic, strong) IBOutlet UILabel *telBindingInfoLabel;

@end
