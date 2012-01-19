//
//  GuideViewController.m
//  PartyAssistant
//
//  Created by Yang Shaoli on 12-1-18.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "GuideViewController.h"
#import "PartyAssistantAppDelegate.h"

@implementation GuideViewController
@synthesize scrollView, pageControl;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y = 0.f;
    self.view.frame = viewFrame;
    
    // Do any additional setup after loading the view from its nib.
    if (!self.pageControl) {
        self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(110, 400, 100, 30)];
    }
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 20, 320, 460)];
    UIImageView *imageView1 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 461)];
    imageView1.image = [UIImage imageNamed:@"guideIcon1"];
    UIImageView *imageView2 = [[UIImageView alloc] initWithFrame:CGRectMake(320, 0, 320, 460)];
    imageView2.image = [UIImage imageNamed:@"guideIcon2"];
    UIImageView *imageView3 = [[UIImageView alloc] initWithFrame:CGRectMake(640, 0, 320, 460)];
    imageView3.image = [UIImage imageNamed:@"guideIcon3"];
    UIImageView *imageView4 = [[UIImageView alloc] initWithFrame:CGRectMake(960, 0, 320, 460)];
    imageView4.image = [UIImage imageNamed:@"guideIcon4"];
    UIImageView *imageView5 = [[UIImageView alloc] initWithFrame:CGRectMake(1280, 0, 320, 460)];
    imageView5.image = [UIImage imageNamed:@"guideIcon5"];
    UIImageView *imageView6 = [[UIImageView alloc] initWithFrame:CGRectMake(1600, 0, 320, 460)];
    imageView6.image = [UIImage imageNamed:@"guideIcon6"];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitleColor:[UIColor greenColor] forState:UIControlStateHighlighted];
    [button setBackgroundColor:[UIColor clearColor]];
    
    [button setFrame:CGRectMake(1645, 240, 230, 70)];
    [button setImage:[UIImage imageNamed:@"start_experience_center"] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:@"start_experience_center_highlight"] forState:UIControlStateHighlighted];
    [button addTarget:self action:@selector(goToApp) forControlEvents:UIControlEventTouchUpInside];
    
    [scrollView addSubview:imageView1];
    [scrollView addSubview:imageView2];
    [scrollView addSubview:imageView3];
    [scrollView addSubview:imageView4];
    [scrollView addSubview:imageView5];
    [scrollView addSubview:imageView6];
    [scrollView addSubview:button];
    scrollView.contentSize = CGSizeMake(1920, 460);
    scrollView.pagingEnabled = YES;
    scrollView.bounces = NO;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.scrollsToTop = NO;
    scrollView.delegate = self;
    
    pageControl.currentPage = 0;
    pageControl.numberOfPages = 6;
    
    [self.view addSubview:scrollView];
    [self.view addSubview:pageControl];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - ScrollView Delegate Method
- (void)scrollViewDidScroll:(UIScrollView *)sender
{	
    // Switch the indicator when more than 50% of the previous/next page is visible
    CGFloat pageWidth = scrollView.frame.size.width;
    int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    pageControl.currentPage = page;
}

// At the begin of scroll dragging, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
}

// At the end of scroll animation, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
}

#pragma mark - Target Action Method
- (void)nextscrollView {
    CGFloat pageWidth = scrollView.frame.size.width;
    int maxPage = floor(scrollView.contentSize.width / pageWidth);
    int page = floor(scrollView.contentOffset.x / pageWidth) + 1;
    
    CGRect frame = scrollView.frame;    
    if (page == maxPage) {
        frame.origin.x = 0;
        frame.origin.y = 0;
        [self.scrollView scrollRectToVisible:frame animated:NO];
    } else {
        frame.origin.x = frame.size.width * page;
        frame.origin.y = 0;
        [self.scrollView scrollRectToVisible:frame animated:YES];
    }
}

- (void)goToApp {
    [self.view removeFromSuperview];
    
    [(PartyAssistantAppDelegate *)[[UIApplication sharedApplication] delegate] gotoLoginView];
}

@end
