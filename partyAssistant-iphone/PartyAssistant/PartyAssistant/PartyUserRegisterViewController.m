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
#define UserNameTextFieldTag        101
#define PwdTextFieldTag             102
#define PwdCheckTextFieldTag        103
#define NickNameTextFieldTag        104

#define NotLegalTag                 1
#define NotPassTag                  2
#define SuccessfulTag               3
#define InvalidateNetwork           4

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
- (void)showRegistSuccessfulAlert;
- (void)showInvalidateNetworkalert;

@end

@implementation PartyUserRegisterViewController
@synthesize tableView = _tableView;
@synthesize userNameCell = _userNameCell;
@synthesize pwdCell = _pwdCell;
@synthesize pwdCheckCell = _pwdCheckCell;
@synthesize nickNameCell = _nickNameCell;
@synthesize userNameTextField = _userNameTextField;
@synthesize pwdTextField = _pwdTextField;
@synthesize pwdCheckTextField = _pwdCheckTextField;
@synthesize nickNameTextField = _nickNameTextField;


- (void)dealloc {
    [super dealloc];
    
    [_tableView release];
    
    [_userNameCell release];
    [_pwdCell release];
    [_pwdCheckCell release];
    [_nickNameCell release];
    
    [_userNameTextField release];
    [_pwdTextField release];
    [_pwdCheckTextField release];
    [_nickNameTextField release];
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
    
    UIToolbar *toolbar = [[[UIToolbar alloc] init] autorelease];
    [toolbar setBarStyle:UIBarStyleBlackTranslucent];
    [toolbar sizeToFit];
    
    UIBarButtonItem *flexButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem *doneButton =[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(resignKeyboard)];
    
    NSArray *itemsArray = [NSArray arrayWithObjects:flexButton, doneButton, nil];
    
    [flexButton release];
    [doneButton release];
    [toolbar setItems:itemsArray];
    
    [_userNameTextField setInputAccessoryView:toolbar];
    
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

-(void)resignKeyboard {
    [_userNameTextField resignFirstResponder];
}

- (void)cleanKeyBoard {
    if ([_userNameTextField isFirstResponder]) {
        [_userNameTextField resignFirstResponder];
    } else if ([_pwdTextField isFirstResponder]) {
        [_pwdTextField resignFirstResponder];
    } else if ([_pwdCheckTextField isFirstResponder]) {
        [_pwdCheckTextField resignFirstResponder];
    } else {
        [_nickNameTextField resignFirstResponder];
    }
}

- (BOOL)inputFieldNonTextCheck {
    NSInteger textFieldTag = [self getInputFieldNonTextTag];
    if (textFieldTag == NullTextFieldTag) {
        return YES;
    } else {
        switch (textFieldTag) {
            case UserNameTextFieldTag:
                _userNameTextField.text = @"";
                break;
            case PwdTextFieldTag:
                _pwdTextField.text = @"";
                break;
            case PwdCheckTextFieldTag:
                _pwdCheckTextField.text = @"";
                break;
            case NickNameTextFieldTag:
                _nickNameTextField.text = @"";
                break;
        }
        [self showNotLegalInput];
        return NO;
    }
}

- (NSInteger)getInputFieldNonTextTag {
    if (!_userNameTextField.text || [_userNameTextField.text isEqualToString:@""]) {
        return UserNameTextFieldTag;
    } else if (!_pwdTextField.text || [_pwdTextField.text isEqualToString:@""]) {
        return PwdTextFieldTag;
    } else if (!_pwdCheckTextField.text || [_pwdCheckTextField.text isEqualToString:@""]) {
        return PwdCheckTextFieldTag;
    } 
//    else if (!_nickNameTextField.text || [_nickNameTextField.text isEqualToString:@""]) {
//        return NickNameTextFieldTag;
//    }
    
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

- (void)showInvalidateNetworkalert {
    [self showAlertWithMessage:@"无法连接网络，请检查网络状态！" 
                   buttonTitle:@"OK" 
                           tag:InvalidateNetwork];
}

- (void)showRegistSuccessfulAlert {
    [self showAlertWithMessage:@"注册成功！" buttonTitle:@"OK" tag:SuccessfulTag];
}

- (void)showNotLegalInput {
    [self showAlertWithMessage:@"注册内容不能为空！" buttonTitle:@"OK" tag:NotLegalTag];
}

- (void)showNotPassChekAlert {
    [self showAlertWithMessage:@"无法完成注册！" buttonTitle:@"OK" tag:NotPassTag];
}

- (BOOL)pwdEqualToPwdCheck {
    if ([_pwdTextField.text isEqualToString:_pwdCheckTextField.text]) {
        return YES;
    }
    return NO;
}

- (void)tryConnectToServer {
    //TODO:register check method!
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjects:
                                                [NSArray arrayWithObjects:
                                                    self.userNameTextField.text, 
                                                    self.pwdTextField.text,
                                                    //self.nickNameTextField.text,
                                                    nil
                                                ] 
                                                         
                                                         forKeys:
                                                [NSArray arrayWithObjects:
                                                    @"username",
                                                    @"password",
                                                    //@"nickname",
                                                    nil
                                                ]
                              ];
    
    NetworkConnectionStatus networkStatus= [[DataManager sharedDataManager]
                                            registerUserWithUsrInfo:userInfo];
    [_HUD hide:YES];
    //may need to creat some other connection status
    switch (networkStatus) {
        case NetworkConnectionInvalidate:
            [self showNotPassChekAlert];
            break;
        case NetWorkConnectionCheckPass:
            [self showRegistSuccessfulAlert];
            break;
        default:
            [self showNotPassChekAlert];
            break;
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
        return _userNameCell;
    } else if (indexPath.row == 1) {
        return _pwdCell;
    } else if (indexPath.row == 2) {
        return _pwdCheckCell;
    } else if (indexPath.row == 3) {
        return _nickNameCell;
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

#pragma mark _
#pragma mark Alert Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == SuccessfulTag) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
       
    }
}
@end
