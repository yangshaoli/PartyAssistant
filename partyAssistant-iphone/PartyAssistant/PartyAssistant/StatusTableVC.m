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



@interface StatusTableVC()

-(void) hideTabBar:(UITabBarController*) tabbarcontroller;
-(void) showTabBar:(UITabBarController*) tabbarcontroller;

@end

@implementation StatusTableVC
@synthesize clientsArray;
@synthesize clientStatusFlag;
@synthesize partyObj;
@synthesize wordString;
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
    NSNumber *partyIdNumber=self.partyObj.partyId;
    NSLog(@"输出后kkkkk。。。。。。%d",[partyIdNumber intValue]);
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%d/%@/",GET_PARTY_CLIENT_SEPERATED_LIST,[partyIdNumber intValue],self.clientStatusFlag]];
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
    UILabel *upLaterLb= [[UILabel alloc] initWithFrame:CGRectMake(230, 0, 80, 20)];
    upLaterLb.text = self.title;
    upLaterLb.textAlignment = UITextAlignmentLeft;
    upLaterLb.textColor = [UIColor blueColor];
    upLaterLb.backgroundColor = [UIColor clearColor];
    [cell addSubview:upLaterLb];
    
    UILabel *firstLb= [[UILabel alloc] initWithFrame:CGRectMake(50, 0, 150, 20)];
    firstLb.text=[clentDic objectForKey:@"cName"];
    //firstLb.text = [self.clientsArray  objectAtIndex:[indexPath row]];
    firstLb.textAlignment = UITextAlignmentLeft;
    firstLb.textColor = [UIColor blueColor];
    firstLb.backgroundColor = [UIColor clearColor];
    [cell addSubview:firstLb];
    
    
    if([self.title isEqualToString:@"已报名"]||[self.title isEqualToString:@"不参加"]){
        BOOL isCheck=[[clentDic  objectForKey:@"isCheck"] boolValue];//不可少boolvalue
        if(isCheck){
            UIImageView *cellImageView=[[UIImageView alloc] initWithFrame:CGRectMake(5, 10, 20, 20)];
            cellImageView.image=[UIImage imageNamed:@"new2"];
            [cell  addSubview:cellImageView];
        }
        
        
        UILabel *secondLb= [[UILabel alloc] initWithFrame:CGRectMake(50, 22, 280, 20)];
        secondLb.text = [clentDic objectForKey:@"msg"];
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
    
     [self.navigationController pushViewController:contactorPhoneDetailsViewController animated:YES];
    contactorPhoneDetailsViewController.messageTextView.text=@"留言自造数据ddddddddddddddddddd的 点点滴滴 ddddddddddd 点点滴滴ddddd 点点滴滴 淡淡的 得到 的的额度的的的的的";//需要放在push后面才可以成功赋值
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


@end