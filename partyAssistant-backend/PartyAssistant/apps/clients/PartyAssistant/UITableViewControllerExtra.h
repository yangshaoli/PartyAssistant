//
//  UITableViewControllerExtra.h
//  TrendsmittR
//
//  Created by Duc on 11-7-16.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IndicatorMessageView.h"

@interface UITableViewController(UITableViewControllerExtra)

- (void)showAlertRequestSuccess;
- (void)showAlertRequestSuccessWithMessage: (NSString *) theMessage;
- (void)showAlertRequestFailed: (NSString *) theMessage;
- (void)showWaitingWithFrame:(CGRect)frame;
- (void)showWaiting;
- (void)dismissWaiting;

@end
