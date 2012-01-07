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
#import "DeviceDetection.h"
#import "PartyListTableVC.h"
#import "ABContact.h"
#import "SegmentManagingViewController.h"
#import "NotificationSettings.h"
#import "AddressBookDBService.h"

@interface CreatNewPartyViaSMSViewController ()

- (void)rearrangeContactNameTFContent;
- (void)createPartySuc;
-(void)showWaiting;
-(void)dismissWaiting; 
- (void)showAlertRequestSuccess;
- (void)showAlertRequestSuccessWithMessage: (NSString *) theMessage;
- (void)showAlertRequestFailed: (NSString *) theMessage;
- (NSString *)getCleanPhoneNumber:(NSString *)originalString;
- (void)addPersonToGroup:(NSDictionary *)personDictionary;
- (NSString *)getCleanLetter:(NSString *)originalString;

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
@synthesize editingTableViewCell = _editingTableViewCell;

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
    UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStyleDone target:self action:@selector(updateRemainCount)];
    self.navigationItem.rightBarButtonItem = right;
    self.rightItem = right;
    self.receipts = [NSMutableArray arrayWithCapacity:10];
    
    if (!smsObject) {
        SMSObjectService *smsObjectService = [SMSObjectService sharedSMSObjectService];
        self.smsObject = [smsObjectService getSMSObject];
    }
    
    self.editingTableViewCell = [[EditableTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    _editingTableViewCell.delegate = self;
    _editingTableViewCell.text = [NSMutableString stringWithCapacity:10];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.smsObject._isSendBySelf) {
        self.sendModeNameLabel.text = @"用自己手机发送";
    } else {
        self.sendModeNameLabel.text = @"通过服务器发送";
    }
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
    } else {
        return self.editingTableViewCell;
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (self.editingTableViewCell) {
            [self.editingTableViewCell.textView resignFirstResponder];
            [self.editingTableViewCell.textView scrollRangeToVisible:NSMakeRange(0, 1)];
        }
        if (indexPath.row == 0) {
            if (!self.picker) {
            ButtonPeoplePicker *aPicker = [[ButtonPeoplePicker alloc] initWithNibName:nil bundle:nil];
            self.picker = aPicker;
            aPicker.delegate = self;
            }
            
            [self.view addSubview:self.picker.view];
            self.navigationItem.rightBarButtonItem = nil;
            
            [self.picker resetData];
//            CATransition *transition = [CATransition animation];
//            transition.duration = 0.3;
//            transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
//            transition.type = kCATransitionReveal;
            
//            [UIView beginAnimations:nil context:nil];
//            [UIView setAnimationTransition:UIViewAnimationTransitionCurlUp forView:self.picker.view cache:YES];
//            [UIView setAnimationDuration:0.3]; //动画时长
            
            //[UIView commitAnimations];
        } else if (indexPath.row == 1) {
            SendSMSModeChooseViewController *vc = [[SendSMSModeChooseViewController alloc] initWithStyle:UITableViewStyleGrouped];
            vc.delegate = self;
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
}

- (CGFloat)tableView:(UITableView *)aTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        NSLog(@"%f",(self.editingTableViewCell.textView.frame.size.height + 11));
        if ([self.editingTableViewCell.textView isFirstResponder]) {
            return (self.editingTableViewCell.textView.frame.size.height > 80) ? (self.editingTableViewCell.textView.frame.size.height + 11) : (80 + 11);
        } else {
            if (self.editingTableViewCell.textView.frame.size.height < 250) {
                if ((self.editingTableViewCell.textView.frame.size.height + 11) < 80) {
                    return 80 + 11;
                } else {
                    return self.editingTableViewCell.textView.frame.size.height + 11;
                }
            } else {
                return (250 + 11);
            }
            return (self.editingTableViewCell.textView.frame.size.height < 250) ? (self.editingTableViewCell.textView.frame.size.height + 11) : (250 + 11);
        }
        
    }
    return 44.0f;
}
#pragma mark -
#pragma mark EditableTableViewCellDelegate

