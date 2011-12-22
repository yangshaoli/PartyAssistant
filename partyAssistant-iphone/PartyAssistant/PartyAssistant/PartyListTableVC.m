//
//  PartyListTableVC.m
//  PartyAssistant
//
//  Created by user on 11-12-19.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
#import "ContactData.h"
#import "PartyListTableVC.h"
#import "PatryDetailTableVC.h"
#import "PartyListService.h"
@implementation PartyListTableVC
@synthesize partyList;
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
    UIBarButtonItem *refreshBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshBtnAction)];
    self.navigationItem.rightBarButtonItem = refreshBtn;
   
    PartyModel *partyObj2=[[PartyModel alloc] init];
    //partyObj2.receiversArray=[[ContactData   contactsArray] mutableCopy];
    partyObj2.contentString=@"唱歌嗨一把";
    partyObj2.isSendByServer=NO;
    partyObj2.partyId=2;
   
    NSLog(@"self.partyList打印出来：：%@",self.partyList);
    self.title=@"活动列表";
    
    PartyModel *partyObj1=[[PartyModel alloc] init];
    //partyObj1.receiversArray=[[ContactData   contactsArray] mutableCopy];
    partyObj1.contentString=@"跳舞爽";
    partyObj1.isSendByServer=NO;
    partyObj1.partyId=1;
    //self.partyList=[[PartyListService sharedPartyListService] addPartyList:partyObj2];
    [PartyListService sharedPartyListService].partyList=[[NSMutableArray alloc] initWithObjects:partyObj2, nil];
//    NSString *lastString2=[[NSString alloc] initWithString:@"最后吃饭"];
   [[PartyListService sharedPartyListService].partyList  addObject:partyObj1];
    [[PartyListService sharedPartyListService] savePartyList];
    self.partyList=[[PartyListService sharedPartyListService] getPartyList];
    
    
    //self.partyList=[[NSArray alloc] initWithObjects:@"踢球1",@"唱歌2",@"聚餐3", nil];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
- (void)refreshBtnAction{
//    UserObjectService *us = [UserObjectService sharedUserObjectService];
//    UserObject *user = [us getUserObject];
//    int page = 1;
//    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%d/%d/" ,GET_PARTY_LIST,user.uID,page]];
//    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
//    request.timeOutSeconds = 30;
//    [request setDelegate:self];
//    [request setShouldAttemptPersistentConnection:NO];
//    [request startAsynchronous];
//    self._isRefreshing = YES;
    UIActivityIndicatorView *acv = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [acv startAnimating];
    self.navigationItem.rightBarButtonItem.customView = acv;
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
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return  1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return self.partyList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    NSInteger row=[indexPath row];
    cell.textLabel.font=[UIFont systemFontOfSize:15];
    cell.textLabel.text=[[self.partyList  objectAtIndex:row] contentString];
    //cell.textLabel.text=[self.partyList  objectAtIndex:row];
    cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    
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
    
    PatryDetailTableVC *partyDetailTableVC = [[PatryDetailTableVC alloc] initWithNibName:@"PatryDetailTableVC" bundle:nil];//如果nibname为空  则不会呈现组显示
    partyDetailTableVC.title=[[self.partyList  objectAtIndex:[indexPath row]] contentString];    //partyDetailTableVC.title=[self.partyList  objectAtIndex:[indexPath row]];
    [self.navigationController pushViewController:partyDetailTableVC animated:YES];
}

@end
