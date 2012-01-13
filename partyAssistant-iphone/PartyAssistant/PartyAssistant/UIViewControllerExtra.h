//
//  UIViewControllerExtra.h
//  TrendsmittR
//
//  Created by Duc on 11-7-15.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IndicatorMessageView.h"


@interface UIViewController(UIViewControllerExtra)

- (void)showAlertRequestSuccess;
- (void)showAlertRequestSuccessWithMessage: (NSString *) theMessage;
- (void)showAlertRequestFailed: (NSString *) theMessage;
- (void)showAlertWithTitle:(NSString *)theTitle Message:(NSString *)theMessage;
- (void)showWaitingWithFrame:(CGRect)frame;
- (void)showWaiting;
- (void)dismissWaiting;
- (void)getVersionFromRequestDic:(NSDictionary *)result;
@end
