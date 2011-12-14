//
//  PartyDetailTableViewController.m
//  PartyAssistant
//
//  Created by 超 李 on 11-11-6.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "PartyDetailTableViewController.h"
#define DELETE_PARTY_ALERT_VIEW_TAG 11
#define NAVIGATION_TITILE @"活动详情"

@implementation PartyDetailTableViewController
@synthesize baseinfo, peopleCountArray;

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

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self performSelectorOnMainThread:@selector(loadClientCount) withObject:nil waitUntilDone:NO];
    self.navigationController.title = @"活动详情";
    self.editButtonItem.action = @selector(editBtnAction);
    self.editButtonItem.title = @"编辑";
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.navigationItem.title = NAVIGATION_TITILE;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(editPartySuccessAction:) name:EDIT_PARTY_SUCCESS object:nil];
    if (!peopleCountArray) {
        self.peopleCountArray = [[NSArray alloc] initWithObjects:@"...",@"...",@"...",@"...", nil];
    }
    NSLog(@"detail-partyId::%d",self.baseinfo.partyId);
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
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section == 0) {
        return 4;
    }else if(section ==1){
        return 4;
    }
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section==0) {
        return @"基本信息";
    }else if(section ==1){
        return @"报名统计";
    }else{
        return @"";
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath;
{
    if(indexPath.section == 0 && indexPath.row == 3) {
        return 120.0f;
    }
    return 44.0f;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
        
    UITableViewCell *cell = nil; //[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    // Configure the cell...
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cell.textLabel.text = @"开始时间:";
            UILabel *starttimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 0, 190, 44)];
            starttimeLabel.textAlignment = UITextAlignmentRight;
            starttimeLabel.backgroundColor = [UIColor clearColor];
            starttimeLabel.text = self.baseinfo.starttimeStr;
            //            starttimeLabel.text = @"2011-11-11 11:00";
            [cell addSubview:starttimeLabel];
        }else if(indexPath.row == 1){
            cell.textLabel.text = @"地点:";
            UILabel *locationLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 0, 190, 44)];
            locationLabel.textAlignment = UITextAlignmentRight;
            locationLabel.backgroundColor = [UIColor clearColor];
            locationLabel.text = self.baseinfo.location;
            [cell addSubview:locationLabel];
        }else if(indexPath.row == 2){
            cell.textLabel.text = @"人数上限:";
            UILabel *peopleStrLable = [[UILabel alloc] initWithFrame:CGRectMake(100, 0, 190, 44)];
            peopleStrLable.backgroundColor = [UIColor clearColor];
            peopleStrLable.textAlignment = UITextAlignmentRight;
            peopleStrLable.text = [NSString stringWithFormat:@"%@ 人", self.baseinfo.peopleMaximum];
            [cell addSubview:peopleStrLable];
        }else{
            cell.textLabel.text = @"描述:";
            UITextView *descriptionTextView = [[UITextView alloc] initWithFrame:CGRectMake(100, 10, 190, 100)];
            descriptionTextView.text = self.baseinfo.description;
            descriptionTextView.backgroundColor = [UIColor clearColor];
            descriptionTextView.font=[UIFont systemFontOfSize:15];
            descriptionTextView.editable = NO;
            [cell addSubview:descriptionTextView];
        }
    }else if(indexPath.section == 1){
        if (indexPath.row == 0) {
            cell.textLabel.text = @"邀请人:";
            NumberLabel *lb_1 = [[NumberLabel alloc] initWithBlueNumber:[self.peopleCountArray objectAtIndex:0] withFrame:CGRectMake(10, 14, 280, 44)];
            
            lb_1.tag = 1;
            lb_1.textAlignment = UITextAlignmentRight;
//            lb_1.backgroundColor = [UIColor clearColor];
            [cell addSubview:lb_1];
//            UIImageView *imgV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"new_tips"]];
//            imgV.frame = CGRectMake(200, 7, imgV.frame.size.width, imgV.frame.size.height);
//            [cell addSubview:imgV];
        }else if(indexPath.row == 1){
            cell.textLabel.text = @"已报名:";
            UILabel *lb_1 = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 280, 44)];
            lb_1.tag = 2;
            lb_1.text = [NSString stringWithFormat:@"%@",[self.peopleCountArray objectAtIndex:1]];
            lb_1.textAlignment = UITextAlignmentRight;
            lb_1.backgroundColor = [UIColor clearColor];
            [cell addSubview:lb_1];
        }else if(indexPath.row == 2){
            cell.textLabel.text = @"不报名:";
            UILabel *lb_1 = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 280, 44)];
            lb_1.tag = 3;
            lb_1.text = [NSString stringWithFormat:@"%@",[self.peopleCountArray objectAtIndex:2]];
            lb_1.textAlignment = UITextAlignmentRight;
            lb_1.backgroundColor = [UIColor clearColor];
            [cell addSubview:lb_1];
        }else if(indexPath.row == 3){
            cell.textLabel.text = @"未报名:";
            UILabel *lb_1 = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 280, 44)];
            lb_1.tag = 4;
            lb_1.text = [NSString stringWithFormat:@"%@",[self.peopleCountArray objectAtIndex:3]];
            lb_1.textAlignment = UITextAlignmentRight;
            lb_1.backgroundColor = [UIColor clearColor];
            [cell addSubview:lb_1];
        }
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }else if(indexPath.section == 2){
        UIButton *delBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [delBtn setFrame:CGRectMake(10, 0, 300, 44)];
        [delBtn setTitle:@"删除该活动" forState:UIControlStateNormal];
        [delBtn addTarget:self action:@selector(deleteParty) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:delBtn];
        cell.backgroundColor = [UIColor clearColor];
    }
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
    if (indexPath.section == 1) {
        ClientStatusTableViewController *vc = [[ClientStatusTableViewController alloc] initWithNibName:@"ClientStatusTableViewController" bundle:[NSBundle mainBundle]];
        if(indexPath.row == 0){
            vc.clientStatusFlag = @"all";
        }else if(indexPath.row == 1){
            vc.clientStatusFlag = @"applied";
        }else if(indexPath.row == 2){
            vc.clientStatusFlag = @"refused";
        }else{
            vc.clientStatusFlag = @"donothing";
        }
        vc.partyId = [self.baseinfo.partyId intValue];
        vc.baseinfo = self.baseinfo;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)loadClientCount
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@" ,GET_PARTY_CLIENT_MAIN_COUNT,self.baseinfo.partyId]];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    request.timeOutSeconds = 30;
    [request setDelegate:self];
    [request setShouldAttemptPersistentConnection:NO];
    [request startAsynchronous];
}

