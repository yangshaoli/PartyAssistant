#import <Foundation/Foundation.h>
#import "ABContact.h"
#import "ABGroup.h"

//Address Book contact
#define KPHONELABELDICDEFINE	@"KPhoneLabelDicDefine"
#define KPHONENUMBERDICDEFINE	@"KPhoneNumberDicDefine"
#define KPHONENAMEDICDEFINE		@"KPhoneNameDicDefine"

@interface ContactData : NSObject {

}
+ (NSArray *)contactsArray; // people
+ (NSDictionary *)contactsNumberDictionary;
+ (NSArray *)groupsArray;
+ (NSArray *)groupsArrayByRecordRef:(ABRecordRef)abRef;
+ (NSArray *)contactsArrayByRecordRef:(ABRecordRef)abRef;

+ (NSDictionary *) hasContactsExistInAddressBookByPhone:(NSString *)phone;

//Get contact
+(ABContact *) byPhoneNumberAndLabelToGetContact:(NSString *)phone withLabel:(NSString *)label;
+(ABContact *) byPhoneNumberAndNameToGetContact:(NSString *)name withPhone:(NSString *)phone;
+(ABContact *) byNameToGetContact:(NSString *)name;
+(ABContact *) byPhoneNumberlToGetContact:(NSString *)phone withLabel:(NSString *)label;

+(NSArray *) getPhoneNumberAndPhoneLabelArray:(ABContact *) contact;
+(NSArray *) getPhoneNumberAndPhoneLabelArrayFromABRecodID:(ABRecordRef)person withABMultiValueIdentifier:(ABMultiValueIdentifier)identifierForValue;

+(NSString *) getPhoneNumberFromDic:(NSDictionary *) Phonedic;
+(NSString *) getPhoneLabelFromDic:(NSDictionary *) Phonedic;
+(NSString *) getPhoneNameFromDic:(NSDictionary *) Phonedic;

+ (BOOL)addPhone:(ABContact *)contact phone:(NSString*)phone;

+ (NSString *)getPhoneNumberFomat:(NSString *)phone;

+ (BOOL)doesStringContain:(NSString* )string Withstr:(NSString*)charcter;

+(NSString *)equalContactByAddressBookContacts:(NSString *)name withPhone:(NSString *)phone withLabel:(NSString *)label PhoneOrLabel:(BOOL)isPhone withFavorite:(BOOL)isFavorite;

+(NSString *)getContactsNameByPhoneNumberAndLabel:(NSString *)phone withLabel:(NSString *)label;

+ (BOOL) removeSelfFromAddressBook:(ABContact *)contact withErrow:(NSError **) error;

+(BOOL)searchResult:(NSString *)contactName searchText:(NSString *)searchT;
@end
