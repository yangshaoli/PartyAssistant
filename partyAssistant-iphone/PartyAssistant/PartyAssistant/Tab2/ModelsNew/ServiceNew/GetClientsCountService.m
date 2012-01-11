//
//  GetClientsCountService.m
//  PartyAssistant
//
//  Created by user on 11-12-25.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "GetClientsCountService.h"
#import "URLSettings.h"
#import "HTTPRequestErrorMSG.h"
@implementation GetClientsCountService
@synthesize peopleCountArray;
@synthesize partyObj;
SYNTHESIZE_SINGLETON_FOR_CLASS(GetClientsCountService)
- (id)init
{
    self = [super init];
    if (self) {
               // Initialization code here.
    }
    return self;
}
- (void)loadClientCount
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%d/" ,GET_PARTY_CLIENT_MAIN_COUNT,self.partyObj.partyId]];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    request.timeOutSeconds = 30;
    [request setDelegate:self];
    [request setShouldAttemptPersistentConnection:NO];
    [request startAsynchronous];
}

- (void)showAlertRequestFailed: (NSString *) theMessage{
	UIAlertView *av=[[UIAlertView alloc] initWithTitle:@"Hold on!" message:theMessage delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK",nil];
    [av show];
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
        }else{
           // [self showAlertRequestFailed:description];		
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
    //	NSError *error = [request error];
	//[self dismissWaiting];
	//[self showAlertRequestFailed: error.localizedDescription];
}


@end
