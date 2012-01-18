#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "ABContact.h"
#import "ABGroup.h"

@interface ABContactsHelper : NSObject

// Address Book
+ (ABAddressBookRef) addressBook;



// Sorting
+ (BOOL) firstNameSorting;

// Add contacts and groups
+ (BOOL) addContact: (ABContact *) aContact withError: (NSError **) error;


// Find contacts
+ (NSArray *) contactsMatchingName: (NSString *) fname;
+ (NSArray *) contactsMatchingName: (NSString *) fname InGroup:(ABRecordRef)aRecord;
+ (NSArray *) contactsMatchingName: (NSString *) fname andName: (NSString *) lname;
+ (NSArray *) contactsMatchingPhone: (NSString *) number;
+ (NSArray *) contactsEqualsName: (NSString *) name;

@end

// For the simple utility of it. Feel free to comment out if desired
@interface NSString (cstring)
@property (readonly) char *UTF8String;
@end