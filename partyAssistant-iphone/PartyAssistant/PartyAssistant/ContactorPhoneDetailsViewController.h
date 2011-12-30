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
#import "ClientObject.h"

@protocol ContactorPhoneDetailsViewControllerDelegate <NSObject>

- (void)contactDetailSelectedWithUserInfo:(NSDictionary *)info;

@end

@interface ContactorPhoneDetailsViewController : UITableViewController<UITableViewDelegate,UIActionSheetDelegate>
{
    ABRecordID contactorID;
    ABMultiValueRef phone;
    ABRecordRef card;
    id<ContactorPhoneDetailsViewControllerDelegate> phoneDetailDelegate;
    NSDictionary *clientDict;
    UITextView *messageTextView;
}
@property(nonatomic, retain)UITextView *messageTextView;
@property(nonatomic, assign)ABRecordID contactorID;
@property(nonatomic, assign)ABMultiValueRef phone;
@property(nonatomic, assign)ABRecordRef card;
@property(nonatomic, strong)id<ContactorPhoneDetailsViewControllerDelegate> phoneDetailDelegate;
@property(nonatomic, retain)NSDictionary *clientDict;

@end
