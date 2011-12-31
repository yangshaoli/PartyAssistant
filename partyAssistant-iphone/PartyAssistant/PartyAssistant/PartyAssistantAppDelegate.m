//
//  PartyAssistantAppDelegate.m
//  PartyAssistant
//
//  Created by 超 李 on 11-10-26.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "PartyAssistantAppDelegate.h"
#import "ECPurchase.h"

@implementation PartyAssistantAppDelegate

@synthesize window = _window;

- (void)applicationDidFinishLaunching:(UIApplication *)application {
    NSLog(@"Luanch");
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    NSLog(@"resign active");
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
    NSLog(@"Background");
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    NSLog(@"Foreground");
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [[ECPurchase shared] verifyReceiptsStoredOnLocal];
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    NSLog(@"BecomeActive");
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
    NSLog(@"WillTerminate");
}

#pragma Push Notification
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {          
    NSLog(@"Luanch Option");
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)];    
    if(addressBook == nil) {
        addressBook = ABAddressBookCreate();
        ABAddressBookRegisterExternalChangeCallback(addressBook, addressBookChanged, self);
    }
    _window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    PartyLoginViewController *login = [[PartyLoginViewController alloc] initWithNibName:nil bundle:nil];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:login];
    [_window addSubview:nav.view];

    application.applicationIconBadgeNumber = 0; //程序开启，设置UIRemoteNotificationTypeBadge标识为0
    
    [[ECPurchase shared] addTransactionObserver];
    [[ECPurchase shared] setProductDelegate:self];
    [[ECPurchase shared] setTransactionDelegate:self];
    [[ECPurchase shared] setVerifyRecepitMode:ECVerifyRecepitModeServer];
    
    return YES;  
}  

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{  
    NSString *data = [[[deviceToken description] 
                       stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]] 
                      stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSLog(@"deviceToken: %@", data);
    [DeviceTokenService saveDeviceToken:data];
}  

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {  
    NSLog(@"Error in registration. Error: %@", error);  
}  

-(void)sendRequestToSaveUserToken{
    
}

//- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo  
//{  
//    
//    NSLog(@"收到推送消息 ：%@",[[userInfo objectForKey:@"aps"] objectForKey:@"alert"]);  
//    if ([[userInfo objectForKey:@"aps"] objectForKey:@"alert"]!=NULL) {  
//        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"推送通知"   
//                                                        message:[[userInfo objectForKey:@"aps"] objectForKey:@"alert"]           
//                                                       delegate:self          
//                                              cancelButtonTitle:@"关闭"       
//                                              otherButtonTitles:@"更新状态",nil];  
//        [alert show];  
//        [alert release];  
//    }  
//}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    NSLog(@"收到推送消息 ：%@",userInfo);
    NSString *badge = [[userInfo objectForKey:@"aps"] objectForKey:@"badge"];
    application.applicationIconBadgeNumber = [badge intValue];
    NSString *operation = [userInfo objectForKey:@"operation"];
    NSLog(@"operation:%@",operation);
    if ([operation isEqualToString:@"enroll"]) {
        NSNotification *notification = [NSNotification notificationWithName:ADD_BADGE_TO_TABBAR object:nil userInfo:[[NSDictionary alloc] initWithObjectsAndKeys:badge,@"badge",nil]];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
    }
}

void addressBookChanged(ABAddressBookRef reference, CFDictionaryRef dictionary, void *context) {
    //	DialerAppDelegate *dialerDelegate = context;
    //	[dialerDelegate refreshServices];
    //	[[AddressBookDataManager sharedAddressBookDataManager] setNeedsUpdate];
    //	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kUpdateContactsDataNotification object:nil]];
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
    
    NSLog(@"%@",[[products lastObject] productIdentifier]);
    
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
    NSLog(@"Fail");
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
    NSLog(@"Success");
}

-(void)didCompleteTransactionAndVerifyFailed:(NSString *)proIdentifier withError:(NSString *)error {
    if (_HUD) {
        _HUD.labelText = @"交易失败";
        [_HUD hide:YES afterDelay:1.0f];
    }
    NSLog(@"Fail");
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
	//		NSString *debugger = [[result objectForKey:@"status"] objectForKey:@"debugger"];
	//[NSThread detachNewThreadSelector:@selector(dismissWaiting) toTarget:self withObject:nil];
    //	[self dismissWaiting];
    if([request responseStatusCode] == 200){
        if ([description isEqualToString:@"ok"]) {
            NSDictionary *dataSource = [result objectForKey:@"datasource"];
            NSNotification *notification = [NSNotification notificationWithName:ADD_BADGE_TO_TABBAR object:nil userInfo:[[NSDictionary alloc] initWithObjectsAndKeys:[dataSource objectForKey:@"badgeNum"],@"badge",nil]];
            [[NSNotificationCenter defaultCenter] postNotification:notification];
        }
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request
{

}
@end
