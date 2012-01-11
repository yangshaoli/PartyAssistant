//
//  UIViewControllerExtra.m
//  TrendsmittR
//
//  Created by Duc on 11-7-15.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UIViewControllerExtra.h"


@implementation UIViewController(UIViewControllerExtra)

- (void)showAlertRequestSuccess{
	UIAlertView *av=[[UIAlertView alloc] initWithTitle:nil message:@"操作已成功" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK",nil];
    [av show];
}

- (void)showAlertRequestSuccessWithMessage: (NSString *) theMessage{
	UIAlertView *av=[[UIAlertView alloc] initWithTitle:nil message:theMessage delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK",nil];
    av.tag=1;
	[av show];
}

- (void)showAlertRequestFailed: (NSString *) theMessage{
	UIAlertView *av=[[UIAlertView alloc] initWithTitle:@"出错啦！" message:theMessage delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK",nil];
    [av show];
}

- (void)showAlertWithTitle:(NSString *)theTitle Message:(NSString *)theMessage{
    UIAlertView *av=[[UIAlertView alloc] initWithTitle:theTitle message:theMessage delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定",nil];
    [av show];
}

- (void)getVersionFromRequestDic:(NSDictionary *)result{
    NSUserDefaults *versionDefault=[NSUserDefaults standardUserDefaults];
	NSString *versionString = [result objectForKey:@"iphone_version"];
    
    NSUserDefaults *isUpdateVersionDefault=[NSUserDefaults standardUserDefaults];
    
    if(versionString==nil&&[versionString isEqualToString:@""]){
        return;
    }else{
        [versionDefault setObject:versionString forKey:@"airenaoIphoneVersion"];
        [isUpdateVersionDefault setBool:YES forKey:@"isUpdateVersion"];
    }
}
#pragma mark --
#pragma mark waitingView Method

- (void)showWaiting {
	
	
	IndicatorMessageView *waitingView = [[IndicatorMessageView alloc] initWithFrame:CGRectMake(80, 110, 160, 60)];
	
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
