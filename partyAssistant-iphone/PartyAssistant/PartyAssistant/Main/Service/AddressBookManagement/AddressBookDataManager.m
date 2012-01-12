//
//  AddressBookDataManager.m
//  Dialer
//
//  Created by JUN WANG on 7/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AddressBookDataManager.h"
#import "PartyAssistantAppDelegate.h"
#import "SynthesizeSingleton.h"
#import "ABContact.h"
#import <AddressBook/AddressBook.h>

@interface AddressBookDataManager ()
    
- (void)updateContactInfo;
    
@end

@implementation AddressBookDataManager
@synthesize contactArray,contactNumberDic;
SYNTHESIZE_SINGLETON_FOR_CLASS(AddressBookDataManager);

- (id)init {
    if ((self = [super init])) {
		isNeedsUpdate = YES;
		callLogContactDataHasChanged = YES;
		contactListDataHasChanged = YES;
    }
    return self;
}

- (NSArray *)contactData {
	if (!contactArray || isNeedsUpdate) {
		[self updateContactInfo];
	}
	return self.contactArray;
}

- (NSDictionary *)contactsNumberDictionary {
	if (!contactArray || isNeedsUpdate) {
		[self updateContactInfo];
	}
	return self.contactNumberDic;
}

- (void)updateContactInfo {
	if (isRunning) {
		return;
	}
	isRunning = YES;
	
	//NSArray *thePeople = (NSArray *)ABAddressBookCopyArrayOfAllPeopleInSourceWithSortOrdering(addressBook, addressBook, kABPersonSortByFirstName);
	CFArrayRef thePeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
	
	CFMutableArrayRef peopleMutable = CFArrayCreateMutableCopy(
															   kCFAllocatorDefault,
															   CFArrayGetCount(thePeople),
															   thePeople
															   );
	
	CFArraySortValues(
					  peopleMutable,
					  CFRangeMake(0, CFArrayGetCount(peopleMutable)),
					  (CFComparatorFunction) ABPersonComparePeopleByName,
					  (void*) ABPersonGetSortOrdering()
					  ); 
	
	NSMutableArray *abContacts = [[NSMutableArray alloc]initWithCapacity:CFArrayGetCount(peopleMutable)];
	for (id person in (__bridge NSMutableArray *)peopleMutable)
		[abContacts addObject:[ABContact contactWithRecord:(__bridge ABRecordRef)person]];
	CFRelease(thePeople);
	CFRelease(peopleMutable);
	
	self.contactArray = abContacts;
	isRunning = NO;
	isNeedsUpdate = NO;
}

- (void)setNeedsUpdate {
	isNeedsUpdate = YES;
	callLogContactDataHasChanged = YES;
	contactListDataHasChanged = YES;
}

- (NSDictionary *)getCallLogContactData {
	if (callLogContactDataHasChanged) {
			NSArray *contactsArray = [self getContactListData];
			NSMutableDictionary *dictionary = [NSMutableDictionary  dictionaryWithCapacity:contactsArray.count];
			NSString *aNumber;
			for (ABContact *contact in contactsArray) {
				NSArray *numbers = [contact phoneArray];
				for (NSString *number in numbers) {
					aNumber = [number stringByReplacingOccurrencesOfString:@"+" withString:@""];
					aNumber = [aNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
					aNumber = [aNumber stringByReplacingOccurrencesOfString:@"(" withString:@""];
					aNumber = [aNumber stringByReplacingOccurrencesOfString:@")" withString:@""];
					aNumber = [aNumber stringByReplacingOccurrencesOfString:@"+" withString:@""];
					aNumber = [aNumber stringByReplacingOccurrencesOfString:@"#" withString:@""];
					aNumber = [aNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
					[dictionary setValue:contact forKey:aNumber];
				}
			self.contactNumberDic = dictionary;
			callLogContactDataHasChanged = NO;
		}
	}
	return (NSMutableDictionary *)self.contactNumberDic;
}

- (NSArray *)getContactListData {
	if (contactListDataHasChanged) {
		if (isNeedsUpdate) {
			[self updateContactInfo];
			contactListDataHasChanged = NO;
		} 
	} 
	return self.contactArray;
}

ABPersonSortOrdering ABPersonGetSortOrdering(void){
	return kABPersonSortByLastName;
}

@end
