//
//  PartyAssistantAppDelegate.m
//  PartyAssistant
//
//  Created by 超 李 on 11-10-26.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "PartyAssistantAppDelegate.h"
#import "AddressBookDataManager.h"
#import "UIViewControllerExtra.h"
#import "DataManager.h"
#import "GuideViewController.h"

@implementation PartyAssistantAppDelegate

@synthesize window = _window;
@synthesize remainCountRequest = _remainCountRequest;
@synthesize nav = _nav;

- (void)applicationDidFinishLaunching:(UIApplication *)application {
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    
    [[ECPurchase shared] verifyReceiptsStoredOnLocal];
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    UserObjectService *s = [UserObjectService sharedUserObjectService];
    UserObject *u = [s getUserObject];
    if (application.applicationIconBadgeNumber > 0 && u.uID>0) {
        [self performSelectorOnMainThread:@selector(getBadgeNumber:) withObject:[NSNumber numberWithInt:u.uID] waitUntilDone:NO];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

#pragma Push Notification
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {          
    NSLog(@"Luanch Option");
    _window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    if(addressBook == nil) {
        addressBook = ABAddressBookCreate();
        ABAddressBookRegisterExternalChangeCallback(addressBook, addressBookChanged, self);
    }
    
    GuideViewController *gViewController = [[GuideViewController alloc] initWithNibName:nil bundle:nil];
    PartyLoginViewController *login = [[PartyLoginViewController alloc] initWithNibName:nil bundle:nil];
    _nav = [[UINavigationController alloc] initWithRootViewController:login];
    [self.window addSubview:_nav.view];
    
    //Show the user guide, if the new version app is comming
    NSString *versionString = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    
    NSString *savedVersion = [[NSUserDefaults standardUserDefaults] stringForKey:@"AppBundleVersion"];
    if (![versionString isEqualToString:savedVersion]) {
        [self.window addSubview:gViewController.view];
        [[NSUserDefaults standardUserDefaults] setValue:versionString forKey:@"AppBundleVersion"];
    }
    
    [login release];
    
    application.applicationIconBadgeNumber = 0; //程序开启，设置UIRemoteNotificationTypeBadge标识为0
    
    [[ECPurchase shared] addTransactionObserver];
    [[ECPurchase shared] setProductDelegate:self];
    [[ECPurchase shared] setTransactionDelegate:self];
    [[ECPurchase shared] setVerifyRecepitMode:ECVerifyRecepitModeServer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateRemainCount) name:UpdateReMainCount object:nil];
    
    [self.window makeKeyAndVisible];
    
    return YES;  
}  

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{  
    NSString *data = [[[deviceToken description] 
                       stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]] 
                      stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *savedDeviceToken = [DeviceTokenService getDeviceToken];
    if ([savedDeviceToken isEqualToString:@""]) {
        [DeviceTokenService saveDeviceToken:data];
        [[DataManager sharedDataManager] performSelectorInBackground:@selector(bindDeviceToken) withObject:nil];
    }
}  

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {  
}  

-(void)sendRequestToSaveUserToken{
    
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    NSString *badge = [[userInfo objectForKey:@"aps"] objectForKey:@"badge"];
    application.applicationIconBadgeNumber = [badge intValue];
    NSString *operation = [userInfo objectForKey:@"operation"];
    if ([operation isEqualToString:@"enroll"]) {
        NSNotification *notification = [NSNotification notificationWithName:ADD_BADGE_TO_TABBAR object:nil userInfo:[[NSDictionary alloc] initWithObjectsAndKeys:badge,@"badge",nil]];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
    }
}

void addressBookChanged(ABAddressBookRef reference, CFDictionaryRef dictionary, void *context) {
	[[AddressBookDataManager sharedAddressBookDataManager] setNeedsUpdate];
    NSNotification *notification = [NSNotification notificationWithName:ADDRESSBOOK_UPDATED object:nil userInfo:nil];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}

#pragma mark -
#pragma Purchase Delegate
-(void)didBeginProductsRequest {
    _HUD = [[MBProgressHUD alloc] initWithView:self.window];
	[self.window addSubview:_HUD];
    _HUD.labelText = @"检查产品状态";
    
    _HUD.delegate = self;
    
    [_HUD show:YES];

}

-(void)didReceivedProducts:(NSArray *)products {
    if (_HUD) {
        _HUD.labelText = @"获取产品信息中...";
    }
    
    
    [[ECPurchase shared] addPayment:[products lastObject]];
}

-(void)requestDidFail {
    if (_HUD) {
        [_HUD hide:YES];
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"产品提交失败" message:@"稍后再试" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
    [alert show];
}

-(void)didFailedTransaction:(NSString *)proIdentifier {
    if (_HUD) {
        _HUD.labelText = @"交易失败";
        [_HUD hide:YES afterDelay:1.0f];
    }
}

-(void)didRestoreTransaction:(NSString *)proIdentifier {
    
}

-(void)didCompleteTransaction:(NSString *)proIdentifier {
    if (_HUD) {
        _HUD.labelText = @"交易完成";
        [_HUD hide:YES afterDelay:1.0f];
    }
}

-(void)didCompleteTransactionAndVerifySucceed:(NSString *)proIdentifier {
    if (_HUD) {
        _HUD.labelText = @"交易完成";
        [_HUD hide:YES afterDelay:1.0f];
    }
}

-(void)didCompleteTransactionAndVerifyFailed:(NSString *)proIdentifier withError:(NSString *)error {
    if (_HUD) {
        _HUD.labelText = @"交易失败";
        [_HUD hide:YES afterDelay:1.0f];
    }
}

#pragma mark -
#pragma HUD delegate
- (void)HUDWasHidden:(MBProgressHUD *)hUD {
    // Remove _HUD from screen when the _HUD was hidded
    [_HUD removeFromSuperview];
    [_HUD release];
    _HUD = nil;
}

- (void)getBadgeNumber:(id)uid
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?id=%@",GET_USER_BADGE_NUM,uid]];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    request.timeOutSeconds = 20;
    [request setDelegate:self];
    [request setShouldAttemptPersistentConnection:NO];
    [request startAsynchronous];
}
- (void)showAlertRequestFailed: (NSString *) theMessage{
	UIAlertView *av=[[UIAlertView alloc] initWithTitle:@"操作失败!" message:theMessage delegate:self cancelButtonTitle:nil otherButtonTitles:@"好的",nil];
    [av show];
}

- (void)getVersionFromRequestDic:(NSDictionary *)result{
    NSUserDefaults *versionDefault=[NSUserDefaults standardUserDefaults];
    NSUserDefaults *isUpdateVersionDefault=[NSUserDefaults standardUserDefaults];
    NSString *newVersionString = [result objectForKey:@"version"];
    if(newVersionString==nil&&[newVersionString isEqualToString:@""]){
        return;
    }else{
        NSString *preVersionString=[versionDefault objectForKey:@"airenaoIphoneVersion"];
        if([newVersionString floatValue]>[preVersionString floatValue]){
            [versionDefault setObject:newVersionString forKey:@"airenaoIphoneVersion"];
            [isUpdateVersionDefault setBool:YES forKey:@"isUpdateVersion"];
        }else{
            [isUpdateVersionDefault setBool:NO forKey:@"isUpdateVersion"];
        }
    }
}
- (void)requestFinished:(ASIHTTPRequest *)request{
	NSString *response = [request responseString];
	SBJsonParser *parser = [[SBJsonParser alloc] init];
	NSDictionary *result = [parser objectWithString:response];
    [self getVersionFromRequestDic:result];
    NSString *status = [result objectForKey:@"status"];   
	NSString *description = [result objectForKey:@"description"];
	//		NSString *debugger = [[result objectForKey:@"status"] objectForKey:@"debugger"];
	//[NSThread detachNewThreadSelector:@selector(dismissWaiting) toTarget:self withObject:nil];
    //	[self dismissWaiting];
    if([request responseStatusCode] == 200){
        if ([status isEqualToString:@"ok"]) {
            NSDictionary *dataSource = [result objectForKey:@"datasource"];
            NSNotification *notification = [NSNotification notificationWithName:ADD_BADGE_TO_TABBAR object:nil userInfo:[[NSDictionary alloc] initWithObjectsAndKeys:[dataSource objectForKey:@"badgeNum"],@"badge",nil]];
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
    }else{
        [self showAlertRequestFailed:REQUEST_ERROR_504];
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request
{

}

#pragma mark -
#pragma mark update remain count
- (void)updateRemainCount {
    if (self.remainCountRequest) {
        if (![self.remainCountRequest isFinished]) {
            return;
        }
    }
    UserObjectService *us = [UserObjectService sharedUserObjectService];
    UserObject *user = [us getUserObject];
    NSString *requestURL = [NSString stringWithFormat:@"%@%d",ACCOUNT_REMAINING_COUNT,user.uID];
    //if (!self.remainCountRequest) {
    self.remainCountRequest = nil;
    self.remainCountRequest = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:requestURL]];
   // } else {
    //    [self.remainCountRequest setURL:[NSURL URLWithString:requestURL]]; 
   // }
    [_remainCountRequest setDelegate:self];
    [_remainCountRequest setDidFinishSelector:@selector(remainCountRequestDidFinish:)];
    [_remainCountRequest setDidFailSelector:@selector(remainCountRequestDidFail:)];
    [_remainCountRequest startSynchronous];
    return;
} 

- (void)remainCountRequestDidFinish:(ASIHTTPRequest *)request {
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
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:UpdateRemainCountFinished object:[NSNumber numberWithInt:[remainCount intValue]]]];
        return;
    } else if([request responseStatusCode] == 404){
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:UpdateRemainCountFailed object:nil]];
    } else {
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:UpdateRemainCountFailed object:nil]];
    }
//------------------wu xue zhang
//    else if([request responseStatusCode] == 404){
//        [self showAlertRequestFailed:REQUEST_ERROR_404];
//    }else if([request responseStatusCode] == 500){
//        [self showAlertRequestFailed:REQUEST_ERROR_500];
//    }else if([request responseStatusCode] == 502){
//        [self showAlertRequestFailed:REQUEST_ERROR_502];
//    }else{
//        [self showAlertRequestFailed:REQUEST_ERROR_504];
//>>>>>>> wuxuezhang
//    }
    [request clearDelegatesAndCancel];
}

- (void)remainCountRequestDidFail:(ASIHTTPRequest *)request {
    NSError *error = [request error];
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:UpdateRemainCountFailed object:nil]];
     [request clearDelegatesAndCancel];
}

- (void)dealloc {
    [super dealloc];
    self.nav = nil;
    [_nav release];
}
@end
