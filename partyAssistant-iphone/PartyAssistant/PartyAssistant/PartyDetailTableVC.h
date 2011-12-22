//
//  PatryDetailTableVC.h
//  PartyAssistant
//
//  Created by user on 11-12-19.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UITableViewControllerExtra.h"

@interface PartyDetailTableVC : UIViewController<UITableViewDelegate>{
   NSArray* myToolbarItems;
}

@property(nonatomic, retain)NSArray* myToolbarItems;

@end
