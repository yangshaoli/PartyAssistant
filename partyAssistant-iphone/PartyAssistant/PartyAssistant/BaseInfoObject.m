//
//  BaseInfoObject.m
//  PartyAssistant
//
//  Created by 超 李 on 11-10-26.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "BaseInfoObject.h"

@implementation BaseInfoObject
@synthesize starttimeStr, starttimeDate, location, description, peopleMaximum, userId, partyId;

- (id)init
{
    self = [super init];
    
    if (self) {
		self.starttimeStr = @"";
        self.starttimeDate = nil;
        self.location = @"";
        self.description = @"";
        self.peopleMaximum = [NSNumber numberWithInt:0];
        self.userId = [NSNumber numberWithInt:0];
        self.partyId = [NSNumber numberWithInt:0];
    }
    
    return self;
}

- (void) encodeWithCoder: (NSCoder *) encoder {
    [encoder encodeObject: self.starttimeStr forKey:@"starttimeStr"];
	[encoder encodeObject: self.location forKey:@"location"];
	[encoder encodeObject: self.description forKey:@"description"];
	[encoder encodeObject: self.peopleMaximum forKey:@"peopleMaximum"];
    [encoder encodeObject: self.userId forKey:@"userId"];
    [encoder encodeObject: self.partyId forKey:@"partyId"];
}

- (id) initWithCoder: (NSCoder *) decoder {
    self.starttimeStr = [decoder decodeObjectForKey:@"starttimeStr"];
	self.location = [decoder decodeObjectForKey:@"location"];
	self.description = [decoder decodeObjectForKey:@"description"];
	self.peopleMaximum = [decoder decodeObjectForKey:@"peopleMaximum"];
    self.userId = [decoder decodeObjectForKey:@"userId"];
    self.partyId = [decoder decodeObjectForKey:@"partyId"];
	
	return self;
}

- (void)clearObject{
	self.starttimeStr = @"";
    self.starttimeDate = nil;
    self.location = @"";
    self.description = @"";
    self.peopleMaximum = 0;
    self.userId = 0;
    self.partyId = 0;
}
- (void)formatDateToString{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init]; 
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"]; 
    self.starttimeStr = [dateFormatter stringFromDate:self.starttimeDate];
}

@end
