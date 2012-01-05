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
#import "PartyModel.h"
@protocol ContactorPhoneDetailsViewControllerDelegate <NSObject>

- (void)contactDetailSelectedWithUserInfo:(NSDictionary *)info;

@end

@interface ContactorPhoneDetailsViewController : UITableViewController<UITableViewDelegate,UIActionSheetDelegate>
{
    ABRecordID contactorID;
    id<ContactorPhoneDetailsViewControllerDelegate> phoneDetailDelegate;
    NSDictionary *clientDict;//服务器获得的数据
    UITextView *messageTextView;
    PartyModel *partyObj;
    NSString *clientStatusFlag;
    
}
@property(nonatomic, retain)UITextView *messageTextView;
@property(nonatomic, assign)ABRecordID contactorID;
@property(nonatomic, assign)id<ContactorPhoneDetailsViewControllerDelegate> phoneDetailDelegate;
@property(nonatomic, retain)NSDictionary *clientDict;
@property(nonatomic, retain)PartyModel *partyObj;
@property(nonatomic, retain)NSString *clientStatusFlag;

@end
