//
//  EmailObjectsService.m
//  PartyAssistant
//
//  Created by 超 李 on 11-11-16.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "EmailObjectService.h"

@implementation EmailObjectService
@synthesize emailObject;

SYNTHESIZE_SINGLETON_FOR_CLASS(EmailObjectService)

-(EmailObject *)getEmailObject{
    if (emailObject) {
        return emailObject;
    }
    
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString* documentsDirectory = [paths objectAtIndex:0];
    
    NSString* fullPathToFile = [documentsDirectory stringByAppendingPathComponent:EMAILOBJECTFILE];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:fullPathToFile];
    if (fileExists) {
        NSData *theData = [NSData dataWithContentsOfFile:fullPathToFile];
        NSKeyedUnarchiver *decoder = [[NSKeyedUnarchiver alloc] initForReadingWithData:theData];
        self.emailObject = [decoder decodeObjectForKey:EMAILOBJECTKEY];
    } else {
        self.emailObject = [[EmailObject alloc] init];
    }
    
    return self.emailObject;
}

-(void)saveEmailObject{
    if (!self.emailObject) {
        return;
    }
    NSMutableData *theData = [NSMutableData data];
    NSKeyedArchiver *encoder = [[NSKeyedArchiver alloc] initForWritingWithMutableData:theData];
    
    [encoder encodeObject:self.emailObject forKey:EMAILOBJECTKEY];
    [encoder finishEncoding];
    
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString* documentsDirectory = [paths objectAtIndex:0];
    NSString* fullPathToFile = [documentsDirectory stringByAppendingPathComponent:EMAILOBJECTFILE];
    [theData writeToFile:fullPathToFile atomically:YES];
    
    
}

-(void)clearEmailObject{
	[self.emailObject clearObject];
}@end
