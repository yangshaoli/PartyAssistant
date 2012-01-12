//
//  BindingListViewController.m
//  PartyAssistant
//
//  Created by Wang Jun on 1/3/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "BindingListViewController.h"
#import "UserInfoBindingStatusService.h"
//name
#import "NameBindingViewController.h"
//tel
#import "TelBindingViewController.h"
#import "TelUnbindingViewController.h"
#import "TelValidateViewController.h"
//mail
#import "MailBindingViewController.h"
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
//bind extern
#import "UIVIewControllerExtern+Binding.h"

@interface BindingListViewController ()

- (void)refreshCurrentStatus;
- (void)decideToOpenWhichTelBindingPage;
- (void)beginProfileUpdate;
- (void)decideToOpenWhichMailBindingPage;

@end

@implementation BindingListViewController
@synthesize tableView = _tableView;
@synthesize nameBindingCell = _nameBindingCell;
@synthesize telBindingCell = _telBindingCell;
@synthesize mailBindingCell = _mailBindingCell;
@synthesize nameBindingStatusLabel = _nameBindingStatusLabel;
@synthesize telBindingStatusLabel = _telBindingStatusLabel;
@synthesize mailBindingStatusLabel = _mailBindingStatusLabel;

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
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self refreshCurrentStatus];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"绑定";
    [self refreshCurrentStatus];
    
    UIBarButtonItem *refreshBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshBtnAction)];
    self.navigationItem.rightBarButtonItem = refreshBtn;
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

#pragma mark _
#pragma mark tableView delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0:
            return self.nameBindingCell;
            break;
        case 1:    
            return self.telBindingCell;
            break;
        case 2:
            return self.mailBindingCell;
            break;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        NameBindingViewController *nameBindingVC = [[NameBindingViewController alloc] initWithNibName:nil bundle:nil];
        [self.navigationController pushViewController:nameBindingVC animated:YES]; 
    } else if (indexPath.row == 1) {
        [self decideToOpenWhichTelBindingPage];
    } else if (indexPath.row == 2) {
        [self decideToOpenWhichMailBindingPage];
    }
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)refreshCurrentStatus {
    UserInfoBindingStatusService *storedStatusService = [UserInfoBindingStatusService sharedUserInfoBindingStatusService];
    self.nameBindingStatusLabel.text = [storedStatusService nickNameStatusString];
    self.telBindingStatusLabel.text = [storedStatusService telStatusString ];
    self.mailBindingStatusLabel.text = [storedStatusService mailStatusString];
}

- (void)decideToOpenWhichTelBindingPage {
    UserInfoBindingStatusService *storedStatusService = [UserInfoBindingStatusService sharedUserInfoBindingStatusService];
    BindingStatus telBindingStatus = [storedStatusService telBindingStatus];
    //1.goTo binding page
    //2.goTo UnBinding Page
    //3.goTo VerifyPage
    UIViewController *vc = nil;
    BindingStatus verifyPageStatus;
    switch (telBindingStatus) {
        case StatusNotBind:
            vc = [[TelBindingViewController alloc] initWithNibName:nil bundle:nil];
            [self.navigationController pushViewController:vc animated:YES];
            break;
        case StatusBinded :
            vc = [[TelUnbindingViewController alloc] initWithNibName:nil bundle:nil];
            [self.navigationController pushViewController:vc animated:YES];
            break;
        case StatusBinding:
            verifyPageStatus = [[UserInfoBindingStatusService sharedUserInfoBindingStatusService] detectTelBindingStatus];
            vc = [[TelValidateViewController alloc] initWithNibName:nil bundle:nil];
            [(TelValidateViewController *)vc setPageStatus:verifyPageStatus];
            [self.navigationController presentModalViewController:vc animated:YES];
            break;
        default:
            return;
            break;
    }
}

- (void)decideToOpenWhichMailBindingPage {
    UserInfoBindingStatusService *storedStatusService = [UserInfoBindingStatusService sharedUserInfoBindingStatusService];
    BindingStatus mailBindingStatus = [storedStatusService telBindingStatus];
    //1.goTo binding page
    //2.goTo UnBinding Page
    //3.goTo VerifyPage
    UIViewController *vc = nil;
    BindingStatus verifyPageStatus;
    switch (mailBindingStatus) {
        case StatusNotBind:
            vc = [[MailBindingViewController alloc] initWithNibName:nil bundle:nil];
            [self.navigationController pushViewController:vc animated:YES];
            break;
        case StatusBinded :
            vc = [[MailUnbindingViewController alloc] initWithNibName:nil bundle:nil];
            [self.navigationController pushViewController:vc animated:YES];
            break;
        case StatusBinding:
            verifyPageStatus = [[UserInfoBindingStatusService sharedUserInfoBindingStatusService] detectTelBindingStatus];
            vc = [[MailValidateViewController alloc] initWithNibName:nil bundle:nil];
            [(MailValidateViewController *)vc setPageStatus:verifyPageStatus];
            [self.navigationController presentModalViewController:vc animated:YES];
            break;
        default:
            return;
            break;
    }
}

- (void)refreshBtnAction {
    [self beginProfileUpdate];
}

- (void)beginProfileUpdate {
    UserObject *user = [[UserObjectService sharedUserObjectService] getUserObject];
    
    if (user.uID == -1) {
        return;
    }
    
    NSURL *url = [NSURL URLWithString:PROFILE_GET];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    
    [request setPostValue:[NSNumber numberWithInteger:user.uID] forKey:@"uid"];
    
    request.timeOutSeconds = 15;
    [request setDelegate:self];
    
    [request setShouldAttemptPersistentConnection:NO];
    [request startAsynchronous];  
    
    [self showWaiting];
}

- (void)requestFinished:(ASIHTTPRequest *)request{
    [self dismissWaiting];
	NSString *response = [request responseString];
    NSLog(@"response string:%@",response);
	SBJsonParser *parser = [[SBJsonParser alloc] init];
	NSDictionary *result = [parser objectWithString:response];
    NSString *status = [result objectForKey:@"status"];
	NSString *description = [result objectForKey:@"description"];
    if ([request responseStatusCode] == 200) {
        if ([status isEqualToString:@"ok"]) {
            NSLog(@"dataSource :%@",[result objectForKey:@"datasource"]);
            [self saveProfileDataFromResult:result];
            [self.tableView reloadData];
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
