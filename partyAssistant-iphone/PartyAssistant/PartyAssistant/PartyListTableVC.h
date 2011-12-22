//
//  PartyListTableVC.h
//  PartyAssistant
//
//  Created by user on 11-12-19.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PartyListTableVC : UITableViewController{
     
    NSMutableArray *partyList;

}


@property(nonatomic, retain)NSMutableArray *partyList;
@end
