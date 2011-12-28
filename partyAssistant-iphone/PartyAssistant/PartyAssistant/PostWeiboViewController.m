//
//  PostWeiboViewController.m
//  PartyAssistant
//
//  Created by 超 李 on 11-11-29.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "PostWeiboViewController.h"
#import "WeiboSettings.h"

#define SEND_SUCCESS_ALERT_TAG 11

@implementation PostWeiboViewController
@synthesize sendV,baseinfo,partyObj;

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
    // Do any additional setup after loading the view from its nib.
    UIBarButtonItem *_sendWeiboButton = [[UIBarButtonItem alloc] initWithTitle:@"发送" style:UIBarButtonItemStyleDone target:self action:@selector(sendBtnTouched:)];
    self.navigationItem.rightBarButtonItem = _sendWeiboButton;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:UIBarButtonItemStylePlain target:self action:@selector(cancelBtnTouched:)];
    NSString *default_text = WEIBO_DEFAULT_CONTENT;
    //NSLog(@"baseinfo:%@",baseinfo);
    default_text = [default_text stringByReplacingOccurrencesOfString:@"party_id" withString:[partyObj.partyId stringValue]];
    self.sendV = [[WBSendView alloc] initWithWeiboText:default_text withImage:nil andDelegate:self];
    sendV.delegate = self;
    [self.view addSubview:sendV];
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

-(void)cancelBtnTouched:(id)sender
{
	[self.navigationController dismissModalViewControllerAnimated:YES];
}

-(void)sendBtnTouched:(id)sender
{
    [sendV sendBtnTouched];
}

#pragma mark WBRequest CALLBACK_API
- (void)request:(WBRequest *)request didFailWithError:(NSError *)error
{
    NSLog(@"error:%@",error);
    NSLog(@"request:%@",[request responseText]);
    //	if ([_delegate respondsToSelector:@selector(request:didFailWithError:)]) 
    //	{
    //		[_delegate request:request didFailWithError:error];
    //	}
    UIAlertView *alertV = [[UIAlertView alloc] initWithTitle:@"" message:@"发送失败，请重试" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [alertV show];
}


- (void)request:(WBRequest *)request didLoad:(id)result
{
    NSLog(@"request:%@",[request responseText]);
    NSLog(@"load:%@",result);
    //	if ([_delegate respondsToSelector:@selector(request:didLoad:)]) 
    //	{
    //		[_delegate request:request didLoad:result];
    //	}
    UIAlertView *alertV = [[UIAlertView alloc] initWithTitle:@"" message:@"发送成功" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
    alertV.tag = SEND_SUCCESS_ALERT_TAG;
    [alertV show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == SEND_SUCCESS_ALERT_TAG) {
        [self.navigationController dismissModalViewControllerAnimated:YES];
    }
}

@end
