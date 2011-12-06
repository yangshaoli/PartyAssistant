//
//  PartyListTabelViewController.h
//  PartyAssistant
//
//  Created by 超 李 on 11-11-6.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PartyListService.h"
#import "URLSettings.h"
#import "JSON.h"
#import "ASIFormDataRequest.h"
#import "UITableViewControllerExtra.h"
#import "PartyDetailTableViewController.h"
#import "CopyPartyTableViewController.h"
#import "HTTPRequestErrorMSG.h"
#import "UserObject.h"
#import "UserObjectService.h"
#import "WeiboLoginViewController.h"
#import "WeiboNavigationController.h"

@interface PartyListTableViewController : UITableViewController<UITableViewDelegate,UIActionSheetDelegate, UIAlertViewDelegate>{
    NSMutableArray *partyList;
    BOOL _isNeedRefresh;
    BOOL _isRefreshing;
    NSInteger pageIndex;
    NSInteger _currentDeletePartyID;
    NSInteger _currentDeletePartyCellIndex;
    NSInteger countNumber;
}

@property(nonatomic, retain)NSMutableArray *partyList;
@property(nonatomic, assign)BOOL _isNeedRefresh;
@property(nonatomic, assign)BOOL _isRefreshing;
@property(nonatomic, assign)NSInteger pageIndex;
@property(nonatomic, assign)NSInteger _currentDeletePartyID;
@property(nonatomic, assign)NSInteger _currentDeletePartyCellIndex;
@property(nonatomic, assign)NSInteger countNumber;
- (void)refreshBtnAction;
- (void)copyPartyAtID:(NSInteger)pIndex;
- (void)deletePartyAtID:(NSInteger)pIndex;
- (void)sharePartyAtID:(NSInteger)pIndex;
@end
