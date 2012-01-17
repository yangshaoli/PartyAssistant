//
//  TelValidateViewController.m
//  PartyAssistant
//
//  Created by Wang Jun on 1/3/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "TelValidateViewController.h"
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

#import "BindingListViewController.h"

@interface TelValidateViewController ()

- (void)resendPhoneVerifyCode;
- (void)sendPhoneVerify;
- (void)closePage;
- (void)resendPage;

@end

@implementation TelValidateViewController
@synthesize tableView = _tableView;
@synthesize inputTelCell = _inputTelCell;
@synthesize inputCodeTextField = _inputCodeTextField;
@synthesize telValidateCell = _telValidateCell;
@synthesize telResendValidateCell = _telResendValidateCell;
@synthesize pageStatus = _pageStatus;
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
    
    if (self.pageStatus == StatusVerifyBinding) {
        self.navigationItem.title = @"绑定验证";
        UIBarButtonItem *resendBtn = [[UIBarButtonItem alloc] initWithTitle:@"更换号码" style:UIBarButtonItemStyleBordered target:self action:@selector(resendPage)];
        self.navigationItem.rightBarButtonItem = resendBtn;
    } else if (self.pageStatus == StatusVerifyUnbinding){
        self.navigationItem.title = @"解绑验证";
    } else {
        self.navigationItem.title = @"未知错误状态";
    }
    
    UIBarButtonItem *closeBtn = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:UIBarButtonItemStyleBordered target:self action:@selector(closePage)];
    self.navigationItem.leftBarButtonItem = closeBtn;
    
    

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
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section==0) {
        NSString *title = @"手机号：";
        if (self.pageStatus == StatusVerifyBinding) {
            return [NSString stringWithFormat:@"%@%@",title,[[UserInfoBindingStatusService sharedUserInfoBindingStatusService] bindingTel]];
        } else if (self.pageStatus == StatusVerifyUnbinding) {
            return [NSString stringWithFormat:@"%@%@",title,[[UserInfoBindingStatusService sharedUserInfoBindingStatusService] bindedTel]];
        }
    }
    return @"";
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.pageStatus == StatusVerifyBinding || self.pageStatus == StatusVerifyUnbinding) {
        return 3;
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return self.inputTelCell;
    } else if (indexPath.section ==1) {
        return self.telValidateCell;
    } else if (indexPath.section == 2) {
        return self.telResendValidateCell;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 1) {
        [self sendPhoneVerify];
    } else if (indexPath.section == 2) {
        [self resendPhoneVerifyCode];
    }
}

- (void)resendPhoneVerifyCode {
    NSString *telText;
    if (self.pageStatus == StatusVerifyBinding) {
        telText = [[UserInfoBindingStatusService sharedUserInfoBindingStatusService] bindingTel];
    } else {
        telText = [[UserInfoBindingStatusService sharedUserInfoBindingStatusService] bindedTel];
    }
    
    if (!telText) {
        return;
    }
    
    //mail validate check
    BOOL isValid = [self validatePhoneCheck:telText];
    if (isValid) {
        
    } else {
        return;
    }
    
    UserObject *user = [[UserObjectService sharedUserObjectService] getUserObject];
    
    if (user.uID == -1) {
        return;
    }
    
    NSURL *url = nil;
    
    if (self.pageStatus == StatusVerifyBinding) {
        url = [NSURL URLWithString:PHONE_BIND];
    } else {
        url = [NSURL URLWithString:PHONE_UNBIND];
    }
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    
    [request setPostValue:[NSNumber numberWithInteger:user.uID] forKey:@"uid"];
    [request setPostValue:telText forKey:@"value"];
    [request setPostValue:@"phone" forKey:@"phone"];
    
    request.timeOutSeconds = 15;
    [request setDelegate:self];
    [request setDidFinishSelector:@selector(resendVerifycodeRequestRequestFinished:)];
    [request setDidFailSelector:@selector(resendVerifycodeRequestRequestFailed:)];
    
    [request setShouldAttemptPersistentConnection:NO];
    [request startAsynchronous];  
    
    [self showWaiting];
}

