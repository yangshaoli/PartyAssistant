//
//  CreatNewPartyViaSMSViewController.m
//  PartyAssistant
//
//  Created by Wang Jun on 12/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CreatNewPartyViaSMSViewController.h"
#import "PartyAssistantAppDelegate.h"
#import "NotificationSettings.h"
#import "URLSettings.h"
#import "ASIFormDataRequest.h"
#import "SMSObjectService.h"
#import "HTTPRequestErrorMSG.h"
#import "DeviceDetection.h"
#import "PartyListTableVC.h"
#import "ABContact.h"
#import "SegmentManagingViewController.h"
#import "NotificationSettings.h"
#import "AddressBookDBService.h"
#import "UIViewControllerExtra.h"
#import "PurchaseListViewController.h"
#import "DataManager.h"
#import "ChangePasswordRandomLoginTableVC.h"
#import "CustomTextView.h"
#import "Reachability.h"

@interface CreatNewPartyViaSMSViewController ()

- (void)rearrangeContactNameTFContent;
- (void)createPartySuc;
-(void)showWaiting;
-(void)dismissWaiting; 
- (void)showAlertRequestSuccess;
- (void)showAlertRequestSuccessWithMessage: (NSString *) theMessage;
- (void)showAlertRequestFailed: (NSString *) theMessage;
- (NSString *)getCleanPhoneNumber:(NSString *)originalString;
- (void)addPersonToGroup:(NSDictionary *)personDictionary;
- (NSString *)getCleanLetter:(NSString *)originalString;
- (void)showLessRemainingCountAlert;
- (void)gotoPurchasPage;
- (void)checkPurchaseValidStatus;

@end

@implementation CreatNewPartyViaSMSViewController
@synthesize tableView = _tableView;
@synthesize addContactCell = _addContactCell;
@synthesize sendModelSelectCell = _sendModelSelectCell;
@synthesize contactNameTF = _contactNameTF;
@synthesize sendModeNameLabel = _sendModeNameLabel;
@synthesize picker = _picker;
@synthesize rightItem = _rightItem;
@synthesize receipts = _receipts;
@synthesize smsObject;
@synthesize HUD = _HUD;
@synthesize editingTableViewCell = _editingTableViewCell;
@synthesize leftCountLabel = _leftCountLabel;
@synthesize sectionOneHeader = _sectionOneHeader;
@synthesize isResendPage = _isResendPage;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
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
    
    self.title = @"活动邀请";
    self.navigationController.navigationBar.tintColor = [UIColor redColor];
    [self.tableView setScrollEnabled:NO];
    UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStyleDone target:self action:@selector(SMSContentInputDidFinish)];
    self.navigationItem.rightBarButtonItem = right;
    self.rightItem = right;
    self.receipts = [NSMutableArray arrayWithCapacity:10];
    
    self.editingTableViewCell = [[EditableTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];\
    [(CustomTextView *)self.editingTableViewCell.textView setPlaceholder:@"该活动内容将被作为短信发送给参加者"];
    _editingTableViewCell.delegate = self;
    _editingTableViewCell.text = [NSMutableString stringWithCapacity:10];
    // Do any additional setup after loading the view from its nib.
    
    if (!self.isResendPage) {
        if (!smsObject) {
            SMSObjectService *smsObjectService = [SMSObjectService sharedSMSObjectService];
            self.smsObject = [smsObjectService getSMSObject];
        }
        
        if (smsObject.receiversArray) {
            [self.receipts addObjectsFromArray:smsObject.receiversArray];
        }
        
        if (smsObject.smsContent) {
            self.editingTableViewCell.text = [NSMutableString stringWithString:smsObject.smsContent];
        }
        
        NSLog(@"%@",smsObject.receiversArray);
        NSLog(@"%@",smsObject.smsContent);
        
        [self rearrangeContactNameTFContent];
    }
    
    
    //wxz
    UserObjectService *us = [UserObjectService sharedUserObjectService];
    UserObject *user = [us getUserObject];
    NSString *keyString=[[NSString alloc] initWithFormat:@"%dcountNumber",user.uID];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];  
    NSInteger  getDefaultCountNumber=[defaults integerForKey:keyString];
    if(getDefaultCountNumber){  
        //tab.selectedIndex=1;
    }else{
        if([DataManager sharedDataManager].isRandomLoginSelf){
            ChangePasswordRandomLoginTableVC *changePasswordRandomLoginTableVC=[[ChangePasswordRandomLoginTableVC alloc] initWithNibName:@"ChangePasswordRandomLoginTableVC" bundle:nil];
            [self.navigationController pushViewController:changePasswordRandomLoginTableVC animated:YES];  
        }
    }
    
    self.leftCountLabel.text = [NSString stringWithFormat:@"帐户剩余:%@条", [[NSNumber numberWithInt:[user.leftSMSCount intValue]] stringValue]];
    
    self.sendModeNameLabel.clipsToBounds = YES;
    self.leftCountLabel.clipsToBounds = YES;
    
    self.sendModeNameLabel.contentMode = UIViewContentModeScaleAspectFit;
    self.leftCountLabel.contentMode = UIViewContentModeScaleAspectFit;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(leftCountRefreshed:) name:UpdateRemainCountFinished object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(leftCountRefreshFailed:) name:UpdateRemainCountFailed object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillTerminate:) name:UIApplicationDidEnterBackgroundNotification object:nil];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.smsObject._isSendBySelf) {
//        self.sendModeNameLabel.text = @"用自己手机发送";
//        CGRect from = self.sendModeNameLabel.frame;
//        CGRect to = from;
//        to.size.height = 26;
//        self.sendModeNameLabel.frame = to;
//        
//        self.sendModeNameLabel.font = [UIFont systemFontOfSize:18];
        
        self.leftCountLabel.hidden = YES;
    } else {
//        self.sendModeNameLabel.text = @"通过服务器发送";
//         
//        CGRect from = self.sendModeNameLabel.frame;
//        CGRect to = from;
//        to.size.height = 11;
//
//        self.sendModeNameLabel.frame = to;
//        
//        self.sendModeNameLabel.font = [UIFont systemFontOfSize:12];
//        
        self.leftCountLabel.hidden = NO;
        
        self.leftCountLabel.text = @"帐户余额更新中";
        
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:UpdateReMainCount object:nil]];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - 
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    } 
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            return self.addContactCell;
        }
