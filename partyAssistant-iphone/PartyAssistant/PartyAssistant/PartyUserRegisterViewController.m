//
//  PartyUserRegisterViewController.m
//  PartyTest
//
//  Created by Wang Jun on 11/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DataManager.h"
#import "PartyUserRegisterViewController.h"

#define NullTextFieldTag            100
#define PhoneNumTextFieldTag        101
#define PwdTextFieldTag             102
#define PwdCheckTextFieldTag        103
#define EmailTextFieldTag           104

#define NotLegalTag                 1
#define NotPassTag                  2

@interface PartyUserRegisterViewController ()

- (void)registerUser;
- (void)cleanKeyBoard;
- (BOOL)inputFieldNonTextCheck;
- (NSInteger)getInputFieldNonTextTag;
- (void)showAlertWithMessage:(NSString *)message 
                 buttonTitle:(NSString *)buttonTitle 
                         tag:(int)tagNum;
- (NSInteger)getInputFieldNonTextTag;
- (void)showNotLegalInput;
- (BOOL)pwdEqualToPwdCheck;

@end

@implementation PartyUserRegisterViewController
@synthesize tableView = _tableView;
@synthesize phoneNumCell = _phoneNumCell;
@synthesize pwdCell = _pwdCell;
@synthesize pwdCheckCell = _pwdCheckCell;
@synthesize emailCell = _emailCell;
@synthesize phoneNumTextField = _phoneNumTextField;
@synthesize pwdTextField = _pwdTextField;
@synthesize pwdCheckTextField = _pwdCheckTextField;
@synthesize emailTextField = _emailTextField;


- (void)dealloc {
    [super dealloc];
    
    [_tableView release];
    
    [_phoneNumCell release];
    [_pwdCell release];
    [_pwdCheckCell release];
    [_emailCell release];
    
    [_phoneNumTextField release];
    [_pwdTextField release];
    [_pwdCheckTextField release];
    [_emailTextField release];
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
    UIBarButtonItem *registerButton = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(registerUser)];
    
    self.navigationItem.rightBarButtonItem = registerButton;
    [registerButton release];
    
    self.navigationItem.title = @"注册";
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

- (void)registerUser {
    //TO-DO
    //check usrname and pwd is not nil and legal( length > 3?)
        
    [self cleanKeyBoard];
    
    BOOL isOk = [self inputFieldNonTextCheck];
    
    if (!isOk) {
        return;
    }
    
    isOk = [self pwdEqualToPwdCheck];
    
    if (!isOk) {
        return;
    }
    
    //Still need other detail check: like email address check, phoneNumber check, etc.
    
    _HUD = [[MBProgressHUD alloc] initWithView:self.view];
	[self.navigationController.view addSubview:_HUD];
	
    _HUD.labelText = @"Loading";
    
    _HUD.delegate = self;
    
    [_HUD showWhileExecuting:@selector(tryConnectToServer) onTarget:self withObject:nil animated:YES];
}

- (void)cleanKeyBoard {
    if ([_phoneNumTextField isFirstResponder]) {
        [_phoneNumTextField resignFirstResponder];
    } else if ([_pwdTextField isFirstResponder]) {
        [_pwdTextField resignFirstResponder];
    } else if ([_pwdCheckTextField isFirstResponder]) {
        [_pwdCheckTextField resignFirstResponder];
    } else {
        [_emailTextField resignFirstResponder];
    }
}

- (BOOL)inputFieldNonTextCheck {
    NSInteger textFieldTag = [self getInputFieldNonTextTag];
    if (textFieldTag == NullTextFieldTag) {
        return YES;
    } else {
        NSString *textFieldName = nil;
        switch (textFieldTag) {
            case PhoneNumTextFieldTag:
                textFieldName = @"";
                break;
            case PwdTextFieldTag:
                textFieldName = @"";
                break;
            case PwdCheckTextFieldTag:
                textFieldName = @"";
                break;
            case EmailTextFieldTag:
                textFieldName = @"";
                break;
        }
        [self showNotLegalInput];
        return NO;
    }
}

- (NSInteger)getInputFieldNonTextTag {
    if (!_phoneNumTextField.text || [_phoneNumTextField.text isEqualToString:@""]) {
        return PhoneNumTextFieldTag;
    } else if (!_pwdTextField.text || [_pwdTextField.text isEqualToString:@""]) {
        return PwdTextFieldTag;
    } else if (!_pwdCheckTextField.text || [_pwdCheckTextField.text isEqualToString:@""]) {
        return PwdCheckTextFieldTag;
    } else if (!_emailTextField.text || [_emailTextField.text isEqualToString:@""]) {
        return EmailTextFieldTag;
    }
    
    return NullTextFieldTag;
}

- (void)showAlertWithMessage:(NSString *)message 
                 buttonTitle:(NSString *)buttonTitle 
                         tag:(int)tagNum{
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

- (BOOL)pwdEqualToPwdCheck {
    if ([_pwdTextField.text isEqualToString:_pwdCheckTextField.text]) {
        return YES;
    }
    return NO;
}

- (void)tryConnectToServer {
    //TODO:register check method!
    NetworkConnectionStatus networkStatus= [[DataManager sharedDataManager]
                                            registerUserWithUsrInfo:nil];
    [_HUD hide:YES];
    //may need to creat some other connection status
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
    } else {
        [self showNotPassChekAlert];
    }
    
}

#pragma mark -
#pragma tableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView 
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) {
        return _phoneNumCell;
    } else if (indexPath.row == 1) {
        return _pwdCell;
    } else if (indexPath.row == 2) {
        return _pwdCheckCell;
    } else if (indexPath.row == 3) {
        return _emailCell;
    }
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

@end
