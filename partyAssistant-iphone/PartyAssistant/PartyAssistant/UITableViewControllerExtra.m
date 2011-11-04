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
	UIAlertView *av=[[UIAlertView alloc] initWithTitle:@"Success!" message:@"OK" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK",nil];
    av.tag=1;
	[av show];
    [av release];
}

- (void)showAlertRequestSuccessWithMessage: (NSString *) theMessage{
	UIAlertView *av=[[UIAlertView alloc] initWithTitle:@"Success!" message:theMessage delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK",nil];
    av.tag=1;
	[av show];
    [av release];
}

- (void)showAlertRequestFailed: (NSString *) theMessage{
	UIAlertView *av=[[UIAlertView alloc] initWithTitle:@"Hold on!" message:theMessage delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK",nil];
    [av show];
    [av release];
}

#pragma mark --
#pragma mark waitingView Method

- (void)showWaiting {
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	IndicatorMessageView *waitingView = [[IndicatorMessageView alloc] initWithFrame:CGRectMake(80, 110+self.tableView.contentOffset.y, 160, 60)];
	
	[self.view addSubview:waitingView];
	[waitingView release];
	self.view.userInteractionEnabled = NO;
	
	[pool release];
}

- (void)showWaitingWithFrame:(CGRect)frame {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	IndicatorMessageView *waitingView = [[IndicatorMessageView alloc] initWithFrame:frame];
	
	[self.view addSubview:waitingView];
	[waitingView release];
	self.view.userInteractionEnabled = NO;
    [pool release];
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
