//
//  AddressBookDBService.h
//  PartyAssistant
//
//  Created by Yang Shaoli on 11-12-14.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//
//***************************************************************************************************//
//  Example:
//  int count=0;
//  AddressBookDBService *s = [AddressBookDBService sharedAddressBookDBService];
//  NSArray *contacts = [ABContactsHelper contactsMatchingName:@"李"];
//  for (ABContact *contact in contacts) {
//      [s useContact:contact];  
//      count = [s getFavoriteRecordCount:contact];
//      NSLog(@"For Loop: first name = %@, last name = %@, count=%d", contact.firstname, contact.lastname,     count);
//  }
//***************************************************************************************************//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@class ClientObject;

@interface AddressBookDBService : NSObject {
    NSMutableArray *myFavorites;
}

@property(nonatomic, retain) NSMutableArray *myFavorites;

+ (AddressBookDBService *)sharedAddressBookDBService;
- (void)loadMyFavorites;
- (void)loadMyFavoritesByDB:(sqlite3 *)database;
- (int)getFavoriteRecordCount:(ClientObject *)contact;
- (void)addFavoriteRecord:(ClientObject *)contact;
- (void)useContact:(ClientObject *)contact;

@end
