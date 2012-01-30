//
//  PartyListTableVC.m
//  PartyAssistant
//
//  Created by user on 11-12-19.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
#define BOOLStringOutput(target) target ? @"YES" : @"NO"

#import "ContactData.h"
#import "PartyListTableVC.h"
#import "PartyDetailTableVC.h"
#import "PartyListService.h"
#import "URLSettings.h"
#import "ClientObject.h"
#import "NotificationSettings.h"
#import "HTTPRequestErrorMSG.h"
#import "UIViewControllerExtra.h"
#import "DataManager.h"
#import "ChangePasswordRandomLoginTableVC.h"
@interface PartyListTableVC()

-(void) hideTabBar:(UITabBarController*) tabbarcontroller;
-(void) showTabBar:(UITabBarController*) tabbarcontroller;

@end

@implementation PartyListTableVC
@synthesize partyList, topRefreshView, bottomRefreshView;
@synthesize peopleCountArray,partyDictArraySelf;
@synthesize lastID,_isRefreshing,_isNeedRefresh,quest,isRefreshImage,rowLastPush;
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clearData) name:USER_LOGOUT_NOTIFICATION object:nil];
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
    
    NSString *partyListPath = [NSString stringWithFormat:@"%@/Documents/partylistofpre20.plist", NSHomeDirectory()];
    NSFileManager* fm = [NSFileManager defaultManager];
    if(![fm fileExistsAtPath:partyListPath]) {
        self.partyDictArraySelf = [[NSMutableArray alloc] initWithCapacity:0];
    } else {
        self.partyDictArraySelf = [[NSMutableArray alloc] initWithContentsOfFile:partyListPath];
    }
    [self.partyList removeAllObjects];
    for(int i=0;i<[self.partyDictArraySelf count];i++){
        NSDictionary *partyDict = [self.partyDictArraySelf objectAtIndex:i];
        PartyModel *partyModel=[[PartyModel alloc] init];
        partyModel.contentString = [partyDict objectForKey:@"description"];
        partyModel.partyId =[partyDict  objectForKey:@"partyId"];
        partyModel.peopleCountDict = [partyDict objectForKey:@"clientsData"];
        partyModel.shortURL = [partyDict objectForKey:@"shortURL"];
        partyModel.type=[partyDict objectForKey:@"type"];
        [self.partyList addObject:partyModel];
    }

    self.title=@"活动列表";
    UIBarButtonItem *refreshBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshBtnAction)];
    self.navigationItem.rightBarButtonItem = refreshBtn;
    self.navigationController.navigationBar.tintColor = [UIColor redColor];//设置背景色  一句永逸
    [[PartyListService sharedPartyListService] savePartyList];
    self.partyList=[[PartyListService sharedPartyListService] getPartyList];
    
    if ([UIApplication sharedApplication].applicationIconBadgeNumber > 0 && !_isRefreshing) {
        [self refreshBtnAction];
    }
    
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
    //wxz
    UserObjectService *us = [UserObjectService sharedUserObjectService];
    UserObject *user = [us getUserObject];
    NSString *keyString=[[NSString alloc] initWithFormat:@"%dcountNumber",user.uID];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];  
    NSInteger  getDefaultCountNumber=[defaults integerForKey:keyString];
    if(getDefaultCountNumber){  //如果该用户活动条数非空
        if([DataManager sharedDataManager].isRandomLoginSelf){
            ChangePasswordRandomLoginTableVC *changePasswordRandomLoginTableVC=[[ChangePasswordRandomLoginTableVC alloc] initWithNibName:@"ChangePasswordRandomLoginTableVC" bundle:nil];
            [self.navigationController pushViewController:changePasswordRandomLoginTableVC animated:YES]; 
        }
    }
    [self refreshBtnAction];
    [self.tableView reloadData];
     
    
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
   
    if(self.isRefreshImage){
        [self refreshBtnAction];
        self.isRefreshImage=NO;
        [self.tableView reloadData];
    }
    NSUserDefaults *isCreatSucDefault=[NSUserDefaults standardUserDefaults];
    BOOL isCreatSucBool=[[isCreatSucDefault objectForKey:@"isCreatSucDefault"] boolValue];
    if(isCreatSucBool){
        [self refreshBtnAction];
        [self.tableView reloadData];
        [isCreatSucDefault setBool:NO forKey:@"isCreatSucDefault"];
    }
    
    
    
    NSUserDefaults *isDeleteSucDefault=[NSUserDefaults standardUserDefaults];
    BOOL isDeleteSucBool=[[isDeleteSucDefault objectForKey:@"isDeleteSucDefault"] boolValue];
    if(isDeleteSucBool){
        [self refreshBtnAction];
        [self.tableView reloadData];
        [isDeleteSucDefault setBool:NO forKey:@"isDeleteSucDefault"];
    }

    
    NSUserDefaults *isEditSucDefault=[NSUserDefaults standardUserDefaults];
    BOOL isEditSucBool=[[isEditSucDefault objectForKey:@"isEditSucDefault"] boolValue];
    if(isEditSucBool){
        [self refreshBtnAction];
        [self.tableView reloadData];
        [isEditSucDefault setBool:NO forKey:@"isEditSucDefault"];
    }
    
    
    
    
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


