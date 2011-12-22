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

@interface PartyListTableVC : UITableViewController <RefreshTableHeaderDelegate>{
     
    NSMutableArray *partyList;
    
    BOOL _reloading;
    float minBottomRefreshViewY;
    BottomRefreshTableView *bottomRefreshView;
    TopRefreshTableView *topRefreshView;
}


@property(nonatomic, retain)NSMutableArray *partyList;
@property(nonatomic, retain) BottomRefreshTableView *bottomRefreshView;
@property(nonatomic, retain) TopRefreshTableView *topRefreshView;

- (void)reloadTableViewDataSource;
- (void)doneLoadingTopRefreshTableViewData;
- (void)doneLoadingBottomRefreshTableViewData;
- (void)setBottomRefreshViewYandDeltaHeight;

@end
