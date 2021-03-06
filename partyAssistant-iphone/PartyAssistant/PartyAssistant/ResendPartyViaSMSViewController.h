//
//  ResendPartyViaSMSViewController.h
//  PartyAssistant
//
//  Created by Wang Jun on 12/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CreatNewPartyViaSMSViewController.h"
#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "EditableTableViewCell.h"
#import "ButtonPeoplePicker.h"
#import "SMSObject.h"
#import "MBProgressHUD.h"
#import "SendSMSModeChooseViewController.h"

#import <UIKit/UIKit.h>

@interface ResendPartyViaSMSViewController : CreatNewPartyViaSMSViewController {
    NSString *smsContent;
    NSInteger groupID;
    SMSObject *tempSMSObject;
}

@property (nonatomic, strong) SMSObject *tempSMSObject;

- (void)setSmsContent:(NSString *)newContent andGropID:(NSInteger)newGroupID;

- (void)setNewReceipts:(NSArray *)receipts;
@end