- (void)requestDataWithLastID:(NSInteger)aLastID {
    UserObjectService *us = [UserObjectService sharedUserObjectService];
    UserObject *user = [us getUserObject];
    if (user.uID < 0) {
        return;
    }
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%d/%d/" ,GET_PARTY_LIST,user.uID,aLastID]];
    
    if (self.quest) {
        [self.quest clearDelegatesAndCancel];
    }

    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    request.timeOutSeconds = 20;
    [request setDelegate:self];
    [request setShouldAttemptPersistentConnection:NO];
    
    if (aLastID > 0) {
        _isAppend = YES;
    } else {
        _isAppend = NO;
    }
    [request startAsynchronous];
    
    self.quest=request;
    //self._isRefreshing = YES;
    UIActivityIndicatorView *acv = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [acv startAnimating];
    self.navigationItem.rightBarButtonItem.customView = acv;
}

- (void)requestFinished:(ASIHTTPRequest *)request{
    //self._isRefreshing = NO;
	NSString *response = [request responseString];
	SBJsonParser *parser = [[SBJsonParser alloc] init];
	NSDictionary *result = [parser objectWithString:response];
    [self getVersionFromRequestDic:result];
    NSString *status = [result objectForKey:@"status"];   
	NSString *description = [result objectForKey:@"description"];
	//		NSString *debugger = [[result objectForKey:@"status"] objectForKey:@"debugger"];
	//[NSThread detachNewThreadSelector:@selector(dismissWaiting) toTarget:self withObject:nil];
    //	[self dismissWaiting];
    if([request responseStatusCode] == 200){
        if ([status isEqualToString:@"ok"]) {
            NSDictionary *dataSource = [result objectForKey:@"datasource"];
            self.lastID = [[dataSource objectForKey:@"lastID"] intValue];
            if (lastID < 0) {
                lastID = 0;
            }
            UITabBarItem *tbi = (UITabBarItem *)[self.tabBarController.tabBar.items objectAtIndex:1];
            [UIApplication sharedApplication].applicationIconBadgeNumber = [[dataSource objectForKey:@"unreadCount"] intValue];
            if ([[dataSource objectForKey:@"unreadCount"] intValue]==0) {
                tbi.badgeValue = nil;
            }else{
                tbi.badgeValue = [NSString stringWithFormat:@"%@",[dataSource objectForKey:@"unreadCount"]];
            }
            NSArray *partyDictArray = [dataSource objectForKey:@"partyList"];
            
            NSUserDefaults *partyListArrayDefault=[NSUserDefaults standardUserDefaults];
            [partyListArrayDefault setObject:partyDictArray forKey:@"partyListArrayDefaultForDetailContentRefresh"];
            
            if (!_isAppend) {
                [self.partyList removeAllObjects];
            }
            ///
            self.partyDictArraySelf=[partyDictArray copy];//新增
            
            NSString *partyListPath = [NSString stringWithFormat:@"%@/Documents/partylistofpre20.plist", NSHomeDirectory()];
            NSFileManager* fm = [NSFileManager defaultManager];
            NSMutableArray *patyListArrayWrite=[[NSMutableArray alloc] init];
            NSMutableArray *getArrayFromFile;
            if(![fm fileExistsAtPath:partyListPath]) {
                getArrayFromFile = [[NSMutableArray alloc] initWithCapacity:0];
            } else {
                getArrayFromFile = [[NSMutableArray alloc] initWithContentsOfFile:partyListPath];
            }
            
            if(getArrayFromFile.count==0){
                if(self.partyDictArraySelf.count>20){
                    for(int i=0;i<20;i++){
                        [patyListArrayWrite addObject:[self.partyDictArraySelf  objectAtIndex:i]];
                    }
                    if(patyListArrayWrite) {
                        [patyListArrayWrite  writeToFile:partyListPath  atomically:YES];
                    } else {
                        NSLog(@"partylistArray writeToFile error");
                    }
                }else{
                    [self.partyDictArraySelf  writeToFile:partyListPath  atomically:YES];
                }
            }
            
            for(int i=0;i<[partyDictArray count];i++){
                NSDictionary *partyDict = [partyDictArray objectAtIndex:i];
                PartyModel *partyModel=[[PartyModel alloc] init];
                partyModel.contentString = [partyDict objectForKey:@"description"];
                partyModel.partyId =[partyDict  objectForKey:@"partyId"];
                partyModel.peopleCountDict = [partyDict objectForKey:@"clientsData"];
                partyModel.shortURL = [partyDict objectForKey:@"shortURL"];
                partyModel.type=[partyDict objectForKey:@"type"];
                [self.partyList addObject:partyModel];
                
            }
            
            self.navigationItem.rightBarButtonItem.customView = nil;
            [self.tableView reloadData];
           
            
            
            //用于判断是否登录后跳转到活动列表页面
            UserObjectService *us = [UserObjectService sharedUserObjectService];
            UserObject *user = [us getUserObject];
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];  
            NSString *keyString=[[NSString alloc] initWithFormat:@"%dcountNumber",user.uID];
            [defaults setInteger: self.partyList.count  forKey:keyString];    
            [self setBottomRefreshViewYandDeltaHeight];
            //        [self setBottomRefreshViewYandDeltaHeight];
        }else{
            self.navigationItem.rightBarButtonItem.customView = nil;
            [self showAlertRequestFailed:description];		
        }
    }else if([request responseStatusCode] == 404){
        self.navigationItem.rightBarButtonItem.customView = nil;
        [self showAlertRequestFailed:REQUEST_ERROR_404];
    }else if([request responseStatusCode] == 500){
        self.navigationItem.rightBarButtonItem.customView = nil;
        [self showAlertRequestFailed:REQUEST_ERROR_500];
    }else if([request responseStatusCode] == 502){
        self.navigationItem.rightBarButtonItem.customView = nil;
        [self showAlertRequestFailed:REQUEST_ERROR_502];
    }else {
        self.navigationItem.rightBarButtonItem.customView = nil;
        [self showAlertRequestFailed:REQUEST_ERROR_504];
    }        
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    self._isRefreshing = NO;
    self.navigationItem.rightBarButtonItem.customView = nil;
	NSError *error = [request error];
	[self dismissWaiting];
	//[self showAlertRequestFailed: error.localizedDescription];
    [self showAlertRequestFailed:@"您的网络好像有问题"];//本地化更改
}



