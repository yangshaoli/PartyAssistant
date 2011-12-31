//
//  RefreshTableViewProtocol.h
//  TrendsmittR
//
//  Created by yangshaoli on 11-6-13.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum{
	PullRefreshPulling = 0,
	PullRefreshNormal,
	PullRefreshLoading,	
} PullRefreshState;

@protocol RefreshTableViewProtocol <NSObject>

- (void)refreshLastUpdatedDate;
- (void)refreshScrollViewDidScroll:(UIScrollView *)scrollView;
- (void)refreshScrollViewDidEndDragging:(UIScrollView *)scrollView;
- (void)refreshScrollViewDataSourceDidFinishedLoading:(UIScrollView *)scrollView;

@end

@protocol RefreshTableHeaderDelegate
- (CGFloat)getTableHeadViewHeight;
- (BOOL)refreshTableHeaderDataSourceIsLoading:(id<RefreshTableViewProtocol>)view;
@optional
- (void)refreshTopTableHeaderDidTriggerRefresh:(id<RefreshTableViewProtocol>)view;
- (void)refreshBottomTableHeaderDidTriggerRefresh:(id<RefreshTableViewProtocol>)view;
- (NSDate*)refreshTableHeaderDataSourceLastUpdated:(id<RefreshTableViewProtocol>)view;

@end
