//
//  ReceiverView.h
//  PartyAssistant
//
//  Created by 超 李 on 11-10-31.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ClientObject.h"
#import <QuartzCore/QuartzCore.h>

@interface ReceiverLabel : UILabel

- (id)initWithReceiverObject:(ClientObject *)receiver lbFrame:(CGRect)lbFrame;

@end
