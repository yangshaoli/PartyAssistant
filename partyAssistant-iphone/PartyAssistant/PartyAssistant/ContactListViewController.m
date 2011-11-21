//
//  ContactListViewController.m
//  PartyAssistant
//
//  Created by 超 李 on 11-10-31.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "ContactListViewController.h"

@implementation ContactListViewController
@synthesize contactorsArray,selectedContactorsArray,contactorsArrayRef,msgType,currentSelectedRowIndex,contactListDelegate;

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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectContactor:) name:SELECT_CONTACT_MANNER object:nil];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStyleDone target:self action:@selector(doneBtnAction)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStyleBordered target:self action:@selector(cancleBtnAction)];
    ABAddressBookRef addressBook = ABAddressBookCreate();
    self.contactorsArrayRef = ABAddressBookCopyArrayOfAllPeopleInSourceWithSortOrdering(addressBook,nil,1);
//    CFIndex nPeople = ABAddressBookGetPersonCount(addressBook);
    if (!msgType) {
        self.msgType = @"SMS";
    }
    //if (!selctedContactorsArray) {
        //self.selectedContactorsArray = [[NSMutableArray alloc] initWithCapacity:0];
    //}
    for (int i=0; i<[self.selectedContactorsArray count]; i++) {
        ClientObject *clientObj = [self.selectedContactorsArray objectAtIndex:i];
        if ([self.msgType isEqualToString:@"SMS"]) {
            [clientObj searchClientIDByPhone];
        }else{
            [clientObj searchClientIDByEmail];
        }
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return CFArrayGetCount(self.contactorsArrayRef);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = nil;// [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    ABRecordRef card = CFArrayGetValueAtIndex(self.contactorsArrayRef, indexPath.row);
    ABRecordID recordID = ABRecordGetRecordID(card);
    NSString *personFName = (__bridge_transfer NSString*)ABRecordCopyValue(card, kABPersonFirstNameProperty);
    if (personFName == nil) {
        personFName = @"";
    }
    NSString *personLName = (__bridge_transfer NSString*)ABRecordCopyValue(card, kABPersonLastNameProperty);
    if (personLName == nil) {
        personLName = @"";
    }
    NSString *personMName = (__bridge_transfer NSString*)ABRecordCopyValue(card, kABPersonMiddleNameProperty);
    if (personMName == nil) {
        personMName = @"";
    }
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@ %@",personLName,personMName,personFName];
    cell.tag = recordID;
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    for (int i=0; i<[self.selectedContactorsArray count]; i++) {
        if ([[self.selectedContactorsArray objectAtIndex:i] cID] == recordID) {
            UIImageView *imgV = [[UIImageView alloc] initWithFrame:CGRectMake(280, 7, 30, 30)];
            imgV.backgroundColor = [UIColor redColor];
            [cell addSubview:imgV];
            break;
        }
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
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    ABRecordID recordID = cell.tag;
    ABAddressBookRef addressBook = ABAddressBookCreate();
    
    ABRecordRef card = ABAddressBookGetPersonWithRecordID(addressBook, recordID);
    if ([msgType isEqualToString:@"SMS"]) {
        ABMultiValueRef phone = ABRecordCopyValue(card, kABPersonPhoneProperty);
        if(ABMultiValueGetCount(phone) == 0){
            [self alertError:@"对不起，该联系人没有电话信息"];
        }else if(ABMultiValueGetCount(phone) == 1){
            [self showOrCancleSelectedMark:cell mutableMSGValue:nil];
        }else{
            BOOL _isAdd = YES;
            NSArray *subArray = cell.subviews;
            for (int i=0; i<[subArray count]; i++) {
                if ([[subArray objectAtIndex:i] isMemberOfClass:[UIImageView class]]) {
                    _isAdd = NO;
                    break;
                }
            }
            if (_isAdd) {
                self.currentSelectedRowIndex = indexPath.row;
                ContactorPhoneDetailsViewController *contactorPhoneDetailsViewController = [[ContactorPhoneDetailsViewController alloc] initWithNibName:@"ContactorPhoneDetailsViewController" bundle:[NSBundle mainBundle]];
                contactorPhoneDetailsViewController.contactorID = recordID;
                [self.navigationController pushViewController:contactorPhoneDetailsViewController animated:YES];
            }else{
                [self showOrCancleSelectedMark:cell mutableMSGValue:nil];
            }
        }
    }else{
        ABMultiValueRef email = ABRecordCopyValue(card, kABPersonEmailProperty);
        if(ABMultiValueGetCount(email) == 0){
            [self alertError:@"对不起，该联系人没有电话信息"];
        }else if(ABMultiValueGetCount(email) == 1){
            [self showOrCancleSelectedMark:cell mutableMSGValue:nil];
        }else{
            ContactorEmailDetailsViewController *contactorEmailDetailsViewController = [[ContactorEmailDetailsViewController alloc] initWithNibName:@"ContactorEmailDetailsViewController" bundle:[NSBundle mainBundle]];
            contactorEmailDetailsViewController.contactorID = recordID;
            [self.navigationController pushViewController:contactorEmailDetailsViewController animated:YES];
        }
    }
    
}

- (void)alertError:(NSString *)errorStr{
    UIAlertView *alertV = [[UIAlertView alloc] initWithTitle:@"出错了！" message:errorStr delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [alertV show];
}

- (void)showOrCancleSelectedMark:(UITableViewCell *)cell mutableMSGValue:(id)msgVal{
    NSArray *subArray = cell.subviews;
    BOOL _isAdd = YES;
    for (int i=0; i<[subArray count]; i++) {
        if ([[subArray objectAtIndex:i] isMemberOfClass:[UIImageView class]]) {
            [[subArray objectAtIndex:i] removeFromSuperview];
            _isAdd = NO;
            [self removeInfoFromArray:cell.tag];
            break;
        }
    }
    if (_isAdd) {
        UIImageView *imgV = [[UIImageView alloc] initWithFrame:CGRectMake(280, 7, 30, 30)];
        imgV.backgroundColor = [UIColor redColor];
        [cell addSubview:imgV];
        ABRecordID recordID = cell.tag;
        ABAddressBookRef addressBook = ABAddressBookCreate();
        
        ABRecordRef card = ABAddressBookGetPersonWithRecordID(addressBook, recordID);
        if ([msgType isEqualToString:@"SMS"]) {
            ABMultiValueRef phone = ABRecordCopyValue(card, kABPersonPhoneProperty);
            if (msgVal == nil) {
                [self addInfoToArray:cell.tag uname:cell.textLabel.text value:(__bridge_transfer NSString*)ABMultiValueCopyValueAtIndex(phone, 0)];
            }else{
                [self addInfoToArray:cell.tag uname:cell.textLabel.text value:msgVal];
            }
        }else{
            ABMultiValueRef email = ABRecordCopyValue(card, kABPersonEmailProperty);
            if (msgVal == nil) {
                [self addInfoToArray:cell.tag uname:cell.textLabel.text value:(__bridge_transfer NSString*)ABMultiValueCopyValueAtIndex(email, 0)];
            }else{
                [self addInfoToArray:cell.tag uname:cell.textLabel.text value:msgVal];
            }
        }
    }
    //[cell.imageView setFrame:CGRectMake(250, 7, 30, 30)];
    //cell.imageView.backgroundColor = [UIColor redColor];
}

- (void)doneBtnAction{
    NSDictionary *userinfo = [NSDictionary dictionaryWithObjectsAndKeys:self.selectedContactorsArray,@"selectedCArray", nil];
    //NSNotification *notification = [NSNotification notificationWithName:SELECT_RECEIVER_IN_SEND_SMS object:nil userInfo:userinfo];
    //[[NSNotificationCenter defaultCenter] postNotification:notification];
    [contactListDelegate reorganizeReceiverField:userinfo];
    [self dismissModalViewControllerAnimated:YES];
}

- (void)cancleBtnAction{
    [self dismissModalViewControllerAnimated:YES];
}

- (void)selectContactor:(NSNotification *)notification{
    NSInteger row = self.currentSelectedRowIndex;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    [self showOrCancleSelectedMark:cell mutableMSGValue:[[notification userInfo] objectForKey:@"val"]];
}

- (void)addInfoToArray:(NSInteger)cID uname:(NSString *)name value:(NSString *)val
{
    ClientObject *client = [[ClientObject alloc] init];
    client.cID = cID;
    client.cName = name;
    client.cVal = val;
    [self.selectedContactorsArray addObject:client];
}

- (void)removeInfoFromArray:(NSInteger)cID
{
    for (int i=0; i<[self.selectedContactorsArray count]; i++) {
        if ([[self.selectedContactorsArray objectAtIndex:i] cID] == cID) {
            [self.selectedContactorsArray removeObjectAtIndex:i];
            break;
        }
        
    }
}
@end
