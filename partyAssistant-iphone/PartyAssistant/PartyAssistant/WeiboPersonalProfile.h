//
//  WeiboPersonalProfile.h
//  PartyAssistant
//
//  Created by 超 李 on 11-11-24.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WeiboPersonalProfile : NSObject
{
    NSString *nickname;
}

@property(nonatomic, retain)NSString *nickname;

- (void)clearObject;

@end
