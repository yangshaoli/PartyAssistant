//
//  AddressBookDataManager.h
//  Dialer
//
//  Created by JUN WANG on 7/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>

@interface AddressBookDataManager : NSObject {
	BOOL isRunning; 
	BOOL callLogContactDataHasChanged;
	BOOL contactListDataHasChanged;
	BOOL isNeedsUpdate;
	NSArray *contactArray;
	NSMutableDictionary *contactNumberDic;
}

@property (nonatomic,retain) NSArray *contactArray;
@property (nonatomic,retain) NSMutableDictionary *contactNumberDic;

- (NSArray *)contactData;

- (NSArray *)getCallLogContactData;

- (NSArray *)getContactListData;

+ (AddressBookDataManager *)sharedAddressBookDataManager;

@end
