//
//  MultiContactsPhoneDetailViewController.h
//  PartyAssistant
//
//  Created by Wang Jun on 1/5/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>
#import "NotificationSettings.h"

@class ClientObject;
@protocol MultiContactsPhoneDetailViewControllerDelegate <NSObject>

- (void)contactDetailSelectedWithUserInfo:(ClientObject *)info;

@end

@interface MultiContactsPhoneDetailViewController : UITableViewController<UITableViewDelegate>
{
    ABRecordID contactorID;
    ABMultiValueRef phone;
    ABRecordRef card;
    NSString *name;
    id<MultiContactsPhoneDetailViewControllerDelegate> phoneDetailDelegate;
    NSInteger selectedIndex;
}

@property(nonatomic, assign)ClientObject *clientObject;
@property(nonatomic, assign)ABRecordID contactorID;
@property(nonatomic, assign)ABMultiValueRef phone;
@property(nonatomic, assign)ABRecordRef card;
@property(nonatomic, strong)NSString *name;
@property(nonatomic, strong)id<MultiContactsPhoneDetailViewControllerDelegate> phoneDetailDelegate;
@property(nonatomic) NSInteger selectedIndex;

@end
