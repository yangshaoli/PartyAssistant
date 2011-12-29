//
//  PartyListTableVC.m
//  PartyAssistant
//
//  Created by user on 11-12-19.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
#import "ContactData.h"
#import "PartyListTableVC.h"
#import "PartyDetailTableVC.h"
#import "PartyListService.h"
#import "URLSettings.h"
#import "ClientObject.h"
@interface PartyListTableVC()

-(void) hideTabBar:(UITabBarController*) tabbarcontroller;
-(void) showTabBar:(UITabBarController*) tabbarcontroller;

@end

@implementation PartyListTableVC
@synthesize partyList, topRefreshView, bottomRefreshView;
@synthesize peopleCountArray;
@synthesize lastID,_isRefreshing,_isNeedRefresh;
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
    self.title=@"活动列表";
    UIBarButtonItem *refreshBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshBtnAction)];
    self.navigationItem.rightBarButtonItem = refreshBtn;
    self.navigationController.navigationBar.tintColor = [UIColor redColor];//设置背景色  一句永逸
    
    [[PartyListService sharedPartyListService] savePartyList];
    self.partyList=[[PartyListService sharedPartyListService] getPartyList];
    
    minBottomRefreshViewY = 366.0;
	//setup refresh tool
    if (bottomRefreshView == nil) {
		
        CGFloat bottomRefreshViewY = MAX(minBottomRefreshViewY, self.tableView.contentSize.height);
		BottomRefreshTableView *bottomView = [[BottomRefreshTableView alloc] initWithFrame: CGRectMake(0.0f, bottomRefreshViewY, 320, 650)];
		bottomView.delegate = self;
		[self.tableView addSubview:bottomView];
		self.bottomRefreshView = bottomView;
		
		if (minBottomRefreshViewY > self.tableView.contentSize.height) {
            bottomView.deltaHeight = minBottomRefreshViewY - self.tableView.contentSize.height;
        } else {
            bottomView.deltaHeight = 0.0f;
        }
		
	}
    if (topRefreshView == nil) {
		
		TopRefreshTableView *topView = [[TopRefreshTableView alloc] initWithFrame: CGRectMake(0.0f, -250.0f, 320, 250)];
		topView.delegate = self;
		[self.tableView addSubview:topView];
		self.topRefreshView = topView;
		
	}
    
	//  update the last update date
	[bottomRefreshView refreshLastUpdatedDate];
    [topRefreshView refreshLastUpdatedDate];
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
    [self setBottomRefreshViewYandDeltaHeight];
    [self showTabBar:self.tabBarController];
    [self refreshBtnAction];
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self hideTabBar:self.tabBarController];
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


- (void)requestDataWithLastID:(NSInteger)aLastID {
    UserObjectService *us = [UserObjectService sharedUserObjectService];
    UserObject *user = [us getUserObject];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%d/%d/" ,GET_PARTY_LIST,user.uID,aLastID]];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    request.timeOutSeconds = 30;
    [request setDelegate:self];
    [request setShouldAttemptPersistentConnection:NO];
    
    if (aLastID > 0) {
        _isAppend = YES;
    } else {
        _isAppend = NO;
    }
    [request startAsynchronous];
    //self._isRefreshing = YES;
    UIActivityIndicatorView *acv = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [acv startAnimating];
    self.navigationItem.rightBarButtonItem.customView = acv;
    NSLog(@"在list页面输出user.uID》》》》%d",user.uID);
}

