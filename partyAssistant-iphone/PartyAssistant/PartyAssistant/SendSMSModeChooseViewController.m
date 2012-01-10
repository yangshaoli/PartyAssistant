//
//  SendSMSModeChooseViewController.m
//  PartyAssistant
//
//  Created by Wang Jun on 12/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SendSMSModeChooseViewController.h"
#import "UserObjectService.h"
#import "UserObject.h"
#import "NotificationSettings.h"

@implementation SendSMSModeChooseViewController
@synthesize tableView = _tableView;
@synthesize delegate;
@synthesize leftCountLabel;

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
    UserObjectService *us = [UserObjectService sharedUserObjectService];
    UserObject *user = [us getUserObject];
    self.leftCountLabel.text = [NSString stringWithFormat:@"剩余帐户:%@条", [[NSNumber numberWithInt:[user.leftSMSCount intValue]] stringValue]];

    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(leftCountRefreshed:) name:UpdateRemainCountFinished object:nil];
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
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:UpdateReMainCount object:nil]];
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    static NSString *Cell1Identifier = @"Cell1";
    static NSString *Cell2Identifier = @"Cell2";
    
    if (indexPath.row == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:Cell1Identifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Cell1Identifier];
        }
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:Cell2Identifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Cell2Identifier];
            CGRect labelFrame = leftCountLabel.frame;
            CGFloat centerY = cell.contentView.frame.size.height / 2;
            CGFloat centerX = cell.contentView.frame.size.width / 2 + labelFrame.size.width / 2;
            leftCountLabel.center = CGPointMake(centerX, centerY);
            [cell addSubview:leftCountLabel];
        }
    }
    
           
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = @"用自己手机发送";
            break;
        case 1:
            cell.textLabel.text = @"通过服务器发送";
            break;
        default:
            break;
    }
    
    if (indexPath.row == 0) {
        if ([self.delegate IsCurrentSMSSendBySelf]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    } else if (indexPath.row == 1) {
        if ([self.delegate IsCurrentSMSSendBySelf]) {
            cell.accessoryType = UITableViewCellAccessoryNone;
        } else {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
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
    if (indexPath.row == 0) {
        [delegate changeSMSModeToSendBySelf:YES];
    } else {
        [delegate changeSMSModeToSendBySelf:NO];
    }
    
    [self.tableView reloadData];
}

- (void)leftCountRefreshed:(NSNotification *)notify {
    UserObjectService *us = [UserObjectService sharedUserObjectService];
    UserObject *user = [us getUserObject];
    self.leftCountLabel.text = [NSString stringWithFormat:@"剩余%@条", [[NSNumber numberWithInt:[user.leftSMSCount intValue]] stringValue]];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
