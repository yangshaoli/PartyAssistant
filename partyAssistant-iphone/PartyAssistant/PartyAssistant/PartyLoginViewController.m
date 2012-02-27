//
//  PartyLoginViewController.m
//  PartyTest
//
//  Created by Wang Jun on 11/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import "PartyListTableVC.h"
#import "ForgetPassword.h"

#import "AddNewPartyBaseInfoTableViewController.h"
#import "CreatNewPartyViaSMSViewController.h"
#import "DataManager.h"
#import "GlossyButton.h"
#import "PartyListTableViewController.h"
#import "PartyLoginViewController.h"
#import "PartyUserRegisterViewController.h"
#import "SettingsListTableViewController.h"
#import "PartyListService.h"
#import "UserObject.h"
#import "UserObjectService.h"
#import "HTTPRequestErrorMSG.h"
#import "JSON.h"
#import "ASIFormDataRequest.h"
#import "URLSettings.h"
#import "NotificationSettings.h"
#import "ChangePasswordRandomLoginTableVC.h"
#define NotLegalTag         1
#define NotPassTag          2
#define InvalidateNetwork   3
#define BOOLStringOutput(target) target ? @"YES" : @"NO"
@interface PartyLoginViewController()

- (void)cleanKeyBoard;
- (void)showAlertWithMessage:(NSString *)message  buttonTitle:(NSString *)buttonTitle 
                         tag:(int)tagNum;
- (void)showNotLegalInput;
- (void)showNotPassChekAlert;
- (void)registerUser;
- (void)gotoContentVC;
- (void)pushToContentVC;
- (void)checkIfUserNameSaved;
- (void)showInvalidateNetworkalert;
- (void)tryConnectToServer;

@end

@implementation PartyLoginViewController
@synthesize tableView = _tableView;
@synthesize loginButton = _loginButton;
@synthesize userNameTableCell = _userNameTableCell;
@synthesize pwdTableCell = _pwdTableCell;
@synthesize userNameTextField = _userNameTextField;
@synthesize pwdTextField = _pwdTextField;
@synthesize modal = _modal;
@synthesize parentVC = _parentVC;
@synthesize partyList;
@synthesize appTab;
@synthesize creatTabButton;
@synthesize listTabButton;
@synthesize setTabButton;
@synthesize creatPageBarImageView;
@synthesize creatLabel;
@synthesize listPageBarImageView;
@synthesize setPageBarImageView;

- (void)dealloc {
    [super dealloc];
    
    [_tableView release];
    
    [_loginButton release];
    
    [_userNameTableCell release];
    [_pwdTableCell release];
    
    [_userNameTextField release];
    [_pwdTextField release];
}

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
    
    self.navigationController.navigationBar.tintColor = [UIColor redColor];
    
    CGSize windowSize = self.view.bounds.size;
    UIView *tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, windowSize.width, 100)];
    
    _loginButton = [[GlossyButton alloc] initWithFrame:CGRectMake(0, 0, windowSize.width - 16, 50)];
    _loginButton.center = CGPointMake(windowSize.width / 2, tableFooterView.bounds.size.height / 2 - 20);
    _loginButton.hue = 0.4f;
    _loginButton.brightness = 0.6f;
    _loginButton.saturation = 0.2f;
    _loginButton.titleLabel.font = [UIFont boldSystemFontOfSize:18.0f];
    [_loginButton setTitle:@"登录" forState:UIControlStateNormal];
    [_loginButton addTarget:self action:@selector(loginCheck) forControlEvents:UIControlEventTouchUpInside];
    
    [tableFooterView addSubview:_loginButton];
    [_tableView setTableFooterView:tableFooterView];
    
    _tableView.scrollEnabled = NO;

    self.navigationItem.title = @"登录";
    
    UIBarButtonItem *registerButton = [[UIBarButtonItem alloc] initWithTitle:@"注册" style:UIBarButtonItemStylePlain target:self action:@selector(registerUser)];
    
    self.navigationItem.leftBarButtonItem = registerButton;
    
    UIBarButtonItem *forgetPasswordButton = [[UIBarButtonItem alloc] initWithTitle:@"忘记密码" style:UIBarButtonItemStylePlain target:self action:@selector(forgetPassword)];
    
    self.navigationItem.rightBarButtonItem = forgetPasswordButton;

    [registerButton release];
    [forgetPasswordButton release];
    [tableFooterView release];
   
    //wxz  如果本地有登陆数据  则跳过登陆页面 自动登陆
    UserObjectService *us = [UserObjectService sharedUserObjectService];
    UserObject *user = [us getUserObject];
