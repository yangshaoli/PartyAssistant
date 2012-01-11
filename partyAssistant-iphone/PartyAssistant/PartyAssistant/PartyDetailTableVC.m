//
//  PartyDetailTableVC.m
//  PartyAssistant
//
//  Created by user on 11-12-19.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//
#import "StatusTableVC.h"
#import "ContentTableVC.h"
#import "PartyDetailTableVC.h"
#import "NotificationSettings.h"
#import "URLSettings.h"
#import "JSON.h"
#import "ASIFormDataRequest.h"
#import "ClientStatusTableViewController.h"
#import "EditPartyTableViewController.h"
#import "UserObject.h"
#import "UserObjectService.h"
#import "ResendPartyViaSMSViewController.h"


#define DELETE_PARTY_ALERT_VIEW_TAG 11

@implementation PartyDetailTableVC
@synthesize myToolbarItems,peopleCountArray,clientsArray;
@synthesize partyObj,quest,seperatedListQuest,deleteQuest;
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
        
    [self performSelectorOnMainThread:@selector(loadClientCount) withObject:nil waitUntilDone:NO];
    self.title=@"活动详情";
    
    self.navigationController.toolbar.tintColor = [UIColor colorWithRed:117/255 green:4/255 blue:32/255 alpha:1];
    [self.navigationController.toolbar setBarStyle:UIBarStyleBlackTranslucent];
    [self.navigationController.toolbar sizeToFit];
    
    
    if (!self.myToolbarItems) {
        UIBarButtonItem *flexButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
        self.myToolbarItems = [NSArray arrayWithObjects:
                               flexButton,  
                               [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"share_word"]
                                                                style:UIBarButtonItemStylePlain
                                                               target:self
                                                               action:@selector(shareAction)], 
                               flexButton, 
                               [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"refresh_word"]
                                                                style:UIBarButtonItemStylePlain 
                                                               target:self
                                                               action:@selector(refreshItem)],
                               flexButton, 
                               [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"del_word"]
                                                                style:UIBarButtonItemStylePlain
                                                               target:self
                                                               action:@selector(deleteParty)],
                               flexButton, 
                               [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"edit_word"]
                                                                style:UIBarButtonItemStylePlain
                                                               target:self
                                                               action:@selector(editBtnAction)],
                               flexButton, 
                               [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"reinvite_word"]
                                                                style:UIBarButtonItemStylePlain
                                                               target:self
                                                               action:@selector(resentMsg)],
                               flexButton,
                               nil];
        
        [self setToolbarItems:myToolbarItems animated:YES];
    }
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self.tableView reloadData];
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
    self.navigationController.toolbarHidden = NO;
    [self loadClientCount];
    [self getPartyClientSeperatedList];
    [self.tableView reloadData];
    
//    //[GetClientsCountService sharedGetClientsCountService].partyObj=self.partyObj;
//    NSLog(@"在Detail页面输出partyid》》》》%d",self.partyObj.partyId);
   

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.toolbarHidden = YES;
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



- (void)loadClientCount
{
    NSNumber *partIdNumber=self.partyObj.partyId;
    NSString *partIdString=[partIdNumber stringValue];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%d/" ,GET_PARTY_CLIENT_MAIN_COUNT,[partIdString intValue]]];
    if (self.quest) {
        [self.quest clearDelegatesAndCancel];
    }
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    request.timeOutSeconds = 30;
    [request setDelegate:self];
    [request setShouldAttemptPersistentConnection:NO];
    [request startAsynchronous];
    
    self.quest = request;
//    NSLog(@"loadClientCount预期调用1111");
//    NSNumber *partyIdNumber=self.partyObj.partyId;
//    NSLog(@"loadClientCount输出后kkkkk。。。。。。%d",[partyIdNumber intValue]);
//    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%d/%@/",GET_PARTY_CLIENT_SEPERATED_LIST,[partyIdNumber intValue],@"all"]];
//    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
//    request.timeOutSeconds = 30;
//    [request setDelegate:self];
//    [request setDidFinishSelector:@selector(requestFinished:)];
//    [request setDidFailSelector:@selector(requestFailed:)];
//    [request setShouldAttemptPersistentConnection:NO];
//    [request startAsynchronous];

    
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
            NSNumber *newAppliedClientcount = [dataSource objectForKey:@"newAppliedClientcount"];
            
            NSNumber *refusedClientcount = [dataSource objectForKey:@"refusedClientcount"];
            NSNumber *newRefusedClientcount = [dataSource objectForKey:@"newRefusedClientcount"];
            NSNumber *donothingClientcount = [dataSource objectForKey:@"donothingClientcount"];
            
            NSArray *countArray = [NSArray arrayWithObjects:[allClientcount stringValue],[appliedClientcount stringValue],[newAppliedClientcount stringValue],[refusedClientcount stringValue],[newRefusedClientcount stringValue],[donothingClientcount stringValue], nil];
            self.peopleCountArray = countArray;
            [self.tableView reloadData];
        }else{
             [self showAlertRequestFailed:description];		
        }
    }else if([request responseStatusCode] == 404){
         NSLog(@"在21");
        [self showAlertRequestFailed:REQUEST_ERROR_404];
    }else if([request responseStatusCode] == 500){
         NSLog(@"在221");
        [self showAlertRequestFailed:REQUEST_ERROR_500];
    }else if([request responseStatusCode] == 502){
         NSLog(@"在22221");
        [self showAlertRequestFailed:REQUEST_ERROR_502];
    }else{
         NSLog(@"在222221");
        [self showAlertRequestFailed:REQUEST_ERROR_504];
    }
    
    
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    //	NSError *error = [request error];
	//[self dismissWaiting];
	//[self showAlertRequestFailed: error.localizedDescription];
}


