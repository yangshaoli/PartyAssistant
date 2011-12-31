//
//  PartyListTabelViewController.m
//  PartyAssistant
//
//  Created by 超 李 on 11-11-6.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "PartyListTableViewController.h"

#define DELETE_PARTY_ALERT_VIEW_TAG 11
#define NAVIGATION_CONTROLLER_TITLE @"趴列表"


@implementation PartyListTableViewController
@synthesize partyList, _isNeedRefresh, _isRefreshing, lastID,_currentDeletePartyID,_currentDeletePartyCellIndex, topRefreshView, bottomRefreshView;
@synthesize countNumber;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(AddBadgeToTabbar:) name:ADD_BADGE_TO_TABBAR object:nil];
    _isRefreshing = NO;
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
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
    }else{
        self._isNeedRefresh = NO;
    }
    if (self._isNeedRefresh) {
        [self refreshBtnAction];
    }
    self.navigationItem.title = NAVIGATION_CONTROLLER_TITLE;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(AfterCreatedDone) name:CREATE_PARTY_SUCCESS object:nil];
    if ([UIApplication sharedApplication].applicationIconBadgeNumber > 0 && !_isRefreshing) {
        [self refreshBtnAction];
    }
    
    minBottomRefreshViewY = 366.0;
	//setup refresh tool
    if (bottomRefreshView == nil) {
		
        CGFloat bottomRefreshViewY = MAX(minBottomRefreshViewY, self.tableView.contentSize.height);
		BottomRefreshTableView *view = [[BottomRefreshTableView alloc] initWithFrame: CGRectMake(0.0f, bottomRefreshViewY, 320, 650)];
		view.delegate = self;
		[self.tableView addSubview:view];
		self.bottomRefreshView = view;
		
		if (minBottomRefreshViewY > self.tableView.contentSize.height) {
            view.deltaHeight = minBottomRefreshViewY - self.tableView.contentSize.height;
        } else {
            view.deltaHeight = 0.0f;
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
    [self.tableView  reloadData];
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath;
{
    return 60.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    
    // Configure the cell...
    UILabel *descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, 300, 40)];
    BaseInfoObject *baseinfo = [partyList objectAtIndex:indexPath.row];
    if (baseinfo.description.length > 10) {
        NSRange range;
        range.location = 10;
        range.length = baseinfo.description.length - 10;
        descriptionLabel.text = [baseinfo.description stringByReplacingCharactersInRange:range withString:@"..."];
    }else{
        descriptionLabel.text = baseinfo.description;
    }
    descriptionLabel.font = [UIFont systemFontOfSize:22];
    descriptionLabel.backgroundColor = [UIColor clearColor];
    [cell addSubview:descriptionLabel];
    
//    UIImageView *imgV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"new_tips"]];
//    imgV.frame = CGRectMake(200, 7, imgV.frame.size.width, imgV.frame.size.height);
//    [cell addSubview:imgV];
    
    UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 44, 180, 16)];
    timeLabel.textAlignment = UITextAlignmentRight;
    timeLabel.text = baseinfo.starttimeStr;
    timeLabel.textColor = [UIColor lightGrayColor];
    [cell addSubview:timeLabel];
    cell.tag = [baseinfo.partyId intValue];
    PeopleCountInPartyListCellSubView *v = [[PeopleCountInPartyListCellSubView alloc] initWithPeopleCount:baseinfo.peopleCountDict];
    [cell addSubview:v];
    cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    NSLog(@"list cell init");
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
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
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
    self._isRefreshing = YES;
    UIActivityIndicatorView *acv = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [acv startAnimating];
    self.navigationItem.rightBarButtonItem.customView = acv;
}

- (void)refreshBtnAction{
    int aLastID = 0;
    [self requestDataWithLastID:aLastID];
}

- (void)requestFinished:(ASIHTTPRequest *)request{
    self._isRefreshing = NO;
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
            
            NSArray *allDatas = [dataSource objectForKey:@"partyList"];
            if (!_isAppend) {
                [self.partyList removeAllObjects];
            }
            for(int i=0;i<[allDatas count];i++){
                NSDictionary *party = [allDatas objectAtIndex:i];
                BaseInfoObject *biObj = [[BaseInfoObject alloc] init];
                if ([party objectForKey:@"starttime"] == [NSNull null]) {
                    biObj.starttimeStr = @"";
                }else{
                    biObj.starttimeStr = [party objectForKey:@"starttime"];
                }
                biObj.description = [party objectForKey:@"description"];
                biObj.peopleMaximum = [party objectForKey:@"peopleMaximum"];
                biObj.location = [party objectForKey:@"location"];
                biObj.partyId = [party objectForKey:@"partyId"];
                biObj.peopleCountDict = [party objectForKey:@"clientsData"];
                [biObj formatStringToDate];
                [self.partyList addObject:biObj];
                
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
    //wxz
    UserObjectService *us = [UserObjectService sharedUserObjectService];
    UserObject *user = [us getUserObject];
    self.countNumber=self.partyList.count;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];  
    NSString *keyString=[[NSString alloc] initWithFormat:@"%dcountNumber",user.uID];
    [defaults setInteger:self.countNumber  forKey:keyString];    //wxz
    
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    self._isRefreshing = NO;
    self.navigationItem.rightBarButtonItem.customView = nil;
	NSError *error = [request error];
	[self dismissWaiting];
	[self showAlertRequestFailed: error.localizedDescription];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"复制",@"删除",@"分享", nil];