//    NSString *keyString=[[NSString alloc] initWithFormat:@"%@defaultUserID",user.userName];
 //  NSLog(@"当前用户名称:%@及》》》》id值:%d",user.userName,user.uID);
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];  
//    NSInteger  getDefaulUserId=[defaults integerForKey:keyString];
   // [keyString release]; 
    
    if(user){
        if(user.uID > 0){
            [self pushToContentVC];
        }else{
            return;
        }    
    }else{
        return;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appBecomeActive) name: UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.userNameTextField becomeFirstResponder];
    
    UserObjectService *us = [UserObjectService sharedUserObjectService];
    UserObject *user = [us getUserObject];
    if(user){
        if(user.uID > 0){
        } else {
            self.navigationController.navigationBarHidden = NO;
        }
    }

    
    self.appTab = nil;
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

- (void)loginCheck {
    //check usrname and pwd is not nil and legal( length > 3?)
  //为了调试暂时先注释掉  
    if (!_userNameTextField.text || [_userNameTextField.text isEqualToString:@""]
        || !_pwdTextField.text || [_pwdTextField.text isEqualToString:@""]) {
        [self showNotLegalInput];
        return;
    }

    [self cleanKeyBoard];

    _HUD = [[MBProgressHUD alloc] initWithView:self.view];
	[self.navigationController.view addSubview:_HUD];
	
    _HUD.labelText = @"Loading";
    
    _HUD.delegate = self;
    
    [_HUD show:YES];
   
    //[self tryConnectToServer];
    
    [self performSelector:@selector(tryConnectToServer) withObject:nil afterDelay:1.0f];
    
    //[self gotoContentVC];//调试新加的无用语句
    
}

- (void)tryConnectToServer {
    //TODO:login check method!
//    NetworkConnectionStatus networkStatus= [[DataManager sharedDataManager]
//                                            validateCheckWithUsrName:self.userNameTextField.text  pwd:self.pwdTextField.text];
    NSString *statusDescription = nil;
    statusDescription = [[DataManager sharedDataManager]
     validateCheckWithUsrName:self.userNameTextField.text  pwd:self.pwdTextField.text];
    [_HUD hide:YES];
    
    if (statusDescription) {
        [self showAlertWithMessage:statusDescription
                       buttonTitle:@"确定" tag:NotLegalTag];
    } else {
        [self gotoContentVC];
    }

//    switch (networkStatus) {
//        case NetworkConnectionInvalidate:
//            [self showInvalidateNetworkalert];
//            break;
//        case NetWorkConnectionCheckPass:
//            [self gotoContentVC];
//            break;
//        default:
//            [self showNotPassChekAlert];
//            break;
//    }
}

- (void)cleanKeyBoard {
    if ([_userNameTextField isFirstResponder]) {
        [_userNameTextField resignFirstResponder];
    } else {
        [_pwdTextField resignFirstResponder];
    }
}

- (void)showAlertWithMessage:(NSString *)message  
                 buttonTitle:(NSString *)buttonTitle 
                         tag:(int)tagNum{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:message delegate:self cancelButtonTitle:@"好的" otherButtonTitles:nil];
    alert.tag = tagNum;
    [alert show];
    [alert release];
}

- (void)gotoContentVC {
    //use different work flow
    
//    //登陆连接服务器成功后   保存用户信息到本地   登出时需要清空才可
//    UserObjectService *us = [UserObjectService sharedUserObjectService];
//    UserObject *user = [us getUserObject];
//   
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];  
//    NSString *keyString=[[NSString alloc] initWithFormat:@"%@defaultUserID",user.userName];
//    [defaults setInteger:user.uID  forKey:keyString];    
//    [keyString  release];
    

    //1.modal
    
    //2.nav
    if (self.isModal) {
            
    } else {
            //2
        [self pushToContentVC];
    }
}

- (void)showInvalidateNetworkalert {
    [self showAlertWithMessage:@"无法连接网络，请检查网络状态！" 
                   buttonTitle:@"OK" 
                           tag:InvalidateNetwork];
}

- (void)showNotLegalInput {
    [self showAlertWithMessage:@"登陆内容不能为空！" buttonTitle:@"好的" tag:NotLegalTag];
}

- (void)showNotPassChekAlert {
    [self showAlertWithMessage:@"登录失败" buttonTitle:@"好的" tag:NotPassTag];
}