//        else if (indexPath.row == 1) {
//            return self.sendModelSelectCell;
//        }
    } else {
        return self.editingTableViewCell;
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (self.editingTableViewCell) {
            [self.editingTableViewCell.textView resignFirstResponder];
            [self.editingTableViewCell.textView scrollRangeToVisible:NSMakeRange(0, 1)];
        }
        if (indexPath.row == 0) {
            if (!self.picker) {
            ButtonPeoplePicker *aPicker = [[ButtonPeoplePicker alloc] initWithNibName:nil bundle:nil];
            self.picker = aPicker;
            aPicker.delegate = self;
            }
            
            [self.view addSubview:self.picker.view];
            self.navigationItem.rightBarButtonItem = nil;
            
            [self.picker resetData];
//            CATransition *transition = [CATransition animation];
//            transition.duration = 0.3;
//            transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
//            transition.type = kCATransitionReveal;
            
//            [UIView beginAnimations:nil context:nil];
//            [UIView setAnimationTransition:UIViewAnimationTransitionCurlUp forView:self.picker.view cache:YES];
//            [UIView setAnimationDuration:0.3]; //动画时长
            
            //[UIView commitAnimations];
        } else if (indexPath.row == 1) {
//            SendSMSModeChooseViewController *vc = [[SendSMSModeChooseViewController alloc] initWithNibName:nil bundle:nil];
//            vc.delegate = self;
//            [self.navigationController pushViewController:vc animated:YES];
        }
    }
}

- (CGFloat)tableView:(UITableView *)aTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        if ([self.editingTableViewCell.textView isFirstResponder]) {
            return (self.editingTableViewCell.textView.frame.size.height > 80) ? (self.editingTableViewCell.textView.frame.size.height + 11) : (80 + 11);
        } else {
//            if (self.editingTableViewCell.textView.frame.size.height < 250) {
//                if ((self.editingTableViewCell.textView.frame.size.height + 11) < 200) {
//                    return 200 + 11;
//                } else {
//                    return self.editingTableViewCell.textView.frame.size.height + 11;
//                }
//            } else {
//                return (250 + 11);
//            }
//            return (self.editingTableViewCell.textView.frame.size.height < 250) ? (self.editingTableViewCell.textView.frame.size.height + 11) : (250 + 11);
            return 200 + 11;
        }
        
    }
    return 44.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 1) {
        return 40.0f;
    }
    return 20;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 1) {
        return self.sectionOneHeader;
    }
    return nil;
}
#pragma mark -
#pragma mark EditableTableViewCellDelegate

- (void)editableTableViewCellDidBeginEditing:(EditableTableViewCell *)editableTableViewCell {
    self.editingTableViewCell = editableTableViewCell;
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    NSRange range = NSMakeRange(self.editingTableViewCell.textView.text.length - 1, 1);
    [self.editingTableViewCell.textView scrollRangeToVisible:range];
    
    CGFloat offset = -80.0f;
    self.tableView.contentInset = UIEdgeInsetsMake(offset, 0.0f, 0.0f, 0.0f);
    
    self.navigationItem.rightBarButtonItem = nil;
    
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}


