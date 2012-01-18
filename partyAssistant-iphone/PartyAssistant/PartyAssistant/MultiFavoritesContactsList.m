//
//  MultiFavoritesContactsList.m
//  PartyAssistant
//
//  Created by Wang Jun on 1/7/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "MultiFavoritesContactsList.h"
#import "AddressBookDBService.h"
#import "ABContact.h"
#import "ClientObject.h"

@implementation MultiFavoritesContactsList
@synthesize managingViewController,dataSource;
@synthesize contactListDelegate;
@synthesize selectedContactorsArray;
@synthesize currentSelectedRowIndex;

- (id)initWithParentViewController:(UIViewController *)aViewController {
    if (self = [super init]) {
        self.managingViewController = aViewController;
        self.title = @"常用联系人";
    }
    return self;
}

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
    
    CGRect viewFrame = self.tableView.frame;
    viewFrame.origin.y = 0.f;
    self.tableView.frame = viewFrame;
    self.selectedContactorsArray = [contactListDelegate dataSourceForContactList:self];

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
    [self.tableView reloadData];
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
    [self initDataSource];
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.dataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"LabelCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    //    NSString *personFName = (__bridge_transfer NSString*)ABRecordCopyValue(card, kABPersonFirstNameProperty);
    //    if (personFName == nil) {
    //        personFName = @"";
    //    }
    //    NSString *personLName = (__bridge_transfer NSString*)ABRecordCopyValue(card, kABPersonLastNameProperty);
    //    if (personLName == nil) {
    //        personLName = @"";
    //    }
    //    NSString *personMName = (__bridge_transfer NSString*)ABRecordCopyValue(card, kABPersonMiddleNameProperty);
    //    if (personMName == nil) {
    //        personMName = @"";
    //    }
    //    
    //    //[self.contactNameArray  addObject:personLName];
    //    NSString  *cellString=[NSString stringWithFormat:@"%@ %@ %@",personLName,personMName,personFName];
    //   
    //cell.textLabel.text = cellString;
    // cell.textLabel.text = [[self.sectionArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    // NSLog(@"cell应该调用");
    //NSLog(@"每行cell.textLabel.text:......%@",cell.textLabel.text);
    ClientObject *client = [self.dataSource objectAtIndex:indexPath.row];
    cell.textLabel.text = client.cName;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@: %@", client.phoneLabel, client.cVal];
    
    ABRecordID recordID = [client cID];
    NSInteger phoneIdentifier = [client phoneIdentifier];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    for (int i=0; i<[self.selectedContactorsArray count]; i++) {
        NSLog(@"selected contact ID:%d",[[self.selectedContactorsArray objectAtIndex:i] cID]);
        if ([[self.selectedContactorsArray objectAtIndex:i] cID] == recordID && [[self.selectedContactorsArray objectAtIndex:i] phoneIdentifier] == phoneIdentifier) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
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
    ClientObject *client = [self.dataSource objectAtIndex:indexPath.row];
    self.currentSelectedRowIndex = indexPath.row;
    [self showOrCancleSelectedMark:client mutableMSGValue:nil];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:self.currentSelectedRowIndex inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
//    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
}


- (void)initDataSource {
    [[AddressBookDBService sharedAddressBookDBService] loadMyFavorites];
    self.dataSource = [[AddressBookDBService sharedAddressBookDBService] myFavorites];
}

- (void)showOrCancleSelectedMark:(ClientObject *)client mutableMSGValue:(id)msgVal{
    
    BOOL _isAdd = YES;
        
    ClientObject *selectedClientInfo = nil;
    for (ClientObject *aClient in self.selectedContactorsArray) {
        if (aClient.cID == client.cID) {
            selectedClientInfo = aClient;
            break;
        }
    }
    
    if (selectedClientInfo) {
        if (msgVal) {
            if (client.phoneIdentifier == selectedClientInfo.phoneIdentifier) {
                if ([(NSString *)msgVal isEqualToString:client.cVal] && ![client.cVal isEqualToString:@""]) {
                    _isAdd = NO;
                    [self removeInfoFromArray:selectedClientInfo.cID];
                }
            } else {
                [self removeInfoFromArray:selectedClientInfo.cID];
            }
        } else {
            _isAdd = NO;
            [self removeInfoFromArray:client.cID];
        }
    }
    if (_isAdd) {
        [self.selectedContactorsArray addObject:client];
    }
}

- (void)removeInfoFromArray:(NSInteger)cID
{
    ClientObject *clientObject = nil;
    for (int i=0; i<[self.selectedContactorsArray count]; i++) {
        if ([[self.selectedContactorsArray objectAtIndex:i] cID] == cID) {
            clientObject = [self.selectedContactorsArray objectAtIndex:i];
            break;
        }
        
    }
    if (clientObject) {
        [self.selectedContactorsArray removeObject:clientObject];
    }
}
@end
