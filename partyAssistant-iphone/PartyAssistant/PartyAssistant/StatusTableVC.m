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
#import "UIViewControllerExtra.h"

#import "ContactData.h"

#import "pinyin.h"

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
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%d/%@/%@/",GET_PARTY_CLIENT_SEPERATED_LIST,[partyIdNumber intValue],self.clientStatusFlag,@"?read=yes"]];
    
    if (self.quest) {
        [self.quest clearDelegatesAndCancel];
    }

    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    request.timeOutSeconds = 20;
    [request setDelegate:self];
    [request setShouldAttemptPersistentConnection:NO];
    [request startAsynchronous];
    self.quest=request;
}

- (void)requestFinished:(ASIHTTPRequest *)request{
	NSString *response = [request responseString];
	SBJsonParser *parser = [[SBJsonParser alloc] init];
	NSDictionary *result = [parser objectWithString:response];
    [self getVersionFromRequestDic:result];
    NSString *status = [result objectForKey:@"status"];   
	NSString *description = [result objectForKey:@"description"];
	[self dismissWaiting];
    if ([request responseStatusCode] == 200) {
        if ([status isEqualToString:@"ok"]) {
            NSDictionary *dict = [result objectForKey:@"datasource"];
            self.clientsArray = [dict objectForKey:@"clientList"];
            NSLog(@"now  打印array：：%@",self.clientsArray);
            //new sorting order
//            self.clientsArray = [clientsArray sortedArrayUsingComparator:^(id obj1, id obj2)
//             {
//                 NSDictionary *clientDic1 = obj1;
//                 NSDictionary *clientDic2 = obj2;
//                 
//                 BOOL isCheck1 = [[clientDic1  objectForKey:@"isCheck"] boolValue];
//                 BOOL isCheck2 = [[clientDic2  objectForKey:@"isCheck"] boolValue];
//                 
//                 if (isCheck1 == isCheck2) {
//                     NSString *name1 = [clientDic1 objectForKey:@"cName"];
//                     NSString *name2 = [clientDic2 objectForKey:@"cName"];
//                     
//                     NSString *standardString = nil;
//                     if (name1.length > name2.length) {
//                         standardString = name2;
//                     } else {
//                         standardString = name1;
//                     }
//                     
//                     
//                     
//                     for (int i=0; i<standardString.length; i++) {
//                         NSString *compareName1 = nil;
//                         NSString *compareName2 = nil;
//                        
//                         NSString *subString1 = [name1 substringWithRange:NSMakeRange(i, 1)];
//                         NSString *subString2 = [name2 substringWithRange:NSMakeRange(i, 1)];
//                         
//                         BOOL isEnglishLetter1 = checkIsEnglishLetter([[subString1 uppercaseString] characterAtIndex:0]);
//                         
//                         BOOL isEnglishLetter2 = checkIsEnglishLetter([[subString2 uppercaseString] characterAtIndex:0]);
//                         
//                         if (isEnglishLetter1 && isEnglishLetter2) {
//                             compareName1 = [NSString stringWithFormat:@"%c",pinyinFirstLetter([subString1  characterAtIndex:0])];
//                             NSUInteger firstLetter1 = [ENHANCEALPHA rangeOfString:[compareName1 substringToIndex:1]].location;
//                             
//                             compareName2 = [NSString stringWithFormat:@"%c",pinyinFirstLetter([subString2  characterAtIndex:0])];
//                             NSUInteger firstLetter2 = [ENHANCEALPHA rangeOfString:[compareName2 substringToIndex:1]].location;
//                             
//                             NSLog(@"%@,%d,%@,%d",compareName1,firstLetter1,compareName2,firstLetter2);
//                             
//                             if (firstLetter1 > firstLetter2) {
//                                 return NSOrderedDescending;
//                             } else if (firstLetter1 < firstLetter2) {
//                                 return NSOrderedAscending;
//                             }
//                             continue;
//                         } else {
//                             if (isEnglishLetter1) {
//                                 return NSOrderedAscending;
//                             } else if (isEnglishLetter2) {
//                                 return NSOrderedDescending;
//                             } else {
//                                 
//                             }
//                         }
//                         
//                         if([ContactData searchResult:subString1 searchText:@"曾"])
//                             compareName1 = @"Z";
//                         else if([ContactData searchResult:subString1 searchText:@"解"])
//                             compareName1 = @"X";
//                         else if([ContactData searchResult:subString1 searchText:@"仇"])
//                             compareName1 = @"Q";
//                         else if([ContactData searchResult:subString1 searchText:@"朴"])
//                             compareName1 = @"P";
//                         else if([ContactData searchResult:subString1 searchText:@"查"])
//                             compareName1 = @"Z";
//                         else if([ContactData searchResult:subString1 searchText:@"能"])
//                             compareName1 = @"N";
//                         else if([ContactData searchResult:subString1 searchText:@"乐"])
//                             compareName1 = @"Y";
//                         else if([ContactData searchResult:subString1 searchText:@"单"])
//                             compareName1 = @"S";
//                         else
//                             compareName1 = [[NSString stringWithFormat:@"%c",pinyinFirstLetter([[subString1 uppercaseString] characterAtIndex:0])] uppercaseString];
//                         NSUInteger firstLetter1 = [ALPHA rangeOfString:[compareName1 substringToIndex:1]].location;
//                         
//                         if([ContactData searchResult:subString2 searchText:@"曾"])
//                             compareName2 = @"Z";
//                         else if([ContactData searchResult:subString2 searchText:@"解"])
//                             compareName2 = @"X";
//                         else if([ContactData searchResult:subString2 searchText:@"仇"])
//                             compareName2 = @"Q";
//                         else if([ContactData searchResult:subString2 searchText:@"朴"])
//                             compareName2 = @"P";
//                         else if([ContactData searchResult:subString2 searchText:@"查"])
//                             compareName2 = @"Z";
//                         else if([ContactData searchResult:subString2 searchText:@"能"])
//                             compareName2 = @"N";
//                         else if([ContactData searchResult:subString2 searchText:@"乐"])
//                             compareName2 = @"Y";
//                         else if([ContactData searchResult:subString2 searchText:@"单"])
//                             compareName2 = @"S";
//                         else
//                             compareName2 = [[NSString stringWithFormat:@"%c",pinyinFirstLetter([[subString2 uppercaseString] characterAtIndex:0])] uppercaseString];
//                         NSUInteger firstLetter2 = [ALPHA rangeOfString:[compareName2 substringToIndex:1]].location;
//                         
//                         if (firstLetter1 > firstLetter2) {
//                             return NSOrderedDescending;
//                         } else if (firstLetter1 < firstLetter2) {
//                             return NSOrderedAscending;
//                         }
//                     }    
//                     
//                     if (standardString == name1) {
//                         return NSOrderedAscending;
//                     } else {
//                         return NSOrderedDescending;
//                     }
//                     
//                 } else {
//                     if (isCheck1) {
//                         return NSOrderedAscending;
//                     } else {
//                         return NSOrderedDescending;
//                     }
//                 }
//            }];
            
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
        }
    }else if([request responseStatusCode] == 404){
        [self showAlertRequestFailed:REQUEST_ERROR_404];
    }else if([request responseStatusCode] == 500){
        [self showAlertRequestFailed:REQUEST_ERROR_500];
    }else if([request responseStatusCode] == 502){
        [self showAlertRequestFailed:REQUEST_ERROR_502];
    }else{
        [self showAlertRequestFailed:REQUEST_ERROR_504];
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
    
//    [self getPartyClientSeperatedList];
//    UIAlertView *alertV = [[UIAlertView alloc] initWithTitle:@"手机版暂不支持邮件发送" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"好的，知道了", nil];
//    [alertV show];
//    NSLog(@"打印出type：：%@",self.partyObj.type);
//    ResendPartyViaSMSViewController *resendPartyViaSMSViewController=[[ResendPartyViaSMSViewController alloc] initWithNibName:@"CreatNewPartyViaSMSViewController" bundle:nil];
//    NSMutableArray *clientDicArray=[self.clientsArray mutableCopy];
//    for(NSDictionary  *clientDic in self.clientsArray){
//        if([self.partyObj.type isEqualToString:@"email"]){
//            [clientDicArray removeObject:clientDic];
//        }
//    }
//    
//    NSLog(@"detail页面输出再次发送数组》》》%@",clientDicArray);
//    [self.navigationController pushViewController:resendPartyViaSMSViewController animated:YES];
//    [resendPartyViaSMSViewController  setSmsContent:self.partyObj.contentString  andGropID:[self.partyObj.partyId intValue]];
//    [resendPartyViaSMSViewController  setNewReceipts:clientDicArray];


  [self getPartyClientSeperatedList];
    if([self.partyObj.type isEqualToString:@"email"]){
        UIAlertView *alertV = [[UIAlertView alloc] initWithTitle:@"手机版暂不支持邮件发送" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"好的，知道了", nil];
        [alertV show];
    }else{
        ResendPartyViaSMSViewController *resendPartyViaSMSViewController=[[ResendPartyViaSMSViewController alloc] initWithNibName:@"CreatNewPartyViaSMSViewController" bundle:nil];
         [self.navigationController pushViewController:resendPartyViaSMSViewController animated:YES];
        [resendPartyViaSMSViewController  setSmsContent:self.partyObj.contentString  andGropID:[self.partyObj.partyId intValue]];
        [resendPartyViaSMSViewController  setNewReceipts:self.clientsArray];
    }

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
    if([clentDic objectForKey:@"cName"]==nil||[[clentDic objectForKey:@"cName"] isEqualToString:@""]){
        nameLb.text=[clentDic objectForKey:@"cValue"];
    }else{
        nameLb.text=[clentDic objectForKey:@"cName"];
    }
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
    phoneLb.font=[UIFont systemFontOfSize:13];
    phoneLb.textAlignment = UITextAlignmentLeft;
    phoneLb.backgroundColor = [UIColor clearColor];
    [cell addSubview:phoneLb];
    
    //8是留言
    UIView *oldLayout8 = nil;
    oldLayout8=[cell viewWithTag:8];
    [oldLayout8 removeFromSuperview];

    //5是图标
    UIView *oldLayout2 = nil;
    oldLayout2=[cell viewWithTag:5];
    [oldLayout2 removeFromSuperview];
    
    if([self.title isEqualToString:@"已报名"]){
        BOOL isCheck=[[clentDic  objectForKey:@"isCheck"] boolValue];//不可少boolvalue
        if(!isCheck){
            UIImageView *cellImageView=[[UIImageView alloc] initWithFrame:CGRectMake(5, 10, 20, 20)];
            cellImageView.image=[UIImage imageNamed:@"new2"];
            cellImageView.tag=5;
            [cell  addSubview:cellImageView];
        }
        
        
        UILabel *secondLb= [[UILabel alloc] initWithFrame:CGRectMake(30, 22, 290, 20)];
        secondLb.textColor=[UIColor grayColor];
        secondLb.font=[UIFont systemFontOfSize:13];
        secondLb.tag=8;
        NSString *statusWordString=[clentDic objectForKey:@"msg"];
        if(statusWordString.length){
            if(statusWordString.length>19){
                secondLb.text = [[statusWordString  substringFromIndex:1]  substringToIndex:19];//去掉留言逗号后截取18个字符
            }else{
                secondLb.text =[statusWordString substringFromIndex:1];//只去掉逗号
            }
            
            
        }else{
            
             secondLb.text=@"无留言";
        }
        secondLb.font=[UIFont systemFontOfSize:15];
        secondLb.textAlignment = UITextAlignmentLeft;
        //secondLb.textColor = [UIColor blueColor];
        secondLb.backgroundColor = [UIColor clearColor];
        [cell addSubview:secondLb];
    }else if([self.title isEqualToString:@"不参加"]){
        BOOL isCheck=[[clentDic  objectForKey:@"isCheck"] boolValue];//不可少boolvalue
        if(!isCheck){
            UIImageView *cellImageView=[[UIImageView alloc] initWithFrame:CGRectMake(5, 10, 20, 20)];
            cellImageView.image=[UIImage imageNamed:@"new2"];
            cellImageView.tag=5;
            [cell  addSubview:cellImageView];
        }
        UILabel *secondLb= [[UILabel alloc] initWithFrame:CGRectMake(30, 22, 280, 20)];
        secondLb.tag=8;
        secondLb.textColor=[UIColor grayColor];
        secondLb.font=[UIFont systemFontOfSize:13];
        NSString *statusWordString=[clentDic objectForKey:@"msg"];
        if(statusWordString.length){
            if(statusWordString.length>19){
                secondLb.text = [[statusWordString  substringFromIndex:1]  substringToIndex:19];//去掉留言逗号后截取18个字符
            }else{
                secondLb.text =[statusWordString substringFromIndex:1];//只去掉逗号
            }

        
        }else{
             secondLb.text=@"无留言";
        
        }
        
        secondLb.font=[UIFont systemFontOfSize:15];
        secondLb.textAlignment = UITextAlignmentLeft;
        //secondLb.textColor = [UIColor blueColor];
        secondLb.backgroundColor = [UIColor clearColor];
        [cell addSubview:secondLb];
    }else if([self.title isEqualToString:@"已邀请"]){
        UILabel *secondLb= [[UILabel alloc] initWithFrame:CGRectMake(30, 22, 280, 20)];
        secondLb.tag=8;
        secondLb.textColor=[UIColor grayColor];
        secondLb.font=[UIFont systemFontOfSize:13];
        NSString *statusWordString=[clentDic objectForKey:@"msg"];
        if(statusWordString.length){
            if(statusWordString.length>19){
                secondLb.text = [[statusWordString  substringFromIndex:1]  substringToIndex:19];//去掉留言逗号后截取18个字符
            }else{
                secondLb.text =[statusWordString substringFromIndex:1];//只去掉逗号
            }
            
            
        }else{
             secondLb.text=@"无留言";
        }
        
        secondLb.font=[UIFont systemFontOfSize:15];
        secondLb.textAlignment = UITextAlignmentLeft;
        //secondLb.textColor = [UIColor blueColor];
        secondLb.backgroundColor = [UIColor clearColor];
        [cell addSubview:secondLb];
    }else if([self.title isEqualToString:@"未响应"]){
        UILabel *secondLb= [[UILabel alloc] initWithFrame:CGRectMake(30, 22, 280, 20)];
        secondLb.tag=8;
        secondLb.textColor=[UIColor grayColor];
        secondLb.font=[UIFont systemFontOfSize:13];
        NSString *statusWordString=[clentDic objectForKey:@"msg"];
        if(statusWordString.length){
            if(statusWordString.length>19){
                secondLb.text = [[statusWordString  substringFromIndex:1]  substringToIndex:19];//去掉留言逗号后截取18个字符
            }else{
                secondLb.text =[statusWordString substringFromIndex:1];//只去掉逗号
            }
            
            
        }else{
             secondLb.text=@"无留言";
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

#pragma mark -
#pragma mark dealloc method
-(void)dealloc {
    [self.quest clearDelegatesAndCancel];
    self.quest = nil;
}

- (void)reorderSubjects : (NSArray *)newSubjects {
    //1 isCheck == NO
    //2 isCheck == YES
    
    //combine two array
    
    //reorder each on by name
}
@end
