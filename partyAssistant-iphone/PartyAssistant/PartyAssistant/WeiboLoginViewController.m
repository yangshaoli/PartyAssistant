//
//  WeiboLoginViewController.m
//  PartyAssistant
//
//  Created by 超 李 on 11-11-25.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "WeiboLoginViewController.h"

@implementation WeiboLoginViewController
@synthesize weibo,childView,baseinfo,isOnlyLogin,delegate,partyObj;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.weibo = [[WeiBo alloc] initWithAppKey:WEIBOPRIVATEAPPKEY withAppSecret:WEIBOPRIVATEAPPSECRETE];
        weibo.delegate = self;
    }
    isOnlyLogin = NO;
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
    //    [weibo LogOut];
    UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelBtnAction:)];
    self.navigationItem.leftBarButtonItem = cancelBtn;
    if ([self.weibo isUserLoggedin]) {
        //        [weibo LogOut];
        if (isOnlyLogin) {
            UIAlertView *alertV = [[UIAlertView alloc] initWithTitle:@"" message:@"您已经登录了" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alertV show];
        }else{
            PostWeiboViewController *vc = [[PostWeiboViewController alloc] initWithNibName:@"PostWeiboViewController" bundle:nil];
            //vc.baseinfo = baseinfo;
            vc.partyObj = self.partyObj;
            [self.navigationController pushViewController:vc animated:NO];
        }
    }else{
        childView = [[WeiBoLoginWebView alloc] initWithFrame:CGRectMake(0, 0, 320, 440)];
        [childView setDelegate:self];
        [self.view addSubview:childView];
        self.navigationItem.title = @"登录微博";
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showLoginPage:) name:@"testNotification" object:nil];
        [self WeiboLogin];
    }
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

- (void)cancelBtnAction:(id)sender{
    [self dismissModalViewControllerAnimated:YES];
}

- (void)showLoginPage:(NSNotification *)notification{
    NSString *urlStr = [[notification userInfo] objectForKey:@"url"];
    NSURL *url = [NSURL URLWithString:urlStr];
    [self.childView loadRequest:[NSURLRequest requestWithURL:url]];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if ([[[request URL] scheme] isEqualToString:[weibo urlSchemeString]]){
        
        NSString *queryStr = [[request URL] query];
        NSString *verifier = [queryStr substringFromIndex:(queryStr.length-6)];
        NSNotification *notification = [NSNotification notificationWithName:@"testNotification1" object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:verifier,@"verifier", nil]];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
        return NO;
    }
    return YES;
}

#pragma weibo delegate

- (void)WeiboLogin
{
	[weibo startAuthorize];
}

- (void)weiboDidLogin
{
	if (isOnlyLogin) {
        UIAlertView *alertV = [[UIAlertView alloc] initWithTitle:@"" message:@"用户验证成功" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
        alertV.delegate = self;
        [alertV show];
        
    }else{
        PostWeiboViewController *vc = [[PostWeiboViewController alloc] initWithNibName:@"PostWeiboViewController" bundle:nil];
       // vc.baseinfo = baseinfo;
        vc.partyObj = vc.partyObj;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)weiboLoginFailed:(BOOL)userCancelled withError:(NSError*)error
{
    if (!userCancelled) {
        UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:nil
                                                           message:@"用户验证失败，请重试" 
                                                          delegate:nil
                                                 cancelButtonTitle:@"确定" 
                                                 otherButtonTitles:nil];
        [alertView show];
    }
	
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    [self.navigationController dismissModalViewControllerAnimated:YES];
    if ([delegate respondsToSelector:@selector(WeiboDidLoginSuccess)]) 
    {
        [delegate WeiboDidLoginSuccess];
    }
}

@end
