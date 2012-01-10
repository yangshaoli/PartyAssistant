//
//  MultiContactsPickerListViewController.h
//  PartyAssistant
//
//  Created by Wang Jun on 1/5/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>
#import "MultiContactsPhoneDetailViewController.h"
#import "ContactorEmailDetailsViewController.h"
#import "NotificationSettings.h"
#import "ClientObject.h"

@class MultiContactsPickerListViewController;
@protocol MultiContactsPickerListViewControllerDelegate <NSObject>

- (NSMutableArray *)dataSourceForContactList:(MultiContactsPickerListViewController *)contactList;

@end

@interface MultiContactsPickerListViewController : UITableViewController <MultiContactsPhoneDetailViewControllerDelegate, UISearchBarDelegate>
{
    NSArray *contactorsArray;
    CFArrayRef contactorsArrayRef;
    NSMutableArray *selectedContactorsArray;
    NSString *msgType;
    NSInteger currentSelectedRowIndex;
    id<MultiContactsPickerListViewControllerDelegate> contactListDelegate;
    
    
    //wxz
    UISearchDisplayController *searchDC;
	UISearchBar *searchBar;
    NSMutableArray *filteredArray;
	NSMutableArray *contactNameArray;
	NSMutableDictionary *contactNameDic;
	NSMutableArray *sectionArray;
	NSArray *contacts;
    NSArray *abData;
	NSString *sectionName;
}

@property(nonatomic,strong)NSArray *contactorsArray;
@property(nonatomic,strong)NSMutableArray *selectedContactorsArray;
@property(nonatomic,assign)CFArrayRef contactorsArrayRef;
@property(nonatomic,strong)NSString *msgType;
@property(nonatomic,assign)NSInteger currentSelectedRowIndex;
@property(nonatomic,assign)NSInteger currentSelectedSectionIndex;
@property(nonatomic,strong)id<MultiContactsPickerListViewControllerDelegate> contactListDelegate;

//wxz
@property (retain) NSArray *abData;
@property (nonatomic,strong) NSArray *contacts;
@property (nonatomic,strong) NSMutableArray *filteredArray;
@property (nonatomic,strong) NSMutableArray *contactNameArray;
@property (nonatomic,strong) NSMutableDictionary *contactNameDic;
@property (nonatomic,strong) NSMutableArray *sectionArray;
@property (nonatomic,strong) UISearchDisplayController *searchDC;
@property (nonatomic,strong) NSMutableArray *sectionContactArray;
@property (nonatomic,strong) UISearchBar *searchBar;

@property (nonatomic,strong) UIViewController *managingViewController;

- (void)alertError:(NSString *)errorStr;
- (void)showOrCancleSelectedMark:(ClientObject *)client mutableMSGValue:(id)msgVal;
- (void)selectContactor:(NSDictionary *)userinfo;
- (void)addInfoToArray:(NSInteger)cID uname:(NSString *)name value:(NSString *)val;
- (void)removeInfoFromArray:(NSInteger)cID;

//wxz
-(void)initData;
-(BOOL)searchResult:(NSString *)contactName searchText:(NSString *)searchT;
- (id)initWithParentViewController:(UIViewController *)aViewController;

- (ClientObject *)loadSingleNumberContact : (ABRecordID)recordID;
@end
