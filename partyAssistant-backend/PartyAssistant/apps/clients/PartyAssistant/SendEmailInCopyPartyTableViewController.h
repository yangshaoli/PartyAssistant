//
//  SendEmailInCopyPartyTableViewController.h
//  PartyAssistant
//
//  Created by 超 李 on 11-11-7.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBookUI/AddressBookUI.h>
#import <AddressBook/ABPerson.h>
#import <MessageUI/MFMailComposeViewController.h>

#import "ContactListViewController.h"
#import "ContactListNavigationController.h"
#import "NotificationSettings.h"
#import "ReceiverLabel.h"
#import "EmailObject.h"
#import "UITableViewControllerExtra.h"
#import "URLSettings.h"
#import "JSON.h"
#import "ASIFormDataRequest.h"
#import "BaseInfoObject.h"
#import "UserObject.h"
#import "UserObjectService.h"
#import "PartyListTableViewController.h"
#import "HTTPRequestErrorMSG.h"
#import "ReceiverTableViewCell.h"

@interface SendEmailInCopyPartyTableViewController : UITableViewController<UITableViewDelegate, UIActionSheetDelegate,  MFMailComposeViewControllerDelegate,ContactListViewControllerDelegate>
{
    BaseInfoObject  *baseinfo;
    EmailObject *emailObject;
    UIView *receiversView;
    NSMutableArray *receiverArray;
    UITextField *subjectTextField;
    UITextView *contentTextView;
    BOOL _isShowAllReceivers;
    UILabel *countlbl;
    ReceiverTableViewCell *receiverCell;
}

@property(nonatomic, retain)BaseInfoObject *baseinfo;
@property(nonatomic, retain)EmailObject *emailObject;
@property(nonatomic, retain)UIView *receiversView;
@property(nonatomic, retain)NSMutableArray *receiverArray;
@property(nonatomic, retain)UITextField *subjectTextField;
@property(nonatomic, retain)UITextView *contentTextView;
@property(nonatomic, assign)BOOL _isShowAllReceivers;
@property(nonatomic, retain)UILabel *countlbl;
@property(nonatomic, retain)ReceiverTableViewCell *receiverCell;

- (void)sendCreateRequest;
- (void)reorganizeReceiverField:(NSNotification *)notification;
- (void)setDefaultAction;
- (void)saveEmailInfo;
- (void)doneBtnAction;
- (void)applyTipsSwitchAction:(UISwitch *)curSwitch;
- (void)sendBySelfSwitchAction:(UISwitch *)curSwitch;
- (NSString *)getDefaultContent:(BaseInfoObject *)baseinfo;

@end
