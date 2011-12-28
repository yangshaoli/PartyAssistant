//
//  PartyListTableVC.h
//  PartyAssistant
//
//  Created by user on 11-12-19.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BottomRefreshTableView.h"
#import "TopRefreshTableView.h"
#import "JSON.h"
#import "ASIFormDataRequest.h"
#import "HTTPRequestErrorMSG.h"
#import "UserObjectService.h"
@interface PartyListTableVC : UITableViewController <RefreshTableHeaderDelegate>{
     
    NSMutableArray *partyList;
    
    BOOL _reloading;
    float minBottomRefreshViewY;
    BottomRefreshTableView *bottomRefreshView;
    TopRefreshTableView *topRefreshView;
    NSArray* peopleCountArray;
    BOOL _isNeedRefresh;
    BOOL _isRefreshing;
    NSInteger lastID;
    BOOL _isAppend;
}
@property(nonatomic, assign)BOOL _isNeedRefresh;
@property(nonatomic, assign)BOOL _isRefreshing;
@property(nonatomic, assign)NSInteger lastID;


@property(nonatomic, retain)NSMutableArray *partyList;
@property(nonatomic, retain) BottomRefreshTableView *bottomRefreshView;
@property(nonatomic, retain) TopRefreshTableView *topRefreshView;
@property(nonatomic, retain)NSArray* peopleCountArray;
- (void)reloadTableViewDataSource;
- (void)doneLoadingTopRefreshTableViewData;
- (void)doneLoadingBottomRefreshTableViewData;
- (void)setBottomRefreshViewYandDeltaHeight;

@end
