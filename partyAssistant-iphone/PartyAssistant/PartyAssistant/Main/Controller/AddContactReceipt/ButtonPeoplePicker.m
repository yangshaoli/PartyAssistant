/*
 * Copyright 2011 Marco Abundo
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "ButtonPeoplePicker.h"
#import "PeoplePickerCustomCell.h"
#import "ClientObject.h"
#import "MultiContactsPickerListViewController.h"

@interface ButtonPeoplePicker () // Class extension
@property (nonatomic, strong) NSMutableArray *filteredPeople;
- (void)layoutNameButtons;
- (void)addPersonToGroup:(ClientObject *)oneClient;
- (void)removePersonFromGroup:(NSDictionary *)personDictionary;
- (NSString *)getCleanPhoneNumber:(NSString *)rawPhoneNumber;
- (NSString *)getCleanLetter:(NSString *)originalString;
- (void)filterContentForSearchText:(NSString*)searchText;
@end


@implementation ButtonPeoplePicker

@synthesize delegate;
@synthesize people;
@synthesize group;
@synthesize addReceiptBGView;
@synthesize addReceiptButton;
@synthesize filteredPeople;
@synthesize deleteLabel;
@synthesize buttonView;
@synthesize uiTableView;
@synthesize searchField;
@synthesize doneButton;
@synthesize toolbar;
@synthesize footerView;
#pragma mark - View lifecycle methods

// Perform additional initialization after the nib file is loaded
- (void)viewDidLoad 
{
    [super viewDidLoad];
	
    addressBook = ABAddressBookCreate();
    
	self.people = (__bridge_transfer NSArray *)ABAddressBookCopyArrayOfAllPeople(addressBook);
    
    ABAddressBookRegisterExternalChangeCallback(addressBook, pickerAddressBookChanged,  (__bridge void*)self);
    
    self.group = [[NSMutableArray alloc] init];
	
	// Create a filtered list that will contain people for the search results table.
	self.filteredPeople = [[NSMutableArray alloc] init];
	
	// Add a "textFieldDidChange" notification method to the text field control.
	[searchField addTarget:self action:@selector(textFieldDidChange) forControlEvents:UIControlEventEditingChanged];
	[searchField setDelegate:self];
    
    UIColor * highColor = [UIColor colorWithWhite:1.000 alpha:1.000];  
    UIColor * lowColor = [UIColor colorWithRed:0.851 green:0.859 blue:0.867 alpha:1.000];  
    //    //The gradient, simply enough.  It is a rectangle  
    CAGradientLayer * gradient = [CAGradientLayer layer];  
    [gradient setFrame:CGRectMake(0, 0, self.uiTableView.frame.size.width, 200)];  
    [gradient setColors:[NSArray arrayWithObjects:(__bridge id)[highColor CGColor], (__bridge id)[lowColor CGColor], nil]]; 
    
    CGRect gradientShadowFrame = gradient.frame;
	gradientShadowFrame.size.width = self.uiTableView.frame.size.width;
	gradient.frame = gradientShadowFrame;
    
    CAGradientLayer *newShadow = [[CAGradientLayer alloc] init];
	CGRect newShadowFrame =
    CGRectMake(0, 0, self.uiTableView.frame.size.width,20);
    newShadow.frame = newShadowFrame;
	CGColorRef darkColor =
    [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.3].CGColor;
	CGColorRef lightColor =
    [[UIColor whiteColor] colorWithAlphaComponent:0.0].CGColor;
	newShadow.colors =
    [NSArray arrayWithObjects:
     (__bridge id)(darkColor),
     (__bridge id)(lightColor),
     nil];
    
    
    self.uiTableView.backgroundView = [[UIView alloc] initWithFrame:self.uiTableView.backgroundView.bounds];
    [self.uiTableView.backgroundView.layer insertSublayer:gradient atIndex:0];
    [self.uiTableView.backgroundView.layer insertSublayer:newShadow atIndex:1];
    self.uiTableView.tableFooterView = self.footerView;
    
    self.searchField.text = @"\u200B";
    
    self.buttonView.clipsToBounds = YES;
    
    self.addReceiptButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
    [self.addReceiptButton addTarget:self action:@selector(callContactList) forControlEvents:UIControlEventTouchUpInside];
    self.addReceiptBGView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 28, 28)];
    self.addReceiptButton.center = CGPointMake(14, 14);
    [self.addReceiptBGView addSubview:self.addReceiptButton];
    
    [self layoutNameButtons];
}

#pragma mark - Memory management

- (void)dealloc
{
	delegate = nil;
    ABAddressBookUnregisterExternalChangeCallback(addressBook, pickerAddressBookChanged,  (__bridge void*)self);
	CFRelease(addressBook);
}

#pragma mark - Respond to touch and become first responder.

- (BOOL)canBecomeFirstResponder
{
	return YES;
}

#pragma mark - Target-action methods

// Action receiver for the clicking of Done button
-(IBAction)doneClick:(id)sender
{
	[delegate buttonPeoplePickerDidFinish:self];
}

// Action receiver for the clicking of Cancel button
- (IBAction)cancelClick:(id)sender
{
	[group removeAllObjects];
	[delegate buttonPeoplePickerDidFinish:self];
}

// Action receiver for the selecting of name button
- (void)buttonSelected:(id)sender {

	selectedButton = (UIButton *)sender;
	
	// Clear other button states
	for (UIView *subview in buttonView.subviews)
    {
		if ([subview isKindOfClass:[UIButton class]] && subview != selectedButton)
        {
			((UIButton *)subview).selected = NO;
		}
	}
	if (selectedButton.selected)
    {
		selectedButton.selected = NO;
		deleteLabel.hidden = YES;

	}
	else
    {
		selectedButton.selected = YES;
		deleteLabel.hidden = NO;
	}

	[self becomeFirstResponder];
}

#pragma mark - UIKeyInput protocol methods

- (BOOL)hasText
{
	return NO;
}

- (void)insertText:(NSString *)text {
    if (selectedButton) {
        NSInteger selectedIndex = selectedButton.tag;
        NSDictionary *selectedPeople = [self.group objectAtIndex:selectedIndex];
        [self removePersonFromGroup:selectedPeople];
        searchField.text = [NSString stringWithFormat:@"%@%@", @"\u200B", text];
        [self.searchField becomeFirstResponder];
    }
}

- (void)deleteBackward
{	
	// Hide the delete label
//	deleteLabel.hidden = YES;
//    NSLog(@"selected button:%@",selectedButton);
//	NSString *name = selectedButton.titleLabel.text;
//	NSInteger identifier = selectedButton.tag;
//	
//	NSArray *personArray = (__bridge_transfer NSArray *)ABAddressBookCopyPeopleWithName(addressBook, (__bridge CFStringRef)name);
//	
//	ABRecordRef person = (__bridge ABRecordRef)([personArray lastObject]);
//
//	ABRecordID abRecordID = ABRecordGetRecordID(person);
//
//    ABMultiValueRef phoneProperty = ABRecordCopyValue(person, kABPersonPhoneProperty);
//    
//    NSString *phone;
//    NSString *personName;
//    
//    name = (__bridge NSString *)ABRecordCopyCompositeName(person);
//    
//    if (phoneProperty)
//    {
//        CFIndex index = ABMultiValueGetIndexForIdentifier(phoneProperty, identifier);
//        
//        if (index != -1)
//        {
//            phone = (__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(phoneProperty, index);
//        }
//    }
//    
//    NSDictionary *personDictionary = nil;
//    
//    if (phone) {
//        personDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
//                                          [NSNumber numberWithInt:abRecordID], @"abRecordID",
//                                          [NSNumber numberWithInt:identifier], @"valueIdentifier", 
//                                          phone, @"phoneNumber", personName, @"name",nil];
//    } 
//    else 
//    {
//        personDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
//                            [NSNumber numberWithInt:abRecordID], @"abRecordID",
//                            [NSNumber numberWithInt:identifier], @"valueIdentifier",       
//                            @"", @"phoneNumber", @"", @"name",nil];
//    }
    
    NSInteger selectedIndex = selectedButton.tag;
    
    NSDictionary *personDictionary = [self.group objectAtIndex:selectedIndex];
    
	[self removePersonFromGroup:personDictionary];
}

#pragma mark - UITableViewDataSource protocol methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	// do we have search text? if yes, are there search results? if yes, return number of results, otherwise, return 1 (add email row)
	// if there are no search results, the table is empty, so return 0
	return searchField.text.length > 0 ? MAX( 1, filteredPeople.count ) : 0 ;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{	
	static NSString *kCellID = @"cellID";
	
	PeoplePickerCustomCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellID];
	
	if (cell == nil)
    {
		cell = [[PeoplePickerCustomCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kCellID];
	}
    
    cell.accessoryType = UITableViewCellAccessoryNone;
	
    cell.backgroundColor = [UIColor clearColor];
    
	// If this is the last row in filteredPeople, take special action
	if (filteredPeople.count == indexPath.row)
    {
		cell.textLabel.text	= @"Add Person";
		cell.labelTF.text = nil;
        cell.phoneNumber = nil;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	else
    {
		NSDictionary *personDictionary = [filteredPeople objectAtIndex:indexPath.row];
		
		ABRecordID abRecordID = (ABRecordID)[[personDictionary valueForKey:@"abRecordID"] intValue];
		
		ABRecordRef abPerson = ABAddressBookGetPersonWithRecordID(addressBook, abRecordID);
		
		ABMultiValueIdentifier identifier = [[personDictionary valueForKey:@"valueIdentifier"] intValue];
		
		{
			NSString *string = (__bridge_transfer NSString *)ABRecordCopyCompositeName(abPerson);
			cell.textLabel.text = string;
		}
		
		ABMultiValueRef phoneProperty = ABRecordCopyValue(abPerson, kABPersonPhoneProperty);
		
		if (phoneProperty)
        {
			CFIndex index = ABMultiValueGetIndexForIdentifier(phoneProperty, identifier);
			
			if (index != -1)
            {
				NSString *phone = (__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(phoneProperty, index);
				CFStringRef phoneLabel = ABMultiValueCopyLabelAtIndex(phoneProperty, index);
                CFStringRef labelName = ABAddressBookCopyLocalizedLabel(phoneLabel);
                cell.labelTF.text = (__bridge NSString *)labelName;
                cell.phoneNumber = phone;
                CFRelease(labelName);
                CFRelease(phoneLabel);
            }
			else
            {
				cell.labelTF.text = nil;
                cell.phoneNumber = nil;
			}
		}
		
		if (phoneProperty) CFRelease(phoneProperty);
	}
	
	return cell;
}

#pragma mark - UITableViewDelegate protocol method

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[self changePickerViewToStatus:ButtonPeoplePickerStatusShowing];

	// Handle the special case
	if (indexPath.row == filteredPeople.count)
    {
		//[self displayAddPersonViewController];
        ClientObject *newClient = nil;
        NSString *newPhoneName = [searchField.text stringByReplacingOccurrencesOfString:@"\u200B" withString:@""];
        newPhoneName = [newPhoneName stringByReplacingOccurrencesOfString:@" " withString:@""];
        if ([newPhoneName length] == 0) {
            return;
        } else {
            newClient = [[ClientObject alloc] init];
            newClient.cVal = newPhoneName;
            newClient.cName = @"";
            [self addPersonToGroup:newClient];
        }
	}
	else
    {
		NSDictionary *personDictionary = [filteredPeople objectAtIndex:indexPath.row];
        NSString *clientName = [personDictionary objectForKey:@"name"];
        NSString *clientPhoneNumber = [personDictionary objectForKey:@"phoneNumber"];
        NSNumber *clientRecordID = [personDictionary objectForKey:@"abRecordID"];
        NSNumber *clientPhoneIdentifier = [personDictionary objectForKey:@"valueIdentifier"];
        NSString *clientPhoneLabel = [personDictionary objectForKey:@"phoneLabel"];
		ClientObject *newClient = nil;
        newClient = [[ClientObject alloc] init];
        newClient.cVal = clientPhoneNumber;
        newClient.cName = clientName;
        newClient.cID = [clientRecordID intValue];
        newClient.phoneLabel = clientPhoneLabel;
        newClient.phoneIdentifier = [clientPhoneIdentifier intValue];
        [self addPersonToGroup:newClient];
	}

	searchField.text = @"\u200B";
}

#pragma mark - Update the filteredPeople array based on the search text.

- (void)filterContentForSearchText:(NSString*)searchText
{
	// First clear the filtered array.
	[filteredPeople removeAllObjects];

	// beginswith[cd] predicate
	NSPredicate *beginsPredicate = [NSPredicate predicateWithFormat:@"(SELF beginswith[cd] '%@')", searchText];

	/*
	 Search the main list for people whose firstname OR lastname OR organization matches searchText; add items that match to the filtered array.
	 */
	
	for (id record in people)
    {
        ABRecordRef person = (__bridge ABRecordRef)record;

		// Access the person's email addresses (an ABMultiValueRef)
		ABMultiValueRef phonesProperty = ABRecordCopyValue(person, kABPersonPhoneProperty);
		
		if (phonesProperty)
        {
			// Iterate through the email address multivalue
			for (CFIndex index = 0; index < ABMultiValueGetCount(phonesProperty); index++)
            {
				NSString *firstName = (__bridge_transfer NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty);
				NSString *lastName = (__bridge_transfer NSString *)ABRecordCopyValue(person, kABPersonLastNameProperty);
				NSString *organization = (__bridge_transfer NSString *)ABRecordCopyValue(person, kABPersonOrganizationProperty);
				NSString *phoneString = (__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(phonesProperty, index);
				NSString *name = (__bridge NSString *)ABRecordCopyCompositeName(person);
                
                
				// Match by firstName, lastName, organization or email address
				if ([beginsPredicate evaluateWithObject:firstName] ||
					[beginsPredicate evaluateWithObject:lastName] ||
					[beginsPredicate evaluateWithObject:organization] ||
					[beginsPredicate evaluateWithObject:phoneString])
                {
					// Get the address identifier for this address
					ABMultiValueIdentifier identifier = ABMultiValueGetIdentifierAtIndex(phonesProperty, index);
					NSString *phoneLabel = (__bridge NSString *)ABMultiValueCopyLabelAtIndex(phonesProperty, index);
					ABRecordID abRecordID = ABRecordGetRecordID(person);
					
					NSDictionary *personDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
													 [NSNumber numberWithInt:abRecordID], @"abRecordID",
													 [NSNumber numberWithInt:identifier], @"valueIdentifier", 
                                                     phoneString,
                                                         @"phoneNumber",
                                                      name,
                                                         @"name",
                                                      phoneLabel,
                                                         @"phoneLabel",
                                                      nil];

					// Add each personDictionary to filteredPeople
					[filteredPeople addObject:personDictionary];
				}
			 }
			
			 CFRelease(phonesProperty);
		}
	}
}

