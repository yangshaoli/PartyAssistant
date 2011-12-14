//
//  EditPartyTableViewController.m
//  PartyAssistant
//
//  Created by 超 李 on 11-11-12.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "EditPartyTableViewController.h"

@implementation EditPartyTableViewController
@synthesize baseInfoObject,datePicker,peoplemaxiumPicker,locationTextField,descriptionTextView;

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

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStyleDone target:self action:@selector(doneBtnAction)];
    self.navigationItem.rightBarButtonItem = doneBtn;
    self.navigationItem.leftBarButtonItem.title = @"取消";
    //wxz
    NSString *titleString;
    if (baseInfoObject.description.length>3) {
        titleString=[[NSString alloc]initWithFormat:@"%@...",[baseInfoObject.description substringToIndex:3]];
    }else{
        titleString = baseInfoObject.description;
    }
    
    self.title=titleString;
    buttonIndexInteger=1;//默认为时间待定
    peoplebuttonIndex=1;//默认人数无限制
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
    return 4;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath;
{
    if(indexPath.section == 0 && indexPath.row == 3) {
        return 120.0f;
    }
    return 44.0f;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"基本信息";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    
    // Configure the cell...
    if (indexPath.row == 0){
        cell.textLabel.text = @"开始时间:";
        UILabel *starttimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 0, 190, 44)];
        starttimeLabel.textAlignment = UITextAlignmentRight;
        starttimeLabel.backgroundColor = [UIColor clearColor];
        if(buttonIndexInteger==0){
             starttimeLabel.text = baseInfoObject.starttimeStr;        
        }else{
            starttimeLabel.text =@"待定";
        }
        [cell addSubview:starttimeLabel];
        //            starttimeLabel.text = @"2011-11-11 11:00";
       
    }else if(indexPath.row == 1){
        cell.textLabel.text = @"地点:";
        if (!locationTextField) {
            self.locationTextField = [[UITextField alloc] initWithFrame:CGRectMake(100, 10, 190, 44)];
        }
        locationTextField.textAlignment = UITextAlignmentRight;
        locationTextField.delegate = self;
        locationTextField.text = baseInfoObject.location;
        [cell addSubview:locationTextField];
    }else if(indexPath.row == 2){
        cell.textLabel.text = @"人数上限:";
        UILabel *peopleStrLable = [[UILabel alloc] initWithFrame:CGRectMake(260, 0, 30, 44)];
        peopleStrLable.backgroundColor = [UIColor clearColor];
        peopleStrLable.textAlignment = UITextAlignmentRight;
        peopleStrLable.text = @"人";
        
        UILabel *peoplemaximumLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 0, 180, 44)];
        peoplemaximumLabel.backgroundColor = [UIColor clearColor];
        peoplemaximumLabel.textAlignment = UITextAlignmentRight;
        if(peoplebuttonIndex==1){
            peoplemaximumLabel.text=@"无限制";
        }else{
            [cell addSubview:peopleStrLable];
           peoplemaximumLabel.text = [baseInfoObject.peopleMaximum stringValue];
        }
        
        //peoplemaximumLabel.text = @"1";
        if (![peoplemaximumLabel.text isEqualToString:@"0"]) {
            peoplemaximumLabel.textColor = [UIColor redColor];
        }
        [cell addSubview:peoplemaximumLabel];
    }else if(indexPath.row == 3){
        cell.textLabel.text = @"描述:";
        if(!descriptionTextView){
            self.descriptionTextView = [[UITextView alloc] initWithFrame:CGRectMake(100, 10, 200, 100)];
        }
        descriptionTextView.text = baseInfoObject.description;
        descriptionTextView.backgroundColor = [UIColor clearColor];
        descriptionTextView.font=[UIFont systemFontOfSize:15];
        //descriptionTextView.text = baseInfoObject.description;
        [cell addSubview:descriptionTextView];
    }
    return cell;
}
//
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
#pragma mark - Save the Info

