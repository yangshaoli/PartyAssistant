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
#import "PartyAssistantAppDelegate.h"

@implementation ContactorPhoneDetailsViewController
@synthesize contactorID,phoneDetailDelegate,clientDict,partyObj,quest;
@synthesize clientStatusFlag;
@synthesize phoneCell;
@synthesize messageCell;
@synthesize phoneLabel;
@synthesize messageTextView;
@synthesize footerView,goButton,notGoButton,activity;

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
    goButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [goButton setFrame:CGRectMake(20, 0, 80, 40)];
    [goButton setTitle:@"参加" forState:UIControlStateNormal];
    [goButton setImage:[UIImage imageNamed:@"apply"] forState:UIControlStateNormal];
    
//    [goButton addTarget:self action:@selector(nil) forControlEvents:UIControlEventTouchUpInside];
    goButton.tag=23;
    goButton.backgroundColor=[UIColor  clearColor];
    [goButton addTarget:self action:@selector(changeClientStatus:) forControlEvents:UIControlEventTouchUpInside];
    
    notGoButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [notGoButton setFrame:CGRectMake(100, 0, 80, 40)];
    [notGoButton setTitle:@"不参加" forState:UIControlStateNormal];
    [notGoButton setImage:[UIImage imageNamed:@"reject"] forState:UIControlStateNormal];
    //    [goButton addTarget:self action:@selector(nil) forControlEvents:UIControlEventTouchUpInside];
    notGoButton.tag=24;
    notGoButton.backgroundColor=[UIColor clearColor];
    [notGoButton addTarget:self action:@selector(changeClientStatus:) forControlEvents:UIControlEventTouchUpInside];
    
    
    bounds = [[UIScreen mainScreen] bounds];
    
    footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, bounds.size.width, 100)];
    footerView.backgroundColor = [UIColor clearColor];
    self.tableView.tableFooterView = footerView;
    [footerView addSubview:goButton];
    [footerView addSubview:notGoButton];
    
    if([self.clientStatusFlag isEqualToString:@"donothing"]){
        //goButton.center = CGPointMake(bounds.size.width / 4, 50);
        //[footerView addSubview:goButton];
        goButton.hidden=NO;
        notGoButton.hidden=NO;
    }else if([self.clientStatusFlag  isEqualToString:@"applied"]){
        goButton.hidden=YES;
        notGoButton.hidden=NO;
            
    }else if([self.clientStatusFlag  isEqualToString:@"refused"]){
       // notGoButton.center = CGPointMake(bounds.size.width - (bounds.size.width / 4), 50);
        //[footerView addSubview:notGoButton];
        goButton.hidden=NO;
        notGoButton.hidden=YES;
        

    }
    
   
    NSString *statusString=[self.clientDict objectForKey:@"status"];
    if([self.clientStatusFlag  isEqualToString:@"all"]){
        if([statusString  isEqualToString:@"noanswer"]){
            //goButton.center = CGPointMake(bounds.size.width / 4, 50);
            goButton.hidden=NO;
            notGoButton.hidden=NO;
        }else if([statusString  isEqualToString:@"apply"]){
            goButton.hidden=YES;
            notGoButton.hidden=NO;
        }else if([statusString  isEqualToString:@"reject"]){
           // notGoButton.center = CGPointMake(bounds.size.width - (bounds.size.width / 4), 50);
            goButton.hidden=NO;
            notGoButton.hidden=YES;           
        }
    
    }
    
//    messageTextView=[[UITextView alloc] init];
//    NSString *cvalueString=[clientDict objectForKey:@"cValue"];
//    if([self.partyObj.type isEqualToString:@"email"]){
//       messageTextView.frame=CGRectMake(100, 85, 200, 175);
//    }else{
//       messageTextView.frame=CGRectMake(100, 153, 200, 175);
//    
//    }
//    
//    messageTextView.font=[UIFont systemFontOfSize:15];
//    messageTextView.backgroundColor=[UIColor clearColor];
//    messageTextView.editable=NO;
//    [self.view addSubview:messageTextView];
   
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
        //[btn setImage:[UIImage imageNamed:@"apply_gray"] forState:UIControlStateNormal];
        NSInteger backendID=[[clientDict  objectForKey:@"backendID"] intValue];
        if (self.quest) {
            [self.quest clearDelegatesAndCancel];
        }
        ASIFormDataRequest *request1 = [ASIFormDataRequest requestWithURL:url];
        [request1 setPostValue:[NSNumber numberWithInteger:backendID] forKey:@"cpID"];
        [request1 setPostValue:statusAction forKey:@"cpAction"];
        request1.timeOutSeconds = 20;
        [request1 setDelegate:self];
        [request1 setShouldAttemptPersistentConnection:NO];
