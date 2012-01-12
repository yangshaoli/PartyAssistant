//
//  ClientStatusTableViewController.m
//  PartyAssistant
//
//  Created by 超 李 on 11-11-11.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "ClientStatusTableViewController.h"

@implementation ClientStatusTableViewController
@synthesize clientsArray,clientStatusFlag,partyId,baseinfo;

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
    
    UIBarButtonItem *resendBtn = [[UIBarButtonItem alloc] initWithTitle:@"再次邀请" style:UIBarButtonItemStyleDone target:self action:@selector(resendBtnAction)];
    self.navigationItem.rightBarButtonItem = resendBtn;
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self showWaiting];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%d/%@/",GET_PARTY_CLIENT_SEPERATED_LIST,self.partyId,self.clientStatusFlag]];
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
	[self dismissWaiting];
    if ([request responseStatusCode] == 200) {
        if ([description isEqualToString:@"ok"]) {
            NSDictionary *dict = [result objectForKey:@"datasource"];
            self.clientsArray = [dict objectForKey:@"clientList"];
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


- (void)requestFailed:(ASIHTTPRequest *)request
{
	NSError *error = [request error];
	[self dismissWaiting];
	[self showAlertRequestFailed: error.localizedDescription];
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
    return [self.clientsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    
    // Configure the cell...
    
    NSDictionary *client = [self.clientsArray objectAtIndex:indexPath.row];
    cell.textLabel.text = [client objectForKey:@"cName"];
    cell.tag = [[client objectForKey:@"backendID"] integerValue];
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(10, 40, 300, 20)];
    lbl.text = [client objectForKey:@"cValue"];
    lbl.backgroundColor = [UIColor clearColor];
    [cell addSubview:lbl];
    UILabel *statusLbl = [[UILabel alloc] initWithFrame:CGRectMake(200, 0, 100, 40)];
    statusLbl.textAlignment=UITextAlignmentRight;
    statusLbl.backgroundColor = [UIColor clearColor];
    UIButton *funcBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [funcBtn setFrame:CGRectMake(200, 40, 100, 20)];
    if ([self.clientStatusFlag isEqualToString:@"all"]) {
        NSString *cStatus = [[self.clientsArray objectAtIndex:indexPath.row] objectForKey:@"status"];
        if ([cStatus isEqualToString:@"已报名"]) {
            [funcBtn setTitle:@"拒绝" forState:UIControlStateNormal];
            statusLbl.text = @"已报名";
        }else if([cStatus isEqualToString:@"不参加"]){
            statusLbl.text = @"已拒绝";
            [funcBtn setTitle:@"报名" forState:UIControlStateNormal];
        }else{
            statusLbl.text = @"未报名";
            [funcBtn setTitle:@"报名" forState:UIControlStateNormal];
        }
    }else{
        if ([clientStatusFlag isEqualToString:@"applied"]) {
            [funcBtn setTitle:@"拒绝" forState:UIControlStateNormal];
            statusLbl.text = @"已报名";
        }else if([clientStatusFlag isEqualToString:@"refused"]){
            statusLbl.text = @"已拒绝";
            [funcBtn setTitle:@"报名" forState:UIControlStateNormal];
        }else{
            statusLbl.text = @"未报名";
            [funcBtn setTitle:@"报名" forState:UIControlStateNormal];
        }
    }
    [funcBtn addTarget:self action:@selector(changeClientStatus:) forControlEvents:UIControlEventTouchUpInside];
    funcBtn.backgroundColor = [UIColor blueColor];
    funcBtn.tag = indexPath.row;
    [cell addSubview:statusLbl];
    [cell addSubview:funcBtn];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)changeClientStatus:(UIButton *)btn
{
    [self performSelectorOnMainThread:@selector(sendChangeClientRequest:) withObject:btn waitUntilDone:NO];
}

- (void)sendChangeClientRequest:(UIButton *)btn
{
    int row = btn.tag;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    NSURL *url = [NSURL URLWithString:CLIENT_STATUS_OPERATOR];
    NSString *statusAction = @"";
    if ([self.clientStatusFlag isEqualToString:@"all"]) {
        if ([[[self.clientsArray objectAtIndex:row] objectForKey:@"status"] isEqualToString:@"已报名"]) {
            statusAction = @"refuse";
        }else{
            statusAction = @"apply";
        }
    }else{
        if ([self.clientStatusFlag isEqualToString:@"applied"]) {
            statusAction = @"refuse";
        }else{
            statusAction = @"apply";
        }
    }
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setPostValue:[NSNumber numberWithInt:cell.tag] forKey:@"cpID"];
    [request setPostValue:statusAction forKey:@"cpAction"];
    request.timeOutSeconds = 30;
    [request setDelegate:self];
    [request setShouldAttemptPersistentConnection:NO];
    btn.hidden = YES;
    btn.enabled = NO;
    UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    activity.frame = btn.frame;
    [activity startAnimating];
    [cell addSubview:activity];
    [request setDidFinishSelector:nil];
    [request setDidFailSelector:nil];
    [request startSynchronous];
    NSError *error = [request error];
    if (!error) {
        [activity removeFromSuperview];
        NSString *response = [request responseString];
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        NSDictionary *result = [parser objectWithString:response];
        NSString *description = [result objectForKey:@"description"];
        if ([request responseStatusCode] == 200) {
            if ([description isEqualToString:@"ok"]) {
                [btn removeFromSuperview];
                for (int i=0; i<[[cell subviews] count]; i++) {
                    if ([[[cell subviews] objectAtIndex:i] isMemberOfClass:[UILabel class]]) {
                        UILabel *l = [[cell  subviews] objectAtIndex:i];
                        if ([l.text isEqualToString:@"已报名" ]) {
                            l.text = @"已拒绝";
                        }else if([l.text isEqualToString:@"已拒绝" ] || [l.text isEqualToString:@"未报名" ]){
                            l.text = @"已报名";
                        }
                    }
                }
            } else {
                btn.enabled = YES;
                btn.hidden = NO;
            }
        }else if([request responseStatusCode] == 404){
            [self showAlertRequestFailed:REQUEST_ERROR_404];
            btn.hidden = NO;
            btn.enabled = YES;
        }else if([request responseStatusCode] == 500){
            [self showAlertRequestFailed:REQUEST_ERROR_500];
            btn.hidden = NO;
            btn.enabled = YES;
        }else if([request responseStatusCode] == 502){
            [self showAlertRequestFailed:REQUEST_ERROR_502];
            btn.hidden = NO;
            btn.enabled = YES;
        }else{
            btn.hidden = NO;
            btn.enabled = YES;
            [self showAlertRequestFailed:REQUEST_ERROR_504];
        }
    } else {
        [activity removeFromSuperview];
        btn.hidden = NO;
        btn.enabled = YES;
        //[self showAlert:[error localizedDescription]];
    }
    

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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath;
{
    return 60.0f;
}

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

- (void)resendBtnAction{
    [self showWaiting];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@/",GET_MSG_IN_COPY_PARTY,self.baseinfo.partyId]];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    request.timeOutSeconds = 30;
    [request setDelegate:self];
    [request setShouldAttemptPersistentConnection:NO];
    [request setDidFinishSelector:@selector(resendRequestFinished:)];
    [request setDidFailSelector:@selector(resendRequestFailed:)];
    [request startAsynchronous];
}

- (void)resendRequestFinished:(ASIHTTPRequest *)request{
    [self dismissWaiting];
	NSString *response = [request responseString];
	SBJsonParser *parser = [[SBJsonParser alloc] init];
	NSDictionary *result = [parser objectWithString:response];
	NSString *description = [result objectForKey:@"description"];
	//		NSString *debugger = [[result objectForKey:@"status"] objectForKey:@"debugger"];
	//[NSThread detachNewThreadSelector:@selector(dismissWaiting) toTarget:self withObject:nil];
    //	[self dismissWaiting];
    if ([request responseStatusCode] == 200) {
        if ([description isEqualToString:@"ok"]) {
            NSDictionary *dataSource = [result objectForKey:@"datasource"];
            NSString *msgType = [dataSource objectForKey:@"msgType"];
            NSMutableArray *receiverObjectsArray = [[NSMutableArray alloc] initWithCapacity:[clientsArray count]];
            for (int i=0; i<[clientsArray count]; i++) {
                ClientObject *client = [[ClientObject alloc] init];
                client.backendID = [[[clientsArray objectAtIndex:i] objectForKey:@"backendID"] intValue];
                client.cName = [[clientsArray objectAtIndex:i] objectForKey:@"cName"];
                client.cVal = [[clientsArray objectAtIndex:i] objectForKey:@"cValue"];
                [receiverObjectsArray addObject:client];
            }
            if ([msgType isEqualToString:@"SMS"]) {
                ResendSMSTableViewController *vc = [[ResendSMSTableViewController alloc] initWithNibName:@"ResendSMSTableViewController" bundle:[NSBundle mainBundle]];
                vc.receiverArray = receiverObjectsArray;
                SMSObject *sobj = [[SMSObject alloc] init];
                sobj.receiversArray = receiverObjectsArray;
                sobj.smsContent = [dataSource objectForKey:@"content"];
                sobj._isApplyTips = [[dataSource objectForKey:@"_isApplyTips"] boolValue];
                sobj._isSendBySelf = [[dataSource objectForKey:@"_isSendBySelf"] boolValue];
                vc.smsObject = sobj;
                vc.baseinfo = self.baseinfo;
                //            [vc setupReceiversView];
                [self.navigationController pushViewController:vc animated:YES];
            }else{
                ResendEmailTableViewController *vc = [[ResendEmailTableViewController alloc] initWithNibName:@"ResendEmailTableViewController" bundle:[NSBundle mainBundle]];
                vc.receiverArray = receiverObjectsArray;
                EmailObject *eobj = [[EmailObject alloc] init];
                eobj.receiversArray = receiverObjectsArray;
                eobj.emailContent = [dataSource objectForKey:@"content"];
                eobj.emailSubject = [dataSource objectForKey:@"subject"];
                eobj._isApplyTips = [[dataSource objectForKey:@"_isApplyTips"] boolValue];
                eobj._isSendBySelf = [[dataSource objectForKey:@"_isSendBySelf"] boolValue];
                vc.emailObject = eobj;
                vc.baseinfo = self.baseinfo;
                //            [vc setupReceiversView];
                [self.navigationController pushViewController:vc animated:YES];
            }
            
            
            [self.tableView reloadData];
            //        [self setBottomRefreshViewYandDeltaHeight];
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

- (void)resendRequestFailed:(ASIHTTPRequest *)request
{
    //	NSError *error = [request error];
	//[self dismissWaiting];
	//[self showAlertRequestFailed: error.localizedDescription];
}

@end
