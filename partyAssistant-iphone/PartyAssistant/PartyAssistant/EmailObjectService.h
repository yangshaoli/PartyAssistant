//
//  EmailObjectsService.h
//  PartyAssistant
//
//  Created by 超 李 on 11-11-16.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EmailObject.h"
#import "SynthesizeSingleton.h"
#define EMAILOBJECTFILE @"EmailObjectFile"
#define EMAILOBJECTKEY @"EmailObjectKey"

@interface EmailObjectService : NSObject
{
    EmailObject *emailObject;
}

@property(nonatomic,retain)EmailObject *emailObject;

+ (EmailObjectService *)sharedEmailObjectService;
- (EmailObject *)getEmailObject;
- (void)saveEmailObject;
- (void)clearEmailObject;

@end
