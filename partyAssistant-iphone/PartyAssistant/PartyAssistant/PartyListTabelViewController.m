//
//  PartyListTabelViewController.m
//  PartyAssistant
//
//  Created by 超 李 on 11-11-6.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "PartyListTabelViewController.h"

@implementation PartyListTabelViewController
@synthesize partyList, _isNeedRefresh, _isRefreshing, pageIndex;

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
    
    UIBarButtonItem *refreshBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshBtnAction)];
    self.navigationItem.rightBarButtonItem = refreshBtn;
    self.partyList = [[NSMutableArray alloc] initWithArray:[[PartyListService sharedPartyListService] getPartyList]];
    if ([partyList count] == 0) {
        self._isNeedRefresh = YES;
    }
    if (self._isNeedRefresh) {
        [self refreshBtnAction];
    }
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
    if ([self.partyList count]>20) {
        return 20;
    }
    return [self.partyList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    BaseInfoObject *baseinfo = [partyList objectAtIndex:indexPath.row];
    NSRange range;
    range.location = 16;
    range.length = baseinfo.description.length - 16;
    cell.textLabel.text = [baseinfo.description stringByReplacingCharactersInRange:range withString:@"..."];
    UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(200, 20, 110, 24)];
    timeLabel.textAlignment = UITextAlignmentRight;
    timeLabel.text = baseinfo.starttimeStr;
    timeLabel.textColor = [UIColor lightGrayColor];
    [cell addSubview:timeLabel];
    cell.tag = [baseinfo.partyId intValue];
    cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
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
    PartyDetailTableViewController *vc = [[PartyDetailTableViewController alloc] initWithNibName:@"PartyDetailTableViewController" bundle:[NSBundle mainBundle]];
    vc.baseinfo = [self.partyList objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)refreshBtnAction{
    UserObjectService *us = [UserObjectService sharedUserObjectService];
    UserObject *user = [us getUserObject];
    NSURL *url = [NSURL URLWithString:GET_PARTY_LIST];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSString stringWithFormat:@"%@uid=%d",url,user.uID]];
    request.timeOutSeconds = 30;
    [request setShouldAttemptPersistentConnection:NO];
    [request startAsynchronous];
    UIActivityIndicatorView *acv = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [acv startAnimating];
    self.navigationItem.rightBarButtonItem.customView = acv;
}

- (void)requestFinished:(ASIHTTPRequest *)request{
	NSString *response = [request responseString];
	SBJsonParser *parser = [[SBJsonParser alloc] init];
	NSDictionary *result = [parser objectWithString:response];
	NSNumber* code = [[result objectForKey:@"status"] objectForKey:@"code"];
	NSString *description = [[result objectForKey:@"status"] objectForKey:@"description"];
	//		NSString *debugger = [[result objectForKey:@"status"] objectForKey:@"debugger"];
	//[NSThread detachNewThreadSelector:@selector(dismissWaiting) toTarget:self withObject:nil];
//	[self dismissWaiting];
	if ([code intValue]==200 && [description isEqualToString:@"ok"]) {
		NSDictionary *dataSource = [result objectForKey:@"datasource"];
        self.pageIndex = [[dataSource objectForKey:@"page"] intValue];
        
        if (pageIndex == 0) {
            pageIndex = 1;
        }
        
        NSArray *allDatas = [dataSource objectForKey:@"partyList"];
        [self.partyList removeAllObjects];
        for(int i=0;i<[partyList count];i++){
            NSDictionary *party = [partyList objectAtIndex:i];
            BaseInfoObject *biObj = [[BaseInfoObject alloc] init];
            biObj.starttimeDate = [party objectForKey:@"starttime"];
            biObj.description = [party objectForKey:@"description"];
            biObj.peopleMaximum = [party objectForKey:@"peopleMaximum"];
            biObj.location = [party objectForKey:@"location"];
            biObj.partyId = [party objectForKey:@"partyId"];
            [biObj formatDateToString];
            [self.partyList addObject:biObj];
        }
        
        
        [self.tableView reloadData];
//        [self setBottomRefreshViewYandDeltaHeight];
	}else{
		[self showAlertRequestFailed:description];		
	}
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
	NSError *error = [request error];
	//[self dismissWaiting];
	//[self showAlertRequestFailed: error.localizedDescription];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"复制",@"删除",@"分享", nil];
    UITableViewCell *cell= [tableView cellForRowAtIndexPath:indexPath];
    sheet.tag = indexPath.row;
    [sheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSInteger pIndex = actionSheet.tag;
    if (buttonIndex == 0) {
        [self copyPartyAtID:pIndex];
    }else if(buttonIndex == 1){
        [self deletePartyAtID:pIndex];
    }else if(buttonIndex == 2){
        [self sharePartyAtID:pIndex];
    }
    
}

- (void)copyPartyAtID:(NSInteger)pIndex
{
    CopyPartyTableViewController *vc = [[CopyPartyTableViewController alloc] initWithNibName:@"CopyPartyTableViewController" bundle:[NSBundle mainBundle]];
    vc.baseinfo = [self.partyList objectAtIndex:pIndex];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)deletePartyAtID:(NSInteger)pIndex
{

}

- (void)sharePartyAtID:(NSInteger)pIndex
{

}
@end
