//
//  SettingsListTableViewController.m
//  PartyAssistant
//
//  Created by 超 李 on 11-11-22.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "SettingsListTableViewController.h"
#import "NicknameManageTableViewController.h"
#import "DataManager.h"
#import "PurchaseListViewController.h"

#define NAVIGATION_CONTROLLER_TITLE @"设置"
#define LogoutTag                   1
#define NotPassTag                  2
#define SuccessfulTag               3
#define InvalidateNetwork           4
#define versionRefreshTag           5

@implementation SettingsListTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
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

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.navigationItem.title = NAVIGATION_CONTROLLER_TITLE;
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
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 7;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    if (indexPath.row == 0) {
        cell.textLabel.text = @"个人信息";
    }else if(indexPath.row == 1){
        cell.textLabel.text = @"修改密码";
    }else if(indexPath.row == 2){
        cell.textLabel.text = @"微博管理";
    }else if(indexPath.row == 3){
        cell.textLabel.text = @"帮我们评分";
    }else if(indexPath.row == 4){
        cell.textLabel.text = @"充值";
    }else if(indexPath.row == 5){
        cell.textLabel.text = @"登出";
    }else if(indexPath.row == 6){
        
        NSUserDefaults *versionDefault=[NSUserDefaults standardUserDefaults];
        NSString *defaultVersionString=[versionDefault objectForKey:@"airenaoIphoneVersion"];
        
        NSUserDefaults *isUpdateVersionDefault=[NSUserDefaults standardUserDefaults];
        BOOL isUpdateVersion=[isUpdateVersionDefault boolForKey:@"isUpdateVersion"];
        
        cell.textLabel.text = [[NSString alloc] initWithFormat:@"当前版本号：%@",defaultVersionString];
      
        UIView *oldLayout2 = nil;
        oldLayout2 = [cell viewWithTag:2];
        [oldLayout2 removeFromSuperview];
        
        if(isUpdateVersion){   
    
            UIImageView *cellImageView=[[UIImageView alloc] initWithFrame:CGRectMake(249, 10, 20, 20)];
            cellImageView.image=[UIImage imageNamed:@"new1"];
            cellImageView.tag=2;
            [cell  addSubview:cellImageView];
        }
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
//    WeiboService *s = [WeiboService sharedWeiboService];
//    [s WeiboLogin];
    if(indexPath.row == 0){
        NicknameManageTableViewController *nickChangeVc = [[NicknameManageTableViewController alloc] initWithNibName:@"NicknameManageTableViewController" bundle:nil];
        [self.navigationController pushViewController:nickChangeVc animated:YES];
    }
    if(indexPath.row == 2){
        WeiboManagerTableViewController *vc = [[WeiboManagerTableViewController alloc] initWithNibName:@"WeiboManagerTableViewController" bundle:nil];
        [self.navigationController pushViewController:vc animated:YES];
    }
    if(indexPath.row == 3){
        NSString *addressString=[[NSString alloc]initWithFormat:@"http://www.airenao.com/"];//评分
        [[UIApplication sharedApplication]openURL:[NSURL URLWithString:addressString]];

    }
    if(indexPath.row == 4){
        PurchaseListViewController *purchaseListVC = [[PurchaseListViewController alloc] initWithNibName:@"PurchaseListViewController" bundle:nil];
        [self.navigationController pushViewController:purchaseListVC animated:YES];
    }
    if(indexPath.row == 5){
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"登出" message:@"确认登出?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
        alertView.tag = LogoutTag;
        [alertView show];
    }
    if(indexPath.row == 6){
        NSUserDefaults *versionDefault=[NSUserDefaults standardUserDefaults];
        NSString *versionString=[versionDefault objectForKey:@"airenaoIphoneVersion"];
        if(versionString==nil&&[versionString isEqualToString:@""]){
            return;
        }else{
            NSUserDefaults *isUpdateVersionDefault=[NSUserDefaults standardUserDefaults];
            BOOL isUpdateVersion=[isUpdateVersionDefault boolForKey:@"isUpdateVersion"];
            if(isUpdateVersion){
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"更新版本" message:@"确认更新?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
                alertView.tag = versionRefreshTag;
                [alertView show];
            }
        }
    }
}

#pragma mark -
#pragma mark MBProgress_HUDDelegate methods

- (void)HUDWasHidden:(MBProgressHUD *)hUD {
    // Remove _HUD from screen when the _HUD was hidded
    [_HUD removeFromSuperview];
	_HUD = nil;
}

#pragma mark - UIAlertDelegate Method 

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if ((alertView.tag == LogoutTag ) && ( buttonIndex == 1)) {
        _HUD = [[MBProgressHUD alloc] initWithView:self.view];
        [self.navigationController.view addSubview:_HUD];
        
        _HUD.labelText = @"Loading";
        
        _HUD.delegate = self;
        
        [_HUD showWhileExecuting:@selector(tryConnectToServer) onTarget:self withObject:nil animated:YES];
    }
    if((alertView.tag ==versionRefreshTag ) && ( buttonIndex == 1)){
        NSString *addressString=[[NSString alloc]initWithFormat:@"itms://itunes.apple.com/cn/app/bubble-spelling/id476527756?mt=8"];//地址待定
        [[UIApplication sharedApplication]openURL:[NSURL URLWithString:addressString]];
        
    
    }
}

- (void)showAlertWithMessage:(NSString *)message 
                 buttonTitle:(NSString *)buttonTitle 
                         tag:(int)tagNum{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    alert.tag = tagNum;
    [alert show];
}

- (void)showInvalidateNetworkalert {
    [self showAlertWithMessage:@"无法连接网络，请检查网络状态！" 
                   buttonTitle:@"OK" 
                           tag:InvalidateNetwork];
}

- (void)showRegistSuccessfulAlert {
    [self.tabBarController.navigationController popToRootViewControllerAnimated:YES];
    [self showAlertWithMessage:@"登出成功！" buttonTitle:@"OK" tag:SuccessfulTag];
}

- (void)showNotPassChekAlert {
    [self showAlertWithMessage:@"无法完成登出！" buttonTitle:@"OK" tag:NotPassTag];
}

- (void)tryConnectToServer {
    NetworkConnectionStatus networkStatus= [[DataManager sharedDataManager]
                                            logoutUser];
    [_HUD hide:YES];
    //may need to creat some other connection status
    switch (networkStatus) {
        case NetworkConnectionInvalidate:
            [self showNotPassChekAlert];
            break;
        case NetWorkConnectionCheckPass:
            [self showRegistSuccessfulAlert];
            break;
        default:
            [self showNotPassChekAlert];
            break;
    }
}

@end
