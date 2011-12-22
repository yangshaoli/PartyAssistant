//
//  PartyDetailTableViewController.h
//  PartyAssistant
//
//  Created by 超 李 on 11-11-6.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseInfoObject.h"
#import "NotificationSettings.h"
#import "URLSettings.h"
#import "JSON.h"
#import "ASIFormDataRequest.h"
#import "ClientStatusTableViewController.h"
#import "UITableViewControllerExtra.h"
#import "EditPartyTableViewController.h"
#import "UserObject.h"
#import "UserObjectService.h"
#import "NumberLabel.h"


@interface PartyDetailTableViewController : UITableViewController<UITableViewDelegate>{
    BaseInfoObject *baseinfo;
    NSArray *peopleCountArray;
    NSArray* myToolbarItems;
}

@property(nonatomic, retain)BaseInfoObject *baseinfo;
@property(nonatomic, retain)NSArray *peopleCountArray;
@property(nonatomic, retain)NSArray* myToolbarItems;

@end
