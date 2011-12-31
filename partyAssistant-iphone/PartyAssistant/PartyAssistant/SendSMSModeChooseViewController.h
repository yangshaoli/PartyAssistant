//
//  SendSMSModeChooseViewController.h
//  PartyAssistant
//
//  Created by Wang Jun on 12/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UserSMSModeCheckDelegate

- (BOOL)IsCurrentSMSSendBySelf;
- (void)changeSMSModeToSendBySelf:(BOOL)status;

@end

@interface SendSMSModeChooseViewController : UITableViewController

@property (nonatomic, weak) id<UserSMSModeCheckDelegate> delegate;

@end
