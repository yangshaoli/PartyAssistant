//
//  MultiContactsPickerListViewController.m
//  PartyAssistant
//
//  Created by Wang Jun on 1/5/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "MultiContactsPickerListViewController.h"
#import "pinyin.h"
#import "AddressBookDataManager.h"
#import "ABContact.h"
#import "ABContactsHelper.h"
#import "SegmentManagingViewController.h"
#import "PartyAssistantAppDelegate.h"

#define SelectedIndicatorImageViewTag 10086

@implementation MultiContactsPickerListViewController
@synthesize contactorsArray,selectedContactorsArray,contactorsArrayRef,msgType,currentSelectedRowIndex,currentSelectedSectionIndex,contactListDelegate,managingViewController;
//wxz
@synthesize abData;
@synthesize contacts;
@synthesize filteredArray;
@synthesize contactNameArray;
@synthesize contactNameDic;
@synthesize sectionArray;
@synthesize sectionContactArray;
@synthesize searchBar;
@synthesize searchDC;

- (id)initWithParentViewController:(UIViewController *)aViewController {
    if (self = [super init]) {
        self.managingViewController = aViewController;
        self.title = @"所有联系人";
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

    //wxz
    CGRect viewFrame = self.tableView.frame;
    viewFrame.origin.y = 0.f;
    viewFrame.size.height = 416.f;
    self.tableView.frame = viewFrame;
    // Create a search bar
	self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 44.0f)];
	self.searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
	self.searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
	self.searchBar.keyboardType = UIKeyboardTypeDefault;
	self.searchBar.delegate = self;
	self.tableView.tableHeaderView = self.searchBar;
	// Create the search display controller
	self.searchDC = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
	self.searchDC.searchResultsDataSource = self;
	self.searchDC.searchResultsDelegate = self;	
    self.searchDC.delegate = self;
    self.searchDC.searchResultsTableView.sectionHeaderHeight = 0.0f;
	NSMutableArray *filterearray =  [[NSMutableArray alloc] init];
	self.filteredArray = filterearray;
	//[filterearray release];
    [self initData];
	NSMutableArray *namearray =  [[NSMutableArray alloc] init];
	self.contactNameArray = namearray;
	//[namearray release];
	NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
	self.contactNameDic = dic;
	//[dic release];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStyleDone target:self action:@selector(doneBtnAction)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStyleBordered target:self action:@selector(cancleBtnAction)];
    
    
    
    //    CFIndex nPeople = ABAddressBookGetPersonCount(addressBook);
    if (!msgType) {
        self.msgType = @"SMS";
    }
    //if (!selctedContactorsArray) {
    //self.selectedContactorsArray = [[NSMutableArray alloc] initWithCapacity:0];
    //}
    self.selectedContactorsArray = [contactListDelegate dataSourceForContactList:self];
    for (int i=0; i<[self.selectedContactorsArray count]; i++) {
        ClientObject *clientObj = [self.selectedContactorsArray objectAtIndex:i];
        if ([self.msgType isEqualToString:@"SMS"]) {
            [clientObj searchClientIDByPhone];
        }else{
            [clientObj searchClientIDByEmail];
        }
    }
    //去掉多余的section空白
    self.tableView.sectionHeaderHeight = 0.0f;
    self.tableView.sectionFooterHeight = 0.0f;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addressBookHasBeenUpdated) name:ADDRESSBOOK_UPDATED object:nil];
    
    isAddressBookDataNeedUpdate = YES;
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
    if (self.searchDC.isActive) {
        [self.searchDC.searchResultsTableView reloadData];
    } else {
       [self.tableView reloadData]; 
    }
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
//wxz
#pragma mark - Search Index  
-(BOOL)searchResult:(NSString *)contactName searchText:(NSString *)searchT{
	NSComparisonResult result = [contactName compare:searchT options:NSCaseInsensitiveSearch   range:NSMakeRange(0, searchT.length)];
	
    if (result == NSOrderedSame)
		return YES;
	else
		return NO;
}


