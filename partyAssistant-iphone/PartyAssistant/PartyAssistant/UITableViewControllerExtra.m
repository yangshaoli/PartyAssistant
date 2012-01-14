//
//  UITableViewControllerExtra.m
//  TrendsmittR
//
//  Created by Duc on 11-7-16.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UITableViewControllerExtra.h"


@implementation UITableViewController(UITableViewControllerExtra)

- (void)showAlertRequestSuccess{
	UIAlertView *av=[[UIAlertView alloc] initWithTitle:@"操作成功!" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"好的",nil];
    av.tag=1;
	[av show];
}

- (void)showAlertRequestSuccessWithMessage: (NSString *) theMessage{
	UIAlertView *av=[[UIAlertView alloc] initWithTitle:@"操作成功!" message:theMessage delegate:self cancelButtonTitle:nil otherButtonTitles:@"好的",nil];
    av.tag=1;
	[av show];
}

- (void)showAlertRequestFailed: (NSString *) theMessage{
	UIAlertView *av=[[UIAlertView alloc] initWithTitle:@"操作失败!" message:theMessage delegate:self cancelButtonTitle:nil otherButtonTitles:@"请重新操作",nil];
    [av show];
}

#pragma mark --
#pragma mark waitingView Method

- (void)showWaiting {
	
	IndicatorMessageView *waitingView = [[IndicatorMessageView alloc] initWithFrame:CGRectMake(80, 110+self.tableView.contentOffset.y, 160, 60)];
	[self.view addSubview:waitingView];
	self.view.userInteractionEnabled = NO;
	
}

- (void)showWaitingWithFrame:(CGRect)frame {
	IndicatorMessageView *waitingView = [[IndicatorMessageView alloc] initWithFrame:frame];
	
	[self.view addSubview:waitingView];
	self.view.userInteractionEnabled = NO;
}

- (void)dismissWaiting
{
	NSEnumerator* myIterator = [self.view.subviews reverseObjectEnumerator];
	id ob;
	while((ob = [myIterator nextObject]))
	{
		if ([ob isMemberOfClass:[IndicatorMessageView class]]) {
			[ob removeFromSuperview];
			break;
		}
	}
    
    self.view.userInteractionEnabled = YES;
}

@end
