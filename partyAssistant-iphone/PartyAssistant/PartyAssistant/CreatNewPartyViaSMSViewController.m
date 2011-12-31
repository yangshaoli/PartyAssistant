//
//  CreatNewPartyViaSMSViewController.m
//  PartyAssistant
//
//  Created by Wang Jun on 12/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CreatNewPartyViaSMSViewController.h"
#import "ContactsListPickerViewController.h"
#import "PartyAssistantAppDelegate.h"
#import "NotificationSettings.h"
#import "URLSettings.h"
#import "ASIFormDataRequest.h"
#import "SMSObjectService.h"
#import "HTTPRequestErrorMSG.h"

@interface CreatNewPartyViaSMSViewController ()

- (void)rearrangeContactNameTFContent;
- (void)createPartySuc;
-(void)showWaiting;
-(void)dismissWaiting; 
- (void)showAlertRequestSuccess;
- (void)showAlertRequestSuccessWithMessage: (NSString *) theMessage;
- (void)showAlertRequestFailed: (NSString *) theMessage;

@end

@implementation CreatNewPartyViaSMSViewController
@synthesize tableView = _tableView;
@synthesize addContactCell = _addContactCell;
@synthesize sendModelSelectCell = _sendModelSelectCell;
@synthesize contactNameTF = _contactNameTF;
@synthesize sendModeNameLabel = _sendModeNameLabel;
@synthesize picker = _picker;
@synthesize rightItem = _rightItem;
@synthesize receipts = _receipts;
@synthesize smsObject;
@synthesize HUD = _HUD;

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
    [self.tableView setScrollEnabled:NO];
    UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStyleDone target:self action:@selector(SMSContentInputDidFinish)];
    self.navigationItem.rightBarButtonItem = right;
    self.rightItem = right;
    self.receipts = [NSMutableArray arrayWithCapacity:10];
    
    if (!smsObject) {
        SMSObjectService *smsObjectService = [SMSObjectService sharedSMSObjectService];
        self.smsObject = [smsObjectService getSMSObject];
    }
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
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 2;
    } 
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            return self.addContactCell;
        } else if (indexPath.row == 1) {
            return self.sendModelSelectCell;
        }
    }
    
    static NSString *CellIdentifier = @"CellIdentifier";
    
    // Dequeue or create a cell of the appropriate type.
    EditableTableViewCell *cell = (EditableTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[EditableTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.delegate = self;
        cell.text = [NSMutableString stringWithCapacity:10];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (editingTableViewCell) {
            [editingTableViewCell.textView resignFirstResponder];
            [editingTableViewCell.textView scrollRangeToVisible:NSMakeRange(0, 1)];
        }
        if (indexPath.row == 0) {
            if (!self.picker) {
            ButtonPeoplePicker *aPicker = [[ButtonPeoplePicker alloc] initWithNibName:nil bundle:nil];
            self.picker = aPicker;
            aPicker.delegate = self;
            }
            [self.picker resetData];
//            CATransition *transition = [CATransition animation];
//            transition.duration = 0.3;
//            transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
//            transition.type = kCATransitionReveal;
            
//            [UIView beginAnimations:nil context:nil];
//            [UIView setAnimationTransition:UIViewAnimationTransitionCurlUp forView:self.picker.view cache:YES];
//            [UIView setAnimationDuration:0.3]; //动画时长
            
            [self.view addSubview:self.picker.view];
            self.navigationItem.rightBarButtonItem = nil;
            
            //[UIView commitAnimations];
        } else if (indexPath.row == 1) {
            SendSMSModeChooseViewController *vc = [[SendSMSModeChooseViewController alloc] initWithStyle:UITableViewStyleGrouped];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
}

- (CGFloat)tableView:(UITableView *)aTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        NSLog(@"%f",(editingTableViewCell.textView.frame.size.height + 11));
        return (editingTableViewCell.textView.frame.size.height > 80) ? (editingTableViewCell.textView.frame.size.height + 11) : (80 + 11);
    }
    return 44.0f;
}
#pragma mark -
#pragma mark EditableTableViewCellDelegate

- (void)editableTableViewCellDidBeginEditing:(EditableTableViewCell *)editableTableViewCell {
    editingTableViewCell = editableTableViewCell;
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    NSRange range = NSMakeRange(editingTableViewCell.textView.text.length - 1, 1);
    [editingTableViewCell.textView scrollRangeToVisible:range];
    
    CGFloat offset = -100.0f;
    self.tableView.contentInset = UIEdgeInsetsMake(offset, 0.0f, 0.0f, 0.0f);
    
    self.navigationItem.rightBarButtonItem = nil;
}


- (void)editableTableViewCellDidEndEditing:(EditableTableViewCell *)editableTableViewCell {
    editingTableViewCell = editableTableViewCell;
    self.tableView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
    self.navigationItem.rightBarButtonItem = self.rightItem;
}