#pragma mark - textFieldDidChange notification method to the searchField control.
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *result = [textField.text stringByReplacingCharactersInRange:range withString:string];
    NSString *empty = @"";
    if (range.length >= 1 && [result isEqualToString:empty]) {
        [self findLastButton];
        return NO;
	}
	return YES;
}

- (void)textFieldDidChange
{
	if (searchField.text.length > 1)
    {
        [self changePickerViewToStatus:ButtonPeoplePickerStatusSearching];
		[self filterContentForSearchText:[searchField.text stringByReplacingOccurrencesOfString:@"\u200B" withString:@""]];
		[uiTableView reloadData];
	}
	else
    {
		[self changePickerViewToStatus:ButtonPeoplePickerStatusShowing];
	}
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (searchField.text.length > 1)
    {
        NSString *newName = [searchField.text stringByReplacingOccurrencesOfString:@"\u200B" withString:@""];
        if ([newName length] == 0) {
            searchField.text = @"\u200B";
            return NO;
        }
        ClientObject *newClient = nil;
        newClient = [[ClientObject alloc] init];
        newClient.cVal = @"";
        newClient.cName = newName;
        searchField.text = @"\u200B";
        
        [newClient searchClientIDByName];
        
        if (![newClient isClientValid]) {
            newName = [newName stringByReplacingOccurrencesOfString:@" " withString:@""];
            newClient.cVal = newName;
            newClient.cName = @"";
            [newClient searchClientIDByPhone];
            
            if ([newClient isClientValid]) {
                [self addPersonToGroup:newClient];
            } else {
                if ([newClient isClientPhoneNumberValid]) {
                    [self addPersonToGroup:newClient];
                } else {
                    return NO;
                }
            }
        } else {
            [self addPersonToGroup:newClient];
        }
	}
	else
    {
		
	}
    return NO;
}