-(void)initData{
	if (!isAddressBookDataNeedUpdate) {
        return;
    }
    
    self.abData = [[AddressBookDataManager sharedAddressBookDataManager] getContactListData];
    
    //self.contacts = contactorsArray; 
    if([self.abData count] <1)
	{
		[contactNameArray removeAllObjects];
		[contactNameDic removeAllObjects];
		for (int i = 0; i < 27; i++) [self.sectionArray replaceObjectAtIndex:i withObject:[NSMutableArray array]];
		return;
	}
    [contactNameArray removeAllObjects];
	[contactNameDic removeAllObjects];
    self.sectionArray = [[NSMutableArray alloc] initWithCapacity:27];
	self.sectionContactArray = [[NSMutableArray alloc] initWithCapacity:27];
    for (int i = 0; i < 27; i++) {
		[self.sectionArray addObject:[NSMutableArray array]];
		[self.sectionContactArray addObject:[NSMutableArray array]];
	}
    for(ABContact *contact in abData) {
		NSString *phone;
		//NSArray *phoneCount = [ContactData getPhoneNumberAndPhoneLabelArray:contact];
		//if([phoneCount count] > 0) {
		//			NSDictionary *PhoneDic = [phoneCount objectAtIndex:0];
		//			phone = [ContactData getPhoneNumberFromDic:PhoneDic];
		//		}
		//if([contact.contactName length] > 0)
		//			[contactNameArray addObject:contact.contactName];
		//		else
		//			[contactNameArray addObject:[NSString stringWithFormat:@" %@",phone]];
		
		//NSString *string = [contactNameArray objectAtIndex:i];
        //        NSLog(@"%@",contact.contactName);
		NSString *string = [contact.contactName length] > 0 ? contact.contactName : [NSString stringWithFormat:@"%@",phone];
        
		if([self searchResult:string searchText:@"曾"])
            sectionName = @"Z";
		else if([self searchResult:string searchText:@"解"])
			sectionName = @"X";
		else if([self searchResult:string searchText:@"仇"])
			sectionName = @"Q";
		else if([self searchResult:string searchText:@"朴"])
			sectionName = @"P";
		else if([self searchResult:string searchText:@"查"])
			sectionName = @"Z";
		else if([self searchResult:string searchText:@"能"])
			sectionName = @"N";
		else if([self searchResult:string searchText:@"乐"])
			sectionName = @"Y";
		else if([self searchResult:string searchText:@"单"])
			sectionName = @"S";
		else
            sectionName = [[NSString stringWithFormat:@"%c",pinyinFirstLetter([[string uppercaseString] characterAtIndex:0])] uppercaseString];
		NSUInteger firstLetter = [ALPHA rangeOfString:[sectionName substringToIndex:1]].location;
		if (firstLetter != NSNotFound) {
			[[self.sectionArray objectAtIndex:firstLetter] addObject:string];
			[[self.sectionContactArray objectAtIndex:firstLetter] addObject:contact];
            
		} 
	}
    
    isAddressBookDataNeedUpdate = NO;
}


- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)aTableView
{
    if (aTableView == self.tableView){
        NSMutableArray *indices = [NSMutableArray arrayWithObject:UITableViewIndexSearch];
		for (int i = 0; i < 27; i++) 
			if ([[self.sectionArray objectAtIndex:i] count])
				[indices addObject:[[ALPHA substringFromIndex:i] substringToIndex:1]];
		//[indices addObject:@"\ue057"]; // <-- using emoji
		return indices;    
    }else{
        return nil;
        
    }
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    NSArray *sectionData = [self.sectionArray objectAtIndex:section];
    if (!(tableView == self.tableView)) return 0.0f;
    if ([sectionData count] <= 0) {
        return 0.0;
        
    } else {
        
        return 25.0;    
        
    } 
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.0f;
}

