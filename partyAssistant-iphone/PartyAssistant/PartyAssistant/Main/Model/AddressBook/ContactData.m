#import "ContactData.h"
#import "AddressBookDataManager.h"
#import "PartyAssistantAppDelegate.h"

@implementation ContactData

//get all of contacts from address book
//get all of contacts from address book
+ (NSArray *)contactsArray
{
	//NSArray *thePeople = (NSArray *)ABAddressBookCopyArrayOfAllPeopleInSourceWithSortOrdering(addressBook, addressBook, kABPersonSortByFirstName);
//	NSMutableArray *array = [NSMutableArray arrayWithCapacity:thePeople.count];
//	for (id person in thePeople)
//		[array addObject:[ABContact contactWithRecord:(ABRecordRef)person]];
//	[thePeople release];
//	return array;
	return [[AddressBookDataManager sharedAddressBookDataManager] getContactListData];
}

+ (NSDictionary *)contactsNumberDictionary {
//	//ABAddressBookRef aAddressBook = ABAddressBookCreate();
//	NSArray *thePeople = (NSArray *)ABAddressBookCopyArrayOfAllPeopleInSourceWithSortOrdering(addressBook, addressBook, kABPersonSortByFirstName);
//	NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithCapacity:thePeople.count];
//    NSString *aNumber;
//	for (id person in thePeople) {
//        ABContact *contact = [ABContact contactWithRecord:(ABRecordRef)person];
//        NSArray *numbers = [contact phoneArray];
//        for (NSString *number in numbers) {
//            aNumber = [number stringByReplacingOccurrencesOfString:@"+" withString:@""];
//            aNumber = [aNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
//            aNumber = [aNumber stringByReplacingOccurrencesOfString:@"(" withString:@""];
//            aNumber = [aNumber stringByReplacingOccurrencesOfString:@")" withString:@""];
//            aNumber = [aNumber stringByReplacingOccurrencesOfString:@"+" withString:@""];
//            aNumber = [aNumber stringByReplacingOccurrencesOfString:@"#" withString:@""];
//            aNumber = [aNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
//            [dictionary setValue:contact forKey:aNumber];
//        }
//    }
//		
//	[thePeople release];
//	//CFRelease(aAddressBook);
//	return dictionary;
	return [[AddressBookDataManager sharedAddressBookDataManager] getCallLogContactData];
}


//get all of groups from address book
+ (NSArray *)groupsArray {
	NSArray *theGroup = (NSArray *)ABAddressBookCopyArrayOfAllGroups(addressBook);
	NSMutableArray *array = [NSMutableArray arrayWithCapacity:theGroup.count];
	for (id group in theGroup)
		[array addObject:[ABGroup groupWithRecord:(ABRecordRef)group]];
	[theGroup release];
	return array;	
}

+ (NSArray *)contactsArrayByRecordRef:(ABRecordRef)abRef {
	NSArray *thePeople = (NSArray *)ABGroupCopyArrayOfAllMembers(abRef);
	NSMutableArray *array = [NSMutableArray arrayWithCapacity:thePeople.count];
	for (id person in thePeople)
		[array addObject:[ABContact contactWithRecord:(ABRecordRef)person]];
	[thePeople release];
	return array;	
}

+ (NSArray *) groupsArrayByRecordRef:(ABRecordRef)abRef {
	NSArray *theGroup = (NSArray *)ABAddressBookCopyArrayOfAllGroupsInSource(addressBook, abRef);
	NSMutableArray *array = [NSMutableArray arrayWithCapacity:theGroup.count];
	for (id group in theGroup)
		[array addObject:[ABGroup groupWithRecord:(ABRecordRef)group]];
	[theGroup release];
	return array;
}

