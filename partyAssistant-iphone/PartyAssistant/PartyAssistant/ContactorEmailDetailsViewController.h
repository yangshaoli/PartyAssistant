//
//  ContactorEmailDetailsViewController.h
//  PartyAssistant
//
//  Created by 超 李 on 11-11-1.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>

@interface ContactorEmailDetailsViewController : UITableViewController
{
    ABRecordID contactorID;
}

@property(nonatomic, assign)ABRecordID contactorID;
@end