- (void)resendVerifycodeRequestRequestFinished:(ASIHTTPRequest *)request {
    [self dismissWaiting];
	NSString *response = [request responseString];
	SBJsonParser *parser = [[SBJsonParser alloc] init];
	NSDictionary *result = [parser objectWithString:response];
    NSString *status = [result objectForKey:@"status"];
	NSString *description = [result objectForKey:@"description"];
    if ([request responseStatusCode] == 200) {
        if ([status isEqualToString:@"ok"]) {
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"提示" message:@"验证码已经发送到您的手机中，请注意查收" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
            av.tag = 11114;
            [av show];
            
            [self saveProfileDataFromResult:result];
        } else {
            if (self.pageStatus == StatusVerifyBinding) {
                if ([status isEqualToString:@"error_has_binded"]) {
                    [self saveProfileDataFromResult:result];
                    
                    [self showBindOperationFailed:description];
                } else if ([status isEqualToString:@"error_different_binded"]) {
                    [self saveProfileDataFromResult:result];
                    
                    [self showBindOperationFailed:description];
                }  else {
                    [self saveProfileDataFromResult:result];
                    
                    [self showBindOperationFailed:description];
                }
            } else if (self.pageStatus == StatusVerifyUnbinding) {
                if ([status isEqualToString:@"error_different_unbinded"]) {
                    [self saveProfileDataFromResult:result];
                    
                    [self showBindOperationFailed:description];
                } else {
                    [self saveProfileDataFromResult:result];
                    
                    [self showBindOperationFailed:description];
                }
            }
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

- (void)resendVerifycodeRequestRequestFailed:(ASIFormDataRequest *)request {
    [self dismissWaiting];
	NSError *error = [request error];
	[self showAlertRequestFailed: error.localizedDescription];
}

- (void)sendPhoneVerify {
    NSString *telText = nil;
    
    if (self.pageStatus == StatusVerifyBinding) {
        telText = [[UserInfoBindingStatusService sharedUserInfoBindingStatusService] bindingTel];
    } else {
        telText = [[UserInfoBindingStatusService sharedUserInfoBindingStatusService] bindedTel];
    }

    if (!telText) {
        return;
    }
    
    //mail validate check
    BOOL isValid = [self validatePhoneCheck:telText];
    if (isValid) {
        
    } else {
        return;
    }
    
    UserObject *user = [[UserObjectService sharedUserObjectService] getUserObject];
    
    if (user.uID == -1) {
        return;
    }
    
    NSURL *url = [NSURL URLWithString:PHONE_VERIFY];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    
    [request setPostValue:[NSNumber numberWithInteger:user.uID] forKey:@"uid"];
    [request setPostValue:telText forKey:@"value"];
    [request setPostValue:@"phone" forKey:@"type"];
    [request setPostValue:self.inputCodeTextField.text forKey:@"verifier"];
    
    request.timeOutSeconds = 15;
    [request setDelegate:self];
    [request setDidFinishSelector:@selector(sendPhoneVerifyRequestFinished:)];
    [request setDidFailSelector:@selector(sendPhoneVerifyRequestFailed:)];
    
    [request setShouldAttemptPersistentConnection:NO];
    [request startAsynchronous];  
    
    [self showWaiting];
}

- (void)sendPhoneVerifyRequestFinished:(ASIHTTPRequest *)request{
    [self dismissWaiting];
	NSString *response = [request responseString];
	SBJsonParser *parser = [[SBJsonParser alloc] init];
	NSDictionary *result = [parser objectWithString:response];
    NSString *status = [result objectForKey:@"status"];
	NSString *description = [result objectForKey:@"description"];
    if ([request responseStatusCode] == 200) {
        if ([status isEqualToString:@"ok"]) {
            [self saveProfileDataFromResult:result];
            
            UIAlertView *av=[[UIAlertView alloc] initWithTitle:@"提示" message:@"验证成功！" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定",nil];
            av.tag = 11113;
            [av show];
        } else if ([status isEqualToString:@"error_has_binded_by_other"]) {
            [self saveProfileDataFromResult:result];
            
            [self showNormalErrorInfo:description];
        } else if ([status isEqualToString:@"error_invalid_verifier"]) {
            [self saveProfileDataFromResult:result];
            
            [self showNormalErrorInfo:description];
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

- (void)sendPhoneVerifyRequestFailed:(ASIHTTPRequest *)request
{
    [self dismissWaiting];
	NSError *error = [request error];
	[self showAlertRequestFailed: error.localizedDescription];
}

- (void)closePage {
    if (self.inSpecialProcess) {
        [self resendPage];
    } else {
        NSArray *controllers = self.navigationController.viewControllers;
        BindingListViewController *bindingList = nil;
        for (UIViewController *controller in controllers) {
            if ([controller isMemberOfClass:[BindingListViewController class]]) {
                bindingList = (BindingListViewController *)controller;
            }
        }
        if (bindingList) {
            CATransition *transition = [CATransition animation];
            transition.duration = 0.5;
            transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            transition.type = kCATransitionReveal;
            transition.subtype = kCATransitionFromBottom;
            [self.navigationController.view.layer addAnimation:transition forKey:nil];
            [self.navigationController popToViewController:bindingList animated:NO];
        }
    }
}

- (void)resendPage {
    CATransition *transition = [CATransition animation];
    transition.duration = 0.5;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionReveal;
    transition.subtype = kCATransitionFromBottom;
    [self.navigationController.view.layer addAnimation:transition forKey:nil];
    [self.navigationController popViewControllerAnimated:NO];
}

#pragma mark - 
#pragma mark alert delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 11112) {
        [self closePage];
    }
    if (alertView.tag == 11113) {
        [self closePage];
    }
    if (alertView.tag == 11114) {
        self.inputCodeTextField.text = nil;
        [self.inputCodeTextField becomeFirstResponder];
    }
    if (alertView.tag == 11116) {
        self.inputCodeTextField.text = nil;
        [self.inputCodeTextField becomeFirstResponder];

    }
}
@end