+ (NSDictionary *) hasContactsExistInAddressBookByPhone:(NSString *)phone{
	NSString *PhoneNumber = nil;
	NSString *PhoneLabel = nil;
	NSString *PhoneName = nil;
	NSArray *contactarray = [ContactData contactsArray];
	for(int i=0; i<[contactarray count]; i++)
	{
		ABContact *contact = [contactarray objectAtIndex:i];
		NSArray *phoneCount = [ContactData getPhoneNumberAndPhoneLabelArray:contact];
		if([phoneCount count] > 0)
		{
			NSDictionary *PhoneDic = [phoneCount objectAtIndex:0];
			PhoneNumber = [ContactData getPhoneNumberFromDic:PhoneDic];
			PhoneLabel = [ContactData getPhoneLabelFromDic:PhoneDic];
			PhoneName = contact.contactName;
			if([PhoneNumber isEqualToString:phone])
			{
				NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:PhoneName,KPHONENAMEDICDEFINE,PhoneNumber,KPHONENUMBERDICDEFINE,PhoneLabel,KPHONELABELDICDEFINE,nil ];
				return dic;
			}
		}
	}
	return nil;
}

+(ABContact *) byPhoneNumberAndLabelToGetContact:(NSString *)phone withLabel:(NSString *)label{
	NSArray *array = [ContactData contactsArray];
	for(ABContact * contast in array)
	{
		NSArray *phoneArray = [ContactData getPhoneNumberAndPhoneLabelArray:contast];
		if(phoneArray == nil)
			return nil;
		for(NSDictionary *dic in phoneArray)
		{
			NSString *aPhone = [ContactData getPhoneNumberFromDic:dic];
			NSString *aLabel = [ContactData getPhoneLabelFromDic:dic];
			if([aPhone isEqualToString:phone] && [aLabel isEqualToString:label])
				return (ABContact *)contast;
		}
	}
	return nil;
}

+(ABContact *) byPhoneNumberAndNameToGetContact:(NSString *)name withPhone:(NSString *)phone{
	NSArray *array = [ContactData contactsArray];
	for(ABContact * contast in array)
	{
		NSArray *phoneArray = [ContactData getPhoneNumberAndPhoneLabelArray:contast];
		if(phoneArray == nil)
			return nil;
		for(NSDictionary *dic in phoneArray)
		{
			NSString *aPhone = [ContactData getPhoneNumberFromDic:dic];
			//	NSString *aLabel = [ContactData getPhoneLabelFromDic:dic];
			if([aPhone isEqualToString:phone] && [name isEqualToString:contast.contactName])
				return (ABContact *)contast;
		}
	}
	return nil;
}

+(ABContact *) byNameToGetContact:(NSString *)name{
	NSArray *array = [ContactData contactsArray];
	for(ABContact * contact in array)
	{
		if([contact.contactName isEqualToString:name])
			return (ABContact *)contact;
	}
	return nil;
}

+(ABContact *) byPhoneNumberlToGetContact:(NSString *)phone withLabel:(NSString *)label{
	NSArray *array = [ContactData contactsArray];
	for(ABContact * contast in array)
	{
		NSArray *phoneArray = [ContactData getPhoneNumberAndPhoneLabelArray:contast];
		if(phoneArray == nil)
			return nil;
		for(NSDictionary *dic in phoneArray)
		{
			NSString *aPhone = [ContactData getPhoneNumberFromDic:dic];
			//NSString *aLabel = [ContactData getPhoneLabelFromDic:dic];
			if([aPhone isEqualToString:phone] && [label isEqualToString:@"未知"])
				return (ABContact *)contast;
		}
	}
	return nil;
}

+(NSArray *) getPhoneNumberAndPhoneLabelArray:(ABContact *) contact
{
	NSMutableDictionary *phoneDic = [[[NSMutableDictionary alloc] init] autorelease];
	NSMutableArray *phoneArray = [[[NSMutableArray alloc] init] autorelease];
	ABMutableMultiValueRef phoneMulti = ABRecordCopyValue(contact.record, kABPersonPhoneProperty);
	int i;
	for (i = 0;  i < ABMultiValueGetCount(phoneMulti);  i++) {
		NSString *phone = [(NSString*)ABMultiValueCopyValueAtIndex(phoneMulti, i) autorelease];
		NSString *label =  [(NSString*)ABMultiValueCopyLabelAtIndex(phoneMulti, i) autorelease];
		phoneDic = [NSDictionary dictionaryWithObjectsAndKeys:contact.contactName,KPHONENAMEDICDEFINE,phone,KPHONENUMBERDICDEFINE,label,KPHONELABELDICDEFINE,nil];
		[phoneArray addObject:phoneDic];
	}
	return phoneArray;
	CFRelease(phoneMulti);
}