//- (UIView *) tableView:(UITableView *)aTableView viewForHeaderInSection:(NSInteger)section 
//{
//    if(aTableView==self.tableView){
//        NSArray *sectionData = [self.sectionArray objectAtIndex:section];
//        if ([sectionData count] <= 0) {
//            return nil;
//        }
//        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 30, 2)];
//        //[headerView setBackgroundColor:[UIColor colorWithRed:0.227 green:0.12 blue:0.0 alpha:0.75]];
//        UILabel *headerTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, 120, 30)];
//        if (![[self.sectionArray objectAtIndex:section]  count]){
//            headerTitleLabel.text = nil;    
//           
//        } else{
//            
//            headerTitleLabel.text =[NSString stringWithFormat:@"%@", [[ALPHA substringFromIndex:section] substringToIndex:1]];   
//            headerTitleLabel.font = [UIFont systemFontOfSize:14];
//            headerTitleLabel.backgroundColor = [UIColor clearColor];
//            headerTitleLabel.textColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.75];
//            [headerView addSubview:headerTitleLabel];
//            
//            return headerView;
//        }   
//        
//        
//    }else{
//        return nil;
//    
//    }
//  
//}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
	if (title == UITableViewIndexSearch) 
	{
		[self.tableView scrollRectToVisible:self.searchBar.frame animated:NO];
		return -1;
	}
	return [ALPHA rangeOfString:title].location;
}



