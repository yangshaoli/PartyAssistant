//
//  ClientObject.m
//  PartyAssistant
//
//  Created by 超 李 on 11-10-26.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "ClientObject.h"
#import "ABContact.h"
#import "AddressBookDataManager.h"
#import "PartyAssistantAppDelegate.h"
#import "ABContactsHelper.h"

#define PhoneNumberLength 11

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

- (void)searchClientIDByName {
    if (self.cID == -1) {
        NSArray *contacts;
        @try {
            contacts = [ABContactsHelper contactsEqualsName:self.cName];
        }
        @catch (NSException * e) {
            NSLog(@"Exception: %@", e); 
            return;
        }
        
        if ([contacts count] == 0) {
            return;
        } else {
            ABContact *theContact = [contacts lastObject];
            
            if (theContact) {
                ABRecordID contactID = theContact.recordID;
                ABRecordRef theSelectContact = ABAddressBookGetPersonWithRecordID(addressBook, contactID);
                ABMultiValueRef phone = ABRecordCopyValue(theSelectContact, kABPersonPhoneProperty);

                NSInteger selectIndex = -1;
                for (int i=0; i<ABMultiValueGetCount(phone); i++) {
                    NSString *number = (__bridge_transfer NSString*)ABMultiValueCopyValueAtIndex(phone, i);
                    
                    self.cVal = number;
                    
                    selectIndex = i;
                    
                    break;
                }
                
                if (selectIndex == -1) {
                    
                } else {
                    ABMultiValueIdentifier indentifier = ABMultiValueGetIdentifierAtIndex(phone, selectIndex);
                    NSString *label = (__bridge NSString *)ABMultiValueCopyLabelAtIndex(phone, selectIndex);
                    self.phoneIdentifier = indentifier;
                    self.cID = contactID;
                    self.phoneLabel = label;
                }
            }

        }
    }
}

- (void)searchClientIDByPhone{
    if (self.cID == -1) {  
        NSDictionary *contactPhoneDic = [[AddressBookDataManager sharedAddressBookDataManager] getCallLogContactData];
            
        NSString *phoneNumber = self.cVal;
        
        BOOL isNeedNewName = NO;
        
        if ([self.cName isEqualToString:@""]) {
            isNeedNewName = YES;
        }
        
        ABContact *theContact = [contactPhoneDic objectForKey:phoneNumber];
        
        if (theContact) {
            
            ABRecordID contactID = theContact.recordID;
            ABRecordRef theSelectContact = ABAddressBookGetPersonWithRecordID(addressBook, contactID);
            ABMultiValueRef phone = ABRecordCopyValue(theSelectContact, kABPersonPhoneProperty);
            
            
            NSString *aNumber = nil;
            NSInteger selectIndex = -1;
            for (int i=0; i<ABMultiValueGetCount(phone); i++) {
                NSString *number = (__bridge_transfer NSString*)ABMultiValueCopyValueAtIndex(phone, i);
                aNumber = [number stringByReplacingOccurrencesOfString:@"+" withString:@""];
                aNumber = [aNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
                aNumber = [aNumber stringByReplacingOccurrencesOfString:@"(" withString:@""];
                aNumber = [aNumber stringByReplacingOccurrencesOfString:@")" withString:@""];
                aNumber = [aNumber stringByReplacingOccurrencesOfString:@"+" withString:@""];
                aNumber = [aNumber stringByReplacingOccurrencesOfString:@"#" withString:@""];
                aNumber = [aNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
                
                if ([aNumber isEqualToString:phoneNumber]) {
                    selectIndex = i;
                    if (isNeedNewName) {
                        self.cName = [theContact contactName];
                    }
                    break;
                }
            }
            
            if (selectIndex == -1) {
                
            } else {
                ABMultiValueIdentifier indentifier = ABMultiValueGetIdentifierAtIndex(phone, selectIndex);
                NSString *label = (__bridge NSString *)ABMultiValueCopyLabelAtIndex(phone, selectIndex);
                self.phoneIdentifier = indentifier;
                self.cID = contactID;
                self.phoneLabel = label;
            }
        }
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

- (BOOL)isClientValid {
    return self.cID == -1 ? NO : YES;
}

- (BOOL)isClientPhoneNumberValid {
    NSMutableString *strippedString = [NSMutableString 
                                       stringWithCapacity:PhoneNumberLength];
    
    NSScanner *scanner = [NSScanner scannerWithString:self.cVal];
    NSCharacterSet *numbers = [NSCharacterSet 
                               characterSetWithCharactersInString:@"0123456789"];
    
    while ([scanner isAtEnd] == NO) {
        NSString *buffer;
        if ([scanner scanCharactersFromSet:numbers intoString:&buffer]) {
            [strippedString appendString:buffer];
            
        } else {
            [scanner setScanLocation:([scanner scanLocation] + 1)];
        }
    }
    
    int stringLength = [strippedString length];
    if (stringLength >= 11) {
        if ([strippedString characterAtIndex:stringLength - PhoneNumberLength]== '1') {
            return YES;
        }
    }
    
    return NO;
}
@end
