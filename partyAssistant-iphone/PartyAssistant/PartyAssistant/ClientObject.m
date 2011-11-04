//
//  ClientObject.m
//  PartyAssistant
//
//  Created by 超 李 on 11-10-26.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "ClientObject.h"

@implementation ClientObject

@synthesize cID,cName,cVal;

- (id)init
{
    self = [super init];
    
    if (self) {
		self.cID = -1;
        self.cName = @"";
        self.cVal = @"";
    }
    
    return self;
}

- (void) encodeWithCoder: (NSCoder *) encoder {
    [encoder encodeObject: [NSNumber numberWithInteger:self.cID] forKey:@"cID"];
	[encoder encodeObject: self.cName forKey:@"cName"];
	[encoder encodeObject: self.cVal forKey:@"cVal"];
}

- (id) initWithCoder: (NSCoder *) decoder {
    self.cID = [[decoder decodeObjectForKey:@"cID"] integerValue];
	self.cName = [decoder decodeObjectForKey:@"cName"];
	self.cVal = [decoder decodeObjectForKey:@"cVal"];
	
	return self;
}

- (void)clearObject{
	self.cID = -1;
    self.cName = @"";
    self.cVal = @"";
}

@end
