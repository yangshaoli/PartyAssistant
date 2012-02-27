//
//  LocationSearchResult.m
//  LocationSearchAndHistory
//
//  Created by Wang Jun on 2/22/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "LocationSearchResult.h"

@implementation LocationSearchResult
@synthesize locationName;
@synthesize locationCity;
@synthesize locationAddress;
@synthesize coordinate;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)dealloc {
    [locationName release];
    [locationCity release];
    [locationAddress release];
    
    [super dealloc];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"location name:%@ city:%@ address:%@ coordinate: %f %f",locationName, locationCity,locationAddress,coordinate.latitude,coordinate.longitude];
}
@end
