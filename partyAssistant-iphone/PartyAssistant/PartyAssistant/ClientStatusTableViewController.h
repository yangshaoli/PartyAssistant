//
//  ClientStatusTableViewController.h
//  PartyAssistant
//
//  Created by 超 李 on 11-11-11.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UITableViewControllerExtra.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "JSON.h"
#import "URLSettings.h"
#import "HTTPRequestErrorMSG.h"
#import "BaseInfoObject.h"
#import "ClientObject.h"
#import "ResendSMSTableViewController.h"

@interface ClientStatusTableViewController : UITableViewController{
    NSArray *clientsArray;
    NSString *clientStatusFlag;
    BaseInfoObject *baseinfo;
    int partyId;
}

@property(nonatomic, retain)NSArray *clientsArray;
@property(nonatomic, retain)NSString *clientStatusFlag;
@property(nonatomic, assign)int partyId;
@property(nonatomic, retain)BaseInfoObject *baseinfo;
@end