#pragma mark - Add and remove a person to/from the group

- (void)addPersonToGroup:(ClientObject *)oneClient
{
    //ABRecordID abRecordID = (ABRecordID)[[personDictionary valueForKey:@"abRecordID"] intValue];
    
    NSString *number = oneClient.cVal;
    NSString *name  = oneClient.cName;
    
    ClientObject *clientWithSameID = nil;
    
    // Check for an existing entry for this person, if so remove it
    if ([name isEqualToString:@""]) {
        if ([number isEqualToString:@""]) {
            return;
        }
        NSString *cleanString = [self getCleanLetter:number];
        
        for (ClientObject *aClient in group)
        {
            NSString *thePhoneString = aClient.cVal;
            if ([cleanString isEqualToString:[self getCleanLetter:thePhoneString]]) {
                return;
            }
        }
    } else {
        for (ClientObject *aClient in group)
        {
            NSString *theContactName = aClient.cName;
            NSString *thePhoneString = aClient.cVal;
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
            
            if (aClient.cID != -1 && aClient.cID == oneClient.cID) {
                clientWithSameID = aClient;
            }
        }
    }
    
    if (clientWithSameID) {
        [group removeObject:clientWithSameID];
    }
    
    [group addObject:oneClient];
    [self layoutNameButtons];
}