- (void)requestFinished:(ASIHTTPRequest *)request{
    
	NSString *response = [request responseString];
	SBJsonParser *parser = [[SBJsonParser alloc] init];
	NSDictionary *result = [parser objectWithString:response];
	NSString *description = [result objectForKey:@"description"];
    if ([request responseStatusCode] == 200) {
        if ([description isEqualToString:@"ok"]) {
            NSDictionary *dataSource = [result objectForKey:@"datasource"];
            NSNumber *allClientcount = [dataSource objectForKey:@"allClientcount"];
            NSNumber *appliedClientcount = [dataSource objectForKey:@"appliedClientcount"];
            NSNumber *refusedClientcount = [dataSource objectForKey:@"refusedClientcount"];
            NSNumber *donothingClientcount = [dataSource objectForKey:@"donothingClientcount"];
            NSArray *countArray = [NSArray arrayWithObjects:[allClientcount stringValue],[appliedClientcount stringValue],[refusedClientcount stringValue],[donothingClientcount stringValue], nil];
            self.peopleCountArray = countArray;
            [self.tableView reloadData];
        }else{
            [self showAlertRequestFailed:description];		
        }
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
//	NSError *error = [request error];
	//[self dismissWaiting];
	//[self showAlertRequestFailed: error.localizedDescription];
}

- (void)editBtnAction{
    EditPartyTableViewController *vc = [[EditPartyTableViewController alloc] initWithNibName:@"EditPartyTableViewController" bundle:[NSBundle mainBundle]];
    vc.baseInfoObject = self.baseinfo;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)editPartySuccessAction:(NSNotification *)notification{
    NSDictionary *userinfo = [notification userInfo];
    self.baseinfo = [userinfo objectForKey:@"baseinfo"];
    [self performSelectorOnMainThread:@selector(loadClientCount) withObject:nil waitUntilDone:NO];
    [self.tableView reloadData];
}

- (void)deleteParty
{
    UIAlertView *alertV = [[UIAlertView alloc] initWithTitle:nil message:@"删除后不能再恢复，是否继续？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"继续", nil];
    alertV.tag = DELETE_PARTY_ALERT_VIEW_TAG;
    [alertV show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(alertView.tag == DELETE_PARTY_ALERT_VIEW_TAG){
        if (buttonIndex == 1) {
            [self showWaiting];
            UserObjectService *us = [UserObjectService sharedUserObjectService];
            UserObject *user = [us getUserObject];
            NSURL *url = [NSURL URLWithString:DELETE_PARTY];
            ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
            [request setPostValue:self.baseinfo.partyId forKey:@"pID"];
            [request setPostValue:[NSNumber numberWithInteger:user.uID] forKey:@"uID"];
            
            request.timeOutSeconds = 30;
            [request setDelegate:self];
            [request setDidFinishSelector:@selector(deleteRequestFinished:)];
            [request setDidFailSelector:@selector(deleteRequestFailed:)];
            [request setShouldAttemptPersistentConnection:NO];
            [request startAsynchronous];
        }
    }
}

- (void)deleteRequestFinished:(ASIHTTPRequest *)request{
	//[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(requestTimeOutHandler) object:nil];
    NSString *response = [request responseString];
	SBJsonParser *parser = [[SBJsonParser alloc] init];
	NSDictionary *result = [parser objectWithString:response];
	NSString *description = [result objectForKey:@"description"];
	[self dismissWaiting];
    if ([request responseStatusCode] == 200) {
        if ([description isEqualToString:@"ok"]) {
            [self.navigationController popViewControllerAnimated:YES];
            NSNotification *notification = [NSNotification notificationWithName:CREATE_PARTY_SUCCESS object:nil userInfo:nil];
            [[NSNotificationCenter defaultCenter] postNotification:notification];
        }else{
            [self showAlertRequestFailed:description];		
        }
    }else if([request responseStatusCode] == 404){
        [self showAlertRequestFailed:REQUEST_ERROR_404];
    }else{
        [self showAlertRequestFailed:REQUEST_ERROR_500];
    }
	
}


- (void)deleteRequestFailed:(ASIHTTPRequest *)request
{
	NSError *error = [request error];
	[self dismissWaiting];
	[self showAlertRequestFailed: error.localizedDescription];
}

@end
