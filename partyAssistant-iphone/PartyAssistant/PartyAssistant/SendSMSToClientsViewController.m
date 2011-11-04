//
//  SendSMSToClientsViewController.m
//  PartyAssistant
//
//  Created by 超 李 on 11-10-28.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "SendSMSToClientsViewController.h"

@implementation SendSMSToClientsViewController
@synthesize receiverArray,contentTextView,receiversView,_isShowAllReceivers,countlbl,smsObject;

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
    if (!_isShowAllReceivers) {
        self._isShowAllReceivers = NO;
    }
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reorganizeReceiverField:) name:SELECT_RECEIVER_IN_SEND_SMS object:nil];
    
    if (!receiversView) {
        self.receiversView = [[UIView alloc] initWithFrame:CGRectMake(80, 0, 140, 44)];
        self.receiversView.backgroundColor = [UIColor clearColor];
    }
    if (!smsObject) {
        SMSObjectService *smsObjectService = [SMSObjectService sharedSMSObjectService];
        self.smsObject = [smsObjectService getSMSObject];
    }
    if (!receiverArray) {
        self.receiverArray = [[NSMutableArray alloc] initWithArray:smsObject.receiversArray];
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
        return 2;
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    
    // Configure the cell...
    if (indexPath.section == 0) {
        cell.textLabel.text = @"收件人";
        cell.textLabel.textAlignment = UITextAlignmentLeft;
//        if (!receiverText) {
//            self.receiverText = [[ReceiverText alloc] initWithPage:CGRectMake(80, 0, 230, 44) delegat:self];
//        }
//        [cell addSubview:receiverText];
        UIButton *addBTN = [UIButton buttonWithType:UIButtonTypeContactAdd];
        [addBTN setFrame:CGRectMake(280, 10, 30, 30)];
        [addBTN addTarget:self action:@selector(addReceiver) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:addBTN];
        [cell addSubview:self.receiversView];
        [self setupReceiversView];
    }else if(indexPath.section == 1){
        if (!contentTextView) {
            self.contentTextView = [[UITextView alloc] initWithFrame:CGRectMake(100, 10, 160,180)];
        }
        contentTextView.text = self.smsObject.smsContent;
        contentTextView.backgroundColor = [UIColor clearColor];
        [cell addSubview:contentTextView];
        cell.textLabel.text  = @"短信内容";
    }else if(indexPath.section == 2){
        if (indexPath.row == 0) {
            UISwitch *applyTipsSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(220, 10, 0, 0)];
            [applyTipsSwitch setOn:self.smsObject._isApplyTips];
            [applyTipsSwitch addTarget:self action:@selector(applyTipsSwitchAction:) forControlEvents:UIControlEventValueChanged];
            cell.textLabel.text = @"带报名提示：";
            [cell addSubview:applyTipsSwitch];
        }else{
            UISwitch *sendBySelfSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(220, 10, 0, 0)];
            [sendBySelfSwitch setOn:self.smsObject._isSendBySelf];
            [sendBySelfSwitch addTarget:self action:@selector(sendBySelfSwitchAction:) forControlEvents:UIControlEventValueChanged];
            cell.textLabel.text = @"通过自己的手机发送：";
            [cell addSubview:sendBySelfSwitch];
        }
    }else{
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

- (void)setDefaultAction{

}

- (void)addReceiver{
//    ABPeoplePickerNavigationController *adPickerNavigationController = [[ABPeoplePickerNavigationController alloc] init];
//    adPickerNavigationController.displayedProperties = [NSArray arrayWithObjects:[NSNumber numberWithInt:kABPersonPhoneProperty],nil];
//    adPickerNavigationController.peoplePickerDelegate = self;
//    [self presentModalViewController:adPickerNavigationController animated:YES];
//    ContactListViewController *vc=[[ContactListViewController alloc] initWithNibName:@"ContactListViewController" bundle:[NSBundle mainBundle]];
//    [self.navigationController pushViewController:vc animated:YES];
    ContactListViewController *clvc = [[ContactListViewController alloc] initWithNibName:@"ContactListViewController" bundle:[NSBundle mainBundle]];
    clvc.msgType = @"SMS";
    clvc.selectedContactorsArray = self.receiverArray;
    ContactListNavigationController *vc = [[ContactListNavigationController alloc] initWithRootViewController:clvc];
    [self presentModalViewController:vc animated:YES];
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
    if (indexPath.section==0) {
        self._isShowAllReceivers = !_isShowAllReceivers;
        [self setupReceiversView];
    }
}

- (void)reorganizeReceiverField:(NSNotification *)notification{
    NSDictionary *userinfo = [notification userInfo];
    self.receiverArray = [userinfo objectForKey:@"selectedCArray"];
    [self setupReceiversView];
}
- (void)setupReceiversView{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    
    CGRect cframe = cell.textLabel.frame;
    NSArray *subVArray = [self.receiversView subviews];
    for (int j = 0;j < [subVArray count];j++) {
        [[subVArray objectAtIndex:j] removeFromSuperview];
    }
    [self.countlbl removeFromSuperview];
    self.countlbl = nil;
    if (_isShowAllReceivers) {
        for (int i = 0 ;i < [receiverArray count];i++) {
            ReceiverLabel *rlbl = [[ReceiverLabel alloc] initWithReceiverObject:[receiverArray objectAtIndex:i] index:i];
            [self.receiversView addSubview:rlbl];
        }
        if ([receiverArray count] == 0) {
            UILabel *defaultLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 140, 44)];
            defaultLabel.backgroundColor = [UIColor clearColor];
            defaultLabel.text = @"请添加收件人";
            defaultLabel.textColor = [UIColor lightGrayColor];
            [self.receiversView addSubview:defaultLabel];
            self.receiversView.frame = CGRectMake(receiversView.frame.origin.x, receiversView.frame.origin.y, receiversView.frame.size.width, 44.0f);
            cell.frame = CGRectMake(cell.frame.origin.x, cell.frame.origin.y, cell.frame.size.width, 44.0f);
        }else{
            self.receiversView.frame = CGRectMake(receiversView.frame.origin.x, receiversView.frame.origin.y, receiversView.frame.size.width, [receiverArray count]*44.0f);
            cell.frame = CGRectMake(cell.frame.origin.x, cell.frame.origin.y, cell.frame.size.width, [receiverArray count]*44.0f);
        }
    }else{
        if ([receiverArray count]>0) {
            ReceiverLabel *rlbl = [[ReceiverLabel alloc] initWithReceiverObject:[receiverArray objectAtIndex:0] index:0];
            [self.receiversView addSubview:rlbl];
            self.countlbl = [[UILabel alloc] initWithFrame:CGRectMake(receiversView.frame.origin.x+receiversView.frame.size.width+5, 0, 50, 44)];
            countlbl.text = [NSString stringWithFormat:@"共%d人",[self.receiverArray count]];
            countlbl.backgroundColor = [UIColor clearColor];
            countlbl.adjustsFontSizeToFitWidth = YES;
            [cell addSubview:countlbl];
        }else{
            UILabel *defaultLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 140, 44)];
            defaultLabel.backgroundColor = [UIColor clearColor];
            defaultLabel.text = @"请添加收件人";
            defaultLabel.textColor = [UIColor lightGrayColor];
            [self.receiversView addSubview:defaultLabel];
        }
        self.receiversView.frame = CGRectMake(receiversView.frame.origin.x, receiversView.frame.origin.y, receiversView.frame.size.width, 44.0f);
        cell.frame = CGRectMake(cell.frame.origin.x, cell.frame.origin.y, cell.frame.size.width, 44.0f);
    }
    cell.textLabel.frame = CGRectMake(cframe.origin.x,cframe.origin.y,cframe.size.width,40);
    cell.textLabel.backgroundColor = [UIColor clearColor];
}