- (void)editableTableViewCellDidEndEditing:(EditableTableViewCell *)editableTableViewCell {
    self.editingTableViewCell = editableTableViewCell;
    self.tableView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
    self.navigationItem.rightBarButtonItem = self.rightItem;
    
//   CGFloat newHeight = [self.editingTableViewCell suggestedHeight];
    
    CGRect oldFrame = self.editingTableViewCell.textView.frame;
    CGRect newFrame = oldFrame;
//    if (newHeight < 200.0f) {
        newFrame.size.height = 200.0f;
//    } else if (newHeight > 250.0f) {
//        newFrame.size.height = 250.0f;
//    } else {
//        newFrame.size.height = newHeight;
//    }
    
    self.editingTableViewCell.textView.frame = newFrame;
    
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}


- (void)editableTableViewCell:(EditableTableViewCell *)editableTableViewCell heightChangedTo:(CGFloat)newHeight {
    // Calling beginUpdates/endUpdates causes the table view to reload cell geometries
    CGRect oldFrame = self.editingTableViewCell.textView.frame;
    CGRect newFrame = oldFrame;
    if (newHeight < 80.0f) {
        if (![editableTableViewCell.textView isFirstResponder]) {
            newFrame.size.height = 200.0f;
        } else {
            newFrame.size.height = 80.0f;
        }
    } else if (newHeight > 100.0f) {
        if (![editableTableViewCell.textView isFirstResponder]) {
//            if (newHeight > 250.0f) {
//                newFrame.size.height = 250.0f;
//            } else if (newHeight < 200.0f) {
//                newFrame.size.height = 200.0f;
//            } else {
//                newFrame.size.height = newHeight;
//            }
            newFrame.size.height = 200.0f;
        } else {
            newFrame.size.height = 80.0f;
        }
    } else {
        if (![editableTableViewCell.textView isFirstResponder]) {
            newFrame.size.height = 200.0f;
        } else {
            //newFrame.size.height = newHeight;
            newFrame.size.height = 80.0f;
        }
    }
    
    self.editingTableViewCell.textView.frame = newFrame;
    
    NSRange range = NSMakeRange(self.editingTableViewCell.textView.text.length - 1, 1);
    [self.editingTableViewCell.textView scrollRangeToVisible:range];
    
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}

#pragma mark -
#pragma mark ButtonPickDelegate
- (void)buttonPeoplePickerDidFinish:(ButtonPeoplePicker *)controller {
    self.receipts = [NSMutableArray arrayWithArray:controller.group];
    [self rearrangeContactNameTFContent];
    [[controller view] removeFromSuperview];
    self.navigationItem.rightBarButtonItem = self.rightItem;
}

- (void)rearrangeContactNameTFContent {
    if ([self.receipts count] == 0) {
        self.contactNameTF.text = nil;
    } else {
        self.contactNameTF.text = nil;
        CGSize holderSize = [@"&recipient" sizeWithFont:[UIFont systemFontOfSize:16.0f]];
        
        CGFloat tfWidth = self.contactNameTF.frame.size.width;
        
        NSMutableString *contactNameTFContent = [[NSMutableString alloc] initWithCapacity:0];
        for (int i=0; i<[self.receipts count]; i++) {
            ClientObject *clientInfo = [self.receipts objectAtIndex:i];
        
            NSString *name  = clientInfo.cName;
            if (!name || [name isEqualToString:@""]) {
                name = clientInfo.cVal;
            }
            
            CGSize nowContentSize = [contactNameTFContent sizeWithFont:[UIFont systemFontOfSize:16.0f]];
                                     
            CGSize newNameSize = [name sizeWithFont:[UIFont systemFontOfSize:16.0f]];
            
            if ((nowContentSize.width + newNameSize.width + holderSize.width) < tfWidth - 10.0f) {
                if (i!=0) {
                    [contactNameTFContent appendString:@","];
                }
                if (name) {
                    [contactNameTFContent appendString:name];
                }
            } else {
                int leftCount = [self.receipts count] - i;
                if (leftCount == 1) {
                    if (i == 0) {
                        [contactNameTFContent appendFormat:@"%d个联系人", leftCount];
                    } else {
                        [contactNameTFContent appendFormat:@"还有%d个联系人", leftCount];   
                    }
                } else {
                    if (i == 0) {
                        [contactNameTFContent appendFormat:@"%d个联系人", leftCount];
                    } else {
                        [contactNameTFContent appendFormat:@"还有%d个联系人", leftCount];   
                    }
                }
                break;
            }
        }
        self.contactNameTF.text = contactNameTFContent;
    }
}

