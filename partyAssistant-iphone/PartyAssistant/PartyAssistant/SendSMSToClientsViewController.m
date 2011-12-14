//
//  SendSMSToClientsViewController.m
//  PartyAssistant
//
//  Created by 超 李 on 11-10-28.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "SendSMSToClientsViewController.h"
#import "AddNewPartyBaseInfoTableViewController.h"
#define APPLY_TIPS_ALERT_TAG 12
#define SET_DEFAULT_ALERT_TAG 11
#define DONE_ALERT_TAG 13


@implementation SendSMSToClientsViewController
@synthesize receiverArray,contentTextView,receiversView,_isShowAllReceivers,countlbl,smsObject,receiverCell;
@synthesize delegate;
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
    UIBarButtonItem *doneBtn=[[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStyleDone target:self action:@selector(doneBtnAction)];
    self.navigationItem.rightBarButtonItem = doneBtn;
//    if (!_isShowAllReceivers) {
//        self._isShowAllReceivers = NO;
//    }
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reorganizeReceiverField:) name:SELECT_RECEIVER_IN_SEND_SMS object:nil];
    
//    if (!receiversView) {
//        self.receiversView = [[UIView alloc] initWithFrame:CGRectMake(80, 0, 140, 44)];
//        self.receiversView.backgroundColor = [UIColor clearColor];
//    }
    if (!smsObject) {
        SMSObjectService *smsObjectService = [SMSObjectService sharedSMSObjectService];
        self.smsObject = [smsObjectService getSMSObject];
    }
    if (!receiverArray) {
        self.receiverArray = [[NSMutableArray alloc] initWithArray:smsObject.receiversArray];
    }
    if(!receiverCell){
//        static NSString *CellIdentifier = @"Cell";
        self.receiverCell = [[ReceiverTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        receiverCell.selectionStyle = UITableViewCellSelectionStyleNone;
        receiverCell.receiverArray = self.receiverArray;
        UIButton *addBTN = [UIButton buttonWithType:UIButtonTypeContactAdd];
        [addBTN setFrame:CGRectMake(280, 10, 30, 30)];
        [addBTN addTarget:self action:@selector(addReceiver) forControlEvents:UIControlEventTouchUpInside];
        [receiverCell addSubview:addBTN];
    }
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
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section == 2) {
        if([MFMessageComposeViewController canSendText]==YES){
            return 2;
        }else{
            self.smsObject._isSendBySelf = FALSE;
        }
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    if (indexPath.section == 0) {
        [receiverCell setupCellData];
        return self.receiverCell;
    }else{
        UITableViewCell *cell = nil;// [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
            
        // Configure the cell...
        if (indexPath.section == 0) {
            
        }else if(indexPath.section == 1){
            if (!contentTextView) {
                self.contentTextView = [[UITextView alloc] initWithFrame:CGRectMake(100, 10, 160,160)];
            }
            contentTextView.text = self.smsObject.smsContent;
            NSLog(@"调用cell");
            contentTextView.backgroundColor = [UIColor clearColor];
            contentTextView.font=[UIFont systemFontOfSize:15];
            [cell addSubview:contentTextView];
            
            cell.textLabel.text  = @"短信内容:";
        }else if(indexPath.section == 2){
            if (indexPath.row == 0) {
                UISwitch *applyTipsSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(220, 10, 0, 0)];
                [applyTipsSwitch setOn:self.smsObject._isApplyTips];
                [applyTipsSwitch addTarget:self action:@selector(applyTipsSwitchAction:) forControlEvents:UIControlEventValueChanged];
                cell.textLabel.text = @"带报名提示：";
                [cell addSubview:applyTipsSwitch];
            }else if (indexPath.row == 1){
                if([MFMessageComposeViewController canSendText]==YES){//wxz
                    UISwitch *sendBySelfSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(220, 10, 0, 0)];
                    [sendBySelfSwitch setOn:self.smsObject._isSendBySelf];
                    [sendBySelfSwitch addTarget:self action:@selector(sendBySelfSwitchAction:) forControlEvents:UIControlEventValueChanged];
                    cell.textLabel.text = @"通过自己的手机发送：";
                    [cell addSubview:sendBySelfSwitch];
                }
                NSLog(@"手机发送开关");
            }
        }else if (indexPath.section == 3){
            UIButton *setDefaultBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            [setDefaultBtn setFrame:CGRectMake(10, 0, 300, 44)];
            [setDefaultBtn setTitle:@"恢复默认内容" forState:UIControlStateNormal];
            [setDefaultBtn addTarget:self action:@selector(setDefaultAction) forControlEvents:UIControlEventTouchUpInside];
            [cell addSubview:setDefaultBtn];
            cell.backgroundColor = [UIColor clearColor];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    
}

- (void)setDefaultAction{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"您将丢失该页面所有内容，是否继续？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"继续", nil];
    alertView.tag = SET_DEFAULT_ALERT_TAG;
    [alertView show];
}

- (void)addReceiver{
    ContactListViewController *clvc = [[ContactListViewController alloc] initWithNibName:@"ContactListViewController" bundle:[NSBundle mainBundle]];
    clvc.msgType = @"SMS";
    clvc.selectedContactorsArray = self.receiverArray;
    clvc.contactListDelegate = self;
    ContactListNavigationController *vc = [[ContactListNavigationController alloc] initWithRootViewController:clvc];
    [self presentModalViewController:vc animated:YES];
    [self.receiverCell setNeedsDisplay];
}

/*
- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person
{
    return YES;
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier

{
    [self dismissModalViewControllerAnimated:YES];
    return YES;
}

- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker{
    [self dismissModalViewControllerAnimated:YES];
}
*/
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 1) {
        return 180;
    }else if(indexPath.section == 0){
        return 44.0*3;
    }
    return 44.0f;
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

