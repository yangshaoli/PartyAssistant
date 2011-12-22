//
//  StatusTableVC.h
//  PartyAssistant
//
//  Created by user on 11-12-19.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PartyDetailTableVC.h"
@interface StatusTableVC : UITableViewController{
    NSMutableArray  *participantsArray;
}
@property (nonatomic,retain) NSMutableArray  *participantsArray;
@end