+(NSArray *) getPhoneNumberAndPhoneLabelArrayFromABRecodID:(ABRecordRef)person withABMultiValueIdentifier:(ABMultiValueIdentifier)identifierForValue
{
	NSString *nameStr = (NSString *)ABRecordCopyCompositeName(person);
	NSMutableDictionary *phoneDic = [[[NSMutableDictionary alloc] init] autorelease];
	NSMutableArray *phoneArray = [[[NSMutableArray alloc] init] autorelease];
	ABMutableMultiValueRef phoneMulti = ABRecordCopyValue(person, kABPersonPhoneProperty);
	NSString *phone = [(NSString*)ABMultiValueCopyValueAtIndex(phoneMulti, identifierForValue) autorelease];
	NSString *label =  [(NSString*)ABMultiValueCopyLabelAtIndex(phoneMulti, identifierForValue) autorelease];
	phoneDic = [NSDictionary dictionaryWithObjectsAndKeys:nameStr,KPHONENAMEDICDEFINE,phone,KPHONENUMBERDICDEFINE,label,KPHONELABELDICDEFINE,nil];
	[phoneArray addObject:phoneDic];
	CFRelease(phoneMulti);
	return phoneArray;
}

+(NSString *) getPhoneNumberFromDic:(NSDictionary *) Phonedic
{
	NSString * phoneNumber = [Phonedic objectForKey:KPHONENUMBERDICDEFINE];
	return [ContactData getPhoneNumberFomat:phoneNumber];
}

+(NSString *) getPhoneNameFromDic:(NSDictionary *) Phonedic
{
	NSString * phoneName = [Phonedic objectForKey:KPHONENAMEDICDEFINE];
	return phoneName;
}

+(NSString *) getPhoneLabelFromDic:(NSDictionary *) Phonedic
{
	NSString * PhoneLabel = [Phonedic objectForKey:KPHONELABELDICDEFINE];
	if([PhoneLabel isEqualToString:@"_$!<Mobile>!$_"])
		PhoneLabel = @"移动电话";
	else if([PhoneLabel isEqualToString:@"_$!<Home>!$_"])
		PhoneLabel = @"住宅";
	else if([PhoneLabel isEqualToString:@"_$!<Work>!$_"])
		PhoneLabel = @"工作";
	else if([PhoneLabel isEqualToString:@"_$!<Main>!$_"])
		PhoneLabel = @"主要";
	else if([PhoneLabel isEqualToString:@"_$!<HomeFAX>!$_"])
		PhoneLabel = @"住宅传真";
	else if([PhoneLabel isEqualToString:@"_$!<WorkFAX>!$_"])
		PhoneLabel = @"工作传真";
	else if([PhoneLabel isEqualToString:@"_$!<Pager>!$_"])
		PhoneLabel = @"传呼";
	else if([PhoneLabel isEqualToString:@"_$!<Other>!$_"])
		PhoneLabel = @"其它";
	return PhoneLabel;
}

+ (BOOL)addPhone:(ABContact *)contact phone:(NSString*)phone{
    ABMutableMultiValueRef multi = ABMultiValueCreateMutable(kABMultiStringPropertyType);
    CFErrorRef anError = NULL;
    
    // The multivalue identifier of the new value isn't used in this example,
    // multivalueIdentifier is just for illustration purposes.  Real-world
    // code can use this identifier to do additional work with this value.
    ABMultiValueIdentifier multivalueIdentifier;
    
    if (!ABMultiValueAddValueAndLabel(multi, (CFStringRef)phone, kABPersonPhoneMainLabel, &multivalueIdentifier)){
        CFRelease(multi);
        return NO;
    }
	
    if (!ABRecordSetValue(contact.record, kABPersonPhoneProperty, multi, &anError)){
        CFRelease(multi);
        return NO;
    }
    CFRelease(multi);
    return YES;
}

