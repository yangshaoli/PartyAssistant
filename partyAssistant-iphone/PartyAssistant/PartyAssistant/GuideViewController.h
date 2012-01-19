//
//  GuideViewController.h
//  PartyAssistant
//
//  Created by Yang Shaoli on 12-1-18.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GuideViewController : UIViewController <UIScrollViewDelegate> {
    UIScrollView *scrollView;
    UIPageControl *pageControl;
}

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIPageControl *pageControl;

@end
