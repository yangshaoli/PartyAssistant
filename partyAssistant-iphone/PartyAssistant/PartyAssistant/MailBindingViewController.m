//
//  MailBindingViewController.m
//  PartyAssistant
//
//  Created by Wang Jun on 1/3/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "MailBindingViewController.h"
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

@interface MailBindingViewController ()

- (void)jumpToVerify;
- (void)beginMailUpdate;

@end

@implementation MailBindingViewController
@synthesize tableView = _tableView;
@synthesize inputMailCell = _inputMailCell;
@synthesize inputMailTextField = _inputMailTextField;
@synthesize mailBindingCell = _mailBindingCell;
@synthesize inSpecialProcess = _inSpecialProcess;

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
    [self.inputMailTextField becomeFirstResponder];
    BindingStatus mailStatus = [[UserInfoBindingStatusService sharedUserInfoBindingStatusService] mailBindingStatus];
    if (mailStatus == StatusNotBind) {
        self.navigationItem.title = @"邮箱绑定";
    } else if (mailStatus != StatusUnknown && mailStatus != StatusBinded) {
        self.navigationItem.title = @"重新输入邮箱";
        
        UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:UIBarButtonItemStyleDone target:self action:@selector(jumpToVerify)];
        
        self.navigationItem.leftBarButtonItem = closeButton;
    }
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
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return self.inputMailCell;
    } else if (indexPath.section == 1) {
        return self.mailBindingCell;
    } 
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 1) {
        // go to verify view
        [self beginMailUpdate];
    }
}

- (void)jumpToVerify {
    CATransition *transition = [CATransition animation];
    transition.duration = 0.5;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionMoveIn;
    transition.subtype = kCATransitionFromTop;
    [self.navigationController.view.layer addAnimation:transition forKey:nil];
    
    BindingStatus verifyPageStatus = [[UserInfoBindingStatusService sharedUserInfoBindingStatusService] detectMailBindingStatus];
    MailValidateViewController *verifyPage = [[MailValidateViewController alloc] initWithNibName:nil bundle:nil];
    //verifyPage.pageStatus = verifyPageStatus;
    verifyPage.pageStatus = StatusVerifyBinding;
    
    if (self.inSpecialProcess) {
        verifyPage.inSpecialProcess = YES;
    }
    
    self.inputMailTextField.text = @"";
    
    [self.navigationController pushViewController:verifyPage animated:NO];
}

- (void)beginMailUpdate {
    NSString *mailText = self.inputMailTextField.text;
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
    
    NSURL *url = [NSURL URLWithString:EMAIL_BIND];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    
    [request setPostValue:[NSNumber numberWithInteger:user.uID] forKey:@"uid"];
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
            BindingStatusObject *userStatus = [[UserInfoBindingStatusService sharedUserInfoBindingStatusService] getBindingStatusObject];
            userStatus.bindingMail = self.inputMailTextField.text;
            
            self.inputMailTextField.text = @"";
            
            [self saveProfileDataFromResult:result];
            
            UIAlertView *av=[[UIAlertView alloc] initWithTitle:@"提示" message:@"验证链接已经发送到您的邮箱中，请注意查收。" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定",nil];
            av.tag = 11001;
            [av show];

        } else if ([status isEqualToString:@"error_has_binded_by_self"]) {
            [self saveProfileDataFromResult:result];
            
            [self.navigationController popViewControllerAnimated:YES];
        } else if ([status isEqualToString:@"error_has_binded"]) {
            [self saveProfileDataFromResult:result];
            
            // handle if binded mail equals to mail address in inputTelTextField
            // if so, pop to settings view directly with no alert.
            BindingStatus mailBindStatus = [[UserInfoBindingStatusService 
                                            sharedUserInfoBindingStatusService] mailBindingStatus];
            if (mailBindStatus == StatusBinded) {
                BindingStatusObject *userStatus = [[UserInfoBindingStatusService sharedUserInfoBindingStatusService] getBindingStatusObject];
                NSString *bindedMail = userStatus.bindedMail;
                
                if (bindedMail && [bindedMail length] > 0 && self.inputMailTextField.text) {
                    if ([bindedMail isEqualToString:self.inputMailTextField.text]) {
                        [self.navigationController popViewControllerAnimated:YES];
                        return;
                    }
                }
            }

            [self showBindOperationFailed:description];
        } else if ([status isEqualToString:@"error_different_binded"]) {
            [self saveProfileDataFromResult:result];
            
            [self showBindOperationFailed:description];
        } else {
            [self saveProfileDataFromResult:result];
            
            [self showBindOperationFailed:description];	
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

#pragma mark - 
#pragma mark alert delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 11001) {
        [self jumpToVerify];
        
        UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:UIBarButtonItemStyleDone target:self action:@selector(jumpToVerify)];
        
        self.navigationItem.leftBarButtonItem = closeButton;
    }
    if (alertView.tag == 11112) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    if (alertView.tag == 11116) {
        self.inputMailTextField.text = @"";
        
        [self.inputMailTextField becomeFirstResponder];
    }
}
@end
