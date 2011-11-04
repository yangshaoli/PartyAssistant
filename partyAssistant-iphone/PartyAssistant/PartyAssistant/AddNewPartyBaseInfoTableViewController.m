//
//  AddNewPartyBaseInfoTableViewController.m
//  PartyAssistant
//
//  Created by 超 李 on 11-10-26.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "AddNewPartyBaseInfoTableViewController.h"

@implementation AddNewPartyBaseInfoTableViewController
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
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    BaseInfoService *baseinfoService = [BaseInfoService sharedBaseInfoService];
    self.baseInfoObject = [baseinfoService getBaseInfo];
    if ([baseInfoObject.starttimeStr isEqualToString:@""]) {
        baseInfoObject.starttimeDate = [NSDate date];
        [baseInfoObject formatDateToString];
    }
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
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if(section==0){
        return 4;
    }
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section==0) {
        return @"基本信息";
    }
    return @"给朋友发邀请";
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath;
{
    if(indexPath.section == 0 && indexPath.row == 3) {
        return 120.0f;
    }
    return 44.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    
    // Configure the cell...
    if (indexPath.section == 0){
        if (indexPath.row == 0){
            cell.textLabel.text = @"开始时间:";
            UILabel *starttimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 0, 190, 44)];
            starttimeLabel.textAlignment = UITextAlignmentRight;
            starttimeLabel.backgroundColor = [UIColor clearColor];
            starttimeLabel.text = baseInfoObject.starttimeStr;
//            starttimeLabel.text = @"2011-11-11 11:00";
            [cell addSubview:starttimeLabel];
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
            [cell addSubview:peopleStrLable];
            UILabel *peoplemaximumLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 0, 180, 44)];
            peoplemaximumLabel.backgroundColor = [UIColor clearColor];
            peoplemaximumLabel.textAlignment = UITextAlignmentRight;
            peoplemaximumLabel.text = [baseInfoObject.peopleMaximum stringValue];
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
            //descriptionTextView.text = baseInfoObject.description;
            [cell addSubview:descriptionTextView];
        }
    }else{
        cell.backgroundColor = [UIColor clearColor];
        if (indexPath.row == 0) {
            UIButton *smsBTN = [UIButton buttonWithType:UIButtonTypeCustom];
            [smsBTN setTitleColor:[UIColor greenColor] forState:UIControlStateHighlighted];
            [smsBTN setBackgroundColor:[UIColor darkGrayColor]];
            
            [smsBTN setFrame:CGRectMake(10, 0, 300, 44)];
            [smsBTN setTitle:@"发送邀请短信" forState:UIControlStateNormal];
            [smsBTN addTarget:self action:@selector(goToSMS) forControlEvents:UIControlEventTouchUpInside];
            [cell addSubview:smsBTN];
        }else{
            UIButton *emailBTN = [UIButton buttonWithType:UIButtonTypeCustom];
            [emailBTN setTitleColor:[UIColor greenColor] forState:UIControlStateHighlighted];
            [emailBTN setBackgroundColor:[UIColor darkGrayColor]];
            
            [emailBTN setFrame:CGRectMake(10, 0, 300, 44)];
            [emailBTN setTitle:@"发送邀请邮件" forState:UIControlStateNormal];
            [emailBTN addTarget:self action:@selector(goToEmail) forControlEvents:UIControlEventTouchUpInside];
            [cell addSubview:emailBTN];
        }
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
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

#pragma mark - Save the Info

- (void)saveInfo{
    self.baseInfoObject.description = self.descriptionTextView.text;
    self.baseInfoObject.location = self.locationTextField.text;
    BaseInfoService *s = [BaseInfoService sharedBaseInfoService];
    [s saveBaseInfo];
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
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            NSString *actionsheetTitle = @"\n\n\n\n\n\n\n\n\n\n\n";
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:actionsheetTitle delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:@"选择", nil];
            actionSheet.tag = 0;
            if (!self.datePicker) {
                self.datePicker = [[UIDatePicker alloc] init];
            }
            if (!self.baseInfoObject.starttimeDate) {
                self.baseInfoObject.starttimeDate = [NSDate date];
            }
            [datePicker setDate:self.baseInfoObject.starttimeDate];
            [actionSheet addSubview:datePicker];
            [actionSheet showInView:self.view];
        }else if(indexPath.row == 2){
            NSString *actionsheetTitle = @"\n\n\n\n\n\n\n\n\n\n\n";
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:actionsheetTitle delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:@"选择", nil];
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
            [actionSheet showInView:self.view];
        }
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 0) {
        self.baseInfoObject.starttimeDate = [datePicker date];
        [self.baseInfoObject formatDateToString];
        [self.tableView reloadData];
    }else{
        NSLog(@"aa");
        NSInteger hundreds= [peoplemaxiumPicker selectedRowInComponent:0];
        NSInteger tens= [peoplemaxiumPicker selectedRowInComponent:1];
        NSInteger nums= [peoplemaxiumPicker selectedRowInComponent:2];
        self.baseInfoObject.peopleMaximum = [NSNumber numberWithInt:hundreds*100 + tens*10 + nums];
        NSLog(@"%@",self.baseInfoObject.peopleMaximum);
        [self.tableView reloadData];
    }
    
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

#pragma mark -- SMS & Email BTN

- (void)goToSMS
{
    [self saveInfo];
    SendSMSToClientsViewController *vc = [[SendSMSToClientsViewController alloc] initWithNibName:@"SendSMSToClientsViewController" bundle:[NSBundle mainBundle]];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)goToEmail
{
    [self saveInfo];
    SendEmailToClientsViewController *vc = [[SendEmailToClientsViewController alloc] initWithNibName:@"SendEmailToClientsViewController" bundle:[NSBundle mainBundle]];
    [self.navigationController pushViewController:vc animated:YES];
}
@end
