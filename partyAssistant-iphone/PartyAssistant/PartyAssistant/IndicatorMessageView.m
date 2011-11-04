//
//  IndicatorMessageView.m
//  TrendsmittR
//
//  Created by yangshaoli on 11-7-13.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "IndicatorMessageView.h"
#import <QuartzCore/QuartzCore.h>


@implementation IndicatorMessageView
@synthesize backgroundView, messageLabel, activityView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        self.layer.cornerRadius = 10;
        self.layer.masksToBounds = YES;
        
        self.backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 160, 60)];
        backgroundView.backgroundColor = [UIColor blackColor];
        backgroundView.alpha = 0.5;
        backgroundView.layer.cornerRadius = 10;
        backgroundView.layer.masksToBounds = YES;
        
        self.messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 25, 140, 30)];
        messageLabel.text = @"请稍候...";
        messageLabel.textAlignment = UITextAlignmentCenter;
        messageLabel.backgroundColor = [UIColor clearColor];
        messageLabel.textColor = [UIColor whiteColor];
        messageLabel.font = [UIFont systemFontOfSize:15.0f];
        
        self.activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        activityView.frame = CGRectMake(70.0f, 5.0f, 20.0f, 20.0f);
        activityView.alpha = 1;
        [self addSubview:backgroundView];
        [self addSubview:activityView];
        [self addSubview:messageLabel];
        [activityView startAnimating];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/


@end