- (void)registerUser {
    //TODO: got register view
    PartyUserRegisterViewController *registerVC = [[PartyUserRegisterViewController alloc] initWithNibName:nil bundle:nil];
    registerVC.delegate=self;
    [self.navigationController pushViewController:registerVC animated:YES];
    [registerVC release];
}

- (void)forgetPassword{
    ForgetPassword *forgetPasswordVC=[[ForgetPassword alloc] initWithNibName:@"ForgetPassword" bundle:nil];
    [self.navigationController  pushViewController:forgetPasswordVC animated:YES];
}

- (void)pushToContentVC {
    self.userNameTextField.text = @"";
    self.pwdTextField.text = @"";
    
    self.navigationController.navigationBarHidden = YES;
    PartyListTableVC  *pattyListTableVC=[[PartyListTableVC alloc] initWithNibName:@"PartyListTableVC" bundle:nil];
    //PartyListTableViewController *list = [[PartyListTableViewController alloc] initWithNibName:nil bundle:nil];
    
//    AddNewPartyBaseInfoTableViewController *addPage = [[AddNewPartyBaseInfoTableViewController alloc] initWithNibName:@"AddNewPartyBaseInfoTableViewController" bundle:nil];
    SettingsListTableViewController *settings = [[SettingsListTableViewController alloc] initWithNibName:@"SettingsListTableViewController" bundle:nil];
    
    UINavigationController *listNav = [[UINavigationController alloc] initWithRootViewController:pattyListTableVC];
    CreatNewPartyViaSMSViewController *creat = [[CreatNewPartyViaSMSViewController alloc] initWithNibName:nil bundle:nil];
    
//    UINavigationController *addPageNav = [[UINavigationController alloc] initWithRootViewController:addPage];
    UINavigationController *settingNav = [[UINavigationController alloc] initWithRootViewController:settings];
    UINavigationController *creatNav = [[UINavigationController alloc] 
        initWithRootViewController:creat];
    
    creatPageBarImageView=[[UIImageView alloc] initWithFrame:CGRectMake(33, 5, 33, 25)];
    listPageBarImageView=[[UIImageView alloc] initWithFrame:CGRectMake(33, 5, 50, 40)];
    setPageBarImageView=[[UIImageView alloc] initWithFrame:CGRectMake(33, 5, 50, 40)];
    UIImage *listBarImage = [UIImage imageNamed:@"listIcon_word"];
    UIImage *creatPageBarImage = [UIImage imageNamed:@"creatIcon"];
    UIImage *settingBarImage = [UIImage imageNamed:@"setting_word"];
    
    creatPageBarImageView.image=creatPageBarImage;
    listPageBarImageView.image=listBarImage;
    setPageBarImageView.image=settingBarImage;
    
    creatLabel=[[UILabel alloc] initWithFrame:CGRectMake(27, 30, 60, 15)];
    creatLabel.text=@"创建活动";
    creatLabel.textColor=[UIColor whiteColor];
    creatLabel.backgroundColor=[UIColor clearColor];
    creatLabel.font=[UIFont systemFontOfSize:11];
    
//    UITabBarItem *listBarItem = [[UITabBarItem alloc] initWithTitle:@"活动列表" image:nil tag:1];
   //UITabBarItem *creatPageBarItem = [[UITabBarItem alloc] initWithTitle:@"创建活动" image:nil tag:2];
//    UITabBarItem *settingBarItem = [[UITabBarItem alloc] initWithTitle:@"设置" image:nil tag:3];
    
    UITabBarItem *listBarItem = [[UITabBarItem alloc] init];
    UITabBarItem *creatPageBarItem = [[UITabBarItem alloc] init];
    UITabBarItem *settingBarItem = [[UITabBarItem alloc] init];
    listNav.tabBarItem = listBarItem;
    creatNav.tabBarItem = creatPageBarItem;
    settingNav.tabBarItem = settingBarItem;
    
    //custom Tab button
    creatTabButton=[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 106, 50)];
    [creatTabButton addTarget:self action:@selector(pressCreatButtonTab) forControlEvents:UIControlEventTouchUpInside];
    
    [creatTabButton addSubview:creatPageBarImageView];
    [creatTabButton addSubview:creatLabel];
   
    listTabButton=[[UIButton alloc] initWithFrame:CGRectMake(107, 0, 106, 50)];
    [listTabButton addTarget:self action:@selector(pressListButtonTab) forControlEvents:UIControlEventTouchUpInside];
    [listTabButton addSubview:listPageBarImageView];

    setTabButton=[[UIButton alloc] initWithFrame:CGRectMake(214, 0, 106, 50)];
    [setTabButton addTarget:self action:@selector(pressSettingButtonTab) forControlEvents:UIControlEventTouchUpInside];
    [setTabButton addSubview:setPageBarImageView];

    [listBarItem release];
    [creatPageBarItem release];
    [settingBarItem release];
    //花了很长时间
    UIImageView *tabBackView=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
    tabBackView.image=[UIImage imageNamed:@"tabBar.png"];
    UITabBarController *tab = [[UITabBarController alloc] init];
    self.appTab = tab;
    [[tab tabBar] addSubview:tabBackView];//关键找准给谁添加subview
   
    tab.viewControllers = [NSArray arrayWithObjects:creatNav, listNav, settingNav,nil];
    
    //[[tab tabBar] setBackgroundColor:[UIColor clearColor]];

    [[tab tabBar] addSubview:creatTabButton];
    [[tab tabBar] addSubview:listTabButton];
    [[tab tabBar] addSubview:setTabButton];
    [self.navigationController pushViewController:tab animated:YES];

    [listNav release];
    [creatNav release];
    [settingNav release];
