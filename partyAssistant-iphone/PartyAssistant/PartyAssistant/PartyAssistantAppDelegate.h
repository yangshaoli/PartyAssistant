//
//  PartyAssistantAppDelegate.h
//  PartyAssistant
//
//  Created by 超 李 on 11-10-26.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PartyLoginViewController.h"
#import "PartyListTableViewController.h"
#import "AddNewPartyBaseInfoTableViewController.h"
#import "DeviceTokenService.h"
#import "NotificationSettings.h"
#import "HTTPRequestErrorMSG.h"
#import "URLSettings.h"
#import "JSON.h"
#import "ASIFormDataRequest.h"
#import "UserObject.h"
#import "UserObjectService.h"
#import <AddressBook/AddressBook.h>
#import "MBProgressHUD.h"

ABAddressBookRef addressBook;
@interface PartyAssistantAppDelegate : UIResponder <UIApplicationDelegate> {
    MBProgressHUD *_HUD;
}

@property (strong, nonatomic) UIWindow *window;


void addressBookChanged (ABAddressBookRef addressBook,
                         CFDictionaryRef info,
                         void *context);

@end
