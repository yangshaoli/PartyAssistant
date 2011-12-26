//
//  ContactorEmailDetailsViewController.h
//  PartyAssistant
//
//  Created by 超 李 on 11-11-1.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>
#import "NotificationSettings.h"
@protocol ContactorEmailDetailsViewControllerDelegate <NSObject>

- (void)contactDetailSelectedWithUserInfo:(NSDictionary *)info;

@end
@interface ContactorEmailDetailsViewController : UITableViewController
{
    ABRecordID contactorID;
    ABMultiValueRef email;
    ABRecordRef card;
    id<ContactorEmailDetailsViewControllerDelegate> EmailDetailDelegate;
}

@property(nonatomic, assign)ABRecordID contactorID;
@property(nonatomic, assign)ABMultiValueRef email;
@property(nonatomic, assign)ABRecordRef card;
@property(nonatomic, strong)id<ContactorEmailDetailsViewControllerDelegate> EmailDetailDelegate;
@end
