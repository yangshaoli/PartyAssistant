//
//  MultiContactsPhoneDetailViewController.m
//  PartyAssistant
//
//  Created by Wang Jun on 1/5/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "MultiContactsPhoneDetailViewController.h"
#import "ContactorPhoneDetailsViewController.h"
#import "ClientObject.h"

@implementation MultiContactsPhoneDetailViewController
@synthesize contactorID,phone,card;
@synthesize phoneDetailDelegate;
@synthesize clientObject;
@synthesize selectedIndex;
@synthesize name;

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
    selectedIndex = -1;
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    ABAddressBookRef addressBook = ABAddressBookCreate();
    if(!card){
        self.card = ABAddressBookGetPersonWithRecordID(addressBook, self.contactorID);
        self.name = (__bridge NSString *)ABRecordCopyCompositeName(self.card);
    }
    if (!phone) {
        self.phone = ABRecordCopyValue(card, kABPersonPhoneProperty);
    }
    int num = ABMultiValueGetCount(self.phone);
    return num;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    NSString *typeStr = (__bridge_transfer NSString*)ABAddressBookCopyLocalizedLabel(ABMultiValueCopyLabelAtIndex(self.phone, indexPath.row));
    NSString *valStr = (__bridge_transfer NSString*)ABMultiValueCopyValueAtIndex(self.phone, indexPath.row);
    ABMultiValueIdentifier indentifier = ABMultiValueGetIdentifierAtIndex(self.phone, indexPath.row);
    if (self.clientObject) {
        if (self.selectedIndex == -1) {
            if (indentifier == self.clientObject.phoneIdentifier) {
                self.selectedIndex = indexPath.row;
            }
        }
    }
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
    
    if (self.selectedIndex >= 0) {
        if (selectedIndex == indexPath.row) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        
    }
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headV = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 85.0f)];
    
    UIImage *img = nil;
    
    if (ABPersonHasImageData(self.card)) {
        NSData *imgData = (__bridge_transfer NSData*)ABPersonCopyImageData(self.card);
        
        UIGraphicsBeginImageContext(CGSizeMake(62.0f, 62.0f));
        [[UIImage imageWithData:imgData] drawInRect:CGRectMake(0.f, 0.f, 62.f, 62.f)];
        img = UIGraphicsGetImageFromCurrentImageContext();
    }
        
    UIImageView *imgV = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 62, 62)];
    if (img) {
        [imgV setImage:img];
    } else {
        img = [UIImage imageNamed:@"contact_with_no-pic.png"];
        [imgV setImage:img];
    }
    
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
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 85.0f;
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
    
    NSString *valStr = (__bridge_transfer NSString*)ABMultiValueCopyValueAtIndex(self.phone, indexPath.row);
    
    ClientObject *newClient = [[ClientObject alloc] init];
    newClient.cID = contactorID;
    newClient.cName = self.name;
    newClient.cVal = valStr;
    newClient.phoneIdentifier = ABMultiValueGetIdentifierAtIndex(self.phone, indexPath.row);
    NSLog(@"%d",ABMultiValueGetIdentifierAtIndex(self.phone, indexPath.row));
    newClient.phoneLabel = (__bridge_transfer NSString*)ABMultiValueCopyLabelAtIndex(self.phone, indexPath.row);
    
    [phoneDetailDelegate contactDetailSelectedWithUserInfo:newClient];
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end

