//
//  ClientObject.m
//  PartyAssistant
//
//  Created by 超 李 on 11-10-26.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "ClientObject.h"

@implementation ClientObject

@synthesize cID,cName,cVal,backendID;
@synthesize phoneIdentifier;
@synthesize phoneLabel;
- (id)init
{
    self = [super init];
    
    if (self) {
		self.cID = -1;
        self.cName = @"";
        self.cVal = @"";
        self.backendID = -1;
        self.phoneIdentifier = -1;
        self.phoneLabel = @"";
    }
    
    return self;
}

- (void) encodeWithCoder: (NSCoder *) encoder {
    [encoder encodeObject: [NSNumber numberWithInteger:self.cID] forKey:@"cID"];
	[encoder encodeObject: self.cName forKey:@"cName"];
	[encoder encodeObject: self.cVal forKey:@"cVal"];
    [encoder encodeObject: [NSNumber numberWithInteger:self.backendID] forKey:@"backendID"];
    [encoder encodeObject: [NSNumber numberWithInteger:self.phoneIdentifier] forKey:@"phoneIdentifier"];
    [encoder encodeObject: self.phoneLabel forKey:@"phoneLabel"];
    
}

- (id) initWithCoder: (NSCoder *) decoder {
    self.cID = [[decoder decodeObjectForKey:@"cID"] integerValue];
	self.cName = [decoder decodeObjectForKey:@"cName"];
	self.cVal = [decoder decodeObjectForKey:@"cVal"];
    self.backendID = [[decoder decodeObjectForKey:@"backendID"] integerValue];
	self.phoneIdentifier = [[decoder decodeObjectForKey:@"phoneIdentifier"] integerValue];
    self.phoneLabel = [decoder decodeObjectForKey:@"phoneLabel"];
    
	return self;
}

- (void)clearObject{
	self.cID = -1;
    self.cName = @"";
    self.cVal = @"";
    self.backendID = -1;
    self.phoneIdentifier = -1;
    self.phoneLabel = @"";
}

- (void)searchClientIDByPhone{
    if (self.cID == -1) {    
        ABAddressBookRef tempAddressBook = ABAddressBookCreate();
        CFArrayRef searchResult =  ABAddressBookCopyPeopleWithName (
                                                                    tempAddressBook,
                                                                    (__bridge CFStringRef)self.cName
                                                                    );
        if (!searchResult) {
            return;
        }
        for (int i=0; i<CFArrayGetCount(searchResult); i++) {
            ABRecordRef card = CFArrayGetValueAtIndex(searchResult, i);
            ABMultiValueRef phone = ABRecordCopyValue(card, kABPersonPhoneProperty);
            for (int j=0; j<ABMultiValueGetCount(phone); j++) {
                NSString *valStr = (__bridge_transfer NSString*)ABMultiValueCopyValueAtIndex(phone, j);
                if ([valStr isEqualToString:self.cVal]) {
                    NSLog(@"isEqual");
                    self.cID = ABRecordGetRecordID(card);
                    self.phoneIdentifier = ABMultiValueGetIdentifierAtIndex(phone, j);
                    self.phoneLabel = (__bridge_transfer NSString*)ABMultiValueCopyLabelAtIndex(phone, j);
                    break;
                }
                if (self.cID != -1) {
                    break;
                }
            }
        }
        CFRelease(tempAddressBook);
    }
}

- (void)searchClientIDByEmail{
    if (self.cID == -1) {    
        ABAddressBookRef addressBook = ABAddressBookCreate();
        CFArrayRef searchResult =  ABAddressBookCopyPeopleWithName (
                                                                    addressBook,
                                                                    (__bridge CFStringRef)self.cName
                                                                    );
        for (int i=0; i<CFArrayGetCount(searchResult); i++) {
            ABRecordRef card = CFArrayGetValueAtIndex(searchResult, i);
            ABMultiValueRef email = ABRecordCopyValue(card, kABPersonEmailProperty);
            for (int j=0; j<ABMultiValueGetCount(email); j++) {
                NSString *valStr = (__bridge_transfer NSString*)ABMultiValueCopyValueAtIndex(email, j);
                if ([valStr isEqualToString:self.cVal]) {
                    NSLog(@"isEqual");
                    self.cID = ABRecordGetRecordID(card);
                    break;
                }
                if (self.cID != -1) {
                    break;
                }
            }
        }
    }
}

- (NSString *)phoneLabel {
    CFStringRef label = (__bridge CFStringRef)phoneLabel;
    return (__bridge_transfer NSString*)ABAddressBookCopyLocalizedLabel(label);
}
@end
