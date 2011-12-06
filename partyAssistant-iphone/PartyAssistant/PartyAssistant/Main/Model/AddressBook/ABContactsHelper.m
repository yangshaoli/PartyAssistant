#import "ABContactsHelper.h"
#import "ContactData.h"
#import "AddressBookDataManager.h"
#import "ContactListTestAppDelegate.h"

@implementation ABContactsHelper
/*
 Note: You cannot CFRelease the addressbook after ABAddressBookCreate();
 */
+ (ABAddressBookRef) addressBook
{
	if(addressBook == nil) {
        return ABAddressBookCreate();
    }
	else
		return addressBook;
}



// Sorting
+ (BOOL) firstNameSorting
{
	return (ABPersonGetCompositeNameFormat() == kABPersonCompositeNameFormatFirstNameFirst);
}

#pragma mark Contact Management

// Thanks to Eridius for suggestions re: error
+ (BOOL) addContact: (ABContact *) aContact withError: (NSError **) error
{
	if (!ABAddressBookAddRecord(addressBook, aContact.record, (CFErrorRef *) error)) return NO;
	return ABAddressBookSave(addressBook, (CFErrorRef *) error);
}


+ (NSArray *) contactsMatchingName: (NSString *) fname
{
	NSPredicate *pred;
	NSArray *contacts = [ContactData contactsArray];
	pred = [NSPredicate predicateWithFormat:@"firstname contains[cd] %@ OR lastname contains[cd] %@ OR nickname contains[cd] %@ OR middlename contains[cd] %@ OR organization contains[cd] %@", fname, fname, fname, fname, fname];
	return [contacts filteredArrayUsingPredicate:pred];
}

+ (NSArray *) contactsMatchingName: (NSString *) fname InGroup:(ABRecordRef)aRecord {
	NSPredicate *pred;
	NSArray *contacts = [ContactData contactsArrayByRecordRef:aRecord];
	pred = [NSPredicate predicateWithFormat:@"firstname contains[cd] %@ OR lastname contains[cd] %@ OR nickname contains[cd] %@ OR middlename contains[cd] %@ OR organization contains[cd] %@", fname, fname, fname, fname, fname];
	return [contacts filteredArrayUsingPredicate:pred];
}

+ (NSArray *) contactsMatchingName: (NSString *) fname andName: (NSString *) lname
{
	NSPredicate *pred;
	NSArray *contacts = [ContactData contactsArray];
	pred = [NSPredicate predicateWithFormat:@"firstname contains[cd] %@ OR lastname contains[cd] %@ OR nickname contains[cd] %@ OR middlename contains[cd] %@", fname, fname, fname, fname];
	contacts = [contacts filteredArrayUsingPredicate:pred];
	pred = [NSPredicate predicateWithFormat:@"firstname contains[cd] %@ OR lastname contains[cd] %@ OR nickname contains[cd] %@ OR middlename contains[cd] %@", lname, lname, lname, lname];
	contacts = [contacts filteredArrayUsingPredicate:pred];
	return contacts;
}

+ (NSArray *) contactsMatchingPhone: (NSString *) number
{
	NSPredicate *pred;
	NSArray *contacts = [ContactData contactsArray];
	pred = [NSPredicate predicateWithFormat:@"phonenumbers contains[cd] %@", number];
	return [contacts filteredArrayUsingPredicate:pred];
}
@end