- (void)removePersonFromGroup:(NSDictionary *)personDictionary
{
    [group removeObject:personDictionary];
	
	[self layoutNameButtons];
}

#pragma mark - Update Person info

-(void)layoutNameButtons
{
	// Remove existing buttons
	for (UIView *subview in buttonView.subviews)
    {
		if ([subview isKindOfClass:[UIButton class]])
        {
			[subview removeFromSuperview];
		}
	}
    
    int rowCount = 0;
    int colCount = 0;
    CGFloat Ver_PADDING = 10.0f;
	CGFloat Begin_PADDING = 8.0f;
    CGFloat End_PADDING = 38.0f;
	CGFloat maxWidth = buttonView.frame.size.width - Begin_PADDING - End_PADDING;
	CGFloat xPosition = Begin_PADDING + 30.f;
	CGFloat yPosition = Ver_PADDING;
    CGFloat minWidth = maxWidth / 3;
    
    CGRect finalRectOfView = buttonView.frame;
    finalRectOfView.size.height = 40.0f;
    
    CGRect originFrame = searchField.frame;
    CGRect targetFrame = originFrame;
    targetFrame.origin.x = xPosition;
    targetFrame.origin.y = yPosition;
    targetFrame.size.height = 25;
    targetFrame.size.width = buttonView.frame.size.width - xPosition - End_PADDING - Begin_PADDING;
    searchField.frame = targetFrame;
    
    originFrame = self.addReceiptBGView.frame;
    targetFrame = originFrame;
    targetFrame.origin.x = buttonView.frame.size.width - End_PADDING;
    targetFrame.origin.y = yPosition;
    [self.addReceiptBGView setFrame:targetFrame];
    
	for (int i = 0; i < group.count; i++)
    {
		ClientObject *oneClient = (ClientObject *)[group objectAtIndex:i];
//		ABRecordID abRecordID = (ABRecordID)[[personDictionary valueForKey:@"abRecordID"] intValue];
//
//        if (abRecordID == -1){
//            continue;
//        }
        
        NSString *name = nil;
//		if (abRecordID) {
//            ABRecordRef abPerson = ABAddressBookGetPersonWithRecordID(addressBook, abRecordID);
//            name = (__bridge_transfer NSString *)ABRecordCopyCompositeName(abPerson);
//        } else {
            name = oneClient.cName;
//        }
        if ([name isEqualToString:@""]) {
            name = oneClient.cVal;
        }
        
//		ABMultiValueIdentifier identifier = [[personDictionary valueForKey:@"valueIdentifier"] intValue];
//		
//        NSLog(@"identifier: %d",identifier);
        
		// Create the button image
		UIImage *image = [UIImage imageNamed:@"ButtonCorners.png"];
		image = [image stretchableImageWithLeftCapWidth:3.5 topCapHeight:3.5];
		
		UIImage *image2 = [UIImage imageNamed:@"bottom-button-bg.png"];
		image2 = [image2 stretchableImageWithLeftCapWidth:3.5 topCapHeight:3.5];

		// Create the button
		UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
		[button setTitle:name forState:UIControlStateNormal];
		
		// Use the identifier as a tag for future reference
		[button setTag:i];
		[button.titleLabel setFont:[UIFont systemFontOfSize:16.0]];
		[button setBackgroundImage:image forState:UIControlStateNormal];
		[button setBackgroundImage:image2 forState:UIControlStateSelected];
		[button addTarget:self action:@selector(buttonSelected:) forControlEvents:UIControlEventTouchUpInside];

		// Get the width and height of the name string given a font size
		CGSize nameSize = [name sizeWithFont:[UIFont systemFontOfSize:16.0]];
        
        if ((xPosition + nameSize.width + Begin_PADDING) > maxWidth && rowCount != 0)
        {
			
            // Reset horizontal position to left edge of superview's frame
			xPosition = Begin_PADDING ;
			
            if (nameSize.width  > (self.buttonView.frame.size.width - (Begin_PADDING * 4))) {
                nameSize.width = self.buttonView.frame.size.width - (Begin_PADDING * 4);
            }
            
			// Set vertical position to a new 'line'
			yPosition += nameSize.height + Ver_PADDING ;
            
            rowCount = 0;
            colCount++;
		} else {
            if (rowCount == 0) {
                if (colCount == 0) {
                    if (nameSize.width  > (self.buttonView.frame.size.width - (Begin_PADDING * 8)))
                    {
                        nameSize.width = self.buttonView.frame.size.width - (Begin_PADDING * 8);
                    }
                } else {
                    if (nameSize.width  > (self.buttonView.frame.size.width - (Begin_PADDING * 4)))
                    {
                        nameSize.width = self.buttonView.frame.size.width - (Begin_PADDING * 4);
                    }
                }
            }
        }
		
        
		// Create the button's frame
		CGRect buttonFrame = CGRectMake(xPosition, yPosition, nameSize.width + (Begin_PADDING  * 2), nameSize.height);
		[button setFrame:buttonFrame];
		[buttonView addSubview:button];
		
		// Calculate xPosition for the next button in the loop
		xPosition += button.frame.size.width + Begin_PADDING ;
		
        rowCount++;
        
		// Calculate the y origin for the delete label
		if ((xPosition + minWidth + Begin_PADDING ) > maxWidth) {
            CGRect from = searchField.frame;
            CGRect to = from;
            
            xPosition = Begin_PADDING ;
            
            to.size.width = maxWidth - Begin_PADDING ;
            yPosition += nameSize.height + Ver_PADDING ;
            to.origin.y = yPosition;
            to.origin.x = Begin_PADDING ;
            
            searchField.frame = to;
            
            rowCount = 0;
            colCount++;
        } else {
            CGRect from = searchField.frame;
            CGRect to = from;
            
            to.size.width = maxWidth - xPosition - Begin_PADDING  * 2;
            to.origin.y = yPosition;
            to.origin.x = xPosition + Begin_PADDING ;
            
            searchField.frame = to;
        }
        
        
        [searchField removeFromSuperview];
        [buttonView addSubview:searchField];
        
        CGRect labelFrame = deleteLabel.frame;
		labelFrame.origin.y = yPosition + button.frame.size.height + Begin_PADDING ;
		[deleteLabel setFrame:labelFrame];
		
        self.buttonView.contentSize = CGSizeMake(buttonView.frame.size.width, yPosition + button.frame.size.height + Ver_PADDING);
        
        if ((yPosition + button.frame.size.height + Ver_PADDING) > 160) {
            CGRect from = self.buttonView.frame;
            CGRect to = from;
            to.size.height = 160;
            //self.buttonView.frame = to;
            finalRectOfView = to;
        } else {
            CGRect from = self.buttonView.frame;
            CGRect to = from;
            to.size.height = yPosition + button.frame.size.height + Ver_PADDING;
            //self.buttonView.frame = to;
            finalRectOfView = to;
        }
        
	}
    
    CGRect addButtonBGFrame = self.addReceiptBGView.frame;
    addButtonBGFrame.origin.y = yPosition - 5.0f;
    self.addReceiptBGView.frame = addButtonBGFrame;
    [addReceiptBGView removeFromSuperview];
    [buttonView addSubview:addReceiptBGView];
    
    if (group.count > 0)
    {
        [doneButton setEnabled:YES];
    }
    else
    {
        [doneButton setEnabled:NO];
    }
	
	[buttonView setHidden:NO];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.1f];
    buttonView.frame = finalRectOfView;
    [UIView commitAnimations];
    
	[searchField becomeFirstResponder];
}