- (void)requestFinished:(ASIHTTPRequest *)request{
    //self._isRefreshing = NO;
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
            self.lastID = [[dataSource objectForKey:@"lastID"] intValue];
            if (lastID < 0) {
                lastID = 0;
            }
            
            NSArray *partyDictArray = [dataSource objectForKey:@"partyList"];
            if (!_isAppend) {
                [self.partyList removeAllObjects];
            }
            for(int i=0;i<[partyDictArray count];i++){
                NSDictionary *partyDict = [partyDictArray objectAtIndex:i];
                PartyModel *partyModel=[[PartyModel alloc] init];
                partyModel.contentString = [partyDict objectForKey:@"description"];
                partyModel.partyId =[partyDict  objectForKey:@"partyId"];
                partyModel.peopleCountDict = [partyDict objectForKey:@"clientsData"];
                [self.partyList addObject:partyModel];
                
            }
            self.navigationItem.rightBarButtonItem.customView = nil;
            [self.tableView reloadData];
            [self setBottomRefreshViewYandDeltaHeight];
            //        [self setBottomRefreshViewYandDeltaHeight];
        }else{
            self.navigationItem.rightBarButtonItem.customView = nil;
            [self showAlertRequestFailed:description];		
        }
    }else if([request responseStatusCode] == 404){
        self.navigationItem.rightBarButtonItem.customView = nil;
        [self showAlertRequestFailed:REQUEST_ERROR_404];
    }else{
        self.navigationItem.rightBarButtonItem.customView = nil;
        [self showAlertRequestFailed:REQUEST_ERROR_500];
    }    
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    self._isRefreshing = NO;
    self.navigationItem.rightBarButtonItem.customView = nil;
	NSError *error = [request error];
	[self dismissWaiting];
	[self showAlertRequestFailed: error.localizedDescription];
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
    
    int aLastID = 0;
    [self requestDataWithLastID:aLastID];
    
    UIActivityIndicatorView *acv = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [acv startAnimating];
    self.navigationItem.rightBarButtonItem.customView = acv;
    
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return  1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
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
    
    UIView *oldLayout = nil;
    oldLayout = [cell viewWithTag:2];
    [oldLayout removeFromSuperview];
    
    NSInteger getPartyId=[[[self.partyList  objectAtIndex:[indexPath row]] partyId]  intValue];
    NSString *keyString=[[NSString alloc] initWithFormat:@"%disStatusChanged",getPartyId];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];  
    NSInteger  getStatusChangedInt=[defaults integerForKey:keyString];
    NSLog(@"在list中输出getStatusChangedInt》》》》》%d",getStatusChangedInt);
    if(1==getStatusChangedInt){
        
        UIImageView *cellImageView=[[UIImageView alloc] initWithFrame:CGRectMake(5, 10, 20, 20)];
        cellImageView.image=[UIImage imageNamed:@"new1"];
        cellImageView.tag=2;
        [cell  addSubview:cellImageView];
    
    }

    
    
    UILabel *contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 0, 175, 40)];
    contentLabel.text=[[self.partyList  objectAtIndex:row] contentString];
    contentLabel.font=[UIFont systemFontOfSize:15];
    [cell  addSubview:contentLabel];
     

    oldLayout = [cell viewWithTag:6];
    [oldLayout removeFromSuperview];

    UILabel *lb_1 = [[UILabel alloc] initWithFrame:CGRectMake(200, 0, 90, 40)];    
    lb_1.tag = 6;
    NSString *applyString=[[NSString alloc] initWithFormat:@"%@",[[[self.partyList  objectAtIndex:row] peopleCountDict] objectForKey:@"appliedClientcount"]];
    NSString *donothingString=[[NSString alloc] initWithFormat:@"%@",[[[self.partyList  objectAtIndex:row] peopleCountDict] objectForKey:@"donothingClientcount"]];
    NSString *refuseString=[[NSString alloc] initWithFormat:@"%@",[[[self.partyList  objectAtIndex:row] peopleCountDict] objectForKey:@"refusedClientcount"]];
    NSInteger allNumbers=[applyString intValue]+[donothingString intValue]+[refuseString intValue];
    lb_1.text = [NSString stringWithFormat:@"%@/%d",applyString,allNumbers];
    lb_1.textAlignment = UITextAlignmentRight;
    lb_1.backgroundColor = [UIColor clearColor];
    [cell addSubview:lb_1];
    
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
    
    PartyDetailTableVC *partyDetailTableVC = [[PartyDetailTableVC alloc] initWithNibName:@"PartyDetailTableVC" bundle:nil];//如果nibname为空  则不会呈现组显示
    partyDetailTableVC.title=[[[self.partyList  objectAtIndex:[indexPath row]] contentString] substringToIndex:3]; 
    partyDetailTableVC.partyObj=[self.partyList  objectAtIndex:[indexPath row]];
    partyDetailTableVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:partyDetailTableVC animated:YES];
}

