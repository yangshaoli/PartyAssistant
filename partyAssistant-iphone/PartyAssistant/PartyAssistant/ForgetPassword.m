//
//  ForgetPassword.m
//  PartyAssistant
//
//  Created by user on 12-1-10.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "ForgetPassword.h"
#import "UITableViewControllerExtra.h"
#import "URLSettings.h"
#import "JSON.h"
#import "HTTPRequestErrorMSG.h"
#import "UIViewControllerExtra.h"
@implementation ForgetPassword
@synthesize inputTextField;
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
    UIBarButtonItem  *getPasswordBarButton=[[UIBarButtonItem alloc] initWithTitle:@"找回" style:
UIBarButtonItemStylePlain target:self action:@selector(getPassword)];
    self.navigationItem.rightBarButtonItem=getPasswordBarButton;
    
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

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section==0) {
        return @"请输入绑定的邮箱或手机号码";
    }else{
        return @"";
    }
}


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
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    
    if (!inputTextField) {
        self.inputTextField = [[UITextField alloc] initWithFrame:CGRectMake(10, 10, 300, 44)];
    }
    inputTextField.textAlignment = UITextAlignmentLeft;
    inputTextField.backgroundColor = [UIColor clearColor];
    inputTextField.placeholder=@"系统将发送随机密码到输入的地址中";
    inputTextField.tag=12;
    [cell addSubview:inputTextField];      
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
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

- (void)getPassword{
    if(!self.inputTextField.text || [self.inputTextField.text isEqualToString:@""]){
        UIAlertView *alert=[[UIAlertView alloc]
                            initWithTitle:@"输入内容不可以为空"
                            message:@"输入为必填项"
                            delegate:self
                            cancelButtonTitle:@"请点击输入内容"
                            otherButtonTitles: nil];
        [alert show];
        return;
        
    }else{
        
        [self showWaiting];
        NSURL *url = [NSURL URLWithString:FORGET_PASSWORD];
        
//        if (self.quest) {
//            [self.quest clearDelegatesAndCancel];
//        }
//        
        ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
        [request setPostValue:self.inputTextField.text forKey:@"value"];
        request.timeOutSeconds = 20;
        [request setDelegate:self];
        [request setShouldAttemptPersistentConnection:NO];
        [request startAsynchronous];
        //self.quest=request;
        
        NSLog(@"%@",self.inputTextField.text);
       
        
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
        }else{
            [self showAlertRequestFailed:description];		
        }
    }else if([request responseStatusCode] == 404){
        NSLog(@"zai 1");
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