- (void)reorganizeReceiverField:(NSDictionary *)userInfo{
    self.receiverArray = [userInfo objectForKey:@"selectedCArray"];
    receiverCell.receiverArray = self.receiverArray;
    [self.receiverCell setupCellData];
    [self saveSMSInfo];
}


- (void)saveSMSInfo{
    self.smsObject.smsContent = [self.contentTextView text];
    self.smsObject.receiversArray = self.receiverArray;
    SMSObjectService *s = [SMSObjectService sharedSMSObjectService];
    [s saveSMSObject];
}

- (void)createPartySuc{
    self.tabBarController.selectedIndex = 1;
    NSNotification *notification = [NSNotification notificationWithName:CREATE_PARTY_SUCCESS object:nil userInfo:nil];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
    [self dismissModalViewControllerAnimated:NO];
    [self.navigationController popToRootViewControllerAnimated:NO];
}

- (IBAction)clearAddNewPartyBaseInfo{
    [delegate clearAddNewPartyBaseInfo];

}
- (void)doneBtnAction{
  if(!self.contentTextView.text || [self.contentTextView.text isEqualToString:@""]){
        UIAlertView *alert=[[UIAlertView alloc]
                            initWithTitle:@"短信内容不可以为空"
                            message:@"内容为必填项"
                            delegate:self
                            cancelButtonTitle:@"请点击输入内容"
                            otherButtonTitles: nil];
        [alert show];
        
        
  }else{
    [self saveSMSInfo];
    if ([self.receiverArray count] == 0) {
        UIAlertView *alertV = [[UIAlertView alloc] initWithTitle:@"警告" message:@"您的短信未指定任何收件人，继续保存？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"继续", nil];
        alertV.tag = DONE_ALERT_TAG;
        [alertV show];
    }else{
        [self sendCreateRequest];
    }
  }
    //清空AddNewPartyBaseInfoVc
    [self clearAddNewPartyBaseInfo];
    NSLog(@"调用done");
}
- (void)sendCreateRequest{
    [self showWaiting];
    BaseInfoService *bs = [BaseInfoService sharedBaseInfoService];
    BaseInfoObject *baseinfo = [bs getBaseInfo];
    UserObjectService *us = [UserObjectService sharedUserObjectService];
    UserObject *user = [us getUserObject];
    NSURL *url = [NSURL URLWithString:CREATE_PARTY];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setPostValue:self.smsObject.receiversArrayJson forKey:@"receivers"];
    [request setPostValue:self.smsObject.smsContent forKey:@"content"];
    [request setPostValue:@"" forKey:@"subject"];
    [request setPostValue:[NSNumber numberWithBool:self.smsObject._isApplyTips] forKey:@"_isapplytips"];
    [request setPostValue:[NSNumber numberWithBool:self.smsObject._isSendBySelf] forKey:@"_issendbyself"];
    [request setPostValue:@"SMS" forKey:@"msgType"];
    [request setPostValue:@"iphone" forKey:@"addressType"];
    [request setPostValue:baseinfo.starttimeDate forKey:@"starttime"];
    [request setPostValue:baseinfo.location forKey:@"location"];
    [request setPostValue:baseinfo.description forKey:@"description"];
    [request setPostValue:baseinfo.peopleMaximum forKey:@"peopleMaximum"];
    [request setPostValue:[NSNumber numberWithInteger:user.uID] forKey:@"uID"];

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
            NSString *applyURL = [[result objectForKey:@"datasource"] objectForKey:@"applyURL"];
            if (self.smsObject._isSendBySelf) {
              if([MFMessageComposeViewController canSendText]==YES){
                  NSLog(@"可以发送短信");
                  MFMessageComposeViewController *vc = [[MFMessageComposeViewController alloc] init];
                  if (self.smsObject._isApplyTips) {
                      vc.body = [self.smsObject.smsContent stringByAppendingString:[NSString stringWithFormat:@"(报名链接: %@)",applyURL]];
                  }else{
                      vc.body = self.smsObject.smsContent;
                  };
                  NSMutableArray *aArray = [NSMutableArray arrayWithCapacity:[self.receiverArray count]];
                  for(int i=0;i<[self.receiverArray count];i++){
                      [aArray addObject:[[self.receiverArray objectAtIndex:i] cVal]];
                  }
                  vc.recipients = aArray;
                  vc.messageComposeDelegate = self;
                  [self presentModalViewController:vc animated:YES];
                  SMSObjectService *s = [SMSObjectService sharedSMSObjectService];
                  [s clearSMSObject];
                  BaseInfoService *bs = [BaseInfoService sharedBaseInfoService];
                  [bs clearBaseInfo];
                  EmailObjectService *se = [EmailObjectService sharedEmailObjectService];
                  [se clearEmailObject];                  
              }else{
                    NSLog(@"不能发送短信");
                    [self createPartySuc];
                    #if TARGET_IPHONE_SIMULATOR // iPhone Simulator
                         return;
                    #endif
              }
                
            }else{
                [self createPartySuc];
            }
        }else{
            [self showAlertRequestFailed:description];		
        }
    }else if([request responseStatusCode] == 404){
        [self showAlertRequestFailed:REQUEST_ERROR_404];
    }else{
        [self showAlertRequestFailed:REQUEST_ERROR_500];
    }
	
}


