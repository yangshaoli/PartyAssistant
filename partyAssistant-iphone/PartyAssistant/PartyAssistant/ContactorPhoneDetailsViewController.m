//
//  ContactorPhoneDetailsViewController.m
//  PartyAssistant
//
//  Created by 超 李 on 11-11-1.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "ContactorPhoneDetailsViewController.h"
#import "URLSettings.h"
#import "JSON.h"
#import "ASIFormDataRequest.h"
#import "HTTPRequestErrorMSG.h"
#import "UITableViewControllerExtra.h"
@implementation ContactorPhoneDetailsViewController
@synthesize contactorID,phoneDetailDelegate,clientDict,partyObj;
@synthesize messageTextView;
@synthesize clientStatusFlag;

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
    NSLog(@"在最后一个页面输出状态：：%@",self.clientStatusFlag);
    UIButton *goButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [goButton setFrame:CGRectMake(50, 200, 80, 40)];
    [goButton setTitle:@"参加" forState:UIControlStateNormal];
    
//    [goButton addTarget:self action:@selector(nil) forControlEvents:UIControlEventTouchUpInside];
    goButton.tag=23;
    goButton.backgroundColor=[UIColor  clearColor];
    [goButton addTarget:self action:@selector(changeClientStatus:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *notGoButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [notGoButton setFrame:CGRectMake(200, 200,80, 40)];
    [notGoButton setTitle:@"不参加" forState:UIControlStateNormal];
    //    [goButton addTarget:self action:@selector(nil) forControlEvents:UIControlEventTouchUpInside];
    notGoButton.tag=24;
    notGoButton.backgroundColor=[UIColor clearColor];
    [notGoButton addTarget:self action:@selector(changeClientStatus:) forControlEvents:UIControlEventTouchUpInside];
    
    if([self.clientStatusFlag isEqualToString:@"donothing"]||[self.clientStatusFlag  isEqualToString:@"refused"]){
         [self.view addSubview:goButton];
    }
     
    if([self.clientStatusFlag isEqualToString:@"donothing"]||[self.clientStatusFlag  isEqualToString:@"applied"]){
        [self.view addSubview:notGoButton];
    
    }
    
    NSString *statusString=[self.clientDict objectForKey:@"status"];
    if([self.clientStatusFlag  isEqualToString:@"all"]){
        if([statusString  isEqualToString:@"noanswer"]||[statusString  isEqualToString:@"reject"]){
              [self.view addSubview:goButton];
        }
        if([statusString isEqualToString:@"noanswer"]||[statusString  isEqualToString:@"apply"]){
               [self.view addSubview:notGoButton];
        }
    
    }
    
    messageTextView=[[UITextView alloc] init];
    messageTextView.frame=CGRectMake(100, 153, 200, 40);
    messageTextView.font=[UIFont systemFontOfSize:15];
    messageTextView.backgroundColor=[UIColor clearColor];
    messageTextView.editable=NO;
    [self.view addSubview:messageTextView];
   
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
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];  
    NSString *keyString=[[NSString alloc] initWithFormat:@"%disStatusChanged",[self.partyObj.partyId intValue]];
    [defaults setInteger:5  forKey:keyString]; 
   
    
    NSInteger  getStatusChangedInt=[defaults integerForKey:keyString];
    NSLog(@"在viewWillAppear中调用  输出keyString:::%@     值:%d",keyString,getStatusChangedInt);
    
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

- (void)changeClientStatus:(UIButton *)btn
{
    [self performSelectorOnMainThread:@selector(sendChangeClientRequest:) withObject:btn waitUntilDone:NO];
//    [btn setTintColor:[UIColor grayColor]];
//    [btn  setBackgroundColor:[UIColor grayColor]];
}

- (void)sendChangeClientRequest:(UIButton *)btn
{
//    int row = btn.tag;
//    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
//    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    NSURL *url = [NSURL URLWithString:CLIENT_STATUS_OPERATOR];
    NSString *statusAction = @"";
    if(btn.tag==23){
        statusAction=@"apply";
        NSUserDefaults *isChenkDefault=[NSUserDefaults standardUserDefaults];
        NSString *appliedKeyString=[[NSString alloc] initWithFormat:@"%dappliedIscheck",[self.partyObj.partyId intValue]];
        NSInteger currentInt=[isChenkDefault integerForKey:appliedKeyString];
        [isChenkDefault  setInteger:currentInt+1  forKey:appliedKeyString]; 
    
    }else if(btn.tag==24){
        statusAction=@"reject";
        NSUserDefaults *isChenkDefault=[NSUserDefaults standardUserDefaults];
        NSString *refusedKeyString=[[NSString alloc] initWithFormat:@"%drefusedIscheck",[self.partyObj.partyId intValue]];
        NSInteger currentInt=[isChenkDefault integerForKey:refusedKeyString];
        [isChenkDefault setInteger:currentInt-1 forKey:refusedKeyString];
    
    }
//    if ([self.clientStatusFlag isEqualToString:@"all"]) {
//        if ([[[self.clientsArray objectAtIndex:row] objectForKey:@"status"] isEqualToString:@"已报名"]) {
//            statusAction = @"refuse";
//        }else{
//            statusAction = @"apply";
//        }
//    }else{
//        if ([self.clientStatusFlag isEqualToString:@"applied"]) {
//            statusAction = @"refuse";
//        }else{
//            statusAction = @"apply";
//        }
//    }
    
    NSInteger backendID=[[clientDict  objectForKey:@"backendID"] intValue];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setPostValue:[NSNumber numberWithInteger:backendID] forKey:@"cpID"];
    [request setPostValue:statusAction forKey:@"cpAction"];
    request.timeOutSeconds = 30;
    [request setDelegate:self];
    [request setShouldAttemptPersistentConnection:NO];
    //btn.hidden = YES;
    btn.enabled = NO;
//    UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
//    activity.frame = btn.frame;
//    [activity startAnimating];
//    [cell addSubview:activity];
    [request setDidFinishSelector:nil];
    [request setDidFailSelector:nil];
    [request startSynchronous];
    NSError *error = [request error];
    if (!error) {
        //[activity removeFromSuperview];
        NSString *response = [request responseString];
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        NSDictionary *result = [parser objectWithString:response];
        NSString *description = [result objectForKey:@"description"];
        if ([request responseStatusCode] == 200) {
            if ([description isEqualToString:@"ok"]) {
                //[btn removeFromSuperview];
//                for (int i=0; i<[[cell subviews] count]; i++) {
//                    if ([[[cell subviews] objectAtIndex:i] isMemberOfClass:[UILabel class]]) {
//                        UILabel *l = [[cell  subviews] objectAtIndex:i];
//                        if ([l.text isEqualToString:@"已报名" ]) {
//                            l.text = @"已拒绝";
//                        }else if([l.text isEqualToString:@"已拒绝" ] || [l.text isEqualToString:@"未报名" ]){
//                            l.text = @"已报名";
                NSLog(@"改变状态成功");
                
                NSLog(@"输出self.partyObj.id>>>>%@",self.partyObj.partyId);
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];  
                NSString *keyString=[[NSString alloc] initWithFormat:@"%disStatusChanged",[self.partyObj.partyId intValue]];
                [defaults setInteger:1  forKey:keyString];    //wxz

                        //}
                    //}
               // }
            } else {
                btn.enabled = YES;
               // btn.hidden = NO;
            }
        }else if([request responseStatusCode] == 404){
            [self showAlertRequestFailed:REQUEST_ERROR_404];
            btn.hidden = NO;
            btn.enabled = YES;
        }else{
            btn.hidden = NO;
            btn.enabled = YES;
            [self showAlertRequestFailed:REQUEST_ERROR_500];
        }
    } else {
        //[activity removeFromSuperview];
        btn.hidden = NO;
        btn.enabled = YES;
        //[self showAlert:[error localizedDescription]];
    }
    
    
}