- (void)refreshBtnAction{
    //    UserObjectService *us = [UserObjectService sharedUserObjectService];
    //    UserObject *user = [us getUserObject];
    //    int page = 1;
    //    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%d/%d/" ,GET_PARTY_LIST,user.uID,page]];
    //    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    //    request.timeOutSeconds = 20;
    //    [request setDelegate:self];
    //    [request setShouldAttemptPersistentConnection:NO];
    //    [request startAsynchronous];
    //    self._isRefreshing = YES;
    [self requestDataWithLastID:0];
    
    UIActivityIndicatorView *acv = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [acv startAnimating];
    self.navigationItem.rightBarButtonItem.customView = acv;
    
    ////////////////////自己新增文件 
    NSString *partyListPath = [NSString stringWithFormat:@"%@/Documents/partylistofpre20.plist", NSHomeDirectory()];
    NSMutableArray *patyListArrayWrite=[[NSMutableArray alloc] init];
    if(self.partyDictArraySelf.count>20){
        for(int i=0;i<20;i++){
            [patyListArrayWrite addObject:[self.partyDictArraySelf  objectAtIndex:i]];
        }
        if(patyListArrayWrite) {
            [patyListArrayWrite  writeToFile:partyListPath  atomically:YES];
        } else {
            NSLog(@"partylistArray writeToFile error");
        }
    }else{
        [self.partyDictArraySelf  writeToFile:partyListPath  atomically:YES];
    }
//    NSUserDefaults *refreshDetailContentDefault=[NSUserDefaults standardUserDefaults];
//    BOOL isrefreshDetailContent=[refreshDetailContentDefault  boolForKey:@"refreshDetailContentDefault"];
//    if(isrefreshDetailContent){
//        PartyDetailTableVC *partyDetailTableVC = [[PartyDetailTableVC alloc] initWithNibName:@"PartyDetailTableVC" bundle:nil];//如果nibname为空  则不会呈现组显示
//        partyDetailTableVC.delegate=self;
//        partyDetailTableVC.hidesBottomBarWhenPushed = YES;
//        [self.navigationController pushViewController:partyDetailTableVC animated:YES];
//          partyDetailTableVC.partyObj=[self.partyList  objectAtIndex:rowLastPush];
//    }

}

