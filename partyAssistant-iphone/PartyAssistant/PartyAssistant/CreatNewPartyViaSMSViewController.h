//
//  CreatNewPartyViaSMSViewController.h
//  PartyAssistant
//
//  Created by Wang Jun on 12/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "EditableTableViewCell.h"
#import "ButtonPeoplePicker.h"
#import "SMSObject.h"
#import "MBProgressHUD.h"
#import "SendSMSModeChooseViewController.h"

@class ButtonPeoplePicker;
@interface CreatNewPartyViaSMSViewController : UIViewController <UITableViewDelegate, UITableViewDataSource,MFMessageComposeViewControllerDelegate,EditableTableViewCellDelegate,ButtonPeoplePickerDelegate,MBProgressHUDDelegate,ContactsListPickerViewControllerDelegate,UserSMSModeCheckDelegate> {
    EditableTableViewCell *editingTableViewCell;
    SMSObject *smsObject;
}

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UITableViewCell *addContactCell;
@property (nonatomic, strong) IBOutlet UITableViewCell *sendModelSelectCell;
 
@property (nonatomic, strong) IBOutlet UITextField *contactNameTF;
@property (nonatomic, strong) IBOutlet UILabel *sendModeNameLabel;

@property (nonatomic, strong) IBOutlet ButtonPeoplePicker *picker;

@property (nonatomic, strong) UIBarButtonItem *rightItem;

@property (nonatomic, strong) NSMutableArray *receipts;

@property (nonatomic, strong) SMSObject *smsObject;

@property (nonatomic, strong) MBProgressHUD *HUD;

- (IBAction)callContactList;
- (void)saveSMSInfo;
- (void)sendCreateRequest;
@end