+ (NSString *)getPhoneNumberFomat:(NSString *)phone{
	if([phone length] <1)
		return nil;
	NSString* telNumber = @"";
	for (int i=0; i<[phone length]; i++) {
		NSString* chr = [phone substringWithRange:NSMakeRange(i, 1)];
		if([ContactData doesStringContain:@"0123456789" Withstr:chr]) {
			/*if([telNumber length] == 3 || [telNumber length] == 8)
			 telNumber = [telNumber stringByAppendingFormat:@"-%@", chr];
			 else
			 telNumber = [telNumber stringByAppendingFormat:@"%@", chr];*/
			telNumber = [telNumber stringByAppendingFormat:@"%@", chr];
		}
	}
	return telNumber;
}

+ (BOOL)doesStringContain:(NSString* )string Withstr:(NSString*)charcter{
	if([string length] < 1)
		return FALSE;
	for (int i=0; i<[string length]; i++) {
		NSString* chr = [string substringWithRange:NSMakeRange(i, 1)];
		if([chr isEqualToString:charcter])
			return TRUE;
	}
	return FALSE;
}

+(NSString *)equalContactByAddressBookContacts:(NSString *)name withPhone:(NSString *)phone withLabel:(NSString *)label PhoneOrLabel:(BOOL)isPhone withFavorite:(BOOL)isFavorite
{
	ABContact *contact = nil;
	NSArray *array;
	NSString *phoneNumber = @"";
	NSString *phoneLabel = @"";
	if(isFavorite)
		contact = [ContactData byNameToGetContact:name];
	if(!contact)
		contact = [ContactData byPhoneNumberAndLabelToGetContact:phone withLabel:label];
	if(!contact)
		contact = [ContactData byPhoneNumberAndNameToGetContact:name withPhone:phone];
	if([label isEqualToString:@"未知"] && contact == nil)
		contact = [ContactData byPhoneNumberlToGetContact:phone withLabel:label];
	if(contact)
	{
		array = [ContactData getPhoneNumberAndPhoneLabelArray:contact];
	}
	if(contact == nil)
		return nil;
	if([array count] == 1)
	{
		NSDictionary *PhoneDic = [array objectAtIndex:0];
		phoneNumber = [ContactData getPhoneNumberFromDic:PhoneDic];
		phoneLabel = [ContactData getPhoneLabelFromDic:PhoneDic];
	}else  if([array count] > 1)
	{
		for(NSDictionary *dic in array)
		{
			NSString *aPhone = [ContactData getPhoneNumberFromDic:dic];
			NSString *aLabel = [ContactData getPhoneLabelFromDic:dic];
			if([phone isEqualToString:aPhone] && [label isEqualToString:aLabel])
			{
				phoneNumber = aPhone;
				phoneLabel = aLabel;
				break;
			}
		}
	}
	if(isPhone)
		return phoneNumber;
	else
		return phoneLabel;
}

+(NSString *)getContactsNameByPhoneNumberAndLabel:(NSString *)phone withLabel:(NSString *)label{
	NSArray *array = [ContactData contactsArray];
	for(ABContact * contast in array)
	{
		NSArray *phoneArray = [ContactData getPhoneNumberAndPhoneLabelArray:contast];
		if(phoneArray == nil)
			return nil;
		for(NSDictionary *dic in phoneArray)
		{
			NSString *aPhone = [ContactData getPhoneNumberFromDic:dic];
			NSString *aLabel = [ContactData getPhoneLabelFromDic:dic];
			if([aPhone isEqualToString:phone] && [aLabel isEqualToString:label])
				return contast.contactName;
		}
	}
	return nil;	
}

+(BOOL) removeSelfFromAddressBook:(ABContact *)contact withErrow:(NSError **) error
{
	if (!ABAddressBookRemoveRecord(addressBook, contact.record, (CFErrorRef *) error)) return NO;
	return ABAddressBookSave(addressBook,  (CFErrorRef *) error);
}

+(BOOL)searchResult:(NSString *)contactName searchText:(NSString *)searchT{
	NSComparisonResult result = [contactName compare:searchT options:NSCaseInsensitiveSearch
											   range:NSMakeRange(0, searchT.length)];
	if (result == NSOrderedSame)
		return YES;
	else
		return NO;
}

@end