- (NSString *)tableView:(UITableView *)aTableView titleForHeaderInSection:(NSInteger)section
{
    if(aTableView==self.tableView){
        if ([[self.sectionArray objectAtIndex:section] count] == 0) return nil;
		return [NSString stringWithFormat:@"%@", [[ALPHA substringFromIndex:section] substringToIndex:1]];
        
    }else{
        return nil;
        
    }
    
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
	[self.searchBar setText:@""]; 
	self.searchBar.prompt = nil;
	[self.searchBar setFrame:CGRectMake(0.0f, 0.0f, 320.0f, 44.0f)];
	self.tableView.tableHeaderView = self.searchBar;	
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView
{
    // Return the number of sections.
    if (aTableView == self.tableView) {
        [self initData];
        return 27;    
    }else{
        return  1;
    }
    
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    if (aTableView == self.tableView) {
        return [[self.sectionArray objectAtIndex:section] count];
        
    }else{
        self.filteredArray = (NSMutableArray *)[ABContactsHelper contactsMatchingName:self.searchBar.text];
    }
    // Search table
    //	for(NSString *string in contactNameArray)
    //	{
    //        
    //		NSString *name = @"";
    //		for (int i = 0; i < [string length]; i++)
    //		{
    //			if([name length] < 1)
    //				name = [NSString stringWithFormat:@"%c",pinyinFirstLetter([string characterAtIndex:i])];
    //			else
    //				name = [NSString stringWithFormat:@"%@%c",name,pinyinFirstLetter([string characterAtIndex:i])];
    //		}
    //		if ([self searchResult:name searchText:self.searchBar.text]){
    //            [filteredArray addObject:string];
    //            NSLog(@"添加成功1");
    //        }else 
    //		{
    //			if ([self searchResult:string searchText:self.searchBar.text])
    //				[filteredArray addObject:string];
    //            NSLog(@"添加成功2");
    ////			else {
    ////				ABContact *contact = [ContactData byNameToGetContact:string];
    ////				NSArray *phoneArray = [ContactData getPhoneNumberAndPhoneLabelArray:contact];
    ////				NSString *phone = @"";
    ////				
    ////				if([phoneArray count] == 1)
    ////				{
    ////					NSDictionary *PhoneDic = [phoneArray objectAtIndex:0];
    ////					phone = [ContactData getPhoneNumberFromDic:PhoneDic];
    ////					if([ContactData searchResult:phone searchText:self.searchBar.text])
    ////						[filteredArray addObject:string];
    ////				}else  if([phoneArray count] > 1)
    ////				{
    ////					for(NSDictionary *dic in phoneArray)
    ////					{
    ////						phone = [ContactData getPhoneNumberFromDic:dic];
    ////						if([ContactData searchResult:phone searchText:self.searchBar.text])
    ////						{
    ////							[filteredArray addObject:string];	
    ////							break;
    ////						}
    ////					}
    ////				}
    ////				
    //			}
    //		
    //	}
	return self.filteredArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = nil;// [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    NSString *contactName;
    ABContact *aPeople;
    if(aTableView==self.tableView){
        contactName = [[self.sectionArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        aPeople = [[self.sectionContactArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    }else{
        contactName = [[self.filteredArray objectAtIndex:indexPath.row] contactName];
        aPeople = [self.filteredArray objectAtIndex:indexPath.row];    
    }
    
    cell.textLabel.text = [NSString stringWithCString:[contactName UTF8String] encoding:NSUTF8StringEncoding];
    
    
    // Configure the cell..
    //    CFArrayRef  sectionCards=CFArrayGetValues(self.contactorsArrayRef, <#CFRange range#>, nil);
    //   ABRecordRef card =CFArrayGetValueAtIndex(CFArrayGetValueAtIndex(self.contactorsArrayRef,indexPath.section),indexPath.row);
    
    ABRecordID recordID = [aPeople recordID];
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
    cell.tag = recordID;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    for (int i=0; i<[self.selectedContactorsArray count]; i++) {
        if ([[self.selectedContactorsArray objectAtIndex:i] cID] == recordID) {
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

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
    NSString *contactName;
    ABContact *aPeople;
    if(aTableView==self.tableView){
        contactName = [[self.sectionArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        aPeople = [[self.sectionContactArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    }else{
        contactName = [[self.filteredArray objectAtIndex:indexPath.row] contactName];
        aPeople = [self.filteredArray objectAtIndex:indexPath.row];    
    }
    
    ABRecordID recordID = [aPeople recordID];
    
    self.currentSelectedRowIndex = indexPath.row;
    self.currentSelectedSectionIndex = indexPath.section;

    ABAddressBookRef tempAddressBook = ABAddressBookCreate();
    ABRecordRef card = ABAddressBookGetPersonWithRecordID(tempAddressBook, recordID);
    if ([msgType isEqualToString:@"SMS"]) {
        ABMultiValueRef phone = ABRecordCopyValue(card, kABPersonPhoneProperty);
        if(ABMultiValueGetCount(phone) == 0){
            [self alertError:@"对不起，该联系人没有电话信息"];
        }else if(ABMultiValueGetCount(phone) == 1){
            ClientObject *client = [self loadSingleNumberContact : recordID];
            [self showOrCancleSelectedMark:client mutableMSGValue:nil];
            [aTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
        }else{
            if (ABMultiValueGetCount(phone) >= 1) {//wxz
                MultiContactsPhoneDetailViewController *contactorPhoneDetailsViewController = [[MultiContactsPhoneDetailViewController alloc] initWithNibName:@"MultiContactsPhoneDetailViewController" bundle:[NSBundle mainBundle]];
                ClientObject *selectedClientInfo = nil;
                for (ClientObject *client in self.selectedContactorsArray) {
                    if (recordID == client.cID) {
                        selectedClientInfo = client;
                        break;
                    }
                }
                contactorPhoneDetailsViewController.contactorID = recordID;
                if (selectedClientInfo) {
                    contactorPhoneDetailsViewController.clientObject = selectedClientInfo;
                }
                contactorPhoneDetailsViewController.phoneDetailDelegate = self;
                [self.managingViewController.navigationController pushViewController:contactorPhoneDetailsViewController animated:YES];
                
            }else{
                ClientObject *client = [self loadSingleNumberContact : recordID];
                [self showOrCancleSelectedMark:client mutableMSGValue:nil];
                [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
            }
            
        }
     }
    //else{
//        ABMultiValueRef email = ABRecordCopyValue(card, kABPersonEmailProperty);
//        if(ABMultiValueGetCount(email) == 0){
//            [self alertError:@"对不起，该联系人没有电子邮箱信息"];
//        }else if(ABMultiValueGetCount(email) == 1){
//            
//            [self showOrCancleSelectedMark:info mutableMSGValue:nil];
//            
//        }else{
//            BOOL _isAdd = YES;
//            NSArray *subArray = cell.subviews;
//            for (int i=0; i<[subArray count]; i++) {
//                if ([[subArray objectAtIndex:i] isMemberOfClass:[UIImageView class]]) {
//                    _isAdd = NO;
//                    break;
//                }
//            }
//            if (ABMultiValueGetCount(email) >= 1) {//wxz
//                //                [self alertError:@"该联系人有多条邮箱信息，请选择其中一条"];
//                //                NSLog(@"看看是否调用");
//                if(cell.accessoryType==UITableViewCellAccessoryCheckmark){
//                    cell.accessoryType=UITableViewCellAccessoryNone;
//                    
//                }
//                
//                if(cell.accessoryType==UITableViewCellAccessoryNone){
//                    self.currentSelectedRowIndex = indexPath.row;
//                    self.currentSelectedSectionIndex = indexPath.section;
//                    ContactorEmailDetailsViewController *contactorEmailDetailsViewController = [[ContactorEmailDetailsViewController alloc] initWithNibName:@"ContactorEmailDetailsViewController" bundle:[NSBundle mainBundle]];
//                    contactorEmailDetailsViewController.contactorID = recordID;
//                    contactorEmailDetailsViewController.EmailDetailDelegate = self;
//                    [self.navigationController pushViewController:contactorEmailDetailsViewController animated:YES];
//                    
//                }
//                
//                
//                
//            }else{
//                UITableViewCell *info = [cell copy];
//                [self showOrCancleSelectedMark:info mutableMSGValue:nil];
//            }       
//        }
//    }
    
}

#pragma mark - 
#pragma mark search DC delegate
- (void) searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller {
    [self.tableView reloadData];
}

- (void)alertError:(NSString *)errorStr{
    UIAlertView *alertV = [[UIAlertView alloc] initWithTitle:@"出错了！" message:errorStr delegate:self cancelButtonTitle:@"好的" otherButtonTitles:nil];
    [alertV show];
}

- (void)showOrCancleSelectedMark:(ClientObject *)client mutableMSGValue:(id)msgVal{
    
    BOOL _isAdd = YES;
    //if this contact selected, remove.
    
    ClientObject *selectedClientInfo = nil;
    for (ClientObject *aClient in self.selectedContactorsArray) {
        if (aClient.cID == client.cID) {
            selectedClientInfo = aClient;
            break;
        }
    }
    NSLog(@"newphoneIdentifier : %d",client.phoneIdentifier);
    if (selectedClientInfo) {
        if (msgVal) {
            NSLog(@"client.phoneIdentifier : %d selectedClientInfo.phoneIdentifier : %d",client.phoneIdentifier,selectedClientInfo.phoneIdentifier);
            NSLog(@"%@",client.phoneIdentifier == selectedClientInfo.phoneIdentifier ? @"YES" : @"NO");
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
        //ABContact *selectedContact;
//        if(aTableView==self.tableView){
//           // selectedContact = [[self.sectionContactArray objectAtIndex:self.currentSelectedSectionIndex] objectAtIndex:self.currentSelectedRowIndex];
//        }else{
//            //selectedContact = [self.filteredArray objectAtIndex:self.currentSelectedRowIndex];    
//        }
        
        if ([msgType isEqualToString:@"SMS"]) {
            if (selectedClientInfo) {
                
            }
            [self.selectedContactorsArray addObject:client];
//            NSArray *phoneBook = [selectedContact phoneArray];
//            if (msgVal == nil) {
//                //[self addInfoToArray:cell.tag uname:cell.textLabel.text value:[phoneBook objectAtIndex:0]];
//            }else{
//                //[self addInfoToArray:cell.tag uname:cell.textLabel.text value:msgVal];
//            }
        }
//        else{
//            NSArray *emailBook = [selectedContact emailArray];
//            if (msgVal == nil) {
//                [self addInfoToArray:cell.tag uname:cell.textLabel.text value:[emailBook objectAtIndex:0]];
//            }else{
//                [self addInfoToArray:cell.tag uname:cell.textLabel.text value:msgVal];
//            }
//        }
    }
}

- (void)doneBtnAction{
//    NSDictionary *userinfo = [NSDictionary dictionaryWithObjectsAndKeys:self.selectedContactorsArray,@"selectedCArray", nil];
    //NSNotification *notification = [NSNotification notificationWithName:SELECT_RECEIVER_IN_SEND_SMS object:nil userInfo:userinfo];
    //[[NSNotificationCenter defaultCenter] postNotification:notification];
    //[contactListDelegate reorganizeReceiverField:userinfo];
    [self dismissModalViewControllerAnimated:YES];
}

- (void)cancleBtnAction{
    [self dismissModalViewControllerAnimated:YES];
}

//- (void)selectContactor:(NSNotification *)notification{
//    NSInteger row = self.currentSelectedRowIndex;
//    NSInteger section = self.currentSelectedSectionIndex;
//    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
//    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
//    UITableViewCell *info = [cell copy];
//    [self showOrCancleSelectedMark:info mutableMSGValue:[[notification userInfo]objectForKey:@"val"]];
//}

- (void)contactDetailSelectedWithUserInfo:(ClientObject *)info{
    NSInteger row = self.currentSelectedRowIndex;
    NSInteger section = self.currentSelectedSectionIndex;

    [self showOrCancleSelectedMark:info mutableMSGValue:info.cVal];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
    if (self.searchDC.isActive) {
        [self.searchDC.searchResultsTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
    } else {
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
}

- (void)addInfoToArray:(NSInteger)cID uname:(NSString *)name value:(NSString *)val
{
    ClientObject *client = [[ClientObject alloc] init];
    client.cID = cID;
    client.cName = name;
    client.cVal = val;
    [self.selectedContactorsArray addObject:client];
}

- (void)selectedContactorsArray:(NSInteger)cID
{
    for (int i=0; i<[self.selectedContactorsArray count]; i++) {
        if ([[self.selectedContactorsArray objectAtIndex:i] cID] == cID) {
            [self.selectedContactorsArray removeObjectAtIndex:i];
            break;
        }
        
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

- (ClientObject *)loadSingleNumberContact : (ABRecordID)recordID {
    ABAddressBookRef tempAddressBook = ABAddressBookCreate();
    ABRecordRef card = ABAddressBookGetPersonWithRecordID(tempAddressBook, recordID);
    
    ClientObject *newClient = [[ClientObject alloc] init];
    
    newClient.cName = (__bridge NSString *)ABRecordCopyCompositeName(card);
    
    ABMultiValueRef phone = ABRecordCopyValue(card, kABPersonPhoneProperty);
    newClient.phoneIdentifier = ABMultiValueGetIdentifierAtIndex(phone, 0);
    newClient.phoneLabel = (__bridge_transfer NSString*)ABMultiValueCopyLabelAtIndex(phone, 0);
    newClient.cVal =  (__bridge_transfer NSString*)ABMultiValueCopyValueAtIndex(phone, 0);
    
    newClient.cID = recordID;
    
    CFRelease(tempAddressBook);
    
    return newClient;
}

- (void)addressBookHasBeenUpdated {
    isAddressBookDataNeedUpdate = YES;
}
@end
