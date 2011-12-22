//
//  BottomRefreshTableView.h
//  TrendsmittR
//
//  Created by yangshaoli on 11-6-10.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "RefreshTableViewProtocol.h"


@protocol RefreshTableHeaderDelegate;
@interface BottomRefreshTableView : UIView <RefreshTableViewProtocol> {
	
	id _delegate;
	PullRefreshState _state;
    
	UILabel *_lastUpdatedLabel;
	UILabel *_statusLabel;
	CALayer *_arrowImage;
	UIActivityIndicatorView *_activityView;
	
    CGFloat deltaHeight;
}

@property (nonatomic, assign) id <RefreshTableHeaderDelegate> delegate;
@property (nonatomic, assign) CGFloat deltaHeight;

@end
