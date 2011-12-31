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

@interface ResendPartyViaSMSViewController ()

- (void)rearrangeContactNameTFContent;
- (void)createPartySuc;
-(void)showWaiting;
-(void)dismissWaiting; 
- (void)showAlertRequestSuccess;
- (void)showAlertRequestSuccessWithMessage: (NSString *) theMessage;
- (void)showAlertRequestFailed: (NSString *) theMessage;

@end


@implementation ResendPartyViaSMSViewController

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
    [request setPostValue:editingTableViewCell.textView.text forKey:@"content"];
    [request setPostValue:@"" forKey:@"subject"];
    [request setPostValue:[NSNumber numberWithBool:self.smsObject._isApplyTips] forKey:@"_isapplytips"];
    [request setPostValue:[NSNumber numberWithBool:self.smsObject._isSendBySelf] forKey:@"_issendbyself"];
    [request setPostValue:@"SMS" forKey:@"msgType"];
    [request setPostValue:[NSNumber numberWithBool:groupID] forKey:@"partyID"];
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


- (void)setReceipts:(NSArray *)receipts {
    [super setReceipts:[receipts mutableCopy]];
}

- (void)setSmsContent:(NSString *)newContent andGropID:(NSInteger)newGroupID{
    smsContent = [newContent copy];
    editingTableViewCell.textView.text = smsContent;
    groupID = newGroupID;
}
@end