#pragma mark -
#pragma mark Data Source Loading / Reloading Methods

- (void)reloadTableViewDataSource{
	
	//  should be calling your tableviews data source model to reload
	//  put here just for demo
    _reloading = YES;
    [self requestDataWithLastID:0];
	[self doneLoadingTopRefreshTableViewData];
}

- (void)loadNextPageTableViewDataSource{
	
	//  should be calling your tableviews data source model to reload
	//  put here just for demo
    _reloading = YES;
   [self requestDataWithLastID:0];
	[self doneLoadingBottomRefreshTableViewData];
}

- (void)doneLoadingTopRefreshTableViewData{
	
	//  model should call this when its done loading
    _reloading = NO;
    [self.tableView reloadData];
    
	[topRefreshView performSelector:@selector(refreshScrollViewDataSourceDidFinishedLoading:) withObject:self.tableView afterDelay:1.0f];
}

- (void)doneLoadingBottomRefreshTableViewData{
	
	//  model should call this when its done loading
	_reloading = NO;
    [self.tableView reloadData];
    
    [bottomRefreshView performSelector:@selector(refreshScrollViewDataSourceDidFinishedLoading:) withObject:self.tableView afterDelay:1.0f];
}

#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{	
    [topRefreshView refreshScrollViewDidScroll:scrollView];
	[bottomRefreshView refreshScrollViewDidScroll:scrollView];
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	[topRefreshView refreshScrollViewDidEndDragging:scrollView];
	[bottomRefreshView refreshScrollViewDidEndDragging:scrollView];
}

- (void)refreshTopTableHeaderDidTriggerRefresh:(id<RefreshTableViewProtocol>)view{
	[self reloadTableViewDataSource];
}

- (void)refreshBottomTableHeaderDidTriggerRefresh:(id<RefreshTableViewProtocol>)view{
	[self loadNextPageTableViewDataSource];
}

- (BOOL)refreshTableHeaderDataSourceIsLoading:(id<RefreshTableViewProtocol>)view{
	
	return _reloading; // should return if data source model is reloading
	
}

- (NSDate*)refreshTableHeaderDataSourceLastUpdated:(id<RefreshTableViewProtocol>)view{
	
	return [NSDate date]; // should return date data source was last changed
}

- (void)setBottomRefreshViewYandDeltaHeight {
    CGFloat bottomRefreshViewY = MAX(minBottomRefreshViewY, self.tableView.contentSize.height);
    
    CGRect frame = bottomRefreshView.frame;
    frame.origin.y = bottomRefreshViewY;
    bottomRefreshView.frame = frame;
    
    if (minBottomRefreshViewY > self.tableView.contentSize.height) {
        bottomRefreshView.deltaHeight = minBottomRefreshViewY - self.tableView.contentSize.height;
    } else {
        bottomRefreshView.deltaHeight = 0.0f;
    }
    
}

- (CGFloat)getTableHeadViewHeight {
	return 0.0f;
}

-(void) hideTabBar:(UITabBarController*) tabbarcontroller {
    
    
    //    [UIView beginAnimations:nil context:NULL];
    //    [UIView setAnimationDuration:0.5];
    for(UIView*view in tabbarcontroller.view.subviews)
    {
        if([view isKindOfClass:[UITabBar class]])
        {
            [view setFrame:CGRectMake(view.frame.origin.x,480, view.frame.size.width, view.frame.size.height)];
        }
        else
        {
            [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width,480)];
        }
        
    }
    
    //[UIView commitAnimations];
}

-(void) showTabBar:(UITabBarController*) tabbarcontroller {
    
//    [UIView beginAnimations:nil context:NULL];
//    [UIView setAnimationDuration:0.5];
//    [UIView commitAnimations];
    
    for(UIView*view in tabbarcontroller.view.subviews)
    {
        if([view isKindOfClass:[UITabBar class]])
        {
            [view setFrame:CGRectMake(view.frame.origin.x,431, view.frame.size.width, view.frame.size.height)];
        }
        else
        {
            [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width,431)];
        }
    }
    
}




@end