- (void)saveSMSInfo{
    self.smsObject.smsContent = [self.contentTextView text];
    self.smsObject.receiversArray = self.receiverArray;
    SMSObjectService *s = [SMSObjectService sharedSMSObjectService];
    [s saveSMSObject];
}

- (void)doneBtnAction{
    [self saveSMSInfo];
    [self showWaiting];
    BaseInfoService *s = [BaseInfoService sharedBaseInfoService];
    BaseInfoObject *baseinfo = [s getBaseInfo];
    NSURL *url = [NSURL URLWithString:CREATE_PARTY];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setPostValue:self.smsObject.receiversArray forKey:@"receivers"];
    [request setPostValue:self.smsObject.smsContent forKey:@"content"];
    [request setPostValue:@"" forKey:@"subject"];
    [request setPostValue:@"SMS" forKey:@"msgType"];
    [request setPostValue:@"" forKey:@"subject"];
    [request setPostValue:baseinfo.starttimeDate forKey:@"starttime"];
    [request setPostValue:baseinfo.location forKey:@"location"];
    [request setPostValue:baseinfo.description forKey:@"description"];
    [request setPostValue:baseinfo.peopleMaximum forKey:@"peopleMaximum"];
//    [request setPostValue:.uID forKey:@"uID";
//    if (!self.eventerestingobject.categoryBaseObject.tagsArray) {
//        [request setPostValue:@"" forKey:@"tags"];
//    } else {
//        [request setPostValue:[self.eventerestingobject.categoryBaseObject.tagsArray componentsJoinedByString:@","] forKey:@"tags"];
//    }
//    
//    //    [request setPostValue:self.eventerestingobject.currentOrNot forKey:@"current_or_not"];
//    [request setPostValue:self.eventerestingobject.latitude forKey:@"latitude"];
//    [request setPostValue:self.eventerestingobject.longitude forKey:@"longitude"];
//    [request setPostValue:self.eventerestingobject.address_line_1 forKey:@"location"];
//    [request setPostValue:self.eventerestingobject.city forKey:@"city"];
//    [request setPostValue:self.eventerestingobject.state forKey:@"state"];
//    [request setPostValue:[NSString stringWithFormat:@"%d",self.eventerestingobject.categoryBaseObject.mainImageIndex] forKey:@"mainImageIndex"];
//    NSString *tempPath = NSTemporaryDirectory();
//    for(NSNumber *i in imageNamesArray){
//        NSString *imageName = [NSString stringWithFormat:@"tempPostingImage_%@.jpg",i];
//        NSString *imageFile = [tempPath stringByAppendingPathComponent:imageName];
//        [request addFile:imageFile withFileName:nil andContentType:@"image/jpeg" forKey:@"images"];
//    }
//    [request setDelegate:self];
//    request.timeOutSeconds = 30;
//    [request setShouldAttemptPersistentConnection:NO];
//    [request startAsynchronous];
    
}

- (void)applyTipsSwitchAction:(UISwitch *)curSwitch{
    self.smsObject._isApplyTips = curSwitch.on;
    [self saveSMSInfo];
}
- (void)sendBySelfSwitchAction:(UISwitch *)curSwitch{
    self.smsObject._isSendBySelf = curSwitch.on;
    [self saveSMSInfo];
    
}

@end
