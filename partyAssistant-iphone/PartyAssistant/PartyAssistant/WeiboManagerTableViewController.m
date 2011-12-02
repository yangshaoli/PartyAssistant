//
//  WeiboManagerTableViewController.m
//  PartyAssistant
//
//  Created by 超 李 on 11-11-29.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "WeiboManagerTableViewController.h"

#define SINA_WEIBO_LOGIN_BTN_TAG 11
#define SINA_WEIBO_LOGOUT_BTN_TAG 12

@implementation WeiboManagerTableViewController
@synthesize weibo;

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
    if (!weibo) {
        self.weibo = [[WeiBo alloc] initWithAppKey:WEIBOPRIVATEAPPKEY withAppSecret:WEIBOPRIVATEAPPSECRETE];
    }
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
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = nil;//[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    cell.textLabel.text = @"新浪微博:";
    if (weibo.isUserLoggedin) {
        WeiboService *s = [WeiboService sharedWeiboService];
        WeiboPersonalProfile *p = [s getWeiboPersonalProfile];
        UILabel *lb = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 260, 44)];
        lb.text = p.nickname;
        lb.backgroundColor = [UIColor clearColor];
        [cell addSubview:lb];
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        btn.frame = CGRectMake(260, 10, 40, 30);
        btn.tag = SINA_WEIBO_LOGOUT_BTN_TAG;
        [btn setTitle:@"登出" forState:UIControlStateNormal];
        //[btn setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
        [btn addTarget:self action:@selector(UserLogout) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:btn];
    }else{
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [btn setTitle:@"登录" forState:UIControlStateNormal];
        btn.tag = SINA_WEIBO_LOGIN_BTN_TAG;
//        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
        btn.frame = CGRectMake(260, 10, 40, 30);
        [btn addTarget:self action:@selector(UserLogin) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:btn];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
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
}

-(void)UserLogout
{
    [weibo LogOut];
    [self.tableView reloadData];
}

-(void)UserLogin
{
    WeiboLoginViewController *rootVC = [[WeiboLoginViewController alloc] initWithNibName:@"WeiboLoginViewController" bundle:nil];
    rootVC.isOnlyLogin = YES;
    rootVC.delegate = self;
    WeiboNavigationController *vc = [[WeiboNavigationController alloc] initWithRootViewController:rootVC];
    [self presentModalViewController:vc animated:YES];
}

-(void)WeiboDidLoginSuccess{
    id loginBtn = [self.view viewWithTag:SINA_WEIBO_LOGIN_BTN_TAG];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    [loginBtn removeFromSuperview];
    WeiboService *s = [WeiboService sharedWeiboService];
    WeiboPersonalProfile *p = [s getWeiboPersonalProfile];
    UILabel *lb = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 260, 44)];
    lb.text = p.nickname;
    lb.backgroundColor = [UIColor clearColor];
    [cell addSubview:lb];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    btn.frame = CGRectMake(260, 10, 40, 30);
    btn.tag = SINA_WEIBO_LOGOUT_BTN_TAG;
    [btn setTitle:@"登出" forState:UIControlStateNormal];
    //[btn setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    [btn addTarget:self action:@selector(UserLogout) forControlEvents:UIControlEventTouchUpInside];
    [cell addSubview:btn];
}

@end
