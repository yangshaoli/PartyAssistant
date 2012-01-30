//
//  PurchaseListViewController.m
//  PartyAssistant
//
//  Created by Wang Jun on 12/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PurchaseListViewController.h"
#import "ECPurchase.h"
#import "UserObject.h"
#import "UserObjectService.h"
#import "Reachability.h"

#define kMyFeatureIdentifierLevelOne @"com.airenao.productLevelOne"
#define kMyFeatureIdentifierLevelTwo @"com.airenao.productLevelTwo"

@implementation PurchaseListViewController
@synthesize tableView;
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
    self.navigationItem.title = @"购买列表";
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    } 
    
    if (indexPath.row == 0) {
        cell.textLabel.text = @"购买50条短信";
        cell.detailTextLabel.text = @"¥ 6.00 / $ 0.99";
    } else if (indexPath.row == 1) {
        cell.textLabel.text = @"购买100条短信";
        cell.detailTextLabel.text = @"¥ 12.00 / $ 1.99";
    }
    
    // Configure the cell...
    
    return cell;
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

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
    if([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == kNotReachable) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"无法连接网络，请检查网络状态！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    
    UserObject *user = [[UserObjectService sharedUserObjectService] getUserObject];
    NSString *userID = [[NSNumber numberWithInt:[user uID]] stringValue];

    NSDictionary *purchaseInfo = nil;
    
    if (indexPath.row == 0) {
        purchaseInfo = [NSDictionary dictionaryWithObjectsAndKeys: userID, @"userID", kMyFeatureIdentifierLevelOne, @"identifier", nil];
    } else if (indexPath.row == 1) {
        purchaseInfo = [NSDictionary dictionaryWithObjectsAndKeys: userID, @"userID", kMyFeatureIdentifierLevelTwo, @"identifier", nil];
    } else {
        return;
    }
    
    
    
    [aTableView deselectRowAtIndexPath:indexPath animated:YES];
    
    BOOL isExist = [[ECPurchase shared] isSameReceiptNotVerifyWithServerWithUserInfo:purchaseInfo];
    if (isExist) {
        //action 
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"上一次购买的物品还没有提交到服务器！点击确认以进行此物品的提交！" delegate:self cancelButtonTitle:@"确认" otherButtonTitles: nil];
        alert.tag = 11180 + indexPath.row;
        [alert show];
        
        return;
    }
    
    if ([SKPaymentQueue canMakePayments]) {
        if (indexPath.row == 0) {
            [[ECPurchase shared] requestProductData:[NSArray arrayWithObjects:kMyFeatureIdentifierLevelOne, nil]];
        } else if (indexPath.row == 1) {
            [[ECPurchase shared] requestProductData:[NSArray arrayWithObjects:kMyFeatureIdentifierLevelTwo, nil]];
        } else {
            return;
        }
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"出错啦！" message:@"程序没有被设置为允许购买！" delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil];
        alert.tag = 110;
        [alert show];
    }
    
}

#pragma mark -
#pragma alert delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 11180) {
        if (buttonIndex == 0) {
            UserObject *user = [[UserObjectService sharedUserObjectService] getUserObject];
            
            NSString *userID = [[NSNumber numberWithInt:[user uID]] stringValue];
            
            NSDictionary *purchaseInfo = [NSDictionary dictionaryWithObjectsAndKeys: userID, @"userID", kMyFeatureIdentifierLevelOne, @"identifier", nil];
            
            if (purchaseInfo) {
                [[ECPurchase shared] verifyProductReceiptUserPurchasedBefore:purchaseInfo];
            } else {
                
            }
        }
    }
    if (alertView.tag == 11181) {
        if (buttonIndex == 0) {
            UserObject *user = [[UserObjectService sharedUserObjectService] getUserObject];
            
            NSString *userID = [[NSNumber numberWithInt:[user uID]] stringValue];
            
            NSDictionary *purchaseInfo = [NSDictionary dictionaryWithObjectsAndKeys: userID, @"userID", kMyFeatureIdentifierLevelTwo, @"identifier", nil];
            
            if (purchaseInfo) {
                [[ECPurchase shared] verifyProductReceiptUserPurchasedBefore:purchaseInfo];
            } else {
                
            }
        }
    }
}
@end