- (void)touchButton {
}

- (void)findLastButton {
    lastButton = nil;
    for (UIView *subview in buttonView.subviews)
    {
		if ([subview isKindOfClass:[UIButton class]])
        {
			lastButton = (UIButton *)subview;
		}
	}
    
    if (lastButton) {
        [self becomeFirstResponder];
        selectedButton = lastButton;
        selectedButton.selected = YES;
    }
}

- (void)callContactList {
//    ABPeoplePickerNavigationController *ppnc = [[ABPeoplePickerNavigationController alloc] init];
//    ppnc.peoplePickerDelegate = self;
//    [ppnc setDisplayedProperties:[NSArray
//                                  arrayWithObject:[NSNumber numberWithInt:kABPersonPhoneProperty]]];
//    [[(UIViewController *)[self delegate] navigationController] presentModalViewController:ppnc animated:YES];
    
//    ContactsListPickerViewController *list = [[ContactsListPickerViewController alloc] init];
//    list.contactDelegate = self;
//    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:list];
//    [[(UIViewController *)[self delegate] navigationController] presentModalViewController:nav animated:YES];
    SegmentManagingViewController * segmentManagingViewController = [[SegmentManagingViewController alloc] init];
    segmentManagingViewController.contactDataDelegate = self;
    UINavigationController *pickersNav = [[UINavigationController alloc] initWithRootViewController:segmentManagingViewController];
    [[(UIViewController *)[self delegate] navigationController] presentModalViewController:pickersNav animated:YES];
}

