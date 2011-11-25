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

@interface ContactorEmailDetailsViewController : UITableViewController
{
    ABRecordID contactorID;
    ABMultiValueRef email;
    ABRecordRef card;
}

@property(nonatomic, assign)ABRecordID contactorID;
@property(nonatomic, assign)ABMultiValueRef email;
@property(nonatomic, assign)ABRecordRef card;
@end