- (NSMutableArray *)getCurrentContactDataSource {
    return self.receipts;
}
#pragma mark -
#pragma mark custom method
- (void)SMSContentInputDidFinish {
//    if(!self.editingTableViewCell.textView.text || [self.editingTableViewCell.textView.text isEqualToString:@""]){
//        UIAlertView *alert=[[UIAlertView alloc]
//                            initWithTitle:@"短信内容不可以为空"
//                            message:@"内容为必填项"
//                            delegate:self
//                            cancelButtonTitle:@"请点击输入内容"
//                            otherButtonTitles: nil];
//        [alert show];
//    }else{
//    [self saveSMSInfo];
    if(!self.editingTableViewCell.textView.text || [self.editingTableViewCell.textView.text isEqualToString:@""]){
        UIAlertView *alert=[[UIAlertView alloc]
                            initWithTitle:@"短信内容不可以为空"
                            message:@"内容为必填项"
                            delegate:self
                            cancelButtonTitle:@"请点击输入内容"
                            otherButtonTitles: nil];
        [alert show];
        return;
    }else{
        //1.check network status
        if([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == kNotReachable) {
            [self showAlertWithTitle:@"提示" Message:REQUEST_INVALID_NETWORK];
            return;
        }
        
        [self saveSMSInfo];
        if ([self.smsObject.receiversArray count] == 0) {
            UIAlertView *alertV = [[UIAlertView alloc] initWithTitle:@"警告" message:@"请添加有效的收件人" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
            [alertV show];
            return;
        }
    }
    
//    if ([self.smsObject.receiversArray count] == 0) {
//        UIAlertView *alertV = [[UIAlertView alloc] initWithTitle:@"警告" message:@"您的短信未指定任何收件人，继续保存？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"继续", nil];
//            [alertV show];
//    }else{
//        UserObjectService *us = [UserObjectService sharedUserObjectService];
//        UserObject *user = [us getUserObject];
        if (self.smsObject._isSendBySelf) {
            
        } else {
//            if ([user.leftSMSCount intValue] < [self.smsObject.receiversArray count]) {
//                UIAlertView *alert=[[UIAlertView alloc]
//                                    initWithTitle:@"需要充值"
//                                    message:@"余额不足，不能通过服务器端发送！"
//                                    delegate:nil
//                                    cancelButtonTitle:@"确定"
//                                    otherButtonTitles: nil];
//                [alert show];
//                return;
//            }
        }        
        [self sendCreateRequest];
//    }
}

- (void)saveSMSInfo{
    self.smsObject.smsContent = [self.editingTableViewCell.textView text];
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:10];
    for (ClientObject *receipt in self.receipts) {
        //need check phone format
        //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        ClientObject *client = [[ClientObject alloc] init];
        client.cName = receipt.cName;
        client.cID = receipt.cID;
        client.phoneLabel = receipt.phoneLabel;
        client.phoneIdentifier = receipt.phoneIdentifier;
        NSString *phoneNumber = receipt.cVal;
        
        if (!phoneNumber) {
            continue;
        } else {
            phoneNumber = [self getCleanPhoneNumber:phoneNumber];
            if (phoneNumber.length >= 11) {
                client.cVal = phoneNumber;
            } else {
                continue;
            }
        }
        [array addObject:client];
    }
    
    self.smsObject.receiversArray = array;
    
    SMSObjectService *s = [SMSObjectService sharedSMSObjectService];
    [s saveSMSObject];
}

- (void)createPartySuc{
    self.editingTableViewCell.textView.text = @"";
    self.receipts = [NSMutableArray arrayWithCapacity:10];
    [self rearrangeContactNameTFContent];

    self.tabBarController.selectedIndex = 1;
    [self.navigationController dismissModalViewControllerAnimated:YES];
    //    NSNotification *notification = [NSNotification notificationWithName:CREATE_PARTY_SUCCESS object:nil userInfo:nil];
//    [[NSNotificationCenter defaultCenter] postNotification:notification];
//    [self.navigationController dismissModalViewControllerAnimated:NO];
}

- (void)sendCreateRequest{
    [self showWaiting];
    UserObjectService *us = [UserObjectService sharedUserObjectService];
    UserObject *user = [us getUserObject];
    NSString *platform = [DeviceDetection platform];
    NSURL *url = [NSURL URLWithString:CREATE_PARTY];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setPostValue:[self.smsObject setupReceiversArrayData] forKey:@"receivers"];
    [request setPostValue:self.smsObject.smsContent forKey:@"content"];
    [request setPostValue:[NSNumber numberWithBool:self.smsObject._isSendBySelf] forKey:@"_issendbyself"];
    [request setPostValue:[NSNumber numberWithInteger:user.uID] forKey:@"uID"];
    [request setPostValue:platform forKey:@"addressType"];
    
    request.timeOutSeconds = 20;
    [request setDelegate:self];
    [request setShouldAttemptPersistentConnection:NO];
    [request startAsynchronous];    
}