- (void)editableTableViewCell:(EditableTableViewCell *)editableTableViewCell heightChangedTo:(CGFloat)newHeight {
    // Calling beginUpdates/endUpdates causes the table view to reload cell geometries
    CGRect oldFrame = editingTableViewCell.textView.frame;
    CGRect newFrame = oldFrame;
    if (newHeight < 80.0f) {
        newFrame.size.height = 80.0f;
    } else if (newHeight > 120.0f) {
        newFrame.size.height = 120.0f;
    } else {
        newFrame.size.height = newHeight;
    }
    
    editingTableViewCell.textView.frame = newFrame;
    
    NSRange range = NSMakeRange(editingTableViewCell.textView.text.length - 1, 1);
    [editingTableViewCell.textView scrollRangeToVisible:range];
    
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}

#pragma mark -
#pragma mark ButtonPickDelegate
- (void)buttonPeoplePickerDidFinish:(ButtonPeoplePicker *)controller {
    self.receipts = [NSMutableArray arrayWithArray:controller.group];
    NSLog(@"%@",self.receipts);
    [self rearrangeContactNameTFContent];
    [[controller view] removeFromSuperview];
    self.navigationItem.rightBarButtonItem = self.rightItem;
    NSLog(@"receipts:%@",self.receipts);
}

- (void)rearrangeContactNameTFContent {
    if ([self.receipts count] == 0) {
        self.contactNameTF.text = nil;
    } else {
        self.contactNameTF.text = nil;
        CGSize holderSize = [@"&recipient" sizeWithFont:[UIFont systemFontOfSize:16.0f]];
        
        CGFloat tfWidth = self.contactNameTF.frame.size.width;
        
        NSMutableString *contactNameTFContent = [[NSMutableString alloc] initWithCapacity:0];
        for (int i=0; i<[self.receipts count]; i++) {
            NSDictionary *peopleInfo = [self.receipts objectAtIndex:i];
            ABRecordID peopleID = [[peopleInfo objectForKey:@"abRecordID"] intValue];
            if (peopleID == -1) {
                continue;
            }
            ABContact *contact = [ABContact contactWithRecordID:peopleID];
            NSString *name = [contact compositeName];
            if ([name length] <= 0) {
                name = [peopleInfo objectForKey:@"phoneNumber"];
            }
            
            CGSize nowContentSize = [contactNameTFContent sizeWithFont:[UIFont systemFontOfSize:16.0f]];
                                     
            CGSize newNameSize = [name sizeWithFont:[UIFont systemFontOfSize:16.0f]];
            
            if ((nowContentSize.width + newNameSize.width + holderSize.width) < tfWidth - 10.0f) {
                if (i!=0) {
                    [contactNameTFContent appendString:@","];
                } 
                [contactNameTFContent appendString:name];
            } else {
                int leftCount = [self.receipts count] - i;
                if (leftCount == 1) {
                    [contactNameTFContent appendFormat:@"&%drecipient", leftCount];
                } else {
                    [contactNameTFContent appendFormat:@"&%drecipients", leftCount];
                }
                break;
            }
        }
        self.contactNameTF.text = contactNameTFContent;
    }
}

- (NSMutableArray *)getCurrentContactDataSource {
    return self.receipts;
}
#pragma mark -
#pragma mark custom method
- (void)SMSContentInputDidFinish {
    if(!editingTableViewCell.textView.text || [editingTableViewCell.textView.text isEqualToString:@""]){
        UIAlertView *alert=[[UIAlertView alloc]
                            initWithTitle:@"短信内容不可以为空"
                            message:@"内容为必填项"
                            delegate:self
                            cancelButtonTitle:@"请点击输入内容"
                            otherButtonTitles: nil];
        [alert show];
    }else{
        [self saveSMSInfo];
        if ([self.smsObject.receiversArray count] == 0) {
            UIAlertView *alertV = [[UIAlertView alloc] initWithTitle:@"警告" message:@"您的短信未指定任何收件人，继续保存？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"继续", nil];
            [alertV show];
        }else{
            [self sendCreateRequest];
        }
    }
}

- (void)saveSMSInfo{
    self.smsObject.smsContent = [editingTableViewCell.textView text];
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:10];
    for (NSDictionary *receipt in self.receipts) {
        ABRecordID peopleID = [[receipt objectForKey:@"abRecordID"] intValue];
        if (peopleID == -1) {
            continue;
        }
        ClientObject *client = [[ClientObject alloc] init];
        client.cID = peopleID;
        client.cName = [receipt objectForKey:@"name"];
        client.cVal = [receipt objectForKey:@"phoneNumber"];
        [array addObject:client];
    }
    
    self.smsObject.receiversArray = array;
    
    SMSObjectService *s = [SMSObjectService sharedSMSObjectService];
    [s saveSMSObject];
}