- (void)editableTableViewCellDidBeginEditing:(EditableTableViewCell *)editableTableViewCell {
    self.editingTableViewCell = editableTableViewCell;
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    NSRange range = NSMakeRange(self.editingTableViewCell.textView.text.length - 1, 1);
    [self.editingTableViewCell.textView scrollRangeToVisible:range];
    
    CGFloat offset = -100.0f;
    self.tableView.contentInset = UIEdgeInsetsMake(offset, 0.0f, 0.0f, 0.0f);
    
    self.navigationItem.rightBarButtonItem = nil;
    
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}


- (void)editableTableViewCellDidEndEditing:(EditableTableViewCell *)editableTableViewCell {
    self.editingTableViewCell = editableTableViewCell;
    self.tableView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
    self.navigationItem.rightBarButtonItem = self.rightItem;
}


- (void)editableTableViewCell:(EditableTableViewCell *)editableTableViewCell heightChangedTo:(CGFloat)newHeight {
    // Calling beginUpdates/endUpdates causes the table view to reload cell geometries
    CGRect oldFrame = self.editingTableViewCell.textView.frame;
    CGRect newFrame = oldFrame;
    if (newHeight < 80.0f) {
        newFrame.size.height = 80.0f;
    } else if (newHeight > 100.0f) {
        if (![editableTableViewCell.textView isFirstResponder]) {
            if (newHeight > 250.0f) {
                newFrame.size.height = 250.0f;
            } else {
                newFrame.size.height = newHeight;
            }
        } else {
            newFrame.size.height = 100.0f;
        }
    } else {
        newFrame.size.height = newHeight;
    }
    
    self.editingTableViewCell.textView.frame = newFrame;
    
    NSRange range = NSMakeRange(self.editingTableViewCell.textView.text.length - 1, 1);
    [self.editingTableViewCell.textView scrollRangeToVisible:range];
    
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}

