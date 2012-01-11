//
//  ResendPartyViaSMSViewController.m
//  PartyAssistant
//
//  Created by Wang Jun on 12/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ResendPartyViaSMSViewController.h"
#import "ABContact.h"
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
- (void)showLessRemainingCountAlert;
- (void)gotoPurchasPage;
@end


@implementation ResendPartyViaSMSViewController
@synthesize tempSMSObject;

#pragma mark - Private Method

- (void)rearrangeContactNameTFContent {
    [super performSelector:@selector(rearrangeContactNameTFContent)];
}

-(void)showWaiting {
    [super performSelector:@selector(showWaiting)];
}

-(void)dismissWaiting {
    [super performSelector:@selector(dismissWaiting)];
}

- (void)showAlertRequestSuccess {
    [super performSelector:@selector(showAlertRequestSuccess)];
}

- (void)showAlertRequestSuccessWithMessage: (NSString *) theMessage {
    [super performSelector:@selector(showAlertRequestSuccessWithMessage:) withObject:theMessage];
}
- (void)showAlertRequestFailed: (NSString *) theMessage; {
    [super performSelector:@selector(showAlertRequestFailed:) withObject:theMessage];
}

- (NSString *)getCleanPhoneNumber:(NSString *)originalString {
    return [super performSelector:@selector(getCleanPhoneNumber:) withObject:originalString];
}

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

- (void)createPartySuc{
    self.editingTableViewCell.textView.text = @"";
    self.receipts = [NSMutableArray arrayWithCapacity:10];
    [self rearrangeContactNameTFContent];
    
    self.tabBarController.selectedIndex = 1;
   [self.navigationController dismissModalViewControllerAnimated:YES];
    [self.navigationController popViewControllerAnimated:YES];
    
    //    NSNotification *notification = [NSNotification notificationWithName:CREATE_PARTY_SUCCESS object:nil userInfo:nil];
    //    [[NSNotificationCenter defaultCenter] postNotification:notification];
    //    [self.navigationController dismissModalViewControllerAnimated:NO];
}

#pragma mark -
#pragma mark custom method
- (void)SMSContentInputDidFinish {
//    [self saveSMSInfo];
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
        if ([self.tempSMSObject.receiversArray count] == 0) {
            UIAlertView *alertV = [[UIAlertView alloc] initWithTitle:@"警告" message:@"请添加有效的收件人" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
            [alertV show];
            return;
        }
    }
    
    //    if ([self.smsObject.receiversArray count] == 0) {
    //        UIAlertView *alertV = [[UIAlertView alloc] initWithTitle:@"警告" message:@"您的短信未指定任何收件人，继续保存？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"继续", nil];
    //            [alertV show];
    //    }else{
    //        UserObjectService *us = [UserObjectService sharedUserObjectService];
    //        UserObject *user = [us getUserObject];
    if (self.tempSMSObject._isSendBySelf) {
        
    } else {
        //            if ([user.leftSMSCount intValue] < [self.smsObject.receiversArray count]) {
        //                UIAlertView *alert=[[UIAlertView alloc]
        //                                    initWithTitle:@"需要充值"
        //                                    message:@"余额不足，不能通过服务器端发送！"
        //                                    delegate:nil
        //                                    cancelButtonTitle:@"确定"
        //                                    otherButtonTitles: nil];
        //                [alert show];
        //                return;
        //            }
    }        
    [self sendCreateRequest];
//    
//    if ([self.tempSMSObject.receiversArray count] == 0) {
//        UIAlertView *alertV = [[UIAlertView alloc] initWithTitle:@"警告" message:@"您的短信未指定任何收件人，继续保存？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"继续", nil];
//        [alertV show];
//    }else{
//        UserObjectService *us = [UserObjectService sharedUserObjectService];
//        UserObject *user = [us getUserObject];
//        if (self.tempSMSObject._isSendBySelf) {
//            
//        } else {
//            if ([user.leftSMSCount intValue] < [self.smsObject.receiversArray count]) {
//                UIAlertView *alert=[[UIAlertView alloc]
//                                    initWithTitle:@"需要充值"
//                                    message:@"余额不足，不能通过服务器端发送！"
//                                    delegate:nil
//                                    cancelButtonTitle:@"确定"
//                                    otherButtonTitles: nil];
//                [alert show];
//                return;
//            }
//        }
//        
//        [self sendCreateRequest];
//    }

//
//    
//    if(!self.editingTableViewCell.textView.text || [self.editingTableViewCell.textView.text isEqualToString:@""]){
//        UIAlertView *alert=[[UIAlertView alloc]
//                            initWithTitle:@"短信内容不可以为空"
//                            message:@"内容为必填项"
//                            delegate:self
//                            cancelButtonTitle:@"请点击输入内容"
//                            otherButtonTitles: nil];
//        [alert show];
//    }else{
//        [self saveSMSInfo];
//        if ([self.tempSMSObject.receiversArray count] == 0) {
//            UIAlertView *alertV = [[UIAlertView alloc] initWithTitle:@"警告" message:@"您的短信未指定任何有效收件人，继续保存？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"继续", nil];
//            [alertV show];
//        }else{
//            [self sendCreateRequest];
//        }
//    }
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
	[self dismissWaiting];
	NSString *response = [request responseString];
	SBJsonParser *parser = [[SBJsonParser alloc] init];
	NSDictionary *result = [parser objectWithString:response];
    NSString *status = [result objectForKey:@"status"];
	NSString *description = [result objectForKey:@"description"];
    if ([request responseStatusCode] == 200) {
        if ([status isEqualToString:@"ok"]) {
            NSString *applyURL = [[result objectForKey:@"datasource"] objectForKey:@"applyURL"];
            if (self.tempSMSObject._isSendBySelf) {
                if([MFMessageComposeViewController canSendText]==YES){
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
                    [self createPartySuc];
                #if TARGET_IPHONE_SIMULATOR // iPhone Simulator
                    return;
                #endif
                }
                
            }else{
                [self createPartySuc];
                }
        }else if ([status isEqualToString:@"lessRemain"]){
            NSDictionary *infos = [result objectForKey:@"data"];
            NSNumber *leftCount = nil;
            leftCount = [infos objectForKey:@"leftCount"];
            if (leftCount) {
                [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:UpdateRemainCountFinished object:leftCount]];
                [self showLessRemainingCountAlert];
                return;
            }
            [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:UpdateRemainCountFailed object:nil]];
        } else {
            [self showAlertRequestFailed:description];	
        }
    } else if ([request responseStatusCode] == 404){
        [self showAlertRequestFailed:REQUEST_ERROR_404];
    } else {
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

#pragma mark -
#pragma mark update remain count
- (void)updateRemainCount {
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
        if ([self.tempSMSObject.receiversArray count] == 0) {
            UIAlertView *alertV = [[UIAlertView alloc] initWithTitle:@"警告" message:@"您的短信未指定任何收件人，继续保存？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"继续", nil];
            [alertV show];
            return;
        }
    }
    
    if (self.tempSMSObject._isSendBySelf) {
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
@end
