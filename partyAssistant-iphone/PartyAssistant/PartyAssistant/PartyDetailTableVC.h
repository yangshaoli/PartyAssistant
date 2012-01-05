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
   NSArray *clientsArray;
   ASIHTTPRequest *quest;
   ASIHTTPRequest *seperatedListQuest; 
   ASIHTTPRequest *deleteQuest;
}

@property(nonatomic, retain)NSArray* myToolbarItems;
@property(nonatomic, retain)PartyModel *partyObj;
@property(nonatomic, retain)NSArray* peopleCountArray;
@property(nonatomic, retain)NSArray *clientsArray;
@property(nonatomic, retain)ASIHTTPRequest *quest;
@property(nonatomic, retain)ASIHTTPRequest *seperatedListQuest;
@property(nonatomic, retain)ASIHTTPRequest *deleteQuest;
- (void)loadClientCount;
- (void)requestFinished:(ASIHTTPRequest *)request;
- (void)requestFailed:(ASIHTTPRequest *)request;
- (void)getPartyClientSeperatedList;

@end