- (void)requestFinished:(ASIHTTPRequest *)request{
    [self dismissWaiting];
	NSString *response = [request responseString];
	SBJsonParser *parser = [[SBJsonParser alloc] init];
	NSDictionary *result = [parser objectWithString:response];
   [self getVersionFromRequestDic:result];
    
    NSString *status = [result objectForKey:@"status"];
	NSString *description = [result objectForKey:@"description"];
    NSUserDefaults *isCreatSucDefault=[NSUserDefaults standardUserDefaults];
    if ([request responseStatusCode] == 200) {
        if ([status isEqualToString:@"ok"]) {
            [isCreatSucDefault setBool:YES forKey:@"isCreatSucDefault"];
            NSNumber *leftCount = [[result objectForKey:@"datasource"] objectForKey:@"sms_count_remaining"];
            [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:UpdateRemainCountFinished object:[NSNumber numberWithInt:[leftCount intValue]]]];

            NSString *applyURL = [[result objectForKey:@"datasource"] objectForKey:@"applyURL"];
            if (self.smsObject._isSendBySelf) {
                if([MFMessageComposeViewController canSendText]==YES){
                    MFMessageComposeViewController *vc = [[MFMessageComposeViewController alloc] init];
                    if (self.smsObject._isApplyTips) {
                        vc.body = [self.smsObject.smsContent stringByAppendingString:[NSString stringWithFormat:@"( 报名链接: %@ )",applyURL]];
                    }else{
                        vc.body = self.smsObject.smsContent;
                    };
                    
                    AddressBookDBService *favourite = [AddressBookDBService sharedAddressBookDBService];
                    for (ClientObject *client in self.smsObject.receiversArray) {
                        [favourite useContact:client];
                    }
                    
                    NSMutableArray *numberArray = [NSMutableArray arrayWithCapacity:10];
                    for (ClientObject *receipt in self.receipts) {
                        NSString *phoneNumber = receipt.cVal;
                        
                        if (!phoneNumber) {
                            continue;
                        } else {
                            phoneNumber = [self getCleanPhoneNumber:phoneNumber];
                            if (phoneNumber.length >= 11) {
                                [numberArray addObject:phoneNumber];
                            } else {
                                continue;
                            }
                        }
                    }
                    vc.recipients = numberArray;
                    vc.messageComposeDelegate = self;
                    [self.navigationController presentModalViewController:vc animated:YES];
                    SMSObjectService *s = [SMSObjectService sharedSMSObjectService];
                    [s clearSMSObject];
                    BaseInfoService *bs = [BaseInfoService sharedBaseInfoService];
                    [bs clearBaseInfo];
                    EmailObjectService *se = [EmailObjectService sharedEmailObjectService];
                    [se clearEmailObject];   
                    
                }else{
                    [self createPartySuc];
                    #if TARGET_IPHONE_SIMULATOR // iPhone Simulator
                    return;
#endif
                }
                
            }else{
                AddressBookDBService *favourite = [AddressBookDBService sharedAddressBookDBService];
                for (ClientObject *client in self.smsObject.receiversArray) {
                    [favourite useContact:client];
                }
                
//                UserObjectService *us = [UserObjectService sharedUserObjectService];
//                UserObject *user = [us getUserObject];
//                user.leftSMSCount = [[NSNumber numberWithInt:([user.leftSMSCount intValue] - [self.smsObject.receiversArray count])] stringValue];
                [self createPartySuc];
                
                SMSObjectService *s = [SMSObjectService sharedSMSObjectService];
                [s clearSMSObject];
                BaseInfoService *bs = [BaseInfoService sharedBaseInfoService];
                [bs clearBaseInfo];
                EmailObjectService *se = [EmailObjectService sharedEmailObjectService];
                [se clearEmailObject];
            }
                 
        } else if ([status isEqualToString:@"error_no_remaining"]){
                NSDictionary *infos = [result objectForKey:@"datasource"];
                NSNumber *leftCount = nil;
                leftCount = [infos objectForKey:@"remaining"];
                if (leftCount) {
                    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:UpdateRemainCountFinished object:leftCount]];
                    [self showLessRemainingCountAlert];
                    return;
                }
                [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:UpdateRemainCountFailed object:nil]];
        } else {
            [isCreatSucDefault setBool:NO forKey:@"isCreatSucDefault"];
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
    [self dismissWaiting];
	NSError *error = [request error];
	[self showAlertRequestFailed: error.localizedDescription];
}

