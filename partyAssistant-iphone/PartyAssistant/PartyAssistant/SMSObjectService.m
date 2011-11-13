//
//  SMSObjectService.m
//  PartyAssistant
//
//  Created by 超 李 on 11-11-3.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "SMSObjectService.h"

@implementation SMSObjectService
@synthesize smsObject;

SYNTHESIZE_SINGLETON_FOR_CLASS(SMSObjectService)

-(SMSObject *)getSMSObject{
    if (smsObject) {
        return smsObject;
    }
    
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString* documentsDirectory = [paths objectAtIndex:0];
    
    NSString* fullPathToFile = [documentsDirectory stringByAppendingPathComponent:SMSOBJECTFILE];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:fullPathToFile];
    if (fileExists) {
        NSData *theData = [NSData dataWithContentsOfFile:fullPathToFile];
        NSKeyedUnarchiver *decoder = [[NSKeyedUnarchiver alloc] initForReadingWithData:theData];
        self.smsObject = [decoder decodeObjectForKey:SMSOBJECTKEY];
    } else {
        self.smsObject = [[SMSObject alloc] init];
    }
    
    return self.smsObject;
}

-(void)saveSMSObject{
    if (!self.smsObject) {
        return;
    }
    NSMutableData *theData = [NSMutableData data];
    NSKeyedArchiver *encoder = [[NSKeyedArchiver alloc] initForWritingWithMutableData:theData];
    
    [encoder encodeObject:self.smsObject forKey:SMSOBJECTKEY];
    [encoder finishEncoding];
    
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString* documentsDirectory = [paths objectAtIndex:0];
    
    NSString* fullPathToFile = [documentsDirectory stringByAppendingPathComponent:SMSOBJECTFILE];
    [theData writeToFile:fullPathToFile atomically:YES];
    
    
}

-(void)clearBaseInfo{
	[self.smsObject clearObject];
}
@end
