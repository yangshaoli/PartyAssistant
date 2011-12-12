//
//  PartyUserNameInputViewController.m
//  PartyAssistant
//
//  Created by Wang Jun on 11/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DataManager.h"
#import "PartyUserNameInputViewController.h"

#define NotLegalTag         1
#define NotPassTag          2

@interface PartyUserNameInputViewController ()

- (void)cleanKeyBoard;
- (void)showAlertWithMessage:(NSString *)message  
                 buttonTitle:(NSString *)buttonTitle 
                         tag:(int)tagNum;
- (void)showNotLegalInput;
- (void)showNotPassChekAlert;

@end

@implementation PartyUserNameInputViewController
@synthesize tableView = _tableView;
@synthesize userNameTableCell = _userNameTableCell;
@synthesize userNameTextField = _userNameTextField;
//wxz
@synthesize emailInfoTableCell = _emailInfoTableCell;
@synthesize emailInfoTextField = _emailInfoTextField;

@synthesize delegate;

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
    }
    if (indexPath.row == 1) {
        return _emailInfoTableCell;
    }
    return nil;
}

- (NSIndexPath *)tableView:(UITableView *)tableView
  willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

#pragma mark -
#pragma custom method
- (IBAction)cancleInput {
    [delegate cancleInput];
}

- (IBAction)SaveInput {
    //check username textField
    BOOL isEmpty = (!_userNameTextField.text 
                    || [_userNameTextField.text isEqualToString:@""]);
        
    //wxz
    BOOL isEmailEmpty = (!_emailInfoTextField.text 
                    || [_emailInfoTextField.text isEqualToString:@""]);
    
    if (isEmailEmpty || isEmpty) {
        [self showNotLegalInput];
        return;
    }
    
    [self cleanKeyBoard];
    [delegate saveInputDidBegin];
    NetworkConnectionStatus status = [[DataManager sharedDataManager] 
                                       setNickName:_userNameTextField.text];
    NetworkConnectionStatus emailStatus = [[DataManager sharedDataManager] setEmailInfo:_emailInfoTextField.text];
    if (status == NetWorkConnectionCheckPass && emailStatus == NetWorkConnectionCheckPass) {
        [delegate saveInputFinished];
    } else {
        [self showNotPassChekAlert];
        [delegate saveInputFailed];
    }
}

- (void)cleanKeyBoard {
    if ([_userNameTextField isFirstResponder]) {
        [_userNameTextField resignFirstResponder];
    } 
    if([_emailInfoTextField isFirstResponder]){
        [_emailInfoTextField resignFirstResponder];
    }
}

- (void)showAlertWithMessage:(NSString *)message  
                 buttonTitle:(NSString *)buttonTitle 
                         tag:(int)tagNum{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    alert.tag = tagNum;
    [alert show];
}

- (void)showNotLegalInput {
    [self showAlertWithMessage:@"登陆内容不能为空！" buttonTitle:@"OK" tag:NotLegalTag];
}

- (void)showNotPassChekAlert {
    [self showAlertWithMessage:@"操作失败" buttonTitle:@"OK" tag:NotPassTag];
}
@end
