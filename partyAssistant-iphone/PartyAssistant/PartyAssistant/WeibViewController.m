//
//  WeiboLoginViewController.m
//  PartyAssistant
//
//  Created by 超 李 on 11-11-25.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "WeibViewController.h"

@implementation WeibViewController
@synthesize weibo,childView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.weibo = [[WeiBo alloc] initWithAppKey:WEIBOPRIVATEAPPKEY withAppSecret:WEIBOPRIVATEAPPSECRETE];
    }
    [self.navigationItem.leftBarButtonItem setAction:@selector(cancelBtnAction)];
    if ([self.weibo isUserLoggedin]) {
        childView = [[WeiboRetweetView alloc] initWithFrame:CGRectMake(0, 40, 320, 440)];
        [self.view addSubview:childView];
        self.navigationItem.title = @"发表微博";
        UIBarButtonItem *sendBtn = [[UIBarButtonItem init] initWithTarget:self selector:@selector(sendBtnAction) object:nil];
        sendBtn.title = @"发送";
        sendBtn.style = UIBarButtonItemStyleDone;
        self.navigationItem.rightBarButtonItem = sendBtn;
    }else{
        NSLog(@"here");
        childView = [[WeiBoLoginWebView alloc] initWithFrame:CGRectMake(0, 40, 320, 440)];
        [self.view addSubview:childView];
        self.navigationItem.title = @"登录微博";
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showLoginPage:) name:@"testNotification" object:nil];
        WeiboService *s = [WeiboService sharedWeiboService];
        [s WeiboLogin];
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
    // Do any additional setup after loading the view from its nib.
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

- (void)cancelBtnAction{
    [self dismissModalViewControllerAnimated:YES];
}

- (void)sendBtnAction{

}

- (void)showLoginPage:(NSNotification *)notification{
    NSString *urlStr = [[notification userInfo] objectForKey:@"url"];
    NSURL *url = [NSURL URLWithString:urlStr];
    [self.childView loadRequest:[NSURLRequest requestWithURL:url]];
}
@end
