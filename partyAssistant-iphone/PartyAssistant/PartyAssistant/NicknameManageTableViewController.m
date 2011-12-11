//
//  NicknameManageTableViewController.m
//  PartyAssistant
//
//  Created by 超 李 on 11-12-5.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "NicknameManageTableViewController.h"
#import "DataManager.h"

@implementation NicknameManageTableViewController
@synthesize nicknameTextField,phoneNumberTextField,emailTextField;

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
    self.title=@"更改个人信息";

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
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
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
    UserObjectService *s = [UserObjectService sharedUserObjectService];
    UserObject *user = [s getUserObject];
    
    if(indexPath.row==0){
        cell.textLabel.text = @"昵称：";
        if (!nicknameTextField) {
            self.nicknameTextField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 280, 44)];
        }
        nicknameTextField.text = user.nickName;
        nicknameTextField.textAlignment = UITextAlignmentRight;
        nicknameTextField.backgroundColor = [UIColor clearColor];
        [cell addSubview:nicknameTextField];        
    }
    if(indexPath.row==1){
        cell.textLabel.text = @"手机号：";
        if (!phoneNumberTextField) {
            self.phoneNumberTextField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 280, 44)];
        }
        phoneNumberTextField.text = user.phoneNum;
        phoneNumberTextField.textAlignment = UITextAlignmentRight;
        phoneNumberTextField.backgroundColor = [UIColor clearColor];
        [cell addSubview:phoneNumberTextField];        
    }
    if(indexPath.row==2){
        cell.textLabel.text = @"邮箱：";
        if (!emailTextField) {
            self.emailTextField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 280, 44)];
        }
        emailTextField.text = user.emailInfo;
        emailTextField.textAlignment = UITextAlignmentRight;
        emailTextField.backgroundColor = [UIColor clearColor];
        [cell addSubview:emailTextField];        
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

- (void)doneBtnAction
{
    [self showWaiting];
    
    UserObject *user = [[UserObjectService sharedUserObjectService] getUserObject];
//    NSNumber *userId = [NSNumber numberWithInt:user.uID];
    DataManager *dataManager = [DataManager sharedDataManager];
    NSString *nickName = self.nicknameTextField.text;
    NetworkConnectionStatus status = [dataManager setNickNameForUserWithUID:user.uID withNewNickName:nickName];
    NSString *phoneNum = self.phoneNumberTextField.text;
    NetworkConnectionStatus  phoneStatus = [dataManager  setPhoneNumForUserWithUID:user.uID withNewPhoneNum:phoneNum];
    NSString *emailInfo = self.emailTextField.text;
    NetworkConnectionStatus  emailStatus = [dataManager setEmailInfoForUserWithUID:user.uID withNewEmailInfo:emailInfo];
    
}

@end
