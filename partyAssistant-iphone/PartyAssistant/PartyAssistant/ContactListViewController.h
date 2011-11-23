//
//  ContactListViewController.h
//  PartyAssistant
//
//  Created by 超 李 on 11-10-31.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>
#import "ContactorPhoneDetailsViewController.h"
#import "ContactorEmailDetailsViewController.h"
#import "NotificationSettings.h"
#import "ClientObject.h"

@protocol ContactListViewControllerDelegate <NSObject>

- (void)reorganizeReceiverField:(NSDictionary *)userInfo;

@end

@interface ContactListViewController : UITableViewController
{
    NSArray *contactorsArray;
    CFArrayRef contactorsArrayRef;
    NSMutableArray *selctedContactorsArray;
    NSString *msgType;
    NSInteger currentSelectedRowIndex;
    id<ContactListViewControllerDelegate> contactListDelegate;
}

@property(nonatomic,retain)NSArray *contactorsArray;
@property(nonatomic,retain)NSMutableArray *selectedContactorsArray;
@property(nonatomic,assign)CFArrayRef contactorsArrayRef;
@property(nonatomic,retain)NSString *msgType;
@property(nonatomic,assign)NSInteger currentSelectedRowIndex;
@property(nonatomic,retain)id<ContactListViewControllerDelegate> contactListDelegate;

- (void)alertError:(NSString *)errorStr;
- (void)showOrCancleSelectedMark:(UITableViewCell *)cell mutableMSGValue:(id)msgVal;
- (void)selectContactor:(NSDictionary *)userinfo;
- (void)addInfoToArray:(NSInteger)cID uname:(NSString *)name value:(NSString *)val;
- (void)removeInfoFromArray:(NSInteger)cID;

@end
