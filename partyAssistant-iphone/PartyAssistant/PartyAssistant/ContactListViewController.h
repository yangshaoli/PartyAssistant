//
//  ContactListViewController.h
//  PartyAssistant
//
//  Created by 超 李 on 11-10-31.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>
#import "ContactorPhoneDetailsViewController.h"
#import "ContactorEmailDetailsViewController.h"
#import "NotificationSettings.h"
#import "ClientObject.h"

@protocol ContactListViewControllerDelegate <NSObject>

- (void)reorganizeReceiverField:(NSDictionary *)userInfo;

@end

@interface ContactListViewController : UITableViewController <ContactorPhoneDetailsViewControllerDelegate, UISearchBarDelegate>
{
    NSArray *contactorsArray;
    CFArrayRef contactorsArrayRef;
    NSMutableArray *selctedContactorsArray;
    NSString *msgType;
    NSInteger currentSelectedRowIndex;
    id<ContactListViewControllerDelegate> contactListDelegate;
    
    
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

@property(nonatomic,retain)NSArray *contactorsArray;
@property(nonatomic,retain)NSMutableArray *selectedContactorsArray;
@property(nonatomic,assign)CFArrayRef contactorsArrayRef;
@property(nonatomic,retain)NSString *msgType;
@property(nonatomic,assign)NSInteger currentSelectedRowIndex;
@property(nonatomic,assign)NSInteger currentSelectedSectionIndex;
@property(nonatomic,retain)id<ContactListViewControllerDelegate> contactListDelegate;

//wxz
@property (retain) NSArray *abData;
@property (nonatomic,retain) NSArray *contacts;
@property (nonatomic,retain) NSMutableArray *filteredArray;
@property (nonatomic,retain) NSMutableArray *contactNameArray;
@property (nonatomic,retain) NSMutableDictionary *contactNameDic;
@property (nonatomic,retain) NSMutableArray *sectionArray;
@property (nonatomic,retain) UISearchDisplayController *searchDC;
@property (nonatomic,retain) NSMutableArray *sectionContactArray;
@property (nonatomic,retain) UISearchBar *searchBar;



- (void)alertError:(NSString *)errorStr;
- (void)showOrCancleSelectedMark:(UITableViewCell *)cell mutableMSGValue:(id)msgVal;
- (void)selectContactor:(NSDictionary *)userinfo;
- (void)addInfoToArray:(NSInteger)cID uname:(NSString *)name value:(NSString *)val;
- (void)removeInfoFromArray:(NSInteger)cID;

//wxz
-(void)initData;
-(BOOL)searchResult:(NSString *)contactName searchText:(NSString *)searchT;

@end
