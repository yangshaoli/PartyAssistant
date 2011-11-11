//
//  PartyDetailTableViewController.m
//  PartyAssistant
//
//  Created by 超 李 on 11-11-6.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "PartyDetailTableViewController.h"

@implementation PartyDetailTableViewController
@synthesize baseinfo;

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
    [self performSelectorOnMainThread:@selector(loadClientCount) withObject:nil waitUntilDone:NO];
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
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section == 0) {
        return 4;
    }else if(section ==1){
        return 4;
    }
    return 1;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cell.textLabel.text = @"开始时间:";
            UILabel *starttimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 0, 190, 44)];
            starttimeLabel.textAlignment = UITextAlignmentRight;
            starttimeLabel.backgroundColor = [UIColor clearColor];
            starttimeLabel.text = self.baseinfo.starttimeStr;
            //            starttimeLabel.text = @"2011-11-11 11:00";
            [cell addSubview:starttimeLabel];
        }else if(indexPath.row == 1){
            cell.textLabel.text = @"地点:";
            UILabel *locationLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 0, 190, 44)];
            locationLabel.textAlignment = UITextAlignmentRight;
            locationLabel.backgroundColor = [UIColor clearColor];
            locationLabel.text = self.baseinfo.location;
            [cell addSubview:locationLabel];
        }else if(indexPath.row == 2){
            cell.textLabel.text = @"人数上限:";
            UILabel *peopleStrLable = [[UILabel alloc] initWithFrame:CGRectMake(100, 0, 190, 44)];
            peopleStrLable.backgroundColor = [UIColor clearColor];
            peopleStrLable.textAlignment = UITextAlignmentRight;
            peopleStrLable.text = [NSString stringWithFormat:@"%@ 人", self.baseinfo.peopleMaximum];
            [cell addSubview:peopleStrLable];
        }else{
            cell.textLabel.text = @"描述:";
            UITextView *descriptionTextView = [[UITextView alloc] initWithFrame:CGRectMake(100, 10, 190, 100)];
            descriptionTextView.text = self.baseinfo.description;
            descriptionTextView.backgroundColor = [UIColor clearColor];
            descriptionTextView.editable = NO;
            [cell addSubview:descriptionTextView];
        }
    }else if(indexPath.section == 1){
        if (indexPath.row == 0) {
            cell.textLabel.text = @"邀请人:";
            UILabel *lb_1 = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 280, 44)];
            lb_1.tag = 1;
            lb_1.text = @"... 人";
            lb_1.textAlignment = UITextAlignmentRight;
            lb_1.backgroundColor = [UIColor clearColor];
            [cell addSubview:lb_1];
        }else if(indexPath.row == 1){
            cell.textLabel.text = @"已报名:";
            UILabel *lb_1 = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 280, 44)];
            lb_1.tag = 2;
            lb_1.text = @"... 人";
            lb_1.textAlignment = UITextAlignmentRight;
            lb_1.backgroundColor = [UIColor clearColor];
            [cell addSubview:lb_1];
        }else if(indexPath.row == 2){
            cell.textLabel.text = @"不报名:";
            UILabel *lb_1 = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 280, 44)];
            lb_1.tag = 3;
            lb_1.text = @"... 人";
            lb_1.textAlignment = UITextAlignmentRight;
            lb_1.backgroundColor = [UIColor clearColor];
            [cell addSubview:lb_1];
        }else if(indexPath.row == 3){
            cell.textLabel.text = @"未报名:";
            UILabel *lb_1 = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 280, 44)];
            lb_1.tag = 4;
            lb_1.text = @"... 人";
            lb_1.textAlignment = UITextAlignmentRight;
            lb_1.backgroundColor = [UIColor clearColor];
            [cell addSubview:lb_1];
        }
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
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
    if (indexPath.section == 1) {
        ClientStatusTableViewController *vc = [[ClientStatusTableViewController alloc] initWithNibName:@"ClientStatusTableViewController" bundle:[NSBundle mainBundle]];
        if(indexPath.row == 0){
            vc.clientStatusFlag = @"all";
        }else if(indexPath.row == 1){
            vc.clientStatusFlag = @"applied";
        }else if(indexPath.row == 2){
            vc.clientStatusFlag = @"refused";
        }else{
            vc.clientStatusFlag = @"donothing";
        }
        vc.partyId = [self.baseinfo.partyId intValue];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)loadClientCount
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@" ,GET_PARTY_CLIENT_MAIN_COUNT,self.baseinfo.partyId]];
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
    if ([request responseStatusCode] == 200) {
        if ([description isEqualToString:@"ok"]) {
            NSDictionary *dataSource = [result objectForKey:@"datasource"];
            NSNumber *allClientcount = [dataSource objectForKey:@"allClientcount"];
            NSNumber *appliedClientcount = [dataSource objectForKey:@"appliedClientcount"];
            NSNumber *refusedClientcount = [dataSource objectForKey:@"refusedClientcount"];
            NSNumber *donothingClientcount = [dataSource objectForKey:@"donothingClientcount"];
            NSArray *countArray = [NSArray arrayWithObjects:allClientcount,appliedClientcount,refusedClientcount,donothingClientcount, nil];
            for (int i = 0; i<4; i++) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:1];
                UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
                for(int j=0;j<[cell.subviews count];j++){
                    if ([[cell.subviews objectAtIndex:j] isMemberOfClass:[UILabel class]]) {
                        UILabel *lbl = [cell.subviews objectAtIndex:j];
                        lbl.text = [NSString stringWithFormat:@"%@ 人", [countArray objectAtIndex:i]];
                        break;
                    }
                }
            }
        }else{
            [self showAlertRequestFailed:description];		
        }
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
//	NSError *error = [request error];
	//[self dismissWaiting];
	//[self showAlertRequestFailed: error.localizedDescription];
}

@end
