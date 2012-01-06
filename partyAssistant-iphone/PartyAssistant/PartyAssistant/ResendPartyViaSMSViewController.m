//
//  ResendPartyViaSMSViewController.m
//  PartyAssistant
//
//  Created by Wang Jun on 12/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ResendPartyViaSMSViewController.h"
#import "ContactsListPickerViewController.h"
#import "PartyAssistantAppDelegate.h"
#import "NotificationSettings.h"
#import "URLSettings.h"
#import "ASIFormDataRequest.h"
#import "SMSObjectService.h"
#import "HTTPRequestErrorMSG.h"
#import "DeviceDetection.h"
#import "AddressBookDataManager.h"

@interface ResendPartyViaSMSViewController ()

- (void)rearrangeContactNameTFContent;
- (void)createPartySuc;
-(void)showWaiting;
-(void)dismissWaiting; 
- (void)showAlertRequestSuccess;
- (void)showAlertRequestSuccessWithMessage: (NSString *) theMessage;
- (void)showAlertRequestFailed: (NSString *) theMessage;
- (NSString *)getCleanPhoneNumber:(NSString *)originalString;

@end


@implementation ResendPartyViaSMSViewController
@synthesize tempSMSObject;
#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tempSMSObject = [[SMSObject alloc] init];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.tempSMSObject._isSendBySelf) {
        self.sendModeNameLabel.text = @"用自己手机发送";
    } else {
        self.sendModeNameLabel.text = @"通过服务器发送";
    }
}
#pragma mark -
#pragma mark custom method
- (void)SMSContentInputDidFinish {
    if(!self.editingTableViewCell.textView.text || [self.editingTableViewCell.textView.text isEqualToString:@""]){
        UIAlertView *alert=[[UIAlertView alloc]
                            initWithTitle:@"短信内容不可以为空"
                            message:@"内容为必填项"
                            delegate:self
                            cancelButtonTitle:@"请点击输入内容"
                            otherButtonTitles: nil];
        [alert show];
    }else{
        [self saveSMSInfo];
        if ([self.tempSMSObject.receiversArray count] == 0) {
            UIAlertView *alertV = [[UIAlertView alloc] initWithTitle:@"警告" message:@"您的短信未指定任何有效收件人，继续保存？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"继续", nil];
            [alertV show];
        }else{
            [self sendCreateRequest];
        }
    }
}

- (void)saveSMSInfo{
    self.tempSMSObject.smsContent = [self.editingTableViewCell.textView text];
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:10];
    for (NSDictionary *receipt in self.receipts) {
        //need check phone format
        //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        ClientObject *client = [[ClientObject alloc] init];
        client.cName = [receipt objectForKey:@"name"];
        NSString *phoneNumber = [receipt objectForKey:@"phoneNumber"];
        
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
    
    self.tempSMSObject.receiversArray = array;
}

- (void)sendCreateRequest{
    [self showWaiting];
    BaseInfoService *bs = [BaseInfoService sharedBaseInfoService];
    BaseInfoObject *baseinfo = [bs getBaseInfo];
    UserObjectService *us = [UserObjectService sharedUserObjectService];
    UserObject *user = [us getUserObject];
    NSURL *url = [NSURL URLWithString:RESEND_MSG_TO_CLIENT];
    NSString *platform = [DeviceDetection platform];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setPostValue:[self.tempSMSObject setupReceiversArrayData] forKey:@"receivers"];
    [request setPostValue:self.editingTableViewCell.textView.text forKey:@"content"];
    [request setPostValue:[NSNumber numberWithBool:self.tempSMSObject._isSendBySelf] forKey:@"_issendbyself"];
    [request setPostValue:[NSNumber numberWithInteger:user.uID] forKey:@"uID"];
    [request setPostValue:platform forKey:@"addressType"];
    [request setPostValue:[NSNumber numberWithInt:groupID] forKey:@"partyID"];
    
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
            if (self.tempSMSObject._isSendBySelf) {
                if([MFMessageComposeViewController canSendText]==YES){
                    NSLog(@"可以发送短信");
                    MFMessageComposeViewController *vc = [[MFMessageComposeViewController alloc] init];
                    if (self.tempSMSObject._isApplyTips) {
                        vc.body = [self.tempSMSObject.smsContent stringByAppendingString:[NSString stringWithFormat:@"(报名链接: %@)",applyURL]];
                    }else{
                        vc.body = self.tempSMSObject.smsContent;
                    };
                    
                    NSMutableArray *numberArray = [NSMutableArray arrayWithCapacity:10];
                    for (NSDictionary *receipt in self.receipts) {
                        NSString *phoneNumber = [receipt objectForKey:@"phoneNumber"];
                        
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
                    [self.tempSMSObject clearObject];
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
#pragma mark save related data

- (void)setNewReceipts:(NSArray *)newValues {
    NSMutableArray *newReceipts = [NSMutableArray arrayWithCapacity:10];
    NSLog(@"mark:new Values===========%@",newValues);
    NSDictionary *contactPhoneDic = [[AddressBookDataManager sharedAddressBookDataManager] getCallLogContactData];
    for (NSDictionary *value in newValues) {
        NSLog(@"%@",value);
        NSDictionary *newReceipt = [NSDictionary dictionaryWithObjectsAndKeys: [value objectForKey:@"cName"], @"name", [value objectForKey:@"cValue"], @"phoneNumber", nil];
        NSLog(@"%@",newReceipt);
        
        NSString *phoneNumber = [value objectForKey:@"cValue"];
        
        ClientObject *newClient = [[ClientObject alloc] init];
        newClient.cName = [value objectForKey:@"cName"];
        newClient.cVal = [value objectForKey:@"cValue"];
        
        BOOL isNeedNewName = NO;
        
        if ([[value objectForKey:@"cName"] isEqualToString:@""]) {
            isNeedNewName = YES;
        }
        
        ABContact *theContact = [contactPhoneDic objectForKey:phoneNumber];
        
        if (theContact) {
            
            ABRecordID contactID = theContact.recordID;
            ABRecordRef theSelectContact = ABAddressBookGetPersonWithRecordID(addressBook, contactID);
            ABMultiValueRef phone = ABRecordCopyValue(theSelectContact, kABPersonPhoneProperty);

            
            NSString *aNumber = nil;
            NSInteger selectIndex = -1;
            for (int i=0; i<ABMultiValueGetCount(phone); i++) {
                NSString *number = (__bridge_transfer NSString*)ABMultiValueCopyValueAtIndex(phone, i);
                aNumber = [number stringByReplacingOccurrencesOfString:@"+" withString:@""];
                aNumber = [aNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
                aNumber = [aNumber stringByReplacingOccurrencesOfString:@"(" withString:@""];
                aNumber = [aNumber stringByReplacingOccurrencesOfString:@")" withString:@""];
                aNumber = [aNumber stringByReplacingOccurrencesOfString:@"+" withString:@""];
                aNumber = [aNumber stringByReplacingOccurrencesOfString:@"#" withString:@""];
                aNumber = [aNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
                
                if ([aNumber isEqualToString:phoneNumber]) {
                    selectIndex = i;
                    if (isNeedNewName) {
                        newClient.cName = [theContact contactName];
                    }
                    break;
                }
            }
            
            if (selectIndex == -1) {
                
            } else {
                ABMultiValueIdentifier indentifier = ABMultiValueGetIdentifierAtIndex(phone, selectIndex);
                NSString *label = (__bridge NSString *)ABMultiValueCopyLabelAtIndex(phone, selectIndex);
                newClient.phoneIdentifier = indentifier;
                newClient.cID = contactID;
                newClient.phoneLabel = label;
            }
        }
        [newReceipts addObject:newClient];
    }
    [super setReceipts:[newReceipts mutableCopy]];
    
    [self rearrangeContactNameTFContent];
}

- (void)setSmsContent:(NSString *)newContent andGropID:(NSInteger)newGroupID{
    smsContent = [newContent copy];
    [self.editingTableViewCell setText:[smsContent mutableCopy]];
    NSLog(@"%@",self.editingTableViewCell);
    groupID = newGroupID;
}

#pragma mark - 
#pragma mark UserSMSModeCheckDelegate

- (BOOL)IsCurrentSMSSendBySelf {
    return self.tempSMSObject._isSendBySelf;
}

- (void)changeSMSModeToSendBySelf:(BOOL)status {
    self.tempSMSObject._isSendBySelf = status;
}
@end