//    [creatNav release];
    
    //[list release];
    [pattyListTableVC release];
//    [addPage release];
    [settings release];
    [creat release];
    
     //add suggest user input name page here?
//    [self checkIfUserNameSaved];

    //如果有趴列表  则直接跳到“趴列表”tab，否则跳到"开新趴”tab
    UserObjectService *us = [UserObjectService sharedUserObjectService];
    UserObject *user = [us getUserObject];
    NSString *keyString=[[NSString alloc] initWithFormat:@"%dcountNumber",user.uID];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];  
    NSInteger  getDefaultCountNumber=[defaults integerForKey:keyString];
    if(getDefaultCountNumber){  
        tab.selectedIndex=1;
    }else{
        tab.selectedIndex=0;
    }
    [keyString release];
    //NSLog(@"打印isRandomLoginSelf  %@",BOOLStringOutput([DataManager sharedDataManager].isRandomLoginSelf));
    
}
//wxz
- (void)autoLogin{
    [self pushToContentVC];

}

-(void)pressCreatButtonTab{
    self.appTab.selectedIndex=0;
    creatLabel.textColor=[UIColor colorWithRed:200 green:166 blue:222 alpha:0.7];
    UIImage *currentSelectImage=[UIImage imageNamed:@"current"];
    
    UIGraphicsBeginImageContextWithOptions(creatTabButton.frame.size, NO, 0.0);
    [[currentSelectImage stretchableImageWithLeftCapWidth:20 topCapHeight:10] drawInRect:CGRectMake(1, 1, creatTabButton.frame.size.width-2, creatTabButton.frame.size.height-4)];
    UIImage *newSelectImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    creatPageBarImageView.image=[UIImage imageNamed:@"CreatIcon_on"];
    self.creatTabButton.backgroundColor=[UIColor colorWithPatternImage:newSelectImage];
    self.listTabButton.backgroundColor=[UIColor clearColor];
    self.setTabButton.backgroundColor=[UIColor clearColor];
    setPageBarImageView.image=[UIImage imageNamed:@"setting_word"];
    listPageBarImageView.image=[UIImage imageNamed:@"listIcon_word"];
    NSLog(@"tab0");
}
-(void)pressListButtonTab{
    self.appTab.selectedIndex=1;
    UIImage *currentSelectImage=[UIImage imageNamed:@"current"];
    
    UIGraphicsBeginImageContextWithOptions(listTabButton.frame.size, NO, 0.0);
    
    [[currentSelectImage stretchableImageWithLeftCapWidth:20 topCapHeight:10] drawInRect:CGRectMake(1, 1, listTabButton.frame.size.width-2, listTabButton.frame.size.height-4)];
    UIImage *newSelectImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();

    listPageBarImageView.image=[UIImage imageNamed:@"listIcon_on_word"];
    self.listTabButton.backgroundColor=[UIColor colorWithPatternImage:newSelectImage];
    self.creatTabButton.backgroundColor=[UIColor clearColor];
    self.setTabButton.backgroundColor=[UIColor clearColor];
    setPageBarImageView.image=[UIImage imageNamed:@"setting_word"];
    creatPageBarImageView.image=[UIImage imageNamed:@"creatIcon"];
    creatLabel.textColor=[UIColor whiteColor];
    NSLog(@"tab1");
}
-(void)pressSettingButtonTab{
    self.appTab.selectedIndex=2;
    UIImage *currentSelectImage=[UIImage imageNamed:@"current"];
    UIGraphicsBeginImageContextWithOptions(setTabButton.frame.size, NO, 0.0);
    
    [[currentSelectImage stretchableImageWithLeftCapWidth:20 topCapHeight:10] drawInRect:CGRectMake(1, 1, setTabButton.frame.size.width-2, setTabButton.frame.size.height-4)];
    UIImage *newSelectImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    setPageBarImageView.image=[UIImage imageNamed:@"setting_on_word"];
    self.setTabButton.backgroundColor=[UIColor colorWithPatternImage:newSelectImage];
    self.creatTabButton.backgroundColor=[UIColor clearColor];
    self.listTabButton.backgroundColor=[UIColor clearColor];
    listPageBarImageView.image=[UIImage imageNamed:@"listIcon_word"];
    creatPageBarImageView.image=[UIImage imageNamed:@"creatIcon"];
    creatLabel.textColor=[UIColor whiteColor];
    NSLog(@"tab2");
}
#pragma mark -
#pragma tableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView 
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.row == 0) {
        return _userNameTableCell;
    } else if (indexPath.row == 1) {
        return _pwdTableCell;
    } 
    return nil;
}

