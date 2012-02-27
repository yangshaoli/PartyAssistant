//
//  LocationHistory.h
//  LocationSearchAndHistory
//
//  Created by Wang Jun on 2/22/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface LocationHistory : NSManagedObject {
    
}

@property (nonatomic, retain) NSString *locationName;
@property (nonatomic, retain) NSString *locationCity;
@property (nonatomic, retain) NSString *locationAddress;
@property (nonatomic, retain) NSNumber *longitude;
@property (nonatomic, retain) NSNumber *latitude;
@property (nonatomic, retain) NSDate *touchedDate;
@end
