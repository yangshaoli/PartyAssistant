//
//  NameBindingViewController.h
//  PartyAssistant
//
//  Created by Wang Jun on 1/3/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NameBindingViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    BOOL modalView;
}

@property (nonatomic, strong) IBOutlet UITableView *tableView;
//header
//@property (nonatomic, strong) IBOutlet UILabel *IDTitleLabel;
//@property (nonatomic, strong) IBOutlet UITextField *IDNameTextField;
//nameInput
@property (nonatomic, strong) IBOutlet UITableViewCell *inputNameCell;
@property (nonatomic, strong) IBOutlet UITextField *nickNameInputTextField;
//upload
@property (nonatomic, strong) IBOutlet UITableViewCell *uploadNameCell;

@property (nonatomic, getter = isModalView) BOOL modalView;
@end
