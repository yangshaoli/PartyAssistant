//
//  StatusTableVC.m
//  PartyAssistant
//
//  Created by user on 11-12-19.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "StatusTableVC.h"
#import "ContactorPhoneDetailsViewController.h"
#import "URLSettings.h"
#import "JSON.h"
#import "ASIFormDataRequest.h"
#import "HTTPRequestErrorMSG.h"
#import "UITableViewControllerExtra.h"
#import "ResendPartyViaSMSViewController.h"


@interface StatusTableVC()
-(void) hideTabBar:(UITabBarController*) tabbarcontroller;
-(void) showTabBar:(UITabBarController*) tabbarcontroller;
@end

@implementation StatusTableVC
@synthesize clientsArray;
@synthesize clientStatusFlag;
@synthesize partyObj;
@synthesize wordString;
@synthesize quest;
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
    //self.clientsArray=[[NSMutableArray alloc] initWithObjects:@"张三",@"李四",@"王五", nil];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self showWaiting];
    
    UIBarButtonItem *resendBtn = [[UIBarButtonItem alloc] initWithTitle:@"再次邀请" style:UIBarButtonItemStyleDone target:self action:@selector(resendBtnAction)];
    self.navigationItem.rightBarButtonItem = resendBtn;
    [self getPartyClientSeperatedList];
}

- (void)getPartyClientSeperatedList{
    NSNumber *partyIdNumber=self.partyObj.partyId;
    NSLog(@"输出后kkkkk。。。。。。%d",[partyIdNumber intValue]);
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%d/%@/",GET_PARTY_CLIENT_SEPERATED_LIST,[partyIdNumber intValue],self.clientStatusFlag]];
    
    if (self.quest) {
        [self.quest clearDelegatesAndCancel];
    }

    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    request.timeOutSeconds = 30;
    [request setDelegate:self];
    [request setShouldAttemptPersistentConnection:NO];
    [request startAsynchronous];
    self.quest=request;
}

- (void)requestFinished:(ASIHTTPRequest *)request{
	NSString *response = [request responseString];
	SBJsonParser *parser = [[SBJsonParser alloc] init];
	NSDictionary *result = [parser objectWithString:response];
	NSString *description = [result objectForKey:@"description"];
	[self dismissWaiting];
    if ([request responseStatusCode] == 200) {
        if ([description isEqualToString:@"ok"]) {
            NSDictionary *dict = [result objectForKey:@"datasource"];
            self.clientsArray = [dict objectForKey:@"clientList"];
            NSLog(@"self.clientsArray在statustableVC中输出后%@",self.clientsArray);
            UITabBarItem *tbi = (UITabBarItem *)[self.tabBarController.tabBar.items objectAtIndex:1];
            [UIApplication sharedApplication].applicationIconBadgeNumber = [[dict objectForKey:@"unreadCount"] intValue];
            if ([[dict objectForKey:@"unreadCount"] intValue]==0) {
                tbi.badgeValue = nil;
            }else{
                tbi.badgeValue = [NSString stringWithFormat:@"%@",[dict objectForKey:@"unreadCount"]];
            }
            [self.tableView reloadData];
        }else{
            [self showAlertRequestFailed:description];	
              NSLog(@"self.clientsArray在1");
        }
    }else if([request responseStatusCode] == 404){
        [self showAlertRequestFailed:REQUEST_ERROR_404];
         NSLog(@"self.clientsArray在2");
    }else{
        [self showAlertRequestFailed:REQUEST_ERROR_500];
         NSLog(@"self.clientsArray在3");
    }
	
}


