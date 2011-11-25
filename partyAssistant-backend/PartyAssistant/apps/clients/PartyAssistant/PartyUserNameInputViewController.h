//
//  PartyUserNameInputViewController.h
//  PartyAssistant
//
//  Created by Wang Jun on 11/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PartyUserNameInputDelegate <NSObject>

- (void)cancleInput;
- (void)saveInputDidBegin;
- (void)saveInputFinished;
- (void)saveInputFailed;

@end

@interface PartyUserNameInputViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>{
    UITableView *_tableView;
    
    UITableViewCell *_userNameTableCell;
    
    UITextField *_userNameTextField;
    
    id<PartyUserNameInputDelegate> delegate;
}

@property (nonatomic, retain) IBOutlet UITableView  *tableView;
@property (nonatomic, retain) IBOutlet UITableViewCell *userNameTableCell;
@property (nonatomic, retain) IBOutlet UITextField *userNameTextField;
@property (nonatomic, retain) id<PartyUserNameInputDelegate> delegate;

- (IBAction)cancleInput;
- (IBAction)SaveInput;

@end