- (void)saveInfo{
        self.baseInfoObject.description = self.descriptionTextView.text;
        self.baseInfoObject.location = self.locationTextField.text;
        [self.baseInfoObject formatDateToString];
}

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
    [self saveInfo];
    if (indexPath.row == 0) {
        NSString *actionsheetTitle = @"\n\n\n\n\n\n\n\n\n\n\n";
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:actionsheetTitle delegate:self cancelButtonTitle:@"时间待定" destructiveButtonTitle:nil otherButtonTitles:@"选择", nil];
        actionSheet.tag = 0;
        if (!self.datePicker) {
            self.datePicker = [[UIDatePicker alloc] init];
        }
        if (!self.baseInfoObject.starttimeDate) {
            [datePicker setDate:[NSDate date]];
        }else{
            [datePicker setDate:self.baseInfoObject.starttimeDate];
        }
        [actionSheet addSubview:datePicker];
        [actionSheet showInView:self.tabBarController.view];
               
        
    }else if(indexPath.row == 2){
        NSString *actionsheetTitle = @"\n\n\n\n\n\n\n\n\n\n\n";
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:actionsheetTitle delegate:self cancelButtonTitle:@"无限制" destructiveButtonTitle:nil otherButtonTitles:@"选择", nil];
        actionSheet.tag = 1;
        if(!peoplemaxiumPicker){
            self.peoplemaxiumPicker = [[UIPickerView alloc] init];
        }
        NSInteger hundreds = [self.baseInfoObject.peopleMaximum intValue]/100;
        NSInteger tens = [self.baseInfoObject.peopleMaximum intValue]%100/10;
        NSInteger nums = [self.baseInfoObject.peopleMaximum intValue]%10;
        [peoplemaxiumPicker selectRow:hundreds inComponent:0 animated:NO];
        [peoplemaxiumPicker selectRow:tens inComponent:1 animated:NO];
        [peoplemaxiumPicker selectRow:nums inComponent:2 animated:NO];
        peoplemaxiumPicker.delegate = self;
        peoplemaxiumPicker.showsSelectionIndicator = YES;
        [actionSheet addSubview:peoplemaxiumPicker];
        [actionSheet showInView:self.tabBarController.view];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{   
    if (actionSheet.tag == 0) {
        if(buttonIndex==0){
            self.baseInfoObject.starttimeDate = [datePicker date];
            [self.baseInfoObject formatDateToString];
            buttonIndexInteger=0;
        }else{
            buttonIndexInteger=1;
        }
    }else{
        if(buttonIndex==0){
            NSInteger hundreds= [peoplemaxiumPicker selectedRowInComponent:0];
            NSInteger tens= [peoplemaxiumPicker selectedRowInComponent:1];
            NSInteger nums= [peoplemaxiumPicker selectedRowInComponent:2];
            self.baseInfoObject.peopleMaximum = [NSNumber numberWithInt:hundreds*100 + tens*10 + nums];
            peoplebuttonIndex=0;
        }else{
            peoplebuttonIndex=1;
        
        }
       
    }
    [self saveInfo];
    [self.tableView reloadData];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    self.baseInfoObject.location = textField.text;
    return NO;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 3;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return 10;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return [NSString stringWithFormat:@"%d",row];
}


- (void)doneBtnAction{
  if(!self.descriptionTextView.text || [self.descriptionTextView.text isEqualToString:@""]){
        UIAlertView *alert=[[UIAlertView alloc]
                            initWithTitle:@"描述内容不可以为空"
                            message:@"描述为必填项"
                            delegate:self
                            cancelButtonTitle:@"请点击输入内容"
                            otherButtonTitles: nil];
        [alert show];
      return;
        
 }else{

    [self saveInfo];
    [self showWaiting];
    UserObjectService *us = [UserObjectService sharedUserObjectService];
    UserObject *user = [us getUserObject];
    NSURL *url = [NSURL URLWithString:EDIT_PARTY];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setPostValue:self.baseInfoObject.starttimeDate forKey:@"starttime"];
    [request setPostValue:self.baseInfoObject.location forKey:@"location"];
    [request setPostValue:self.baseInfoObject.description forKey:@"description"];
    [request setPostValue:self.baseInfoObject.peopleMaximum forKey:@"peopleMaximum"];
    [request setPostValue:self.baseInfoObject.partyId forKey:@"partyID"];
    [request setPostValue:[NSNumber numberWithInteger:user.uID] forKey:@"uID"];
    
    request.timeOutSeconds = 30;
    [request setDelegate:self];
    [request setShouldAttemptPersistentConnection:NO];
    [request startAsynchronous];
 }
}

- (void)requestFinished:(ASIHTTPRequest *)request{
	NSString *response = [request responseString];
	SBJsonParser *parser = [[SBJsonParser alloc] init];
	NSDictionary *result = [parser objectWithString:response];
	NSString *description = [result objectForKey:@"description"];
	[self dismissWaiting];
    if ([request responseStatusCode] == 200) {
        if ([description isEqualToString:@"ok"]) {
            [self.navigationController popViewControllerAnimated:YES];
            NSDictionary *userinfo = [[NSDictionary alloc] initWithObjectsAndKeys:self.baseInfoObject,@"baseinfo", nil];
            NSNotification *notification = [NSNotification notificationWithName:EDIT_PARTY_SUCCESS object:nil userInfo:userinfo];
            [[NSNotificationCenter defaultCenter] postNotification:notification];
        }else{
            [self showAlertRequestFailed:description];		
        }
    }else if([request responseStatusCode] == 404){
        [self showAlertRequestFailed:REQUEST_ERROR_404];
    }else{
        [self showAlertRequestFailed:REQUEST_ERROR_500];
    }
	
}


- (void)requestFailed:(ASIHTTPRequest *)request
{
	NSError *error = [request error];
	[self dismissWaiting];
	[self showAlertRequestFailed: error.localizedDescription];
}

@end
