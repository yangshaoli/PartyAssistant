//
//  PartyDetailTableVC.h
//  PartyAssistant
//
//  Created by user on 11-12-19.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UITableViewControllerExtra.h"
#import "PartyModel.h"
#import "JSON.h"
#import "ASIFormDataRequest.h"


@interface PartyDetailTableVC : UITableViewController<UITableViewDelegate,UITableViewDataSource>{
   NSArray* myToolbarItems;
   PartyModel *partyObj;
   NSArray* peopleCountArray; 
}

@property(nonatomic, retain)NSArray* myToolbarItems;
@property(nonatomic, retain)PartyModel *partyObj;
@property(nonatomic, retain)NSArray* peopleCountArray;
- (void)loadClientCount;
- (void)requestFinished:(ASIHTTPRequest *)request;
- (void)requestFailed:(ASIHTTPRequest *)request;

@end
