#import <UIKit/UIKit.h>
#import "ABContactsHelper.h"
#import "ABContact.h"
#import <AddressBookUI/AddressBookUI.h>

@class ContactsListPickerViewController;

@protocol ContactsListPickerViewControllerDelegate <NSObject>

- (void)contactList:(ContactsListPickerViewController *)contactList cancelAction:(BOOL)action;
- (void)contactList:(ContactsListPickerViewController *)contactList selectDefaultActionForPerson:(ABRecordID)personID property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier;

@end

@interface ContactsListPickerViewController : UITableViewController <ABNewPersonViewControllerDelegate, 
ABPersonViewControllerDelegate,UISearchBarDelegate>{
	ABRecordRef record;
	UISearchDisplayController *searchDC;
	UISearchBar *searchBar;
	NSMutableArray *filteredArray;
	NSMutableArray *contactNameArray;
	NSMutableDictionary *contactNameDic;
	NSMutableDictionary *searchContactNameDic;
	NSMutableArray *sectionArray;
	NSMutableArray *sectionContactArray;
	NSArray *abData;
	NSString *sectionName;
}

@property (retain) NSArray *abData;
@property (retain) NSMutableArray *filteredArray;
@property (retain) NSMutableArray *contactNameArray;
@property (retain) NSMutableDictionary *contactNameDic;
@property (retain) NSMutableDictionary *searchContactNameDic;
@property (retain) NSMutableArray *sectionArray;
@property (retain) NSMutableArray *sectionContactArray;
@property (retain) UISearchDisplayController *searchDC;
@property (retain) UISearchBar *searchBar;
@property (nonatomic, assign) id<ContactsListPickerViewControllerDelegate> contactDelegate;

- (id)initWithRecordRef:(ABRecordRef)aRecord;
@end
