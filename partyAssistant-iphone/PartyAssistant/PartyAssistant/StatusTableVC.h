//
//  StatusTableVC.h
//  PartyAssistant
//
//  Created by user on 11-12-19.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PartyDetailTableVC.h"
#import "PartyModel.h"
#import "ClientObject.h"
@interface StatusTableVC : UITableViewController{
    NSArray *clientsArray;
    NSString *clientStatusFlag;
    PartyModel *partyObj;
    NSString *wordString;
}
@property(nonatomic, retain)NSArray *clientsArray;
@property(nonatomic, retain)NSString *clientStatusFlag;
@property(nonatomic, retain)PartyModel *partyObj;
@property(nonatomic, retain)NSString *wordString;

- (void)getPartyClientSeperatedList;
@end