#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
//    if(section==0){
//        ABAddressBookRef addressBook = ABAddressBookCreate();
//        if(!card){
//            self.card = ABAddressBookGetPersonWithRecordID(addressBook, self.contactorID);
//        }
//        if (!phone) {
//            self.phone = ABRecordCopyValue(card, kABPersonPhoneProperty);
//        }
//        int num = ABMultiValueGetCount(self.phone);
//        return num;
//    }
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
    if(indexPath.section==0){
        //NSString *typeStr = (__bridge_transfer NSString*)ABAddressBookCopyLocalizedLabel(ABMultiValueCopyLabelAtIndex(self.phone, indexPath.row));
       // NSString *valStr = (__bridge_transfer NSString*)ABMultiValueCopyValueAtIndex(self.phone, indexPath.row);
        UILabel *typeLb = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 80, 44)];
        typeLb.text = @"联系方式";
        typeLb.textAlignment = UITextAlignmentRight;
        typeLb.textColor = [UIColor blueColor];
        typeLb.backgroundColor = [UIColor clearColor];
        [cell addSubview:typeLb];
        UILabel *valLb = [[UILabel alloc] initWithFrame:CGRectMake(100, 0, 200, 44)];
        valLb.text = [clientDict objectForKey:@"cValue"];
        valLb.backgroundColor = [UIColor clearColor];
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        [cell addSubview:valLb];
    }
    if(indexPath.section==1){
        cell.selectionStyle= UITableViewCellSelectionStyleNone;
        UILabel *wordsLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 80, 44)];
        wordsLabel.text=@"留言";
        wordsLabel.textAlignment = UITextAlignmentRight;
        wordsLabel.textColor = [UIColor blueColor];
        wordsLabel.backgroundColor = [UIColor clearColor];
        NSString *detailWordString=[self.clientDict objectForKey:@"msg"];
        if(detailWordString.length>1){
             messageTextView.text=[detailWordString substringFromIndex:1];
        }else{
            NSLog(@"Detail页面留言为空");
        }
        [cell addSubview:wordsLabel];
    }
        
    return cell;
}


