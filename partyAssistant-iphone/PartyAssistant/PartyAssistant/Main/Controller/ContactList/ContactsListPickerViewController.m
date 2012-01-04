#define ALPHA	@"ABCDEFGHIJKLMNOPQRSTUVWXYZ#"
#define BARBUTTON(TITLE, SELECTOR)		[[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR] autorelease]//UIBarButtonItem

#import "ContactsListPickerViewController.h"
#import "ContactData.h"
#import "AddressBookDataManager.h"
#import "pinyin.h"

@interface ContactsListPickerViewController(privavteCLVC)
- (void)initData;
@end

@implementation ContactsListPickerViewController
@synthesize abData;
@synthesize filteredArray;
@synthesize contactNameArray;
@synthesize contactNameDic;
@synthesize searchContactNameDic;
@synthesize sectionArray;
@synthesize sectionContactArray;
@synthesize searchBar;
@synthesize searchDC;
@synthesize contactDelegate;

- (id)initWithRecordRef:(ABRecordRef)aRecord {
	if (self = [super init]) {
        record = CFRetain(aRecord);
	}
	return self;
}
// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

- (id)init {
    self = [super init];
    if (self) {
        // Custom initialization.;
        self.navigationItem.prompt = @"Choose a contact to text message";
        self.navigationItem.title = @"All Contacts";
	}
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
 
	self.searchBar = [[[UISearchBar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, [[UIScreen mainScreen] bounds].size.width, 44.0f)] autorelease];
	self.searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
	self.searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
	self.searchBar.keyboardType = UIKeyboardTypeDefault;
	self.searchBar.delegate = self;
	self.tableView.tableHeaderView = self.searchBar;
	
	// Create the search display controller
	self.searchDC = [[[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self] autorelease];
	self.searchDC.searchResultsDataSource = self;
	self.searchDC.searchResultsDelegate = self;
	self.searchDC.delegate = self;
	
	NSMutableArray *filterearray =  [[NSMutableArray alloc] init];
	self.filteredArray = filterearray;
	[filterearray release];
	
	NSMutableArray *namearray =  [[NSMutableArray alloc] init];
	self.contactNameArray = namearray;
	[namearray release];
	
	NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
	self.contactNameDic = dic;
	[dic release];	
	
	searchContactNameDic = [[NSMutableDictionary alloc] initWithCapacity:10];
	
    UIBarButtonItem *refreshButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshBtn:)];
	self.navigationItem.leftBarButtonItem = refreshButtonItem;
    
    UIBarButtonItem *cancleButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelBtn:)];
	self.navigationItem.rightBarButtonItem = cancleButtonItem;
	[cancleButtonItem release];	

}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:YES];
	if (self.searchDC.active) {
		[self.searchDC.searchResultsTableView reloadData];
	} else {
		[self.tableView reloadData];
	}
}

- (void)initData {
    if (!record) {
		self.abData = [[AddressBookDataManager sharedAddressBookDataManager] getContactListData];
	} else {
		self.abData = [ContactData contactsArrayByRecordRef:record];
	}
		
	if([abData count] <1) {
		[contactNameArray removeAllObjects];
		[contactNameDic removeAllObjects];
		for (int i = 0; i < 27; i++) [self.sectionArray replaceObjectAtIndex:i withObject:[NSMutableArray array]];
		return;
	}
	[contactNameArray removeAllObjects];
	[contactNameDic removeAllObjects];
	
	
	self.sectionArray = [[[NSMutableArray alloc] initWithCapacity:27] autorelease];
	self.sectionContactArray = [[[NSMutableArray alloc] initWithCapacity:27] autorelease];
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
		
		//NSString *string = [contactNameArray objectAtIndex:i]
        NSLog(@"%@",contact.contactName);;
		NSString *string = [contact.contactName length] > 0 ? contact.contactName : [NSString stringWithFormat:@" %@",phone];
		sectionName = [[NSString stringWithFormat:@"%c",pinyinFirstLetter([[string uppercaseString] characterAtIndex:0])] uppercaseString];
		//[self.contactNameDic setObject:[string substringFromIndex:2] forKey:sectionName];
		NSUInteger firstLetter = [ALPHA rangeOfString:[sectionName substringToIndex:1]].location;
		if (firstLetter != NSNotFound) {
			[[self.sectionArray objectAtIndex:firstLetter] addObject:string];
			[[self.sectionContactArray objectAtIndex:firstLetter] addObject:contact];
		} 
		
	}
	
	
	//for (int i=0; i<[contactNameArray count]; i++) {
	//		NSString *string = [contactNameArray objectAtIndex:i];
	//		sectionName = [[NSString stringWithFormat:@"%c",stringFirstLetter([[string uppercaseString] characterAtIndex:0])] uppercaseString];
	//		[self.contactNameDic setObject:[string substringFromIndex:2] forKey:sectionName];
	//		NSUInteger firstLetter = [ALPHA rangeOfString:[sectionName substringToIndex:1]].location;
	//		if (firstLetter != NSNotFound) {
	//			[[self.sectionArray objectAtIndex:firstLetter] addObject:string];
	//			[[self.sectionContactArray objectAtIndex:firstLetter] addObject:[abData objectAtIndex:i]];
	//		} 
	//	}
	
	[searchContactNameDic removeAllObjects];
	/*
	 for(ABContact * contact in abData) {
	 [searchContactNameDic setValue:contact forKey:contact.contactName]; 
	 }
	 */
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    
    [super dealloc];
}