- (void)requestFailed:(ASIHTTPRequest *)request
{
	NSError *error = [request error];
	[self dismissWaiting];
	[self showAlertRequestFailed: error.localizedDescription];
}

- (void)applyTipsSwitchAction:(UISwitch *)curSwitch{
    self.smsObject._isApplyTips = curSwitch.on;
    if (!self.smsObject._isApplyTips) {
        UIAlertView *alertV = [[UIAlertView alloc] initWithTitle:@"" message:@"关闭报名提示后，在该短信中将不包含报名链接." delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        alertV.tag = APPLY_TIPS_ALERT_TAG;
        [alertV show];
    }
    [self saveSMSInfo];
}
- (void)sendBySelfSwitchAction:(UISwitch *)curSwitch{
    self.smsObject._isSendBySelf = curSwitch.on;
    [self saveSMSInfo];
    
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
	
	// Notifies users about errors associated with the interface
	switch (result) {
		case MessageComposeResultCancelled:{
            UIActionSheet *sh = [[UIActionSheet alloc] initWithTitle:@"警告:您还未向受邀者发送邀请短信" delegate:self cancelButtonTitle:@"继续编辑短信" destructiveButtonTitle:@"返回趴列表" otherButtonTitles:nil];
            [sh showInView:self.tabBarController.view];
            break;
            }
		case MessageComposeResultSent:
			[self createPartySuc];
			break;
		case MessageComposeResultFailed:{
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"错误" message:@"发送失败，请重新发送" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [av show];
			break;
        }
		default:
			break;
	}
}



- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [self createPartySuc];
    }else{
        [actionSheet dismissWithClickedButtonIndex:1 animated:YES];
    }
    
}

- (NSString *)getDefaultContent:(BaseInfoObject *)paraBaseInfo{
    NSString *defaultText = @"";
    UserObjectService *s = [UserObjectService sharedUserObjectService];
    UserObject *u = [s getUserObject];
    NSString *userName = @"";
    if ([u.nickName isEqualToString:@""]) {
        userName = u.userName;
    }else{
        userName = u.nickName;
    }
    if ([paraBaseInfo.location isEqualToString:@""] && [paraBaseInfo.starttimeStr isEqualToString:@""]) {
        defaultText = [NSString stringWithFormat:@"%@ 邀您参加：%@，时间/地点待定，另行通知",userName,paraBaseInfo.description];
    }else if([paraBaseInfo.location isEqualToString:@""]){
        defaultText = [NSString stringWithFormat:@"%@ 邀您参加：%@ 活动，时间为：%@，地点待定，敬请光临",userName,paraBaseInfo.description,paraBaseInfo.starttimeStr];
    }else if([paraBaseInfo.starttimeStr isEqualToString:@""]){
        defaultText = [NSString stringWithFormat:@"%@ 邀您参加：%@ 活动，地点为：%@，时间待定，敬请光临",userName,paraBaseInfo.description,paraBaseInfo.location];
    }else{
        defaultText = [NSString stringWithFormat:@"%@ 邀您参加：于%@ 在 %@ 举办的%@，敬请光临",userName,paraBaseInfo.starttimeStr,paraBaseInfo.location, paraBaseInfo.description];
    }
    return defaultText;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(alertView.tag == SET_DEFAULT_ALERT_TAG){
        if (buttonIndex == 1) {
            [self.smsObject clearObject];
            BaseInfoService *s = [BaseInfoService sharedBaseInfoService];
            BaseInfoObject *baseinfo  = [s getBaseInfo];
            self.smsObject.smsContent = [self getDefaultContent:baseinfo];
            SMSObjectService *ss = [SMSObjectService sharedSMSObjectService];
            [ss saveSMSObject];
            receiverCell.receiverArray = self.receiverArray;
            [receiverCell setupCellData];
            [self.tableView reloadData];
        }
    }if (alertView.tag == DONE_ALERT_TAG) {
        if (buttonIndex == 1) {
            [self sendCreateRequest];
        }
    }
}

@end