- (void)AddBadgeToTabbar:(NSNotification *)notification{
    NSDictionary *userinfo = [notification userInfo];
    NSString *badge = [NSString stringWithFormat:@"%@",[userinfo objectForKey:@"badge"]];
    if ([badge intValue] <= 0) {
        return;
    }
    UITabBarItem *tbi = (UITabBarItem *)[self.tabBarController.tabBar.items objectAtIndex:1];
    tbi.badgeValue = badge;
}

- (void)clearData {
    [partyList removeAllObjects];
    [self.tableView reloadData];
    [self.navigationController popToRootViewControllerAnimated:NO];
    
    self.lastID = 0;
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
    
        
    NSString *newAppliedString=[[NSString alloc] initWithFormat:@"%@",[[[self.partyList  objectAtIndex:row] peopleCountDict] objectForKey:@"newAppliedClientcount"]];
    
    NSString *newRefusedString=[[NSString alloc] initWithFormat:@"%@",[[[self.partyList  objectAtIndex:row] peopleCountDict] objectForKey:@"newRefusedClientcount"]];
    
    PartyModel *partyObjCell=[self.partyList  objectAtIndex:[indexPath row]];
    if([newAppliedString intValue]>0){
       partyObjCell.isnewApplied=YES;
    }else{
       partyObjCell.isnewApplied=NO;
    }
    
    if([newRefusedString intValue]>0){
        partyObjCell.isnewRefused=YES;
    }else{
        partyObjCell.isnewRefused=NO;
    }
    
    //NSLog(@"row :%d,isnewApplied>>>%@.....isnewRefused>>>%@",row,BOOLStringOutput(partyObjCell.isnewApplied) ,BOOLStringOutput(partyObjCell.isnewRefused));
    
    UIView *oldLayout2 = nil;
    oldLayout2 = [cell viewWithTag:2];
    [oldLayout2 removeFromSuperview];

    if(partyObjCell.isnewApplied||partyObjCell.isnewRefused){  
        self.isRefreshImage=YES;
        UIImageView *cellImageView=[[UIImageView alloc] initWithFrame:CGRectMake(5, 10, 20, 20)];
        cellImageView.image=[UIImage imageNamed:@"new1"];
        cellImageView.tag=2;
        [cell  addSubview:cellImageView];
    
    }
    
    
    UIView *oldLayout3 = nil;
    oldLayout3 = [cell viewWithTag:3];
    [oldLayout3 removeFromSuperview];
    UILabel *contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 0, 175, 40)];
    contentLabel.tag=3;
    contentLabel.text=[[self.partyList  objectAtIndex:row] contentString];
    contentLabel.font=[UIFont systemFontOfSize:15];
    [cell  addSubview:contentLabel];
     
    NSString *applyString=[[NSString alloc] initWithFormat:@"%@",[[[self.partyList  objectAtIndex:row] peopleCountDict] objectForKey:@"appliedClientcount"]];
    NSString *donothingString=[[NSString alloc] initWithFormat:@"%@",[[[self.partyList  objectAtIndex:row] peopleCountDict] objectForKey:@"donothingClientcount"]];
    NSString *refuseString=[[NSString alloc] initWithFormat:@"%@",[[[self.partyList  objectAtIndex:row] peopleCountDict] objectForKey:@"refusedClientcount"]];
    NSInteger allNumbers=[applyString intValue]+[donothingString intValue]+[refuseString intValue];
    //已报名人数label
    UIView *oldLayout6 = nil;
    oldLayout6 = [cell viewWithTag:6];
    [oldLayout6 removeFromSuperview];
    UILabel *lb_1 = [[UILabel alloc] initWithFrame:CGRectMake(200, 0, 50, 40)];    
    lb_1.tag = 6;
    lb_1.text = [NSString stringWithFormat:@"%@/",applyString];
    lb_1.textColor=[UIColor greenColor];
    lb_1.textAlignment = UITextAlignmentRight;
    lb_1.backgroundColor = [UIColor clearColor];
    [cell addSubview:lb_1];
    
    //所有邀请人label
    UIView *oldLayout7 = nil;
    oldLayout7 = [cell viewWithTag:7];
    [oldLayout7 removeFromSuperview];
    UILabel *lb_7 = [[UILabel alloc] initWithFrame:CGRectMake(250, 0, 45, 40)];    
    lb_7.tag = 7;
    lb_7.text = [NSString stringWithFormat:@"%d",allNumbers];
    lb_7.textAlignment = UITextAlignmentLeft;
    lb_7.backgroundColor = [UIColor clearColor];
    [cell addSubview:lb_7];
    
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
    partyDetailTableVC.partyObj=[self.partyList  objectAtIndex:[indexPath row]];
    self.rowLastPush=[indexPath row];//记忆
    partyDetailTableVC.delegate=self;
    partyDetailTableVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:partyDetailTableVC animated:YES];
    partyDetailTableVC.rowLastPush=self.rowLastPush;
    //
}