- (void)createPartySuc{
//    self.tabBarController.selectedIndex = 1;
//    NSNotification *notification = [NSNotification notificationWithName:CREATE_PARTY_SUCCESS object:nil userInfo:nil];
//    [[NSNotificationCenter defaultCenter] postNotification:notification];
//    [self.navigationController dismissModalViewControllerAnimated:NO];
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
    NSLog(@"%@",self.smsObject.receiversArrayJson);
    [request setPostValue:self.smsObject.smsContent forKey:@"content"];
    [request setPostValue:@"" forKey:@"subject"];
    [request setPostValue:[NSNumber numberWithBool:self.smsObject._isApplyTips] forKey:@"_isapplytips"];
    [request setPostValue:[NSNumber numberWithBool:self.smsObject._isSendBySelf] forKey:@"_issendbyself"];
    [request setPostValue:@"SMS" forKey:@"msgType"];
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
                    
                    NSMutableArray *numberArray = [[NSMutableArray alloc] initWithCapacity:10];
                    for (NSDictionary *receipt in self.receipts) {
                        ABRecordID peopleID = [[receipt objectForKey:@"abRecordID"] intValue];
                        if (peopleID == -1) {
                            continue;
                        }
                        if (![[receipt objectForKey:@"phoneNumber"] isEqualToString:@""]) {
                            [numberArray addObject:[receipt objectForKey:@"phoneNumber"]];
                        }
                    }
                    vc.recipients = numberArray;
                    vc.messageComposeDelegate = self;
                    [self.navigationController presentModalViewController:vc animated:YES];
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
#pragma mark -
#pragma mark SMS delegate
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
	
	// Notifies users about errors associated with the interface
	switch (result) {
		case MessageComposeResultCancelled:{
            [self.navigationController dismissModalViewControllerAnimated:YES];
            //            UIActionSheet *sh = [[UIActionSheet alloc] initWithTitle:@"警告:您还未向受邀者发送邀请短信" delegate:self cancelButtonTitle:@"继续编辑短信" destructiveButtonTitle:@"返回趴列表" otherButtonTitles:nil];
//            [sh showInView:self.tabBarController.view];
            break;
        }
		case MessageComposeResultSent:
			//send
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
#pragma mark -
#pragma contact list delegate
- (void)callContactList {
    ContactsListPickerViewController *list = [[ContactsListPickerViewController alloc] init];
    list.contactDelegate = self;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:list];
    [self.navigationController presentModalViewController:nav animated:YES];
}

- (void)contactList:(ContactsListPickerViewController *)contactList cancelAction:(BOOL)action {
    [self.navigationController dismissModalViewControllerAnimated:action];
}

- (void)contactList:(ContactsListPickerViewController *)contactList selectDefaultActionForPerson:(ABRecordID)personID property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier {
    
    ABRecordRef person = ABAddressBookGetPersonWithRecordID(addressBook, personID);
    
    // Access the person's email addresses (an ABMultiValueRef)
    ABMultiValueRef phonesProperty = ABRecordCopyValue(person, kABPersonPhoneProperty);
    CFIndex index = ABMultiValueGetIndexForIdentifier(phonesProperty, identifier);
    NSString *name = (__bridge NSString *)ABRecordCopyCompositeName(person);
    
    NSString *phone;
    
    NSDictionary *personDictionary = nil;
    
    if (index != -1)
    {
        phone = (__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(phonesProperty, index);
        
        if (phone) {
            personDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                [NSNumber numberWithInt:personID], @"abRecordID",
                                [NSNumber numberWithInt:identifier], @"valueIdentifier", 
                                phone, @"phoneNumber", name, @"name",nil];
            [self.receipts addObject:personDictionary];
        } 
    }
    
    CFRelease(person);
    
    [self.navigationController dismissModalViewControllerAnimated:YES];
    
    [self rearrangeContactNameTFContent];
}

#pragma mark _
#pragma mark HUD method
-(void)showWaiting {
    self.HUD = [[MBProgressHUD alloc] initWithView:self.view];
	[self.view addSubview:_HUD];
    _HUD.labelText = @"waiting...";
    
    _HUD.delegate = self;
    
    [_HUD show:YES];
    
}

-(void)dismissWaiting {
    if (_HUD) {
        [_HUD hide:YES afterDelay:1.0f];
    }
}

- (void)HUDWasHidden:(MBProgressHUD *)hUD {
    // Remove _HUD from screen when the _HUD was hidded
    [_HUD removeFromSuperview];
    self.HUD = nil;
}

#pragma mark - 
#pragma mark alert method
- (void)showAlertRequestSuccess{
	UIAlertView *av=[[UIAlertView alloc] initWithTitle:@"Success!" message:@"OK" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK",nil];
    av.tag=1;
	[av show];
}

- (void)showAlertRequestSuccessWithMessage: (NSString *) theMessage{
	UIAlertView *av=[[UIAlertView alloc] initWithTitle:@"Success!" message:theMessage delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK",nil];
    av.tag=1;
	[av show];
}

- (void)showAlertRequestFailed: (NSString *) theMessage{
	UIAlertView *av=[[UIAlertView alloc] initWithTitle:@"Hold on!" message:theMessage delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK",nil];
    [av show];
}

#pragma mark - 
#pragma mark UserSMSModeCheckDelegate

- (BOOL)IsCurrentSMSSendBySelf {
    return self.smsObject._isSendBySelf;
}

- (void)changeSMSModeToSendBySelf:(BOOL)status {
    self.smsObject._isSendBySelf = status;
}
@end