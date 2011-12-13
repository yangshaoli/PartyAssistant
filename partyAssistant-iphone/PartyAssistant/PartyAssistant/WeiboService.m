//
//  WeiboService.m
//  PartyAssistant
//
//  Created by 超 李 on 11-11-24.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "WeiboService.h"

@implementation WeiboService

@synthesize weiboPersonalProfile;
@synthesize userObject;
SYNTHESIZE_SINGLETON_FOR_CLASS(WeiboService)

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
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

- (void)saveNickName:(NSString *)nickName{
    if (!self.weiboPersonalProfile) {
        return;
    }
    self.weiboPersonalProfile.nickname = nickName;
    [self saveWeiboPersonalProfile];
}

- (void)clearWeiboPersonalProfile
{
    [self.weiboPersonalProfile clearObject];
}


@end