- (NSString *)getCleanLetter:(NSString *)originalString {
    NSAssert(originalString != nil, @"Input phone number is %@!", @"NIL");
    NSMutableString *strippedString = [NSMutableString 
                                       stringWithCapacity:originalString.length];
    
    NSScanner *scanner = [NSScanner scannerWithString:originalString];
    NSCharacterSet *numbers = [NSCharacterSet 
                               characterSetWithCharactersInString:@"0123456789abcdefghijklmnopqrestuvwxyzABCDEFGHIJKLMNOPQRESTUVWXYZ"];
    
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
#pragma mark -
#pragma mark SMS delegate
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
	
	// Notifies users about errors associated with the interface
	switch (result) {
		case MessageComposeResultCancelled:{
            [self.navigationController dismissModalViewControllerAnimated:YES];
            //            UIActionSheet *sh = [[UIActionSheet alloc] initWithTitle:@"警告:您还未向受邀者发送邀请短信" delegate:self cancelButtonTitle:@"继续编辑短信" destructiveButtonTitle:@"返回趴列表" otherButtonTitles:nil];
//            [sh showInView:self.tabBarController.view];
            break;
        }
		case MessageComposeResultSent:
			//send
            [self createPartySuc];
			break;
		case MessageComposeResultFailed:{
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"错误" message:@"发送失败，请重新发送" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
            av.tag = 10011;
            [av show];
			break;
        }
		default:
			break;
	}
}
#pragma mark -
#pragma contact list delegate
- (void)callContactList {
//    ABPeoplePickerNavigationController *ppnc = [[ABPeoplePickerNavigationController alloc] init];
//    ppnc.peoplePickerDelegate = self;
//    [ppnc setDisplayedProperties:[NSArray
//                                  arrayWithObject:[NSNumber numberWithInt:kABPersonPhoneProperty]]];
//    
//    [self.navigationController presentModalViewController:ppnc animated:YES];

//    ContactsListPickerViewController *list = [[ContactsListPickerViewController alloc] init];
//    list.contactDelegate = self;
//    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:list];
//    [self.navigationController presentModalViewController:nav animated:YES];
    
    SegmentManagingViewController * segmentManagingViewController = [[SegmentManagingViewController alloc] init];
    segmentManagingViewController.contactDataDelegate = self;
    UINavigationController *pickersNav = [[UINavigationController alloc] initWithRootViewController:segmentManagingViewController];
    [self.navigationController presentModalViewController:pickersNav animated:YES];
}

#pragma mark _
#pragma mark HUD method
-(void)showWaiting {
    self.HUD = [[MBProgressHUD alloc] initWithView:self.view];
	[self.view addSubview:_HUD];
    _HUD.labelText = @"请稍等...";
    
    _HUD.delegate = self;
    
    [_HUD show:YES];
    
}

-(void)dismissWaiting {
    if (_HUD) {
        [_HUD hide:YES afterDelay:1.0f];
    }
}

- (void)HUDWasHidden:(MBProgressHUD *)hUD {
    // Remove _HUD from screen when the _HUD was hidded
    [_HUD removeFromSuperview];
    self.HUD = nil;
}

#pragma mark - 
#pragma mark alert method
- (void)showAlertRequestSuccess{
	UIAlertView *av=[[UIAlertView alloc] initWithTitle:@"操作成功!" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"好的",nil];
    av.tag=1;
	[av show];
}

- (void)showAlertRequestSuccessWithMessage: (NSString *) theMessage{
	UIAlertView *av=[[UIAlertView alloc] initWithTitle:@"操作成功!" message:theMessage delegate:self cancelButtonTitle:nil otherButtonTitles:@"好的",nil];
    av.tag=1;
	[av show];
}

- (void)showAlertRequestFailed: (NSString *) theMessage{
	UIAlertView *av=[[UIAlertView alloc] initWithTitle:@"操作失败!" message:theMessage delegate:self cancelButtonTitle:nil otherButtonTitles:@"好的",nil];
    [av show];
}

#pragma mark - 
#pragma mark UserSMSModeCheckDelegate

- (BOOL)IsCurrentSMSSendBySelf {
    return self.smsObject._isSendBySelf;
}

- (void)changeSMSModeToSendBySelf:(BOOL)status {
    self.smsObject._isSendBySelf = status;
}

#pragma mark -
#pragma mark people picker delegate
- (BOOL)peoplePickerNavigationController:
            (ABPeoplePickerNavigationController *)peoplePicker
            shouldContinueAfterSelectingPerson:(ABRecordRef)person {
        
    return YES; 
    
}
// Display the selected property
- (BOOL)peoplePickerNavigationController:
(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
    // We are guaranteed to only be working with e-mail or phone [self dismissModalViewControllerAnimated:YES];
    NSArray *array = [ABContact arrayForProperty:property
                                        inRecord:person];
    ABContact *contact = [ABContact contactWithRecord:person];
    NSString *phone = (NSString *)[array objectAtIndex:identifier];
    NSString *name = [contact compositeName];
    NSDictionary *personDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                        phone, @"phoneNumber", name, @"name",nil];
    [self addPersonToGroup:personDictionary];
    
    [self.navigationController dismissModalViewControllerAnimated:YES];
    
    return NO;
}
// Handle user cancels
- (void)peoplePickerNavigationControllerDidCancel:
(ABPeoplePickerNavigationController *)peoplePicker {
    
    [self.navigationController dismissModalViewControllerAnimated:YES];
    
}

