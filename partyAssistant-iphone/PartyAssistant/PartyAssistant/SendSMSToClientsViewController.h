//
//  SendSMSToClientsViewController.h
//  PartyAssistant
//
//  Created by 超 李 on 11-10-28.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBookUI/AddressBookUI.h>
#import <AddressBook/ABPerson.h>
#import <MessageUI/MFMessageComposeViewController.h>

#import "ContactListViewController.h"
#import "ContactListNavigationController.h"
#import "NotificationSettings.h"
#import "ReceiverLabel.h"
#import "SMSObject.h"
#import "SMSObjectService.h"
#import "UITableViewControllerExtra.h"
#import "URLSettings.h"
#import "JSON.h"
#import "ASIFormDataRequest.h"
#import "BaseInfoService.h"
#import "BaseInfoObject.h"
#import "UserObject.h"
#import "UserObjectService.h"
#import "PartyListTabelViewController.h"

@interface SendSMSToClientsViewController : UITableViewController<UITableViewDelegate, UIActionSheetDelegate>
{
    UIView *receiversView;
    NSMutableArray *receiverArray;
    UITextView *contentTextView;
    BOOL _isShowAllReceivers;
    UILabel *countlbl;
    SMSObject *smsObject;
}

@property(nonatomic, retain)UIView *receiversView;
@property(nonatomic, retain)NSMutableArray *receiverArray;
@property(nonatomic, retain)UITextView *contentTextView;
@property(nonatomic, assign)BOOL _isShowAllReceivers;
@property(nonatomic, retain)UILabel *countlbl;
@property(nonatomic, retain)SMSObject *smsObject;

- (void)reorganizeReceiverField:(NSNotification *)notification;
- (void)setupReceiversView;
- (void)setDefaultAction;
- (void)saveSMSInfo;
- (void)doneBtnAction;
- (void)applyTipsSwitchAction:(UISwitch *)curSwitch;
- (void)sendBySelfSwitchAction:(UISwitch *)curSwitch;

@end
