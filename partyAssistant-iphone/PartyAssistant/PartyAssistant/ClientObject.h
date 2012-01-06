//
//  ClientObject.h
//  PartyAssistant
//
//  Created by 超 李 on 11-10-26.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>

@interface ClientObject : NSObject
{
    NSInteger cID;
    NSInteger backendID;
    NSString *cName;
    NSString *cVal;
    NSInteger phoneIdentifier;
    NSString *phoneLabel;
}

@property(nonatomic, assign)NSInteger cID;
@property(nonatomic, assign)NSInteger backendID;
@property(nonatomic, retain)NSString *cName;
@property(nonatomic, retain)NSString *cVal;
@property(nonatomic, assign)NSInteger phoneIdentifier;
@property(nonatomic, retain)NSString *phoneLabel;

- (void)searchClientIDByPhone;
- (void)searchClientIDByEmail;
- (void)clearObject;

@end