#pragma mark - resend  request
- (void)getPartyClientSeperatedList{
    NSNumber *partyIdNumber=self.partyObj.partyId;
    if (self.seperatedListQuest) {
        [self.seperatedListQuest clearDelegatesAndCancel];
    }
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%d/%@/",GET_PARTY_CLIENT_SEPERATED_LIST,[partyIdNumber intValue],@"all"]];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    request.timeOutSeconds = 30;
    [request setDelegate:self];
    [request setDidFinishSelector:@selector(getPartyClientSeperatedListRequestFinished:)];
    [request setDidFailSelector:@selector(getPartyClientSeperatedListRequestFailed:)];
    [request setShouldAttemptPersistentConnection:NO];
    [request startAsynchronous];
    self.seperatedListQuest = request;
}

- (void)getPartyClientSeperatedListRequestFinished:(ASIHTTPRequest *)request{
	NSString *response = [request responseString];
	SBJsonParser *parser = [[SBJsonParser alloc] init];
	NSDictionary *result = [parser objectWithString:response];
	NSString *description = [result objectForKey:@"description"];
	[self dismissWaiting];
    if ([request responseStatusCode] == 200) {
        if ([description isEqualToString:@"ok"]) {
            NSDictionary *dict = [result objectForKey:@"datasource"];
            self.clientsArray = [dict objectForKey:@"clientList"];
            NSLog(@"打印调试数组%@",[dict objectForKey:@"clientList"]);
            UITabBarItem *tbi = (UITabBarItem *)[self.tabBarController.tabBar.items objectAtIndex:1];
            [UIApplication sharedApplication].applicationIconBadgeNumber = [[dict objectForKey:@"unreadCount"] intValue];
            if ([[dict objectForKey:@"unreadCount"] intValue]==0) {
                tbi.badgeValue = nil;
            }else{
                tbi.badgeValue = [NSString stringWithFormat:@"%@",[dict objectForKey:@"unreadCount"]];
            }
            [self.tableView reloadData];
        }else{
            [self showAlertRequestFailed:description];	
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


- (void)getPartyClientSeperatedListRequestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
	[self dismissWaiting];
	[self showAlertRequestFailed: error.localizedDescription];
}

#pragma mark - Table view data source


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath;
{
    if(indexPath.section==0){
        return 100;
    }
    return 44;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    
    if(section==1){
        return 4;
    }
    return 1;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section==0) {
        return @"活动内容";
    }else if(section ==1){
        return @"人数统计";
    }else{
        return @"";
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    UIView *oldLayout2 = nil;
    oldLayout2=[cell viewWithTag:5];
    [oldLayout2 removeFromSuperview];
    
    
    UIView *oldLayout = nil;
    oldLayout = [cell viewWithTag:2];
    [oldLayout removeFromSuperview];
    if(indexPath.section==0){
        cell.textLabel.font=[UIFont systemFontOfSize:13];
        cell.textLabel.numberOfLines = 0;
        if([self.partyObj.contentString length]>140){
            cell.textLabel.text=[self.partyObj.contentString  substringToIndex:140];
        }else{
            cell.textLabel.text=self.partyObj.contentString;
        }
        cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    }else{
        if(indexPath.row==0){
            cell.textLabel.text=@"已邀请";
            
            UILabel *lb_1 = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 280, 44)];
            lb_1.tag = 2;
            lb_1.text = [NSString stringWithFormat:@"%@",[self.peopleCountArray objectAtIndex:0]];
            lb_1.textAlignment = UITextAlignmentRight;
            lb_1.backgroundColor = [UIColor clearColor];
            [cell addSubview:lb_1];
            
        }else if(indexPath.row==1){
            cell.textLabel.text=@"已报名";
            NSInteger newAppliedInt=[[self.peopleCountArray objectAtIndex:2] intValue];
            
            if(self.partyObj.isnewApplied){
                UIImageView *cellImageView=[[UIImageView alloc] initWithFrame:CGRectMake(200, 15, 20, 20)];
                cellImageView.image=[UIImage imageNamed:@"new2"];
                cellImageView.tag=5;
                [cell  addSubview:cellImageView];
            }
            UILabel *lb_1 = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 280, 44)];
            lb_1.tag = 2;
            lb_1.text = [NSString stringWithFormat:@"%@",[self.peopleCountArray objectAtIndex:1]];
            lb_1.textAlignment = UITextAlignmentRight;
            lb_1.backgroundColor = [UIColor clearColor];
            [cell addSubview:lb_1];
        }else if(indexPath.row==2){
            cell.textLabel.text=@"未响应";  
            UILabel *lb_1 = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 280, 44)];
            lb_1.tag = 2;
            lb_1.text = [NSString stringWithFormat:@"%@",[self.peopleCountArray objectAtIndex:5]];
            lb_1.textAlignment = UITextAlignmentRight;
            lb_1.backgroundColor = [UIColor clearColor];
            [cell addSubview:lb_1];
        }else {
            cell.textLabel.text=@"不参加";
            NSInteger newRefusedInt=[[self.peopleCountArray objectAtIndex:4] intValue];
            if(self.partyObj.isnewRefused){
                UIImageView *cellImageView=[[UIImageView alloc] initWithFrame:CGRectMake(200, 15, 20, 20)];
                cellImageView.image=[UIImage imageNamed:@"new2"];
                cellImageView.tag=5;
                [cell  addSubview:cellImageView];
            }
            UILabel *lb_1 = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 280, 44)];
            lb_1.tag = 2;
            lb_1.text = [NSString stringWithFormat:@"%@",[self.peopleCountArray objectAtIndex:3]];
            lb_1.textAlignment = UITextAlignmentRight;
            lb_1.backgroundColor = [UIColor clearColor];
            [cell addSubview:lb_1];
        }
        cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    
    }
    // Configure the cell...
    
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
    if(indexPath.section==0){
        ContentTableVC *contentTableVC=[[ContentTableVC alloc] initWithNibName:@"ContentTableVC" bundle:nil];
        contentTableVC.title=@"编辑活动内容";
        contentTableVC.partyObj=self.partyObj;
        [self.navigationController pushViewController:contentTableVC animated:YES];
    }
    if(indexPath.section==1){
        StatusTableVC  *statusTableVC=[[StatusTableVC  alloc] initWithNibName:@"StatusTableVC" bundle:nil];//如果nibname为空  则不会呈现组显示
        statusTableVC.partyObj=self.partyObj;
        if(indexPath.row==0){
            statusTableVC.title=@"已邀请";
            statusTableVC.clientStatusFlag=@"all";
            self.partyObj.isnewApplied=NO;
            self.partyObj.isnewRefused=NO;
        }else if(indexPath.row==1){
            statusTableVC.title=@"已报名";
            statusTableVC.clientStatusFlag=@"applied";
            self.partyObj.isnewApplied=NO;
        }else if(indexPath.row==2){
            statusTableVC.title=@"未响应";
            statusTableVC.clientStatusFlag=@"donothing";
        }else {
            statusTableVC.title=@"不参加";
            statusTableVC.clientStatusFlag=@"refused";
            self.partyObj.isnewRefused=NO;
        }
        [self.navigationController pushViewController:statusTableVC animated:YES];
        
    }
}

