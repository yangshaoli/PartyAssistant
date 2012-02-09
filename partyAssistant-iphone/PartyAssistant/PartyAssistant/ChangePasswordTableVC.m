//
//  ChangePasswordTableVC.m
//  PartyAssistant
//
//  Created by user on 12-1-13.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "ChangePasswordTableVC.h"
#import "UIViewControllerExtra.h"
#import "ASIFormDataRequest.h"
#import "JSON.h"
#import "HTTPRequestErrorMSG.h"
#import "URLSettings.h"
#import "UserObject.h"
#import "UserObjectService.h"
#import "DataManager.h"
#import "Reachability.h"

@implementation ChangePasswordTableVC
@synthesize originPasswordTextField;
@synthesize nPasswordTextField;
@synthesize resurePasswordTextField;
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
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
    UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStyleDone target:self action:@selector(doneBtnAction)];
    self.navigationItem.rightBarButtonItem = doneBtn;
    self.title=@"修改密码";

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
        if(indexPath.row==0){
            cell.textLabel.text = @"输入原密码：";
            if (!originPasswordTextField) {
                self.originPasswordTextField = [[UITextField alloc] initWithFrame:CGRectMake(110, 10, 200, 44)];
                [self. originPasswordTextField becomeFirstResponder];
            }
            originPasswordTextField.textAlignment = UITextAlignmentLeft;
            originPasswordTextField.backgroundColor = [UIColor clearColor];
            originPasswordTextField.placeholder=@"6-16位必填，大小写区分";
            [originPasswordTextField setSecureTextEntry:YES];
            [cell addSubview:originPasswordTextField];        
        }
        if(indexPath.row==1){
            cell.textLabel.text = @"输入新密码：";
            if (!nPasswordTextField) {
                self.nPasswordTextField = [[UITextField alloc] initWithFrame:CGRectMake(110, 10, 200, 44)];
            }
            nPasswordTextField.textAlignment = UITextAlignmentLeft;
            nPasswordTextField.backgroundColor = [UIColor clearColor];
            nPasswordTextField.placeholder=@"6-16位必填，大小写区分";
            [nPasswordTextField setSecureTextEntry:YES];
            [cell addSubview:nPasswordTextField];        
        }
        if(indexPath.row==2){
            cell.textLabel.text = @"确认新密码：";
            if (!resurePasswordTextField) {
                self.resurePasswordTextField = [[UITextField alloc] initWithFrame:CGRectMake(110, 10, 200, 44)];
            }
            resurePasswordTextField.textAlignment = UITextAlignmentLeft;
            resurePasswordTextField.backgroundColor = [UIColor clearColor];
            resurePasswordTextField.placeholder=@"与新密码一致";
            resurePasswordTextField.secureTextEntry = YES;
            [cell addSubview:resurePasswordTextField];        
        }        
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}
- (void)doneBtnAction{
    if(originPasswordTextField.text==nil||[originPasswordTextField.text isEqualToString:@""]||nPasswordTextField.text==nil||[nPasswordTextField.text isEqualToString:@""]||resurePasswordTextField.text==nil||[resurePasswordTextField.text isEqualToString:@""]){
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"输入不完整" message:@"所有输入不能为空" delegate:self cancelButtonTitle:nil otherButtonTitles:@"点击请重新输入", nil];
        [alertView show];

    }else if(![nPasswordTextField.text isEqualToString:resurePasswordTextField.text]){
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"输入不正确" message:@"两次输入的新密码不匹配" delegate:self cancelButtonTitle:nil otherButtonTitles:@"点击请重新输入", nil];
        [alertView show];
        
    }else{
        //1.check network status
        if([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == kNotReachable) {
            [self showAlertWithTitle:@"提示" Message:REQUEST_INVALID_NETWORK];
            return;
        }
        
        [self showWaiting];
        NSURL *url = [NSURL URLWithString:CHANGE_PASSWORD];
        
        //        if (self.quest) {
        //            [self.quest clearDelegatesAndCancel];
        //        }
        //      
        
        ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
        UserObjectService *us = [UserObjectService sharedUserObjectService];
        UserObject *user = [us getUserObject];
        [request setPostValue:[NSNumber numberWithInteger:user.uID] forKey:@"uID"];
        [request setPostValue:self.originPasswordTextField.text forKey:@"originalpassword"];
        [request setPostValue:self.nPasswordTextField.text forKey:@"newpassword"];
        request.timeOutSeconds = 20;
        [request setDelegate:self];
        [request setShouldAttemptPersistentConnection:NO];
        [request startAsynchronous];
        //self.quest=request;

    
    }
}
- (void)requestFinished:(ASIHTTPRequest *)request{
	NSString *response = [request responseString];
	SBJsonParser *parser = [[SBJsonParser alloc] init];
	NSDictionary *result = [parser objectWithString:response];
    [self getVersionFromRequestDic:result];
    NSString *status = [result objectForKey:@"status"];   
	NSString *description = [result objectForKey:@"description"];
	[self dismissWaiting];
    if ([request responseStatusCode] == 200) {
        if ([status isEqualToString:@"ok"]) {
            [self.navigationController popViewControllerAnimated:YES];
            //            NSDictionary *userinfo = [[NSDictionary alloc] initWithObjectsAndKeys:self.partyObj,@"baseinfo", nil];
            //            NSNotification *notification = [NSNotification notificationWithName:EDIT_PARTY_SUCCESS  object:nil userInfo:userinfo];
            //            [[NSNotificationCenter defaultCenter] postNotification:notification];
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"修改密码成功" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"好的，知道了", nil];
            [alertView show];
        }else{
            [self showAlertRequestFailed:description];		
        }
    }else if([request responseStatusCode] == 404){
        [self showAlertRequestFailed:REQUEST_ERROR_404];
    }else if([request responseStatusCode] == 500){
        [self showAlertRequestFailed:REQUEST_ERROR_500];
    }else if([request responseStatusCode] == 502){
        [self showAlertRequestFailed:REQUEST_ERROR_502];
    }else {
        [self showAlertRequestFailed:REQUEST_ERROR_504];
    }
    
}


- (void)requestFailed:(ASIHTTPRequest *)request
{
	NSError *error = [request error];
	[self dismissWaiting];
	[self showAlertRequestFailed: error.localizedDescription];
}


@end