#pragma mark - Add and remove a person to/from the group

- (void)addPersonToGroup:(NSDictionary *)personDictionary
{
    NSString *number = [personDictionary valueForKey:@"phoneNumber"];
    NSString *name  = [personDictionary valueForKey:@"name"];
    
    // Check for an existing entry for this person, if so remove it
    if ([name isEqualToString:@""]) {
        if ([number isEqualToString:@""]) {
            return;
        }
        NSString *cleanString = [self getCleanLetter:number];
        
        for (NSDictionary *personDict in self.receipts)
        {
            NSString *thePhoneString = [personDict valueForKey:@"phoneNumber"];
            if ([cleanString isEqualToString:[self getCleanLetter:thePhoneString]]) {
                return;
            }
        }
    } else {
        for (NSDictionary *personDict in self.receipts)
        {
            NSString *theContactName = [personDict valueForKey:@"name"];
            NSString *thePhoneString = [personDict valueForKey:@"phoneNumber"];
            //if (abRecordID == (ABRecordID)[[personDict valueForKey:@"abRecordID"] intValue])
            
            if ([[self getCleanPhoneNumber:number] isEqualToString:thePhoneString] && [name isEqualToString:theContactName]) {
                return;
            }
            
            if ([[self getCleanPhoneNumber:number] isEqualToString:[self getCleanPhoneNumber:thePhoneString]] && ![number isEqualToString:@""])
            {
                return;
            }
            
            if ([number isEqualToString:@""] && [theContactName isEqualToString:name]) {
                return;
            }
        }
    }
    
    [self.receipts addObject:personDictionary];
    [self rearrangeContactNameTFContent];
}

#pragma mark -
#pragma mark update remain count
- (void)updateRemainCount {
//    if(!self.editingTableViewCell.textView.text || [self.editingTableViewCell.textView.text isEqualToString:@""]){
//        UIAlertView *alert=[[UIAlertView alloc]
//                            initWithTitle:@"短信内容不可以为空"
//                            message:@"内容为必填项"
//                            delegate:self
//                            cancelButtonTitle:@"请点击输入内容"
//                            otherButtonTitles: nil];
//        [alert show];
//        return;
//    }else{
//        [self saveSMSInfo];
//        if ([self.smsObject.receiversArray count] == 0) {
//            UIAlertView *alertV = [[UIAlertView alloc] initWithTitle:@"警告" message:@"请添加收件人" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
//            [alertV show];
//            return;
//        }
//    }
    
    if (self.smsObject._isSendBySelf) {
        [self SMSContentInputDidFinish];
    } else {
        UserObjectService *us = [UserObjectService sharedUserObjectService];
        UserObject *user = [us getUserObject];
        NSString *requestURL = [NSString stringWithFormat:@"%@%d",ACCOUNT_REMAINING_COUNT,user.uID];
        ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:requestURL]];
        [request setDelegate:self];
        [request setDidFinishSelector:@selector(remainCountRequestDidFinish:)];
        [request setDidFailSelector:@selector(remainCountRequestDidFail:)];
        [self showWaiting];
        [request startSynchronous];
    }
} 

- (void)remainCountRequestDidFinish:(ASIHTTPRequest *)request {
    [self dismissWaiting];
    NSString *response = [request responseString];
    SBJsonParser *parser = [[SBJsonParser alloc] init];
	NSDictionary *result = [parser objectWithString:response];
    if ([request responseStatusCode] == 200) {
        NSNumber *remainCount = [[result objectForKey:@"datasource"] objectForKey:@"remaining"];
        UserObjectService *us = [UserObjectService sharedUserObjectService];
        UserObject *user = [us getUserObject];
        user.leftSMSCount = [remainCount stringValue];
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:UpdateRemainCountFinished object:remainCount]];
        [self SMSContentInputDidFinish];
    }else if([request responseStatusCode] == 404){
        [self showAlertRequestFailed:REQUEST_ERROR_404];
    }else if([request responseStatusCode] == 500){
        [self showAlertRequestFailed:REQUEST_ERROR_500];
    }else if([request responseStatusCode] == 502){
        [self showAlertRequestFailed:REQUEST_ERROR_502];
    } else {
        [self showAlertRequestFailed:REQUEST_ERROR_504];
    }
}

