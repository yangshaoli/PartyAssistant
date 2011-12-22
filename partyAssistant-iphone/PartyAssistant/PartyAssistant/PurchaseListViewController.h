//
//  PurchaseListViewController.h
//  PartyAssistant
//
//  Created by Wang Jun on 12/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>

@interface PurchaseListViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    
    UITableView *tableView;

}

@property (nonatomic, strong) IBOutlet UITableView *tableView;

@end