- (NSIndexPath *)tableView:(UITableView *)tableView
  willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

#pragma mark -
#pragma mark MBProgress_HUDDelegate methods

- (void)HUDWasHidden:(MBProgressHUD *)hUD {
    // Remove _HUD from screen when the _HUD was hidded
    [_HUD removeFromSuperview];
    [_HUD release];
	_HUD = nil;
}

#pragma mark _
#pragma mark Alert Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
   if (alertView.tag == NotLegalTag) {
       if (!_userNameTextField.text || [_userNameTextField.text isEqualToString:@""]) {
           [_userNameTextField becomeFirstResponder];
       } else {
           [_pwdTextField becomeFirstResponder];
       }
   } else {
       [_userNameTextField becomeFirstResponder];
   }
}

#pragma mark _
#pragma mark PartyUserNameInput Method and Delegate

- (void)checkIfUserNameSaved {
    //1.datamanager check
    BOOL isSaved = [[DataManager sharedDataManager] checkIfUserNameSaved];
    if (isSaved) {
        return;
    }
    //2.show viewController
//    PartyUserNameInputViewController *vc = [[PartyUserNameInputViewController alloc] initWithNibName:nil bundle:nil];
//    vc.delegate = self;
//    [self presentModalViewController:vc animated:YES];
//    [vc release];
    
//    //wxz判断   只在用户首次登陆才执行
//    UserObjectService *us = [UserObjectService sharedUserObjectService];
//    UserObject *user = [us getUserObject];
//    NSString *keyString1=[[NSString alloc] initWithFormat:@"%@defaultUserID",user.userName];
//    NSUserDefaults *defaults1 = [NSUserDefaults standardUserDefaults];  
//    NSInteger  getDefaulUserId=[defaults1 integerForKey:keyString1];
//    if(-1==getDefaulUserId){
//        PartyUserNameInputViewController *vc = [[PartyUserNameInputViewController alloc] initWithNibName:nil bundle:nil];
//        vc.delegate = self;
//        [self presentModalViewController:vc animated:YES];
//        [vc release];
//    }
//    [keyString1 release];
} 

- (void)cancleInput {
    [self.navigationController dismissModalViewControllerAnimated:YES];
}

- (void)saveInputDidBegin {
    //wait DataManager method
    _HUD = [[MBProgressHUD alloc] initWithView:self.view];
	[self.navigationController.view addSubview:_HUD];
	
    _HUD.labelText = @"Loading";
    
    _HUD.delegate = self;
    
    [_HUD show:YES];
}

- (void)saveInputFinished {
    [_HUD hide:YES];
    [self.navigationController dismissModalViewControllerAnimated:YES];
}

- (void)saveInputFailed {
    [_HUD hide:YES];
    [self.navigationController dismissModalViewControllerAnimated:YES];
}

- (void)appBecomeActive {
    if (self.appTab) {
        UINavigationController *nav = [[self.appTab viewControllers] objectAtIndex:self.appTab.selectedIndex];
        if (nav.presentedViewController) {
            [nav.presentedViewController viewWillAppear:YES];
        }
    }
}
@end
