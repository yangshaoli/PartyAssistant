//
//  PartyLoginViewController.m
//  PartyTest
//
//  Created by Wang Jun on 11/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DataManager.h"
#import "GlossyButton.h"
#import "PartyLoginViewController.h"
#import "PartyUserRegisterViewController.h"

#define NotLegalTag 1
#define NotPassTag  2

@interface PartyLoginViewController()

- (void)cleanKeyBoard;
- (void)showAlertWithMessage:(NSString *)message  buttonTitle:(NSString *)buttonTitle 
                         tag:(int)tagNum;
- (void)showNotLegalInput;
- (void)showNotPassChekAlert;
- (void)registerUser;

@end

@implementation PartyLoginViewController
@synthesize tableView = _tableView;
@synthesize loginButton = _loginButton;
@synthesize userNameTableCell = _userNameTableCell;
@synthesize pwdTableCell = _pwdTableCell;
@synthesize userNameTextField = _userNameTextField;
@synthesize pwdTextField = _pwdTextField;
@synthesize modal = _modal;
@synthesize parentVC = _parentVC;

- (void)dealloc {
    [super dealloc];
    
    [_tableView release];
    
    [_loginButton release];
    
    [_userNameTableCell release];
    [_pwdTableCell release];
    
    [_userNameTextField release];
    [_pwdTextField release];
}

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
    CGSize windowSize = self.view.bounds.size;
    UIView *tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, windowSize.width, 100)];
    
    _loginButton = [[GlossyButton alloc] initWithFrame:CGRectMake(0, 0, windowSize.width - 16, 50)];
    _loginButton.center = CGPointMake(windowSize.width / 2, tableFooterView.bounds.size.height / 2 - 20);
    _loginButton.hue = 0.4f;
    _loginButton.brightness = 0.6f;
    _loginButton.saturation = 0.2f;
    _loginButton.titleLabel.font = [UIFont boldSystemFontOfSize:18.0f];
    [_loginButton setTitle:@"登录" forState:UIControlStateNormal];
    //[_loginButton addTarget:self action:@selector(loginCheck) forControlEvents:UIControlEventTouchUpInside];
    
    [tableFooterView addSubview:_loginButton];
    [_tableView setTableFooterView:tableFooterView];
    
    _tableView.scrollEnabled = NO;

    self.navigationItem.title = @"登录";
    
    UIBarButtonItem *registerButton = [[UIBarButtonItem alloc] initWithTitle:@"注册" style:UIBarButtonItemStylePlain target:self action:@selector(registerUser)];
    
    self.navigationItem.rightBarButtonItem = registerButton;
    [registerButton release];
    
    [tableFooterView release];
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

- (void)loginCheck {
    //check usrname and pwd is not nil and legal( length > 3?)
    if (!_userNameTextField.text || [_userNameTextField.text isEqualToString:@""]
        || !_pwdTextField.text || [_pwdTextField.text isEqualToString:@""]) {
        [self showNotLegalInput];
        return;
    }

    [self cleanKeyBoard];

    _HUD = [[MBProgressHUD alloc] initWithView:self.view];
	[self.navigationController.view addSubview:_HUD];
	
    _HUD.labelText = @"Loading";
    
    _HUD.delegate = self;
    
    [_HUD showWhileExecuting:@selector(tryConnectToServer) onTarget:self withObject:nil animated:YES];
         
}

- (void)tryConnectToServer {
    //TODO:login check method!
    NetworkConnectionStatus networkStatus= [[DataManager sharedDataManager]
                                            validateCheckWithUsrName:@""  pwd:@""];
    [_HUD hide:YES];
    switch (networkStatus) {
        case NetworkConnectionInvalidate:
            [self showNotPassChekAlert];
            break;
        case NetWorkConnectionCheckPass:
            
            break;
        default:
            
            break;
    }
    BOOL result = NO;
    if (result) {
       //use different work flow
        
        //1.modal
        
        //2.nav 
    } else {
        [self showNotPassChekAlert];
    }
    
}

- (void)cleanKeyBoard {
    if ([_userNameTextField isFirstResponder]) {
        [_userNameTextField resignFirstResponder];
    } else {
        [_pwdTextField resignFirstResponder];
    }
}

- (void)showAlertWithMessage:(NSString *)message  buttonTitle:(NSString *)buttonTitle tag:(int)tagNum{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    alert.tag = tagNum;
    [alert show];
    [alert release];
}

- (void)showNotLegalInput {
    [self showAlertWithMessage:@"something" buttonTitle:@"OK" tag:NotLegalTag];
}

- (void)showNotPassChekAlert {
    [self showAlertWithMessage:@"something" buttonTitle:@"OK" tag:NotPassTag];
}

- (void)registerUser {
    //TODO: got register view
    PartyUserRegisterViewController *registerVC = [[PartyUserRegisterViewController alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:registerVC animated:YES];
    [registerVC release];
}

#pragma mark -
#pragma tableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView 
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.row == 0) {
        return _userNameTableCell;
    } else if (indexPath.row == 1) {
        return _pwdTableCell;
    } 
    return nil;
}

- (NSIndexPath *)tableView:(UITableView *)tableView
  willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

#pragma mark -
#pragma mark MBProgress_HUDDelegate methods

- (void)HUDWasHidden:(MBProgressHUD *)hUD {
    // Remove _HUD from screen when the _HUD was hidded
    [_HUD removeFromSuperview];
    [_HUD release];
	_HUD = nil;
}

#pragma mark _
#pragma mark Alert Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
   if (alertView.tag == NotLegalTag) {
       if (!_userNameTextField.text || [_userNameTextField.text isEqualToString:@""]) {
           [_userNameTextField becomeFirstResponder];
       } else {
           [_pwdTextField becomeFirstResponder];
       }
   } else {
       [_userNameTextField becomeFirstResponder];
   }
}
@end