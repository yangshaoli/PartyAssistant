//
//  IndicatorMessageView.h
//  TrendsmittR
//
//  Created by yangshaoli on 11-7-13.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface IndicatorMessageView : UIView {
    UIView *backgroundView;
    UILabel *messageLabel;
    UIActivityIndicatorView *activityView;
}

@property (nonatomic, retain) UIView *backgroundView;
@property (nonatomic, retain) UILabel *messageLabel;
@property (nonatomic, retain) UIActivityIndicatorView *activityView;

@end
