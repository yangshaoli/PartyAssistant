//
//  BaseInfoObject.m
//  PartyAssistant
//
//  Created by 超 李 on 11-10-26.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "BaseInfoObject.h"

@implementation BaseInfoObject
@synthesize starttimeStr, starttimeDate, location, description, peopleMaximum, userObject, partyId;

- (id)init
{
    self = [super init];
    
    if (self) {
		self.starttimeStr = @"";
        self.starttimeDate = nil;
        self.location = @"";
        self.description = @"";
        self.peopleMaximum = [NSNumber numberWithInt:0];
        self.userObject = [[UserObjectService sharedUserObjectService] getUserObject];
        self.partyId = [NSNumber numberWithInt:-1];
    }
    
    return self;
}

- (void) encodeWithCoder: (NSCoder *) encoder {
    [encoder encodeObject: self.starttimeStr forKey:@"starttimeStr"];
    [encoder encodeObject: self.starttimeDate forKey:@"starttimeDate"];
	[encoder encodeObject: self.location forKey:@"location"];
	[encoder encodeObject: self.description forKey:@"description"];
	[encoder encodeObject: self.peopleMaximum forKey:@"peopleMaximum"];
    [encoder encodeObject: self.userObject forKey:@"userObject"];
    [encoder encodeObject: self.partyId forKey:@"partyId"];
}

- (id) initWithCoder: (NSCoder *) decoder {
    self.starttimeStr = [decoder decodeObjectForKey:@"starttimeStr"];
    self.starttimeDate = [decoder decodeObjectForKey:@"starttimeDate"];
	self.location = [decoder decodeObjectForKey:@"location"];
	self.description = [decoder decodeObjectForKey:@"description"];
	self.peopleMaximum = [decoder decodeObjectForKey:@"peopleMaximum"];
    self.userObject = [decoder decodeObjectForKey:@"userObject"];
    self.partyId = [decoder decodeObjectForKey:@"partyId"];
	return self;
}

- (void)clearObject{
	self.starttimeStr = @"";
    self.starttimeDate = nil;
    self.location = @"";
    self.description = @"";
    self.peopleMaximum = [NSNumber numberWithInt:0];
    self.userObject = [[UserObjectService sharedUserObjectService] getUserObject];
    self.partyId = [NSNumber numberWithInt:-1];
}

- (void)formatDateToString{
    if (self.starttimeDate == nil) {
        self.starttimeStr = @"";
    }else{
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init]; 
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"]; 
        self.starttimeStr = [dateFormatter stringFromDate:self.starttimeDate];
    }
}

- (void)formatStringToDate{
    if (self.starttimeStr == nil) {
        self.starttimeStr = @"";
        self.starttimeDate = nil;
    }else if([self.starttimeStr isEqualToString:@""]){
        self.starttimeStr = @"";
        self.starttimeDate = nil;
    }else{
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init]; 
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"]; 
        
        self.starttimeDate = [dateFormatter dateFromString:self.starttimeStr];
    }
}
@end