//        activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
//        activity.frame = activity.frame = CGRectMake(200,200, 60, 60);
//        [activity startAnimating];
//        [self.view addSubview:activity];
        _HUD = [[MBProgressHUD alloc] initWithView:self.tableView];
        [self.tableView addSubview:_HUD];
        _HUD.labelText = @"变更此人状态";
        [_HUD show:YES];

        [request1 setDidFinishSelector:nil];
        [request1 setDidFailSelector:nil];
        [request1 startSynchronous];
        self.quest=request1;
    
    }else if(btn.tag==24){
        statusAction=@"reject";
        NSUserDefaults *isChenkDefault=[NSUserDefaults standardUserDefaults];
        NSString *refusedKeyString=[[NSString alloc] initWithFormat:@"%drefusedIscheck",[self.partyObj.partyId intValue]];
        NSInteger currentInt=[isChenkDefault integerForKey:refusedKeyString];
        [isChenkDefault setInteger:currentInt-1 forKey:refusedKeyString];
        //[btn setImage:[UIImage imageNamed:@"reject_gray"] forState:UIControlStateNormal];
        
        NSInteger backendID=[[clientDict  objectForKey:@"backendID"] intValue];
        
        if (self.quest) {
            [self.quest clearDelegatesAndCancel];
        }
        ASIFormDataRequest *request2 = [ASIFormDataRequest requestWithURL:url];
        [request2 setPostValue:[NSNumber numberWithInteger:backendID] forKey:@"cpID"];
        [request2 setPostValue:statusAction forKey:@"cpAction"];
        request2.timeOutSeconds = 20;
        [request2 setDelegate:self];
        [request2 setShouldAttemptPersistentConnection:NO];
//        activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
//        activity.frame = CGRectMake(20,20, 50, 50);
//        [activity startAnimating];
//        [self.view addSubview:activity];
       _HUD = [[MBProgressHUD alloc] initWithView:self.tableView];
        [self.tableView addSubview:_HUD];
        _HUD.labelText = @"变更此人状态";        
        [_HUD show:YES];
        [request2 setDidFinishSelector:nil];
        [request2 setDidFailSelector:nil];
        [request2 startSynchronous];
        self.quest=request2;
    
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
    
    
    
    
    NSError *error = [self.quest error];
    if (!error) {
        //[activity removeFromSuperview];
        NSString *response = [self.quest responseString];
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        NSDictionary *result = [parser objectWithString:response];
        NSString *description = [result objectForKey:@"description"];
        NSString *status = [result objectForKey:@"status"];
        if ([self.quest responseStatusCode] == 200) {
            if ([status isEqualToString:@"ok"]) {
                NSLog(@"请求发送成功－－－－－");
                if(btn.tag==23){//点击参加
                    goButton.hidden=YES;
                    notGoButton.hidden=NO;
                }else if(btn.tag==24){
                    goButton.hidden=NO;
                    notGoButton.hidden=YES;
                }
//                [activity stopAnimating];
//                [activity removeFromSuperview];
                [_HUD hide:YES];
                [self.tableView reloadData];
                //[btn removeFromSuperview];
//                for (int i=0; i<[[cell subviews] count]; i++) {
//                    if ([[[cell subviews] objectAtIndex:i] isMemberOfClass:[UILabel class]]) {
//                        UILabel *l = [[cell  subviews] objectAtIndex:i];
//                        if ([l.text isEqualToString:@"已报名" ]) {
//                            l.text = @"已拒绝";
//                        }else if([l.text isEqualToString:@"已拒绝" ] || [l.text isEqualToString:@"未报名" ]){
//                            l.text = @"已报名";
                
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];  
                NSString *keyString=[[NSString alloc] initWithFormat:@"%disStatusChanged",[self.partyObj.partyId intValue]];
                [defaults setInteger:1  forKey:keyString];    //wxz
                 
                        //}
                    //}
               // }
            } else {
                btn.enabled = YES;
            }
        }else if([self.quest responseStatusCode] == 404){
            [self showAlertRequestFailed:REQUEST_ERROR_404];
            btn.enabled = YES;
            btn.hidden = NO;
        }else if([self.quest responseStatusCode] == 500){
            [self showAlertRequestFailed:REQUEST_ERROR_500];
            btn.enabled = YES;
            btn.hidden = NO;
        }else if([self.quest responseStatusCode] == 502){
            [self showAlertRequestFailed:REQUEST_ERROR_502];
            btn.hidden = NO;
            btn.enabled = YES;
        }else{
            btn.hidden = NO;
            btn.enabled = YES;
            [self showAlertRequestFailed:REQUEST_ERROR_504];
        }
    } else {
        //[activity removeFromSuperview];
        btn.hidden = NO;
        btn.enabled = YES;
        //[self showAlert:[error localizedDescription]];
    }
    
    
}


