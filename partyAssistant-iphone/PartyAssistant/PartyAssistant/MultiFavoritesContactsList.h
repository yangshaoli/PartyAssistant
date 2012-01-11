//
//  MultiFavoritesContactsList.h
//  PartyAssistant
//
//  Created by Wang Jun on 1/7/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#include "MultiContactsPickerListViewController.h"

@interface MultiFavoritesContactsList : UITableViewController

@property (nonatomic,strong) UIViewController *managingViewController;
@property (nonatomic,strong) NSArray *dataSource;
@property(nonatomic,strong)id<MultiContactsPickerListViewControllerDelegate> contactListDelegate;
@property(nonatomic,strong)NSMutableArray *selectedContactorsArray;
@property(nonatomic,assign)NSInteger currentSelectedRowIndex;

- (id)initWithParentViewController:(UIViewController *)aViewController;
- (void)initDataSource;
- (void)showOrCancleSelectedMark:(ClientObject *)client mutableMSGValue:(id)msgVal;
- (void)removeInfoFromArray:(NSInteger)cID;
@end
