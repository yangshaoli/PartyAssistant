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
#import "ASIFormDataRequest.h"
#import "MBProgressHUD.h"
@protocol ContactorPhoneDetailsViewControllerDelegate <NSObject>

- (void)contactDetailSelectedWithUserInfo:(NSDictionary *)info;

@end

@interface ContactorPhoneDetailsViewController : UITableViewController<UITableViewDelegate,UIActionSheetDelegate>
{
    ABRecordID contactorID;
    id<ContactorPhoneDetailsViewControllerDelegate> phoneDetailDelegate;
    NSDictionary *clientDict;//服务器获得的数据
    PartyModel *partyObj;
    NSString *clientStatusFlag;
    ASIHTTPRequest *quest;
    
    UITableViewCell *phoneCell;
    UITableViewCell *messageCell;
    
    UILabel *phoneLabel;
    UITextView *messageTextView;
    
    UIView *footerView;
    UIButton *goButton;
    UIButton *notGoButton;
    UIActivityIndicatorView *activity;
    MBProgressHUD *_HUD;
    CGRect bounds;
}
@property(nonatomic, assign)ABRecordID contactorID;
@property(nonatomic, assign)id<ContactorPhoneDetailsViewControllerDelegate> phoneDetailDelegate;
@property(nonatomic, retain)NSDictionary *clientDict;
@property(nonatomic, retain)PartyModel *partyObj;
@property(nonatomic, retain)NSString *clientStatusFlag;
@property(nonatomic, retain)ASIHTTPRequest *quest;

@property(nonatomic, retain)IBOutlet UITableViewCell *phoneCell;
@property(nonatomic, retain)IBOutlet UITableViewCell *messageCell;
@property(nonatomic, retain)UIView *footerView;
@property(nonatomic, retain)UIButton *goButton;
@property(nonatomic, retain)UIButton *notGoButton;
@property(nonatomic, retain)UIActivityIndicatorView *activity;
@property(nonatomic, retain)IBOutlet UILabel *phoneLabel;
@property(nonatomic, retain)IBOutlet UITextView *messageTextView;
//- (BOOL) isEmailAddress:(NSString*)email;
@end