////正则判断是否Email地址
//- (BOOL) isEmailAddress:(NSString*)email { 
//    
//    NSString *emailRegex = @"^\\w+((\\-\\w+)|(\\.\\w+))*@[A-Za-z0-9]+((\\.|\\-)[A-Za-z0-9]+)*.[A-Za-z0-9]+$"; 
//    
//    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex]; 
//    
//    return [emailTest evaluateWithObject:email]; 
//    
//} 

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    NSString *cvalueString=[clientDict objectForKey:@"cValue"];
    if([self.partyObj.type isEqualToString:@"email"]){
        return 1;
    }

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
    if([self.partyObj.type isEqualToString:@"email"]){
        if(indexPath.section==0){
//            cell.selectionStyle= UITableViewCellSelectionStyleNone;
//            UITextView *wordTextField = [[UITextView alloc] initWithFrame:CGRectMake(10, 0, 80, 44)];
//            wordTextField.text=@"留言";
//            wordTextField.textAlignment = UITextAlignmentRight;
//            wordTextField.textColor = [UIColor blueColor];
//            wordTextField.backgroundColor = [UIColor clearColor];
//            wordTextField.editable = NO;
            NSString *detailWordString=[self.clientDict objectForKey:@"msg"];
           detailWordString = [detailWordString stringByReplacingOccurrencesOfString:@"<br/>" withString:@"\n"]; 
            if(detailWordString.length>1){
                messageTextView.text=[detailWordString substringFromIndex:1];
                
                CGFloat height = 0.f;
                
                CGSize textSize = [detailWordString sizeWithFont:[UIFont systemFontOfSize:14] forWidth:80.f lineBreakMode:UILineBreakModeClip];
                if (textSize.height < 80) {
                    height = 80.0f;
                } else if (textSize.height > 160) {
                    height = 160;
                } else {
                    height = textSize.height;
                }
                
                CGRect from = messageTextView.frame;
                CGRect to = from;
                to.size.height = height;
                
                messageTextView.frame = to;
            }else{
            }
            //[cell addSubview:wordTextField];
            return self.messageCell;
        }
    
    }else{
        if(indexPath.section==0){
            //NSString *typeStr = (__bridge_transfer NSString*)ABAddressBookCopyLocalizedLabel(ABMultiValueCopyLabelAtIndex(self.phone, indexPath.row));
            // NSString *valStr = (__bridge_transfer NSString*)ABMultiValueCopyValueAtIndex(self.phone, indexPath.row);
            
//            UILabel *typeLb = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 80, 44)];
//            typeLb.text = @"联系方式";
//            typeLb.textAlignment = UITextAlignmentRight;
//            typeLb.textColor = [UIColor blueColor];
//            typeLb.backgroundColor = [UIColor clearColor];
//            [cell addSubview:typeLb];
//            UILabel *valLb = [[UILabel alloc] initWithFrame:CGRectMake(100, 0, 200, 44)];
//            valLb.text = [clientDict objectForKey:@"cValue"];
//            valLb.backgroundColor = [UIColor clearColor];
//            cell.selectionStyle=UITableViewCellSelectionStyleNone;
//            [cell addSubview:valLb];
            self.phoneLabel.text = [clientDict objectForKey:@"cValue"];
            return self.phoneCell;
        }
        if(indexPath.section==1){
//            cell.selectionStyle= UITableViewCellSelectionStyleNone;
//            UITextView *wordTextField = [[UITextView alloc] initWithFrame:CGRectMake(10, 0, 80, 44)];
//            wordTextField.text=@"留言";
//            wordTextField.textAlignment = UITextAlignmentRight;
//            wordTextField.textColor = [UIColor blueColor];
//            wordTextField.backgroundColor = [UIColor clearColor];
//            wordTextField.editable = NO;
            NSString *detailWordString=[self.clientDict objectForKey:@"msg"];
            detailWordString=[detailWordString stringByReplacingOccurrencesOfString:@"<br/>" withString:@"\n"]; 
            if(detailWordString.length>1){
                messageTextView.text=[detailWordString substringFromIndex:1];
            }else{
            }
            
            CGFloat height = 0.f;
            
            CGSize textSize = [detailWordString sizeWithFont:[UIFont systemFontOfSize:14] forWidth:80.f lineBreakMode:UILineBreakModeClip];
            if (textSize.height < 80) {
                height = 80.0f;
            } else if (textSize.height > 160) {
                height = 160;
            } else {
                height = textSize.height;
            }
            
            CGRect from = messageTextView.frame;
            CGRect to = from;
            to.size.height = height;
            
            messageTextView.frame = to;
            
//            [cell addSubview:wordTextField];
            return self.messageCell;
        }

    }
    // Configure the cell...
            
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
    return strippedString;
}

