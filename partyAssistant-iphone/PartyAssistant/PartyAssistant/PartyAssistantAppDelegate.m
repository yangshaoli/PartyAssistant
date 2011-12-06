//
//  PartyAssistantAppDelegate.m
//  PartyAssistant
//
//  Created by 超 李 on 11-10-26.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "PartyAssistantAppDelegate.h"

@implementation PartyAssistantAppDelegate

@synthesize window = _window;

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
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
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
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)];    
    // other codes here.
    _window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    PartyLoginViewController *login = [[PartyLoginViewController alloc] initWithNibName:nil bundle:nil];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:login];
    [_window addSubview:nav.view];
    application.applicationIconBadgeNumber = 0; //程序开启，设置UIRemoteNotificationTypeBadge标识为0
    return YES;  
}  

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {  
    NSLog(@"deviceToken: %@", deviceToken);  
}  

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {  
    NSLog(@"Error in registration. Error: %@", error);  
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
    application.applicationIconBadgeNumber = 0;
    for (id key in userInfo) {
        NSLog(@"key: %@, value: %@", key, [userInfo objectForKey:key]);
    }    
    
}

@end
