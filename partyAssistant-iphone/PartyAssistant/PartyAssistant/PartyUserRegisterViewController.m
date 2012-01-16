//
//  PartyUserRegisterViewController.m
//  PartyTest
//
//  Created by Wang Jun on 11/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DataManager.h"
#import "PartyUserRegisterViewController.h"
#import "PartyLoginViewController.h"
#import "UserInfoValidator.h"

#define NullTextFieldTag            100
#define UserNameTextFieldTag        101
#define PwdTextFieldTag             102
#define PwdCheckTextFieldTag        103


#define NotLegalTag                         1
#define NotPassTag                          2
#define SuccessfulTag                       3
#define InvalidateNetwork                   4
#define PasswordAndPasswordCheckNotEqual    5

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
- (void)showRegistSuccessfulAlert;
- (void)showInvalidateNetworkalert;

@end

@implementation PartyUserRegisterViewController
@synthesize tableView = _tableView;
@synthesize userNameCell = _userNameCell;
@synthesize pwdCell = _pwdCell;


@synthesize userNameTextField = _userNameTextField;
@synthesize pwdTextField = _pwdTextField;

@synthesize delegate;
- (void)dealloc {
    [super dealloc];
    
    [_tableView release];
    
    [_userNameCell release];
    [_pwdCell release];
 
    
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
    
//    BOOL isOk = [self pwdEqualToPwdCheck];
//    
//    if (!isOk) {
//        [self showAlertWithMessage:@"密码和确认密码内容不一致！" buttonTitle:@"好的" tag:NotLegalTag];
//        return;
//    }
    
    UserInfoValidator *validator = [UserInfoValidator sharedUserInfoValidator];
    ValidatorResultCode result = [validator validateUsername:self.userNameTextField.text];
    if (result != ValidatorResultPass) {
        NSString *errorMessge = [validator getUsernameErrorMessageByCode:result];
        [self showAlertWithMessage:errorMessge buttonTitle:@"好的" tag:NotLegalTag];
        return;
    }
    
    result = [validator validatePassword:self.pwdTextField.text];
    if (result != ValidatorResultPass) {
        NSString *errorMessge = [validator getPasswordErrorMessageByCode:result];
        [self showAlertWithMessage:errorMessge buttonTitle:@"好的" tag:NotLegalTag];
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
    }     
    return NullTextFieldTag;
}

- (void)showAlertWithMessage:(NSString *)message 
                 buttonTitle:(NSString *)buttonTitle 
                         tag:(int)tagNum{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:message delegate:self cancelButtonTitle:@"好的" otherButtonTitles:nil];
    alert.tag = tagNum;
    [alert show];
    [alert release];
}

- (void)showInvalidateNetworkalert {
    [self showAlertWithMessage:@"无法连接网络，请检查网络状态！" 
                   buttonTitle:@"好的" 
                           tag:InvalidateNetwork];
}

- (void)showRegistSuccessfulAlert {
    [self showAlertWithMessage:@"注册成功！" buttonTitle:@"好的" tag:SuccessfulTag];
}
- (IBAction)autoLogin{
    [delegate autoLogin];
    
}
- (void)showNotLegalInput {
    [self showAlertWithMessage:@"注册内容不能为空！" buttonTitle:@"好的" tag:NotLegalTag];
}
- (void)showNotPassChekAlert {
    [self showAlertWithMessage:@"无法完成注册！" buttonTitle:@"好的" tag:NotPassTag];
}

//- (BOOL)pwdEqualToPwdCheck {
//    if ([_pwdTextField.text isEqualToString:_pwdCheckTextField.text]) {
//        return YES;
//    }
//    return NO;
//}

- (void)tryConnectToServer {
    //TODO:register check method!
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjects:
                                                [NSArray arrayWithObjects:
                                                    self.userNameTextField.text, 
                                                    self.pwdTextField.text,
                                                    nil
                                                ] 
                                                         
                                                         forKeys:
                                                [NSArray arrayWithObjects:
                                                    @"username",
                                                    @"password",
                                                    nil
                                                ]
                              ];
    
//    NetworkConnectionStatus networkStatus= [[DataManager sharedDataManager]
//                                            registerUserWithUsrInfo:userInfo];
    NSString *statusDescription = nil;
    statusDescription = [[DataManager sharedDataManager]
                                    registerUserWithUsrInfo:userInfo];;
    [_HUD hide:YES];
    
    if (statusDescription) {
        [self showAlertWithMessage:statusDescription buttonTitle:@"确定" tag:NotLegalTag];
    } else {
        [self showRegistSuccessfulAlert];
    }
    //may need to creat some other connection status
//    switch (networkStatus) {
//        case NetworkConnectionInvalidate:
//            [self showInvalidateNetworkalert];
//            break;
//        case NetWorkConnectionCheckPass:
//            [self showRegistSuccessfulAlert];
//            break;
//        default:
//            [self showNotPassChekAlert];
//            break;
//    }
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
        return _userNameCell;
    } else if (indexPath.row == 1) {
        return _pwdCell;
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
       //[self.navigationController popViewControllerAnimated:YES];
        [delegate  autoLogin];
        
         
    } else {
       
    }
}
@end