- (void)remainCountRequestDidFail:(ASIHTTPRequest *)request {
    [self dismissWaiting];
//    NSError *error = [request error];
//    NSLog(@"%@", error);
}

#pragma mark -
#pragma mark segment contact delegate
- (NSArray *)getCurrentContactData {
    NSLog(@"%@",self.receipts);
    return self.receipts;
}

- (void)setNewContactData : (NSArray *)newData {
    self.receipts = [NSMutableArray arrayWithArray:newData];
    [self rearrangeContactNameTFContent];
}

- (void)selectedCancelInController:(UIViewController *)vc {
    [self.navigationController dismissModalViewControllerAnimated:YES];
}

- (void)selectedFinishedInController:(UIViewController *)vc {
    [self.navigationController dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark less remain count error
- (void)showLessRemainingCountAlert {
//    UIAlertView *lessAlert = [[UIAlertView alloc] initWithTitle:@"操作提示" message:@"帐户余额不足，不能完成本次发送!" delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:@"去充值", nil];
//    [lessAlert setTag:10001];
//    [lessAlert show];
}


#pragma mark - 
#pragma mark alert view delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 10011) {
        [self.navigationController dismissModalViewControllerAnimated:YES];
    } else if (alertView.tag == 10001) {
        if (buttonIndex == 0) {
            return;
        } else {
            [self checkPurchaseValidStatus];
        }
    }
}

#pragma mark -
#pragma mark custom method
- (void)gotoPurchasPage {
    PurchaseListViewController *purchase = [[PurchaseListViewController alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:purchase animated:YES];
}

- (void)checkPurchaseValidStatus {
    if([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == kNotReachable) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:REQUEST_INVALID_NETWORK delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alertView show];
        return;
    }
    
    NSURL *url =  [NSURL URLWithString:CHECK_IF_IAP_VALID_FOR_THIS_VERSION];
    
    NSString *versionString = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    
    [request setPostValue:versionString forKey:@"version"];
    
    [request setDidFinishSelector:@selector(checkPurchaseValidStatusFinished:)];
    [request setDidFailSelector:@selector(checkPurchaseValidStatusFailed:)];
    
    request.timeOutSeconds = 15;
    [request setDelegate:self];
    
    [request setShouldAttemptPersistentConnection:NO];
    [request startAsynchronous];  
    
    [self showWaiting];
}


- (void)checkPurchaseValidStatusFinished:(ASIHTTPRequest *)request {
    [self dismissWaiting];
	NSString *response = [request responseString];
    
	SBJsonParser *parser = [[SBJsonParser alloc] init];
	NSDictionary *result = [parser objectWithString:response];
    NSString *status = [result objectForKey:@"status"];
    
    NSLog(@"%@",result);
    
    if ([request responseStatusCode] == 200) {
        if ([status isEqualToString:@"ok"]) {
            NSNumber *statusCode = [result objectForKey:@"datasource"];
            if (statusCode) {
                if ([statusCode intValue] == 0) {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"当前的版本并不支持此功能，请下载新版本后再使用此功能!" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                    [alertView show];
                } else if ([statusCode intValue] == 1) {
                    [self gotoPurchasPage];
                } else {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"与服务器连接异常，请稍后再试!" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                    [alertView show];
                }
            } else {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"与服务器连接异常，请稍后再试!" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                [alertView show];
            }
        } else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"与服务器连接异常，请稍后再试!" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alertView show];
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

- (void)checkPurchaseValidStatusFailed:(ASIHTTPRequest *)request {
    [self dismissWaiting];
	//NSError *error = [request error];
	[self showAlertRequestFailed: @"目前无法连接服务器，请稍候重试！"];
}
#pragma mark - 
#pragma mark notification method
- (void)leftCountRefreshing:(NSNotification *)notify {
    
}

- (void)leftCountRefreshed:(NSNotification *)notify {
    UserObjectService *us = [UserObjectService sharedUserObjectService];
    UserObject *user = [us getUserObject];
    self.leftCountLabel.text = [NSString stringWithFormat:@"帐户剩余:%@条", [[NSNumber numberWithInt:[user.leftSMSCount intValue]] stringValue]];
}

- (void)leftCountRefreshFailed:(NSNotification *)notify {
    self.leftCountLabel.text = @"帐户余额更新失败";
}

- (void)applicationWillTerminate:(NSNotification *)notify {
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:10];
    for (ClientObject *receipt in self.receipts) {
        [array addObject:receipt];
    }
    
    self.smsObject.receiversArray = array;
    
    self.smsObject.smsContent = [self.editingTableViewCell.textView text];

    [[SMSObjectService sharedSMSObjectService] saveSMSObject];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