//    UITableViewCell *cell= [tableView cellForRowAtIndexPath:indexPath];
    sheet.tag = indexPath.row;
    [sheet showInView:self.tabBarController.view];
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
    UIAlertView *alertV = [[UIAlertView alloc] initWithTitle:nil message:@"删除后不能再恢复，是否继续？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"继续", nil];
    alertV.tag = DELETE_PARTY_ALERT_VIEW_TAG;
    BaseInfoObject *b = [self.partyList objectAtIndex:pIndex];
    self._currentDeletePartyID = [b.partyId integerValue];
    self._currentDeletePartyCellIndex = pIndex;
    [alertV show];
}

- (void)sharePartyAtID:(NSInteger)pIndex
{
    WeiboLoginViewController *rootVC = [[WeiboLoginViewController alloc] initWithNibName:@"WeiboLoginViewController" bundle:nil];
    BaseInfoObject *b = [self.partyList objectAtIndex:pIndex];
    rootVC.baseinfo = b;
    WeiboNavigationController *vc = [[WeiboNavigationController alloc] initWithRootViewController:rootVC];
    [self presentModalViewController:vc animated:YES];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(alertView.tag == DELETE_PARTY_ALERT_VIEW_TAG){
        if (buttonIndex == 1) {
            [self showWaiting];
            UserObjectService *us = [UserObjectService sharedUserObjectService];
            UserObject *user = [us getUserObject];
            NSURL *url = [NSURL URLWithString:DELETE_PARTY];
            ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
            [request setPostValue:[NSNumber numberWithInteger:_currentDeletePartyID] forKey:@"pID"];
            [request setPostValue:[NSNumber numberWithInteger:user.uID] forKey:@"uID"];

            request.timeOutSeconds = 30;
            [request setDelegate:self];
            [request setDidFinishSelector:@selector(deleteRequestFinished:)];
            [request setDidFailSelector:@selector(deleteRequestFailed:)];
            [request setShouldAttemptPersistentConnection:NO];
            [request startAsynchronous];
        }
    }
}

- (void)deleteRequestFinished:(ASIHTTPRequest *)request{
	//[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(requestTimeOutHandler) object:nil];
    NSString *response = [request responseString];
	SBJsonParser *parser = [[SBJsonParser alloc] init];
	NSDictionary *result = [parser objectWithString:response];
	NSString *description = [result objectForKey:@"description"];
	[self dismissWaiting];
    if ([request responseStatusCode] == 200) {
        if ([description isEqualToString:@"ok"]) {
            NSIndexPath *index = [NSIndexPath indexPathForRow:self._currentDeletePartyCellIndex inSection:0];
            NSArray *indexPathArray = [NSArray arrayWithObject:index];
            [partyList removeObjectAtIndex:_currentDeletePartyCellIndex];
            [self.tableView deleteRowsAtIndexPaths:indexPathArray withRowAnimation:UITableViewRowAnimationTop];
            [self setBottomRefreshViewYandDeltaHeight];
        }else{
            [self showAlertRequestFailed:description];		
        }
    }else if([request responseStatusCode] == 404){
        [self showAlertRequestFailed:REQUEST_ERROR_404];
    }else{
        [self showAlertRequestFailed:REQUEST_ERROR_500];
    }
	
}


- (void)deleteRequestFailed:(ASIHTTPRequest *)request
{
	NSError *error = [request error];
	[self dismissWaiting];
	[self showAlertRequestFailed: error.localizedDescription];
}

- (void)AfterCreatedDone{
    [self.navigationController popToRootViewControllerAnimated:YES];
    [self refreshBtnAction];
}

- (void)AddBadgeToTabbar:(NSNotification *)notification{
    NSDictionary *userinfo = [notification userInfo];
    NSLog(@"badge:%@",[userinfo objectForKey:@"badge"]);
    UITabBarItem *tbi = (UITabBarItem *)[self.tabBarController.tabBar.items objectAtIndex:1];
    tbi.badgeValue = [NSString stringWithFormat:@"%@",[userinfo objectForKey:@"badge"]];
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
    [self requestDataWithLastID:lastID];
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

@end