//通过姓名和电话找出此联系人的头像数据
- (ABRecordRef)getContactorImageData{
//    NSString *contactorNameString=[self.clientDict objectForKey:@"cName"];
//    NSString *contactorPhoneString=[self.clientDict objectForKey:@"cValue"];
//    NSLog(@"姓名：：%@   电话：：%@",contactorNameString,contactorPhoneString);
//        ABAddressBookRef addressBook = ABAddressBookCreate();
//        CFArrayRef searchNameResult =  ABAddressBookCopyPeopleWithName (
//                                                                    addressBook,
//                                                                    (__bridge CFStringRef)contactorNameString);
//    
//    
//    CFArrayRef searchPhoneResult =  ABAddressBookCopyPeopleWithName (
//                                                                     addressBook,
//                                                                     (__bridge CFStringRef)contactorPhoneString);
//    
//    NSArray *array2=(__bridge_transfer NSArray*)searchPhoneResult;  
//
//    
//  NSArray *array1=(__bridge_transfer NSArray*)searchNameResult;  
//  if(array1.count>0){
//    for (int i=0; i<CFArrayGetCount(searchNameResult); )
//           {
//            ABRecordRef card = CFArrayGetValueAtIndex(searchNameResult, i);
//            if(!card){
//                continue;
//            }
//            ABMultiValueRef phone = ABRecordCopyValue(card, kABPersonPhoneProperty);
//            if(!phone){
//                continue;
//            }
//            for (int j=0; j<ABMultiValueGetCount(phone); j++) {
//                NSString *valStr = (__bridge_transfer NSString*)ABMultiValueCopyValueAtIndex(phone, j);
//                NSString *getCleanPhoneString=[self getCleanPhoneNumber:valStr]; 
//                if ([getCleanPhoneString  isEqualToString:contactorPhoneString]) {
//                    if(ABPersonHasImageData(card)){
//                          return card;
//                    }else{
//                        return nil;
//                    }
//                }else{
//                    continue;
//                }
//               
//            }
//            return nil;   
//               
//        }
//  }else if(array2.count>0){
//          for (int i=0; i<CFArrayGetCount(searchPhoneResult); )
//          {
//              ABRecordRef card = CFArrayGetValueAtIndex(searchPhoneResult, i);
//              if(!card){
//                  continue;
//              }
//             
//              if(ABPersonHasImageData(card)){
//                  return card;
//              }else{
//                  return nil;
//              }
//              
//         } 
//        return nil;   
//
//  }else{
//      return nil;
//
//  }
    NSString *contactorNameString=[self.clientDict objectForKey:@"cName"];
    NSString *contactorPhoneString=[self.clientDict objectForKey:@"cValue"];
    
    ClientObject *newClient = [[ClientObject alloc] init];
    newClient.cName = contactorNameString;
    newClient.cVal = contactorPhoneString;
    
    [newClient searchClientIDByPhone];
    
    if (newClient.cID == -1) {
        return nil;
    } else {
        return ABAddressBookGetPersonWithRecordID(addressBook, newClient.cID);
    }
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if(section==0){
        UIView *headV = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 85.0f)];
        ABRecordRef getCard=[self getContactorImageData];
        
        UIImageView *imgV = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 62, 62)];
        imgV.backgroundColor = [UIColor whiteColor];
        UIImage *person = nil;
    
        if (getCard) {
            if (ABPersonHasImageData(getCard)) {
                NSData *imgData = (__bridge_transfer NSData*)ABPersonCopyImageData(getCard);
                
                UIGraphicsBeginImageContext(CGSizeMake(62.0f, 62.0f));
                [[UIImage imageWithData:imgData] drawInRect:CGRectMake(0.f, 0.f, 62.f, 62.f)];
                person = UIGraphicsGetImageFromCurrentImageContext();
            }
            
            if (person) {
                [imgV setImage:person];
            } else {
                person = [UIImage imageNamed:@"contact_with_no-pic.png"];
                [imgV setImage:person];
            }

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
        
        
        if([self.clientDict objectForKey:@"cName"]==nil||[[self.clientDict objectForKey:@"cName"] isEqualToString:@""]){
            lblV.text=[self.clientDict objectForKey:@"cValue"];
        }else{
            lblV.text=[self.clientDict objectForKey:@"cName"];
        }
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
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if([self.partyObj.type isEqualToString:@"email"]){
        NSString *detailWordString=[self.clientDict objectForKey:@"msg"];
        CGSize textSize = [detailWordString sizeWithFont:[UIFont systemFontOfSize:14] forWidth:80.f lineBreakMode:UILineBreakModeClip];
        if (textSize.height < 80) {
            return 100;
        } else if (textSize.height > 160) {
            return 180;
        } else {
            return textSize.height + 20;
        }
    }
    
   if(![self.partyObj.type isEqualToString:@"email"]){
       if(indexPath.section==1){
           NSString *detailWordString=[self.clientDict objectForKey:@"msg"];
           CGSize textSize = [detailWordString sizeWithFont:[UIFont systemFontOfSize:14] forWidth:80.f lineBreakMode:UILineBreakModeClip];
           if (textSize.height < 80) {
               return 100;
           } else if (textSize.height > 160) {
               return 180;
           } else {
               return textSize.height + 20;
           }
           
       }
       return 44;
    }  
    return 44.f;
    
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
    if([self.partyObj.type isEqualToString:@"email"]){
        return;
    }else{
        if(indexPath.section==0){
            //NSString *actionsheetTitle = @"\n\n\n\n\n\n\n\n\n\n\n";
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"发送短信" otherButtonTitles:@"拨打电话", nil];
            actionSheet.tag = 5;
            [actionSheet showInView:self.tabBarController.view];
        }

    
    }
}



- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{  
    if(actionSheet.tag==5){
      if([[[UIDevice alloc] init]userInterfaceIdiom]!=UIUserInterfaceIdiomPhone){
            
          UIAlertView *cannotAlertView=[[UIAlertView alloc] initWithTitle:@"设备类型不符合" message:@"该设备不能发送短信与拨打电话" delegate:self cancelButtonTitle:nil otherButtonTitles:@"好的，知道了", nil];
          [cannotAlertView show];
      }else { 
          if(buttonIndex==0){
              NSString *shotMegString=[[NSString alloc]initWithFormat:@"sms://%@",[clientDict objectForKey:@"cValue"]];
              [[UIApplication sharedApplication]openURL:[NSURL URLWithString:shotMegString]];
              
          }else if(buttonIndex==1){
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
#pragma mark -
#pragma mark dealloc method
-(void)dealloc {
    [self.quest  clearDelegatesAndCancel];
    self.quest = nil;
}


@end
