//
//  DeviceTokenService.m
//  PartyAssistant
//
//  Created by 超 李 on 11-12-8.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "DeviceTokenService.h"

@implementation DeviceTokenService

+ (NSString *)getDeviceToken{
    NSString *DeviceToken;
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString* documentsDirectory = [paths objectAtIndex:0];
    
    NSString* fullPathToFile = [documentsDirectory stringByAppendingPathComponent:DEVICETOKENFILE];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:fullPathToFile];
    if (fileExists) {
        NSData *theData = [NSData dataWithContentsOfFile:fullPathToFile];
        NSKeyedUnarchiver *decoder = [[NSKeyedUnarchiver alloc] initForReadingWithData:theData];
        DeviceToken = [decoder decodeObjectForKey:DEVICETOKENKEY];
    } else {
        DeviceToken = @"";
    }
    
    return DeviceToken;
}
+ (void)saveDeviceToken:(NSString *)DevieceToken{
    NSMutableData *theData = [NSMutableData data];
    NSKeyedArchiver *encoder = [[NSKeyedArchiver alloc] initForWritingWithMutableData:theData];
    
    [encoder encodeObject:DevieceToken forKey:DEVICETOKENKEY];
    [encoder finishEncoding];
    
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString* documentsDirectory = [paths objectAtIndex:0];
    NSString* fullPathToFile = [documentsDirectory stringByAppendingPathComponent:DEVICETOKENFILE];
    [theData writeToFile:fullPathToFile atomically:YES];
}
+ (void)clearDeviceToken{
    [self saveDeviceToken:@""];
}
@end
