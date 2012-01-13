//
//  MailUnbindingViewController.m
//  PartyAssistant
//
//  Created by Wang Jun on 1/3/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "MailUnbindingViewController.h"
#import "MailValidateViewController.h"
//net work use
#import "URLSettings.h"
#import "ASIFormDataRequest.h"
#import "SBJsonParser.h"
#import "UserObjectService.h"
#import "UserObject.h"
#import "UIViewControllerExtra.h"
#import "HTTPRequestErrorMSG.h"
#import "UserInfoBindingStatusService.h"
//bind extern
#import "UIVIewControllerExtern+Binding.h"

@interface MailUnbindingViewController ()

- (void)jumpToVerify;
- (void)beginMailUpdate;

@end

@implementation MailUnbindingViewController
@synthesize tableView = _tableView;
@synthesize inputMailCell = _inputMailCell;
@synthesize mailInfoTitleLabel = _mailInfoTitleLabel;
@synthesize mailUnBindingCell = _mailUnBindingCell;
@synthesize mailTextField = _mailTextField;

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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.mailTextField.text = [[UserInfoBindingStatusService sharedUserInfoBindingStatusService] bindedMail];
}
#pragma mark _
#pragma mark tableView delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return self.inputMailCell;
    } else if (indexPath.section == 1) {
        return self.mailUnBindingCell;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        // go to verify view
        MailValidateViewController *verifyPage = [[MailValidateViewController alloc] initWithNibName:nil bundle:nil];
        [self.navigationController presentModalViewController:verifyPage animated:YES];
    }
}

- (void)jumpToVerify {
    MailValidateViewController *verifyPage = [[MailValidateViewController alloc] initWithNibName:nil bundle:nil];
    [self.navigationController presentModalViewController:verifyPage animated:YES];
}

- (void)beginMailUpdate {
    NSString *mailText = [[UserInfoBindingStatusService sharedUserInfoBindingStatusService] bindedMail];
    if (!mailText) {
        return;
    }
    
    //mail validate check
    BOOL isValid = [self validateEmailCheck:mailText];
    if (isValid) {
        
    } else {
        return;
    }
    
    UserObject *user = [[UserObjectService sharedUserObjectService] getUserObject];
    
    if (user.uID == -1) {
        return;
    }
    
    NSURL *url = [NSURL URLWithString:EMAIL_UNBIND];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    
    [request setPostValue:[NSNumber numberWithInteger:user.uID] forKey:@"uID"];
    [request setPostValue:mailText forKey:@"value"];
    
    request.timeOutSeconds = 15;
    [request setDelegate:self];
    
    [request setShouldAttemptPersistentConnection:NO];
    [request startAsynchronous];  
    
    [self showWaiting];
}

- (void)requestFinished:(ASIHTTPRequest *)request{
    [self dismissWaiting];
	NSString *response = [request responseString];
	SBJsonParser *parser = [[SBJsonParser alloc] init];
	NSDictionary *result = [parser objectWithString:response];
    NSString *status = [result objectForKey:@"status"];
	NSString *description = [result objectForKey:@"description"];
    if ([request responseStatusCode] == 200) {
        if ([status isEqualToString:@"ok"]) {
            NSLog(@"dataSource :%@",[result objectForKey:@"datasource"]);
            [self jumpToVerify];
        } else {
            [self showAlertRequestFailed:description];	
        }
    }else if([request responseStatusCode] == 404){
        [self showAlertRequestFailed:REQUEST_ERROR_404];
    }else if([request responseStatusCode] == 500){
        [self showAlertRequestFailed:REQUEST_ERROR_500];
    }else if([request responseStatusCode] == 502){
        [self showAlertRequestFailed:REQUEST_ERROR_502];
    }else{
        [self showAlertRequestFailed:REQUEST_ERROR_504];
    }
	
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    [self dismissWaiting];
	NSError *error = [request error];
	[self showAlertRequestFailed: error.localizedDescription];
}
@end
