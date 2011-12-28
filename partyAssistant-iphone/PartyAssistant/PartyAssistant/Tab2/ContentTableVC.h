//
//  ContentTableVC.h
//  PartyAssistant
//
//  Created by user on 11-12-22.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PartyModel.h"
@interface ContentTableVC : UITableViewController
{
  UITextView *contentTextView;
    PartyModel *partyObj;
}
@property (nonatomic,retain) UITextView *contentTextView;
@property (nonatomic,retain) PartyModel *partyObj;
@end