#pragma mark -
#pragma custom view changing method
- (void)changePickerViewToStatus:(ButtonPeoplePickerStatus)newStatus {
    if (newStatus == pickerStatus) {
        return;
    }
    
    //add new change view method
    if (newStatus == ButtonPeoplePickerStatusSearching) {
        //modify view location
        CGRect oldButtonViewFrame = self.buttonView.frame;
        CGRect newButtonViewFrame = oldButtonViewFrame;
        CGFloat currentTableViewYPosition = CGRectGetMaxY(newButtonViewFrame);        
        CGRect oldTableViewFrame = self.uiTableView.frame;
        CGRect newTableViewFrame = oldTableViewFrame;
        newTableViewFrame.origin.y = currentTableViewYPosition;
        
        self.uiTableView.frame = newTableViewFrame;
        [self.uiTableView setHidden:NO];
        
        //animation
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.2f];
        CGFloat offset = currentTableViewYPosition - 40.0f;
        newTableViewFrame.origin.y = newTableViewFrame.origin.y - offset;
        newButtonViewFrame.origin.y = newButtonViewFrame.origin.y - offset;
        self.buttonView.frame = newButtonViewFrame;
        self.uiTableView.frame = newTableViewFrame;

        [UIView commitAnimations];
        
        pickerStatus = ButtonPeoplePickerStatusSearching;
        
        [self.buttonView reloadInputViews];
        self.searchField.inputAccessoryView = nil;
        [self.toolbar removeFromSuperview];
    } else {
        [self.uiTableView setHidden:YES];
        [self.toolbar setHidden:NO];
        self.toolbar.exclusiveTouch = YES;
        
        CGRect oldButtonViewFrame = self.buttonView.frame;
        CGRect newButtonViewFrame = oldButtonViewFrame;
        newButtonViewFrame.origin.y = 0.0f;
        self.buttonView.frame = newButtonViewFrame;
        
        pickerStatus = ButtonPeoplePickerStatusShowing;
        
        [self.buttonView reloadInputViews];
        self.searchField.inputAccessoryView = self.toolbar;
        [self.searchField reloadInputViews];
    }
}

