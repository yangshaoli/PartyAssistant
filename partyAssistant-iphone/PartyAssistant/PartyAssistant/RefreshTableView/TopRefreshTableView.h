//
//  TopRefreshTableView.h
//  TrendsmittR
//
//  Created by yangshaoli on 11-6-10.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "RefreshTableViewProtocol.h"
/*

*/
@protocol RefreshTableHeaderDelegate;
@interface TopRefreshTableView : UIView <RefreshTableViewProtocol> {
	
	id _delegate;
	PullRefreshState _state;
    
	UILabel *_lastUpdatedLabel;
	UILabel *_statusLabel;
	CALayer *_arrowImage;
	UIActivityIndicatorView *_activityView;
	
    
}

@property(nonatomic,assign) id <RefreshTableHeaderDelegate> delegate;

@end
/*

*/