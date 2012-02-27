//
//  LocationSearchResult.h
//  LocationSearchAndHistory
//
//  Created by Wang Jun on 2/22/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface LocationSearchResult : NSObject

@property (nonatomic, retain) NSString *locationName;
@property (nonatomic, retain) NSString *locationCity;
@property (nonatomic, retain) NSString *locationAddress;
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

@end