- (void)resetData {
    NSMutableArray *array = [delegate getCurrentContactDataSource];
    if (array) {
        self.group = [NSMutableArray arrayWithArray:array];
        [self layoutNameButtons];
    } else {
        self.group = [[NSMutableArray alloc] init];
    }
    [self layoutNameButtons];
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

#pragma mark -
#pragma mark search local addressbook
- (ClientObject *)scanAddressBookAndSearch:(ClientObject *)client
{
    NSUInteger i;
    NSUInteger k;
    
    NSString *phoneNumber = client.cVal;
    
    ABAddressBookRef localAddressBook = ABAddressBookCreate();
    NSArray *m_people = (__bridge NSArray *) ABAddressBookCopyArrayOfAllPeople(localAddressBook);
    
    if ( m_people == nil )
    {
        NSLog(@"NO ADDRESS BOOK ENTRIES TO SCAN");
        CFRelease(localAddressBook);
        return client;
    }
    
    for ( i=0; i<[m_people count]; i++ )
    {
        ABRecordRef person = (__bridge ABRecordRef)[m_people objectAtIndex:i];
        
        //
        // Phone Numbers
        //
        ABMutableMultiValueRef phoneNumbers = ABRecordCopyValue(person, kABPersonPhoneProperty);
        CFIndex phoneNumberCount = ABMultiValueGetCount( phoneNumbers );
        
        for ( k=0; k<phoneNumberCount; k++ )
        {
            NSString *phoneNumberValue = (__bridge NSString *)ABMultiValueCopyValueAtIndex( phoneNumbers, k );
            
            if ([phoneNumber isEqualToString:phoneNumberValue]) {
                NSString *phoneLabelValue = (__bridge NSString *)ABMultiValueCopyLabelAtIndex(phoneNumbers, k);
                NSInteger indentifier = ABMultiValueGetIdentifierAtIndex(phoneNumbers, k);
                client.phoneIdentifier = indentifier;
                client.phoneLabel = phoneLabelValue;
                client.cID = ABRecordGetRecordID(person);
                client.cName = (__bridge NSString *)ABRecordCopyCompositeName(person);
                break;
            }
        }
    }

    CFRelease(localAddressBook);
    return client;
}

#pragma mark -
#pragma mark segment contact delegate
- (NSArray *)getCurrentContactData {
    NSLog(@"%@",self.group);
    return self.group;
}

- (void)setNewContactData : (NSArray *)newData {
    self.group = [NSMutableArray arrayWithArray:newData];
    [self layoutNameButtons];
}

- (void)selectedCancelInController:(UIViewController *)vc {
    [[(UIViewController *)[self delegate] navigationController]dismissModalViewControllerAnimated:YES];
}

- (void)selectedFinishedInController:(UIViewController *)vc {
    [[(UIViewController *)[self delegate] navigationController]dismissModalViewControllerAnimated:YES];
}

#pragma input accessory view
- (UIView *)inputAccessoryView {
    if (pickerStatus == ButtonPeoplePickerStatusSearching) {
        return nil;
    }
    return self.toolbar;
}

void pickerAddressBookChanged(ABAddressBookRef reference, CFDictionaryRef dictionary, void *context) {
    if ([[[(__bridge ButtonPeoplePicker *)context searchField] text] length] > 1) {
        [(__bridge ButtonPeoplePicker *)context setPeople:(__bridge_transfer NSArray *)ABAddressBookCopyArrayOfAllPeople(reference)];
        [(__bridge ButtonPeoplePicker *)context filterContentForSearchText:[[[(__bridge ButtonPeoplePicker *)context searchField] text] stringByReplacingOccurrencesOfString:@"\u200B" withString:@""]];
        [[(__bridge ButtonPeoplePicker *)context uiTableView] reloadData];
    }
}
@end
