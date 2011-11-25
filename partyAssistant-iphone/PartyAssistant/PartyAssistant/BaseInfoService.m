//
//  BaseInfoObjectServices.m
//  PartyAssistant
//
//  Created by 超 李 on 11-10-26.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "BaseInfoService.h"


@implementation BaseInfoService
@synthesize baseinfoObject;

SYNTHESIZE_SINGLETON_FOR_CLASS(BaseInfoService)

- (id)init
{
    self = [super init];
    self.baseinfoObject = [self getBaseInfo];
    return self;
}

-(BaseInfoObject *)getBaseInfo{
    if (baseinfoObject) {
        return baseinfoObject;
    }
    
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString* documentsDirectory = [paths objectAtIndex:0];
    
    NSString* fullPathToFile = [documentsDirectory stringByAppendingPathComponent:BASEINFOOBJECTFILE];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:fullPathToFile];
    if (fileExists) {
        NSData *theData = [NSData dataWithContentsOfFile:fullPathToFile];
        NSKeyedUnarchiver *decoder = [[NSKeyedUnarchiver alloc] initForReadingWithData:theData];
        self.baseinfoObject = [decoder decodeObjectForKey:BASEINFOOBJECTKEY];
    } else {
        self.baseinfoObject = [[BaseInfoObject alloc] init];
    }
    
    return self.baseinfoObject;
}

- (void)reorganizeData
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init]; 
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"]; 
    self.baseinfoObject.starttimeStr = [dateFormatter stringFromDate:baseinfoObject.starttimeDate];
    [self saveBaseInfo];
}

-(void)saveBaseInfo{
    if (!self.baseinfoObject) {
        return;
    }
    [self.baseinfoObject formatDateToString];
    NSMutableData *theData = [NSMutableData data];
    NSKeyedArchiver *encoder = [[NSKeyedArchiver alloc] initForWritingWithMutableData:theData];
    
    [encoder encodeObject:self.baseinfoObject forKey:BASEINFOOBJECTKEY];
    [encoder finishEncoding];
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString* documentsDirectory = [paths objectAtIndex:0];
    
    NSString* fullPathToFile = [documentsDirectory stringByAppendingPathComponent:BASEINFOOBJECTFILE];
    [theData writeToFile:fullPathToFile atomically:YES];
    
    
}

-(void)clearBaseInfo{
	[self.baseinfoObject clearObject];
}



@end
