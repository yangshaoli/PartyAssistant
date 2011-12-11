//
//  ContactorPhoneDetailsViewController.h
//  PartyAssistant
//
//  Created by 超 李 on 11-11-1.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>
#import "NotificationSettings.h"

@protocol ContactorPhoneDetailsViewControllerDelegate <NSObject>

- (void)contactDetailSelectedWithUserInfo:(NSDictionary *)info;

@end

@interface ContactorPhoneDetailsViewController : UITableViewController<UITableViewDelegate>
{
    ABRecordID contactorID;
    ABMultiValueRef phone;
    ABRecordRef card;
    id<ContactorPhoneDetailsViewControllerDelegate> phoneDetailDelegate;
}

@property(nonatomic, assign)ABRecordID contactorID;
@property(nonatomic, assign)ABMultiValueRef phone;
@property(nonatomic, assign)ABRecordRef card;
@property(nonatomic, strong)id<ContactorPhoneDetailsViewControllerDelegate> phoneDetailDelegate;

@end
