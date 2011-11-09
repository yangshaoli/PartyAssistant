//
//  PartyListService.m
//  PartyAssistant
//
//  Created by 超 李 on 11-11-6.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "PartyListService.h"

@implementation PartyListService
@synthesize partyList;

SYNTHESIZE_SINGLETON_FOR_CLASS(PartyListService)

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (NSArray *)getPartyList
{
    if (partyList) {
        return partyList;
    }
    
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString* documentsDirectory = [paths objectAtIndex:0];
    
    NSString* fullPathToFile = [documentsDirectory stringByAppendingPathComponent:PARTYLISTFILE];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:fullPathToFile];
    if (fileExists) {
        NSData *theData = [NSData dataWithContentsOfFile:fullPathToFile];
        NSKeyedUnarchiver *decoder = [[NSKeyedUnarchiver alloc] initForReadingWithData:theData];
        self.partyList = [decoder decodeObjectForKey:PARTYLISTKEY];
    } else {
        self.partyList = [[NSMutableArray alloc] initWithCapacity:0];
    }
    
    return self.partyList;
}
- (void)savePartyList
{
    if (!self.partyList) {
        return;
    }
    
    NSMutableData *theData = [NSMutableData data];
    NSKeyedArchiver *encoder = [[NSKeyedArchiver alloc] initForWritingWithMutableData:theData];
    
    [encoder encodeObject:self.partyList forKey:PARTYLISTKEY];
    [encoder finishEncoding];
    
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString* documentsDirectory = [paths objectAtIndex:0];
    
    NSString* fullPathToFile = [documentsDirectory stringByAppendingPathComponent:PARTYLISTFILE];
    [theData writeToFile:fullPathToFile atomically:YES];
}

- (NSArray *)addPartyList:(BaseInfoObject *)baseinfo
{
    [self.partyList addObject:baseinfo];
    return partyList;
}
- (void)clearPartyList
{
    self.partyList = [[NSMutableArray alloc]initWithCapacity:0];
}

@end
