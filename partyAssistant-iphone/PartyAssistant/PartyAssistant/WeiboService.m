//
//  WeiboService.m
//  PartyAssistant
//
//  Created by 超 李 on 11-11-24.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "WeiboService.h"
#define WEIBOAPPKEY @"999433557"
#define WEIBOAPPSECRET @"8ebb477102459b3387da43686b21c963"

@implementation WeiboService

@synthesize weiboPersonalProfile;

SYNTHESIZE_SINGLETON_FOR_CLASS(WeiboService)

- (id)init
{
    self = [super init];
    self.weiboPersonalProfile = [self getWeiboPersonalProfile];
    return self;
}

- (WeiboPersonalProfile *)getWeiboPersonalProfile
{
    if (weiboPersonalProfile) {
        return weiboPersonalProfile;
    }
    
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString* documentsDirectory = [paths objectAtIndex:0];
    
    NSString* fullPathToFile = [documentsDirectory stringByAppendingPathComponent:WEIBOPERSONALPROFILEFILE];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:fullPathToFile];
    if (fileExists) {
        NSData *theData = [NSData dataWithContentsOfFile:fullPathToFile];
        NSKeyedUnarchiver *decoder = [[NSKeyedUnarchiver alloc] initForReadingWithData:theData];
        self.weiboPersonalProfile = [decoder decodeObjectForKey:WEIBOPERSONALPROFILEKEY];
    } else {
        self.weiboPersonalProfile = [[WeiboPersonalProfile alloc] init];
    }
    
    return self.weiboPersonalProfile;
}

- (void)saveWeiboPersonalProfile
{
    if (!self.weiboPersonalProfile) {
        return;
    }
    
    NSMutableData *theData = [NSMutableData data];
    NSKeyedArchiver *encoder = [[NSKeyedArchiver alloc] initForWritingWithMutableData:theData];
    
    [encoder encodeObject:self.weiboPersonalProfile forKey:WEIBOPERSONALPROFILEKEY];
    [encoder finishEncoding];
    
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString* documentsDirectory = [paths objectAtIndex:0];
    
    NSString* fullPathToFile = [documentsDirectory stringByAppendingPathComponent:WEIBOPERSONALPROFILEFILE];
    [theData writeToFile:fullPathToFile atomically:YES];
}

- (void)clearWeiboPersonalProfile
{
    [self.weiboPersonalProfile clearObject];
}



@end