#pragma mark -
#pragma mark ButtonPickDelegate
- (void)buttonPeoplePickerDidFinish:(ButtonPeoplePicker *)controller {
    self.receipts = [NSMutableArray arrayWithArray:controller.group];
    NSLog(@"now receipts is :%@",self.receipts);
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
            ClientObject *clientInfo = [self.receipts objectAtIndex:i];
        
            NSString *name  = clientInfo.cName;
            if (!name || [name isEqualToString:@""]) {
                name = clientInfo.cVal;
            }
            
            CGSize nowContentSize = [contactNameTFContent sizeWithFont:[UIFont systemFontOfSize:16.0f]];
                                     
            CGSize newNameSize = [name sizeWithFont:[UIFont systemFontOfSize:16.0f]];
            
            if ((nowContentSize.width + newNameSize.width + holderSize.width) < tfWidth - 10.0f) {
                if (i!=0) {
                    [contactNameTFContent appendString:@","];
                }
                NSLog(@"name :%@", name);
                if (name) {
                    [contactNameTFContent appendString:name];
                }
            } else {
                int leftCount = [self.receipts count] - i;
                if (leftCount == 1) {
                    if (i == 0) {
                        [contactNameTFContent appendFormat:@"%drecipient", leftCount];
                    } else {
                        [contactNameTFContent appendFormat:@"&%drecipient", leftCount];   
                    }
                } else {
                    if (i == 0) {
                        [contactNameTFContent appendFormat:@"&%drecipients", leftCount];
                    } else {
                        [contactNameTFContent appendFormat:@"&%drecipients", leftCount];   
                    }
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
//    if(!self.editingTableViewCell.textView.text || [self.editingTableViewCell.textView.text isEqualToString:@""]){
//        UIAlertView *alert=[[UIAlertView alloc]
//                            initWithTitle:@"短信内容不可以为空"
//                            message:@"内容为必填项"
//                            delegate:self
//                            cancelButtonTitle:@"请点击输入内容"
//                            otherButtonTitles: nil];
//        [alert show];
//    }else{
//    [self saveSMSInfo];
    if ([self.smsObject.receiversArray count] == 0) {
        UIAlertView *alertV = [[UIAlertView alloc] initWithTitle:@"警告" message:@"您的短信未指定任何收件人，继续保存？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"继续", nil];
            [alertV show];
    }else{
        UserObjectService *us = [UserObjectService sharedUserObjectService];
        UserObject *user = [us getUserObject];
        if (self.smsObject._isSendBySelf) {
            
        } else {
            if ([user.leftSMSCount intValue] < [self.smsObject.receiversArray count]) {
                UIAlertView *alert=[[UIAlertView alloc]
                                    initWithTitle:@"需要充值"
                                    message:@"余额不足，不能通过服务器端发送！"
                                    delegate:nil
                                    cancelButtonTitle:@"确定"
                                    otherButtonTitles: nil];
                [alert show];
                return;
            }
        }
        
        [self sendCreateRequest];
    }
}

- (void)saveSMSInfo{
    self.smsObject.smsContent = [self.editingTableViewCell.textView text];
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:10];
    for (ClientObject *receipt in self.receipts) {
        //need check phone format
        //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        ClientObject *client = [[ClientObject alloc] init];
        client.cName = receipt.cName;
        NSString *phoneNumber = receipt.cVal;
        
        if (!phoneNumber) {
            continue;
        } else {
            phoneNumber = [self getCleanPhoneNumber:phoneNumber];
            if (phoneNumber.length >= 11) {
                client.cVal = phoneNumber;
            } else {
                continue;
            }
        }
        [array addObject:client];
    }
    
    self.smsObject.receiversArray = array;
    NSLog(@"receiversArray count:%d",[array count]);
    
    SMSObjectService *s = [SMSObjectService sharedSMSObjectService];
    [s saveSMSObject];
}

- (void)createPartySuc{
    self.editingTableViewCell.textView.text = @"";
    self.receipts = [NSMutableArray arrayWithCapacity:10];
    [self rearrangeContactNameTFContent];

    self.tabBarController.selectedIndex = 1;
    [self.navigationController dismissModalViewControllerAnimated:YES];
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
    NSString *platform = [DeviceDetection platform];
    NSURL *url = [NSURL URLWithString:CREATE_PARTY];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setPostValue:[self.smsObject setupReceiversArrayData] forKey:@"receivers"];
    NSLog(@"%@",self.smsObject.receiversArrayJson);
    [request setPostValue:self.smsObject.smsContent forKey:@"content"];
    [request setPostValue:[NSNumber numberWithBool:self.smsObject._isSendBySelf] forKey:@"_issendbyself"];
    [request setPostValue:[NSNumber numberWithInteger:user.uID] forKey:@"uID"];
    [request setPostValue:platform forKey:@"addressType"];
    
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
                    
                    AddressBookDBService *favourite = [AddressBookDBService sharedAddressBookDBService];
                    for (ClientObject *client in self.smsObject.receiversArray) {
                        [favourite useContact:client];
                    }
                    
                    NSMutableArray *numberArray = [NSMutableArray arrayWithCapacity:10];
                    for (ClientObject *receipt in self.receipts) {
                        NSString *phoneNumber = receipt.cVal;
                        
                        if (!phoneNumber) {
                            continue;
                        } else {
                            phoneNumber = [self getCleanPhoneNumber:phoneNumber];
                            if (phoneNumber.length >= 11) {
                                [numberArray addObject:phoneNumber];
                            } else {
                                continue;
                            }
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
                UserObjectService *us = [UserObjectService sharedUserObjectService];
                UserObject *user = [us getUserObject];
                user.leftSMSCount = [[NSNumber numberWithInt:([user.leftSMSCount intValue] - [self.smsObject.receiversArray count])] stringValue];
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

- (NSString *)getCleanLetter:(NSString *)originalString {
    NSAssert(originalString != nil, @"Input phone number is %@!", @"NIL");
    NSMutableString *strippedString = [NSMutableString 
                                       stringWithCapacity:originalString.length];
    
    NSScanner *scanner = [NSScanner scannerWithString:originalString];
    NSCharacterSet *numbers = [NSCharacterSet 
                               characterSetWithCharactersInString:@"0123456789abcdefghijklmnopqrestuvwxyzABCDEFGHIJKLMNOPQRESTUVWXYZ"];
    
    while ([scanner isAtEnd] == NO) {
        NSString *buffer;
        if ([scanner scanCharactersFromSet:numbers intoString:&buffer]) {
            [strippedString appendString:buffer];
            
        } else {
            [scanner setScanLocation:([scanner scanLocation] + 1)];
        }
    }
    NSLog(@"strippedString : %@",strippedString);
    return strippedString;
}

- (NSString *)getCleanPhoneNumber:(NSString *)originalString {
    NSAssert(originalString != nil, @"Input phone number is %@!", @"NIL");
    NSMutableString *strippedString = [NSMutableString 
                                       stringWithCapacity:originalString.length];
    
    NSScanner *scanner = [NSScanner scannerWithString:originalString];
    NSCharacterSet *numbers = [NSCharacterSet 
                               characterSetWithCharactersInString:@"0123456789"];
    
    while ([scanner isAtEnd] == NO) {
        NSString *buffer;
        if ([scanner scanCharactersFromSet:numbers intoString:&buffer]) {
            [strippedString appendString:buffer];
            
        } else {
            [scanner setScanLocation:([scanner scanLocation] + 1)];
        }
    }
    NSLog(@"strippedString : %@",strippedString);
    return strippedString;
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
            [self createPartySuc];
			break;
		case MessageComposeResultFailed:{
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"错误" message:@"发送失败，请重新发送" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
            av.tag = 10011;
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
//    ABPeoplePickerNavigationController *ppnc = [[ABPeoplePickerNavigationController alloc] init];
//    ppnc.peoplePickerDelegate = self;
//    [ppnc setDisplayedProperties:[NSArray
//                                  arrayWithObject:[NSNumber numberWithInt:kABPersonPhoneProperty]]];
//    
//    [self.navigationController presentModalViewController:ppnc animated:YES];

//    ContactsListPickerViewController *list = [[ContactsListPickerViewController alloc] init];
//    list.contactDelegate = self;
//    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:list];
//    [self.navigationController presentModalViewController:nav animated:YES];
    
    SegmentManagingViewController * segmentManagingViewController = [[SegmentManagingViewController alloc] init];
    segmentManagingViewController.contactDataDelegate = self;
    UINavigationController *pickersNav = [[UINavigationController alloc] initWithRootViewController:segmentManagingViewController];
    [self.navigationController presentModalViewController:pickersNav animated:YES];
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

#pragma mark - 
#pragma mark alert view delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 10011) {
        [self.navigationController dismissModalViewControllerAnimated:YES];
    }
}

#pragma mark -
#pragma mark people picker delegate
- (BOOL)peoplePickerNavigationController:
            (ABPeoplePickerNavigationController *)peoplePicker
            shouldContinueAfterSelectingPerson:(ABRecordRef)person {
        
    return YES; 
    
}
// Display the selected property
- (BOOL)peoplePickerNavigationController:
(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
    // We are guaranteed to only be working with e-mail or phone [self dismissModalViewControllerAnimated:YES];
    NSArray *array = [ABContact arrayForProperty:property
                                        inRecord:person];
    ABContact *contact = [ABContact contactWithRecord:person];
    NSString *phone = (NSString *)[array objectAtIndex:identifier];
    NSString *name = [contact compositeName];
    NSDictionary *personDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                        phone, @"phoneNumber", name, @"name",nil];
    [self addPersonToGroup:personDictionary];
    
    [self.navigationController dismissModalViewControllerAnimated:YES];
    
    return NO;
}
// Handle user cancels
- (void)peoplePickerNavigationControllerDidCancel:
(ABPeoplePickerNavigationController *)peoplePicker {
    
    [self.navigationController dismissModalViewControllerAnimated:YES];
    
}

#pragma mark - Add and remove a person to/from the group

- (void)addPersonToGroup:(NSDictionary *)personDictionary
{
    NSString *number = [personDictionary valueForKey:@"phoneNumber"];
    NSString *name  = [personDictionary valueForKey:@"name"];
    
    // Check for an existing entry for this person, if so remove it
    if ([name isEqualToString:@""]) {
        if ([number isEqualToString:@""]) {
            return;
        }
        NSString *cleanString = [self getCleanLetter:number];
        
        for (NSDictionary *personDict in self.receipts)
        {
            NSString *thePhoneString = [personDict valueForKey:@"phoneNumber"];
            if ([cleanString isEqualToString:[self getCleanLetter:thePhoneString]]) {
                return;
            }
        }
    } else {
        for (NSDictionary *personDict in self.receipts)
        {
            NSString *theContactName = [personDict valueForKey:@"name"];
            NSString *thePhoneString = [personDict valueForKey:@"phoneNumber"];
            //if (abRecordID == (ABRecordID)[[personDict valueForKey:@"abRecordID"] intValue])
            NSLog(@"number :%@ theNumber :%@", number, thePhoneString);
            
            if ([[self getCleanPhoneNumber:number] isEqualToString:thePhoneString] && [name isEqualToString:theContactName]) {
                return;
            }
            
            if ([[self getCleanPhoneNumber:number] isEqualToString:[self getCleanPhoneNumber:thePhoneString]] && ![number isEqualToString:@""])
            {
                return;
            }
            
            if ([number isEqualToString:@""] && [theContactName isEqualToString:name]) {
                return;
            }
        }
    }
    
    [self.receipts addObject:personDictionary];
    [self rearrangeContactNameTFContent];
}

#pragma mark -
#pragma mark update remain count
- (void)updateRemainCount {
    AddressBookDBService *fav = [AddressBookDBService sharedAddressBookDBService];
    for (ClientObject *client in self.receipts){
        [fav useContact:client];
    }
    return;
    if(!self.editingTableViewCell.textView.text || [self.editingTableViewCell.textView.text isEqualToString:@""]){
        UIAlertView *alert=[[UIAlertView alloc]
                            initWithTitle:@"短信内容不可以为空"
                            message:@"内容为必填项"
                            delegate:self
                            cancelButtonTitle:@"请点击输入内容"
                            otherButtonTitles: nil];
        [alert show];
        return;
    }else{
        [self saveSMSInfo];
        if ([self.smsObject.receiversArray count] == 0) {
            UIAlertView *alertV = [[UIAlertView alloc] initWithTitle:@"警告" message:@"您的短信未指定任何收件人，继续保存？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"继续", nil];
            [alertV show];
            return;
        }
    }
    
    if (self.smsObject._isSendBySelf) {
        [self SMSContentInputDidFinish];
    } else {
        UserObjectService *us = [UserObjectService sharedUserObjectService];
        UserObject *user = [us getUserObject];
        NSString *requestURL = [NSString stringWithFormat:@"%@%d",ACCOUNT_REMAINING_COUNT,user.uID];
         NSLog(@"result:%@",requestURL);
        ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:requestURL]];
        [request setDelegate:self];
        [request setDidFinishSelector:@selector(remainCountRequestDidFinish:)];
        [request setDidFailSelector:@selector(remainCountRequestDidFail:)];
        [request startSynchronous];
        [self showWaiting];
    }
} 

- (void)remainCountRequestDidFinish:(ASIHTTPRequest *)request {
    [self dismissWaiting];
    NSString *response = [request responseString];
    SBJsonParser *parser = [[SBJsonParser alloc] init];
	NSDictionary *result = [parser objectWithString:response];
    NSLog(@"response : %d",[request responseStatusCode]);
    if ([request responseStatusCode] == 200) {
        NSNumber *remainCount = [[result objectForKey:@"datasource"] objectForKey:@"remaining"];
        UserObjectService *us = [UserObjectService sharedUserObjectService];
        UserObject *user = [us getUserObject];
        user.leftSMSCount = [remainCount stringValue];
        NSLog(@"%@", user.leftSMSCount);
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:UpdateRemainCountFinished object:remainCount]];
        [self SMSContentInputDidFinish];
    } else if([request responseStatusCode] == 404){
        [self showAlertRequestFailed:REQUEST_ERROR_404];
    } else {
        [self showAlertRequestFailed:REQUEST_ERROR_500];
    }
}

- (void)remainCountRequestDidFail:(ASIHTTPRequest *)request {
    [self dismissWaiting];
    NSError *error = [request error];
}

#pragma mark -
#pragma mark segment contact delegate
- (NSArray *)getCurrentContactData {
    NSLog(@"%@",self.receipts);
    return self.receipts;
}

- (void)setNewContactData : (NSArray *)newData {
    self.receipts = [NSMutableArray arrayWithArray:newData];
    [self rearrangeContactNameTFContent];
}

- (void)selectedFinishedInController:(UIViewController *)vc {
    [self.navigationController dismissModalViewControllerAnimated:YES];
}
@end