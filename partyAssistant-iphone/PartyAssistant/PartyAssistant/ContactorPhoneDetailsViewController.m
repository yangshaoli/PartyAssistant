//
//  ContactorPhoneDetailsViewController.m
//  PartyAssistant
//
//  Created by 超 李 on 11-11-1.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "ContactorPhoneDetailsViewController.h"

@implementation ContactorPhoneDetailsViewController
@synthesize contactorID,phone,card,phoneDetailDelegate;

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
    
    UIButton *goButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [goButton setFrame:CGRectMake(50, 200, 80, 40)];
    [goButton setTitle:@"参加" forState:UIControlStateNormal];
//    [goButton addTarget:self action:@selector(nil) forControlEvents:UIControlEventTouchUpInside];
    goButton.backgroundColor=[UIColor  clearColor];
    [self.view addSubview:goButton];

    UIButton *notGoButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [notGoButton setFrame:CGRectMake(200, 200,80, 40)];
    [notGoButton setTitle:@"不参加" forState:UIControlStateNormal];
    //    [goButton addTarget:self action:@selector(nil) forControlEvents:UIControlEventTouchUpInside];
    notGoButton.backgroundColor=[UIColor clearColor];
    [self.view addSubview:notGoButton];

    
      
   
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
        ABAddressBookRef addressBook = ABAddressBookCreate();
        if(!card){
            self.card = ABAddressBookGetPersonWithRecordID(addressBook, self.contactorID);
        }
        if (!phone) {
            self.phone = ABRecordCopyValue(card, kABPersonPhoneProperty);
        }
        int num = ABMultiValueGetCount(self.phone);
        return num;
    }
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
        NSString *typeStr = (__bridge_transfer NSString*)ABAddressBookCopyLocalizedLabel(ABMultiValueCopyLabelAtIndex(self.phone, indexPath.row));
        NSString *valStr = (__bridge_transfer NSString*)ABMultiValueCopyValueAtIndex(self.phone, indexPath.row);
        UILabel *typeLb = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 80, 44)];
        typeLb.text = typeStr;
        typeLb.textAlignment = UITextAlignmentRight;
        typeLb.textColor = [UIColor blueColor];
        typeLb.backgroundColor = [UIColor clearColor];
        [cell addSubview:typeLb];
        UILabel *valLb = [[UILabel alloc] initWithFrame:CGRectMake(100, 0, 200, 44)];
        valLb.text = valStr;
        valLb.backgroundColor = [UIColor clearColor];
        [cell addSubview:valLb];
    }
    if(indexPath.section==1){
        UILabel *wordsLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 80, 44)];
        wordsLabel.text=@"留言";
        wordsLabel.textAlignment = UITextAlignmentRight;
        wordsLabel.textColor = [UIColor blueColor];
        wordsLabel.backgroundColor = [UIColor clearColor];
        [cell addSubview:wordsLabel];

         
    }
        
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if(section==0){
        UIView *headV = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 85.0f)];
        
        NSData *imgData = (__bridge_transfer NSData*)ABPersonCopyImageData(self.card);
        
        UIImageView *imgV = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 65, 65)];
        [imgV setImage:[UIImage imageWithData:imgData]];
        imgV.backgroundColor = [UIColor whiteColor];
        [headV addSubview:imgV];
        
        UILabel *lblV = [[UILabel alloc] initWithFrame:CGRectMake(100, 10, 210, 65)];
        NSString *personFName = (__bridge_transfer NSString*)ABRecordCopyValue(self.card, kABPersonFirstNameProperty);
        if (personFName == nil) {
            personFName = @"";
        }
        NSString *personLName = (__bridge_transfer NSString*)ABRecordCopyValue(self.card, kABPersonLastNameProperty);
        if (personLName == nil) {
            personLName = @"";
        }
        NSString *personMName = (__bridge_transfer NSString*)ABRecordCopyValue(self.card, kABPersonMiddleNameProperty);
        if (personMName == nil) {
            personMName = @"";
        }
        lblV.text = [NSString stringWithFormat:@"%@ %@ %@",personFName,personMName,personLName];
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
            actionSheet.tag = 0;
            [actionSheet showInView:self.tabBarController.view];
    }
}

@end
