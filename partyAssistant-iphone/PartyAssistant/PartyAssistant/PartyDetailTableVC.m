//
//  PatryDetailTableVC.m
//  PartyAssistant
//
//  Created by user on 11-12-19.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//
#import "StatusTableVC.h"
#import "PartyDetailTableVC.h"
#import "NotificationSettings.h"
#import "URLSettings.h"
#import "JSON.h"
#import "ASIFormDataRequest.h"
#import "ClientStatusTableViewController.h"
#import "EditPartyTableViewController.h"
#import "UserObject.h"
#import "UserObjectService.h"

#define DELETE_PARTY_ALERT_VIEW_TAG 11

@implementation PartyDetailTableVC
@synthesize myToolbarItems;

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
   
    self.navigationController.toolbar.tintColor = [UIColor colorWithRed:117/255 green:4/255 blue:32/255 alpha:1];
    [self.navigationController.toolbar setBarStyle:UIBarStyleBlackTranslucent];
    [self.navigationController.toolbar sizeToFit];
    
    if (!self.myToolbarItems) {
        UIBarButtonItem *flexButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
        self.myToolbarItems = [NSArray arrayWithObjects:
                               flexButton,  
                               [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"share_word"]
                                                                style:UIBarButtonItemStylePlain
                                                               target:self
                                                               action:@selector(shareAction)], 
                               flexButton, 
                               [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"refresh_word"]
                                                                style:UIBarButtonItemStylePlain 
                                                               target:self
                                                               action:@selector(refreshItem:)],
                               flexButton, 
                               [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"del_word"]
                                                                style:UIBarButtonItemStylePlain
                                                               target:self
                                                               action:@selector(deleteParty)],
                               flexButton, 
                               [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"edit_word"]
                                                                style:UIBarButtonItemStylePlain
                                                               target:self
                                                               action:@selector(editBtnAction)],
                               flexButton, 
                               nil];
        
        [self setToolbarItems:myToolbarItems animated:YES];
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
    self.navigationController.toolbarHidden = NO;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.toolbarHidden = YES;
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
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    
    if(section==1){
        return 4;
    }
    return 1;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section==0) {
        return @"活动内容";
    }else if(section ==1){
        return @"人数统计";
    }else{
        return @"";
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    if(indexPath.section==0){
        UITextField *contentTextField=[[UITextField alloc]initWithFrame:CGRectMake(0, 0, 200, 40)];
        [cell addSubview:contentTextField];
    
    
    }else{
        if(indexPath.row==0){
            cell.textLabel.text=@"已邀请";
        }else if(indexPath.row==1){
            cell.textLabel.text=@"已报名";
        }else if(indexPath.row==2){
            cell.textLabel.text=@"未响应";  
        }else {
            cell.textLabel.text=@"不参加";
        }
        cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
    if(indexPath.section==1){
        StatusTableVC  *statusTableVC=[[StatusTableVC  alloc] initWithNibName:@"StatusTableVC" bundle:nil];//如果nibname为空  则不会呈现组显示
        
        if(indexPath.row==0){
            statusTableVC.title=@"已邀请";
        }else if(indexPath.row==1){
            statusTableVC.title=@"已报名";
        }else if(indexPath.row==2){
            statusTableVC.title=@"未响应";
        }else {
            statusTableVC.title=@"不参加";
        }
        [self.navigationController pushViewController:statusTableVC animated:YES];
    }
}

@end
