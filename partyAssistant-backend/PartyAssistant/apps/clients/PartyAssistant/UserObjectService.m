//
//  UserObjectService.m
//  PartyAssistant
//
//  Created by 超 李 on 11-11-4.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "UserObjectService.h"

@implementation UserObjectService
@synthesize userObject;

SYNTHESIZE_SINGLETON_FOR_CLASS(UserObjectService)

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (UserObject *)getUserObject
{
    if (userObject) {
        return userObject;
    }
    
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString* documentsDirectory = [paths objectAtIndex:0];
    
    NSString* fullPathToFile = [documentsDirectory stringByAppendingPathComponent:USEROBJECTFILE];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:fullPathToFile];
    if (fileExists) {
        NSData *theData = [NSData dataWithContentsOfFile:fullPathToFile];
        NSKeyedUnarchiver *decoder = [[NSKeyedUnarchiver alloc] initForReadingWithData:theData];
        self.userObject = [decoder decodeObjectForKey:USEROBJECTKEY];
    } else {
        self.userObject = [[UserObject alloc] init];
    }
    
    return self.userObject;
}
- (void)saveUserObject
{
    if (!self.userObject) {
        return;
    }
    
    NSMutableData *theData = [NSMutableData data];
    NSKeyedArchiver *encoder = [[NSKeyedArchiver alloc] initForWritingWithMutableData:theData];
    
    [encoder encodeObject:self.userObject forKey:USEROBJECTKEY];
    [encoder finishEncoding];
    
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString* documentsDirectory = [paths objectAtIndex:0];
    
    NSString* fullPathToFile = [documentsDirectory stringByAppendingPathComponent:USEROBJECTFILE];
    [theData writeToFile:fullPathToFile atomically:YES];
}
- (void)clearUserObject
{
    [self.userObject clearObject];
}

@end