- (void)shareAction
{
    
    WeiboLoginViewController *rootVC = [[WeiboLoginViewController alloc] initWithNibName:@"WeiboLoginViewController" bundle:nil];
    //rootVC.baseinfo = baseinfo;
    rootVC.partyObj=self.partyObj;
    WeiboNavigationController *vc = [[WeiboNavigationController alloc] initWithRootViewController:rootVC];
    [self presentModalViewController:vc animated:YES];
}

////正则判断是否Email地址
//- (BOOL) isEmailAddress:(NSString*)email { 
//    
//    NSString *emailRegex = @"^\\w+((\\-\\w+)|(\\.\\w+))*@[A-Za-z0-9]+((\\.|\\-)[A-Za-z0-9]+)*.[A-Za-z0-9]+$"; 
//    
//    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex]; 
//    
//    return [emailTest evaluateWithObject:email]; 
//    
//} 


- (void)resentMsg{
//    UIAlertView *alertV = [[UIAlertView alloc] initWithTitle:@"手机版暂不支持邮件发送" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"好的，知道了", nil];
//    [alertV show];
//
//    ResendPartyViaSMSViewController *resendPartyViaSMSViewController=[[ResendPartyViaSMSViewController alloc] initWithNibName:@"CreatNewPartyViaSMSViewController" bundle:nil];
//    NSMutableArray *clientDicArray=[self.clientsArray mutableCopy];
//    NSLog(@"打印type：：：%@",self.partyObj.type);
//    for(NSDictionary  *clientDic in self.clientsArray){
//        if([self.partyObj.type isEqualToString:@"email"]){
//            [clientDicArray removeObject:clientDic];
//        }
//    }
//    
//    NSLog(@"detail页面输出再次发送数组》》》%@",clientDicArray);
//    [self.navigationController pushViewController:resendPartyViaSMSViewController animated:YES];
//    [resendPartyViaSMSViewController  setSmsContent:self.partyObj.contentString  andGropID:[self.partyObj.partyId intValue]];
//    [resendPartyViaSMSViewController  setNewReceipts:clientDicArray];

    
    [self getPartyClientSeperatedList];
    if([self.partyObj.type isEqualToString:@"email"]){
        UIAlertView *alertV = [[UIAlertView alloc] initWithTitle:@"手机版暂不支持邮件发送" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"好的，知道了", nil];
        [alertV show];
    }else{
        ResendPartyViaSMSViewController *resendPartyViaSMSViewController=[[ResendPartyViaSMSViewController alloc] initWithNibName:@"CreatNewPartyViaSMSViewController" bundle:nil];
        [self.navigationController pushViewController:resendPartyViaSMSViewController animated:YES];
        [resendPartyViaSMSViewController  setSmsContent:self.partyObj.contentString  andGropID:[self.partyObj.partyId intValue]];
        [resendPartyViaSMSViewController  setNewReceipts:self.clientsArray];
    }
}
- (void)editBtnAction{
    ContentTableVC *contentTableVC=[[ContentTableVC alloc] initWithNibName:@"ContentTableVC" bundle:nil];
    contentTableVC.title=@"编辑活动内容";
    contentTableVC.partyObj=self.partyObj;
    [self.navigationController pushViewController:contentTableVC animated:YES];
    
}
- (void)refreshItem{
    [self loadClientCount];
    
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
            if (self.deleteQuest) {
                [self.deleteQuest clearDelegatesAndCancel];
            }
            
            ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
            [request setPostValue:self.partyObj.partyId forKey:@"pID"];
            [request setPostValue:[NSNumber numberWithInteger:user.uID] forKey:@"uID"];
            
            //request.timeOutSeconds = 30;
            [request setDelegate:self];
            [request setDidFinishSelector:@selector(deleteRequestFinished:)];
            [request setDidFailSelector:@selector(deleteRequestFailed:)];
            [request setShouldAttemptPersistentConnection:NO];
            [request startAsynchronous];

            self.deleteQuest=request;
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
    }else if([request responseStatusCode] == 500){
        [self showAlertRequestFailed:REQUEST_ERROR_500];
    }else if([request responseStatusCode] == 502){
        [self showAlertRequestFailed:REQUEST_ERROR_502];
    }else {
        [self showAlertRequestFailed:REQUEST_ERROR_504];
    }
	
}

- (void)deleteRequestFailed:(ASIHTTPRequest *)request
{
	NSError *error = [request error];
	[self dismissWaiting];
	[self showAlertRequestFailed: error.localizedDescription];
}

#pragma mark -
#pragma mark dealloc method
- (void)dealloc {
    [self.quest clearDelegatesAndCancel];
    [self.seperatedListQuest  clearDelegatesAndCancel];
    self.quest = nil;
    self.seperatedListQuest=nil;
}
@end