- (NSString *)getCleanPhoneNumber:(NSString *)originalString {
    NSAssert(originalString != nil, @"Input phone number is %@!", @"NIL");
    NSMutableString *strippedString = [NSMutableString 
                                       stringWithCapacity:originalString.length];
    
    NSScanner *scanner = [NSScanner scannerWithString:originalString];
    NSCharacterSet *numbers = [NSCharacterSet 
                               characterSetWithCharactersInString:@"0123456789"];
    
    while ([scanner isAtEnd] == NO) {
        NSString *buffer;
        if ([scanner scanCharactersFromSet:numbers intoString:&buffer]) {
            [strippedString appendString:buffer];
            
        } else {
            [scanner setScanLocation:([scanner scanLocation] + 1)];
        }
    }
    NSLog(@"strippedString : %@",strippedString);
    return strippedString;
}

//通过姓名和电话找出此联系人的头像数据
- (ABRecordRef)getContactorImageData{
    NSString *contactorNameString=[self.clientDict objectForKey:@"cName"];
    NSString *contactorPhoneString=[self.clientDict objectForKey:@"cValue"];
        ABAddressBookRef addressBook = ABAddressBookCreate();
        CFArrayRef searchResult =  ABAddressBookCopyPeopleWithName (
                                                                    addressBook,
                                                                    (__bridge CFStringRef)contactorNameString);
    
  NSLog(@"后台数据先输出名字>>>>>>>>>%@,再输出号码》》》%@",contactorNameString,contactorPhoneString);
  NSArray *array1=(__bridge_transfer NSArray*)searchResult;  
  if(array1.count>0){
    NSLog(@"按名字已找到数据－－－");
    for (int i=0; i<CFArrayGetCount(searchResult); )
           {
            ABRecordRef card = CFArrayGetValueAtIndex(searchResult, i);
            if(!card){
                continue;
            }
            ABMultiValueRef phone = ABRecordCopyValue(card, kABPersonPhoneProperty);
            if(!phone){
                continue;
            }
            for (int j=0; j<ABMultiValueGetCount(phone); j++) {
                NSString *valStr = (__bridge_transfer NSString*)ABMultiValueCopyValueAtIndex(phone, j);
                NSLog(@"找到名字后打印valstr：：：－－－%@   该联系人有%d个号码",valStr,ABMultiValueGetCount(phone));
                NSString *getCleanPhoneString=[self getCleanPhoneNumber:valStr]; 
                NSLog(@"清空无用符后的电话－－－getCleanPhoneString>>>%@",getCleanPhoneString);
                if ([getCleanPhoneString  isEqualToString:contactorPhoneString]) {
                    NSLog(@"又找到匹配号码－－");
                    //self.cID = ABRecordGetRecordID(card);
                    if(ABPersonHasImageData(card)){
                          NSLog(@"找到匹配联系人头像数据");
                          return card;
                    }else{
                        NSLog(@"找到联系人了但是没头像数据");
                        return nil;
                    }
                }else{
                    NSLog(@"》》》》没找到匹配号码");
                    continue;
                }
               
            }
            return nil;   
               
        }
  }else{
      NSLog(@"－名字没有匹配到数据－");
      return nil;
  }
    NSLog(@"－－－－调用找头像方法－－－");
    return nil;
}



- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if(section==0){
        UIView *headV = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 85.0f)];
        ABRecordRef getCard=[self getContactorImageData];
        
        UIImageView *imgV = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 65, 65)];
        imgV.backgroundColor = [UIColor whiteColor];
        UIImage *person = nil;
        if(getCard){
            CFDataRef imgData = ABPersonCopyImageData(getCard);
            UIGraphicsBeginImageContext(CGSizeMake(62, 62));
            [[UIImage imageWithData:(NSData *)imgData] drawInRect:CGRectMake(0, 0, 65, 65)];
            person  = UIGraphicsGetImageFromCurrentImageContext();
            CFRelease(imgData);
        }
        [imgV setImage:person];
        [headV addSubview:imgV];
        UILabel *lblV = [[UILabel alloc] initWithFrame:CGRectMake(100, 10, 210, 65)];
//        NSString *personFName = (__bridge_transfer NSString*)ABRecordCopyValue(self.card, kABPersonFirstNameProperty);
//        if (personFName == nil) {
//            personFName = @"";
//        }
//        NSString *personLName = (__bridge_transfer NSString*)ABRecordCopyValue(self.card, kABPersonLastNameProperty);
//        if (personLName == nil) {
//            personLName = @"";
//        }
//        NSString *personMName = (__bridge_transfer NSString*)ABRecordCopyValue(self.card, kABPersonMiddleNameProperty);
//        if (personMName == nil) {
//            personMName = @"";
//        }
       // lblV.text = [NSString stringWithFormat:@"%@ %@ %@",personFName,personMName,personLName];
        lblV.text=[self.clientDict objectForKey:@"cName"];
        lblV.backgroundColor = [UIColor clearColor];
        [headV addSubview:lblV];
        return headV;

    }else{
        return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{   
    if(section==0){
       return 85.0f;
    }else{
        return 0.0f;
    }
    
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
    
//    NSString *valStr = (__bridge_transfer NSString*)ABMultiValueCopyValueAtIndex(self.phone, indexPath.row);
//    NSDictionary *userinfo = [NSDictionary dictionaryWithObjectsAndKeys:valStr,@"val",[NSNumber numberWithInteger:contactorID],@"id", nil];
//    [phoneDetailDelegate contactDetailSelectedWithUserInfo:userinfo];
//   
//    [self.navigationController popViewControllerAnimated:YES];
    if(indexPath.section==0){
            //NSString *actionsheetTitle = @"\n\n\n\n\n\n\n\n\n\n\n";
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"发送短信" otherButtonTitles:@"拨打电话", nil];
            actionSheet.tag = 5;
            [actionSheet showInView:self.tabBarController.view];
    }
}



- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{  
    if(actionSheet.tag==5){
      if([[[UIDevice alloc] init]userInterfaceIdiom]!=UIUserInterfaceIdiomPhone){
            
          NSLog(@"不用iphone发送短信与拨打电话");   
          UIAlertView *cannotAlertView=[[UIAlertView alloc] initWithTitle:@"设备类型不符合" message:@"该设备不能发送短信与拨打电话" delegate:self cancelButtonTitle:nil otherButtonTitles:@"好的，知道了", nil];
          [cannotAlertView show];
      }else { 
          if(buttonIndex==0){
              NSLog(@"用iphone发送短信"); 
              NSString *shotMegString=[[NSString alloc]initWithFormat:@"sms://%@",[clientDict objectForKey:@"cValue"]];
              [[UIApplication sharedApplication]openURL:[NSURL URLWithString:shotMegString]];
              
          }else if(buttonIndex==1){
              NSLog(@">>>>>phoneConnect");
              NSString *phoneString=[[NSString alloc]initWithFormat:@"tel://%@",[clientDict objectForKey:@"cValue"]];
              [[UIApplication sharedApplication]openURL:[NSURL URLWithString:phoneString]];
              
              return;
          }else{
              return;
              
          }

      
      
      }
        
            
    }
    return;
      
        
}

@end