- (void)requestFailed:(ASIHTTPRequest *)request
{
	NSError *error = [request error];
	[self dismissWaiting];
	[self showAlertRequestFailed: error.localizedDescription];
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
    [self hideTabBar:self.tabBarController];
    [self getPartyClientSeperatedList];

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


- (void)resendBtnAction{
    
    NSLog(@"在status中输出-----%@%@",self.clientsArray,self.partyObj.contentString);
    [self getPartyClientSeperatedList];
    ResendPartyViaSMSViewController *resendPartyViaSMSViewController=[[ResendPartyViaSMSViewController alloc] initWithNibName:@"CreatNewPartyViaSMSViewController" bundle:nil];
    [self.navigationController pushViewController:resendPartyViaSMSViewController animated:YES];
    [resendPartyViaSMSViewController  setSmsContent:self.partyObj.contentString  andGropID:[self.partyObj.partyId intValue]];
    [resendPartyViaSMSViewController  setNewReceipts:self.clientsArray];
    NSLog(@"调用再次发送");
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return  [self.clientsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
       
    
    cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    NSDictionary *clentDic=[self.clientsArray objectAtIndex:[indexPath row]];
    self.wordString=[clentDic objectForKey:@"msg"];
       // Configure the cell...
    //cell.textLabel.text=[self.clientsArray  objectAtIndex:[indexPath row]];
     NSString *statusString=[clentDic objectForKey:@"status"];
    UIView *oldLayout10 = nil;
    oldLayout10=[cell viewWithTag:10];
    [oldLayout10 removeFromSuperview];

    UILabel *statusLb= [[UILabel alloc] initWithFrame:CGRectMake(230, 0, 80, 20)];
    statusLb.tag=10;
    if([statusString isEqualToString:@"apply"]){
         statusLb.text = @"已报名";
    }else if([statusString isEqualToString:@"reject"]){
         statusLb.text = @"不参加";
    }else if([statusString isEqualToString:@"noanswer"]){
         statusLb.text = @"未响应";
    }else{
          statusLb.text = @"已邀请";
    }
    statusLb.textAlignment = UITextAlignmentLeft;
    statusLb.textColor = [UIColor blueColor];
    statusLb.backgroundColor = [UIColor clearColor];
    [cell addSubview:statusLb];
    
    
       
    UIView *oldLayout6 = nil;
    oldLayout6=[cell viewWithTag:6];
    [oldLayout6 removeFromSuperview];
    UILabel *nameLb= [[UILabel alloc] initWithFrame:CGRectMake(30, 0, 70, 20)];
    nameLb.tag=6;
    nameLb.text=[clentDic objectForKey:@"cName"];
    nameLb.font=[UIFont systemFontOfSize:15];
    nameLb.textAlignment = UITextAlignmentLeft;
    nameLb.textColor = [UIColor blueColor];
    nameLb.backgroundColor = [UIColor clearColor];
    [cell addSubview:nameLb];
    
    
    UIView *oldLayout7 = nil;
    oldLayout7=[cell viewWithTag:7];
    [oldLayout7 removeFromSuperview];
    UILabel *phoneLb= [[UILabel alloc] initWithFrame:CGRectMake(120, 0, 80, 20)];
    phoneLb.tag=7;
    phoneLb.text=[clentDic objectForKey:@"cValue"];
    phoneLb.font=[UIFont systemFontOfSize:10];
    phoneLb.textAlignment = UITextAlignmentLeft;
    phoneLb.textColor = [UIColor grayColor];
    phoneLb.backgroundColor = [UIColor clearColor];
    [cell addSubview:phoneLb];
    
    //8是留言
    UIView *oldLayout8 = nil;
    oldLayout8=[cell viewWithTag:8];
    [oldLayout8 removeFromSuperview];

    NSLog(@"%@输出状态。。。%@",[clentDic objectForKey:@"cName"],statusString);
    //5是图标
    UIView *oldLayout2 = nil;
    oldLayout2=[cell viewWithTag:5];
    [oldLayout2 removeFromSuperview];
    
    if([self.title isEqualToString:@"已报名"]){
        BOOL isCheck=[[clentDic  objectForKey:@"isCheck"] boolValue];//不可少boolvalue
        if(isCheck){
            NSLog(@"在已报名页面");
            UIImageView *cellImageView=[[UIImageView alloc] initWithFrame:CGRectMake(5, 10, 20, 20)];
            cellImageView.image=[UIImage imageNamed:@"new2"];
            cellImageView.tag=5;
            [cell  addSubview:cellImageView];
        }
        
        
        UILabel *secondLb= [[UILabel alloc] initWithFrame:CGRectMake(30, 22, 280, 20)];
        secondLb.tag=8;
        NSString *statusWordString=[clentDic objectForKey:@"msg"];
        if(statusWordString.length){
            if(statusWordString.length>19){
                secondLb.text = [[statusWordString  substringFromIndex:1]  substringToIndex:19];//去掉留言逗号后截取18个字符
            }else{
                secondLb.text =[statusWordString substringFromIndex:1];//只去掉逗号
            }
            
            
        }else{
            NSLog(@"留言为空");
            
        }
        
        
        NSLog(@"secondLb.text>>>>>>>%@",secondLb.text);
        secondLb.font=[UIFont systemFontOfSize:15];
        secondLb.textAlignment = UITextAlignmentLeft;
        //secondLb.textColor = [UIColor blueColor];
        secondLb.backgroundColor = [UIColor clearColor];
        [cell addSubview:secondLb];
    }else if([self.title isEqualToString:@"不参加"]){
        BOOL isCheck=[[clentDic  objectForKey:@"isCheck"] boolValue];//不可少boolvalue
        if(isCheck){
            NSLog(@"在不参加页面");
            UIImageView *cellImageView=[[UIImageView alloc] initWithFrame:CGRectMake(5, 10, 20, 20)];
            cellImageView.image=[UIImage imageNamed:@"new2"];
            cellImageView.tag=5;
            [cell  addSubview:cellImageView];
        }
        UILabel *secondLb= [[UILabel alloc] initWithFrame:CGRectMake(30, 22, 280, 20)];
        secondLb.tag=8;
        
        NSString *statusWordString=[clentDic objectForKey:@"msg"];
        if(statusWordString.length){
            if(statusWordString.length>19){
                secondLb.text = [[statusWordString  substringFromIndex:1]  substringToIndex:19];//去掉留言逗号后截取18个字符
            }else{
                secondLb.text =[statusWordString substringFromIndex:1];//只去掉逗号
            }

        
        }else{
            NSLog(@"留言为空");
        
        }
        
        secondLb.font=[UIFont systemFontOfSize:15];
        secondLb.textAlignment = UITextAlignmentLeft;
        //secondLb.textColor = [UIColor blueColor];
        secondLb.backgroundColor = [UIColor clearColor];
        [cell addSubview:secondLb];
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
    
     ContactorPhoneDetailsViewController *contactorPhoneDetailsViewController = [[ContactorPhoneDetailsViewController alloc] initWithNibName:@"ContactorPhoneDetailsViewController" bundle:[NSBundle mainBundle]];
      
      contactorPhoneDetailsViewController.contactorID =10;
//    contactorPhoneDetailsViewController.contactorID =[[clientDic  objectForKey:@"backendID"] intValue];
//    NSLog(@"backendID>>>>%d",contactorPhoneDetailsViewController.contactorID);
    
   
//      contactorPhoneDetailsViewController.phoneDetailDelegate = self;
     contactorPhoneDetailsViewController.clientDict=[self.clientsArray  objectAtIndex:[indexPath row]];
     contactorPhoneDetailsViewController.partyObj=self.partyObj;
     contactorPhoneDetailsViewController.clientStatusFlag=self.clientStatusFlag;
     [self.navigationController pushViewController:contactorPhoneDetailsViewController animated:YES];
    
   
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

//-(void) showTabBar:(UITabBarController*) tabbarcontroller {
//    
//    [UIView beginAnimations:nil context:NULL];
//    [UIView setAnimationDuration:0.5];
//    [UIView commitAnimations];
//    
//    for(UIView*view in tabbarcontroller.view.subviews)
//    {
//        if([view isKindOfClass:[UITabBar class]])
//        {
//            [view setFrame:CGRectMake(view.frame.origin.x,431, view.frame.size.width, view.frame.size.height)];
//        }
//        else
//        {
//            [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width,431)];
//        }
//    }
//    
//}
#pragma mark -
#pragma mark dealloc method
-(void)dealloc {
    [self.quest clearDelegatesAndCancel];
    self.quest = nil;
}


@end