#pragma mark -
#pragma mark Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView {
    // Return the number of sections.
    if(aTableView == self.tableView) {
		[self initData];
		return 27;
	} 
	return 1; 
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	if (tableView == self.tableView) return [[self.sectionArray objectAtIndex:section] count];
	else {
		//[filteredArray removeAllObjects];
        self.filteredArray = (NSMutableArray *)[ABContactsHelper contactsMatchingName:self.searchBar.text];
	}
	return [self.filteredArray count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = nil;
	UITableViewCellStyle style =  UITableViewCellStyleSubtitle;
	cell = [aTableView dequeueReusableCellWithIdentifier:@"ContactCell"];
	if (!cell) cell = [[[UITableViewCell alloc] initWithStyle:style reuseIdentifier:@"ContactCell"] autorelease];
	NSString *contactName;
	ABContact *theContact;
	// Retrieve the crayon and its color
	if (aTableView == self.tableView) {
		contactName = [[self.sectionArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
		theContact = [[self.sectionContactArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
	}
	else {
		contactName = [[self.filteredArray objectAtIndex:indexPath.row] contactName];
		theContact = [self.filteredArray objectAtIndex:indexPath.row];
	}
	
	cell.textLabel.text = contactName;
	
	return cell;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)aTableView 
{
	if (aTableView == self.tableView)  // regular table
	{
		NSMutableArray *indices = [NSMutableArray arrayWithObject:UITableViewIndexSearch];
		for (int i = 0; i < 27; i++) 
			if ([[self.sectionArray objectAtIndex:i] count])
				[indices addObject:[[ALPHA substringFromIndex:i] substringToIndex:1]];
		return indices;
	} else {
		return nil; // search table
	} 		
}
	
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

	if (aTableView == self.tableView) 
	{
		if ([[self.sectionArray objectAtIndex:section] count] == 0) return nil;
		return [NSString stringWithFormat:@"%@", [[ALPHA substringFromIndex:section] substringToIndex:1]];
	}
	else return nil;
}
	
#pragma mark -
#pragma mark table view delegate
- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ABPersonViewController *pvc = [[ABPersonViewController alloc] init];
	ABContact *contact = [[self.sectionContactArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
	pvc.displayedPerson = contact.record;
    pvc.displayedProperties = [NSArray arrayWithObject:[NSNumber numberWithInt:kABPersonPhoneProperty]];
	pvc.personViewDelegate = self;
    pvc.navigationItem.prompt = @"Choose a contact to text message";
	[[self navigationController] pushViewController:pvc animated:YES];    
    [pvc release];
}

#pragma mark -
#pragma mark UISearchDisplayDelegate
- (void) searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller {
	[self.tableView reloadData];
}

#pragma mark NEW PERSON DELEGATE METHODS
- (BOOL)personViewController:(ABPersonViewController *)personViewController shouldPerformDefaultActionForPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier {
	ABRecordID personID =  ABRecordGetRecordID(person);
    [contactDelegate contactList:self selectDefaultActionForPerson:personID property:property identifier:identifier];
	return NO;
}
#pragma mark button custom method 
- (void)cancelBtn:(id)sender {
    NSLog(@"cancel button pressed!");
    [contactDelegate contactList:self cancelAction:YES];
}

- (void)refreshBtn:(id)sender {
    NSLog(@"refresh button pressed!");
    [self.tableView reloadData];
}
@end