#pragma mark -
#pragma mark Data Source Loading / Reloading Methods

- (void)reloadTableViewDataSource{
	
	//  should be calling your tableviews data source model to reload
	//  put here just for demo
    _reloading = YES;
    [self requestDataWithLastID:0];
	[self doneLoadingTopRefreshTableViewData];
    ////////////////////自己新增文件 
    NSString *partyListPath = [NSString stringWithFormat:@"%@/Documents/partylistofpre20.plist", NSHomeDirectory()];
    NSMutableArray *patyListArrayWrite=[[NSMutableArray alloc] init];
    if(self.partyDictArraySelf.count>20){
        for(int i=0;i<20;i++){
            [patyListArrayWrite addObject:[self.partyDictArraySelf  objectAtIndex:i]];
        }
        if(patyListArrayWrite) {
            [patyListArrayWrite  writeToFile:partyListPath  atomically:YES];
        } else {
            NSLog(@"partylistArray writeToFile error");
        }
    }else{
        [self.partyDictArraySelf  writeToFile:partyListPath  atomically:YES];
    }

    
}

- (void)loadNextPageTableViewDataSource{
	
	//  should be calling your tableviews data source model to reload
	//  put here just for demo
    _reloading = YES;
   [self requestDataWithLastID:self.lastID];
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
            [view setFrame:CGRectMake(view.frame.origin.x,431, view.frame.size.width, view.frame.size.height)];
        }
        else
        {
            [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width,431)];
        }
        
    }
    
    //[UIView commitAnimations];
}

-(void) showTabBar:(UITabBarController*) tabbarcontroller {
    
    
    for(UIView*view in tabbarcontroller.view.subviews)
    {
        
        if([view isKindOfClass:[UITabBar class]])
        {
            [view setFrame:CGRectMake(view.frame.origin.x,431, view.frame.size.width, view.frame.size.height)];
        }else{
            [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width,480)];
        }
    }
    
}
#pragma mark -
#pragma mark dealloc method
- (void)dealloc {
    [self.quest clearDelegatesAndCancel];
    self.quest = nil;
}




@end
