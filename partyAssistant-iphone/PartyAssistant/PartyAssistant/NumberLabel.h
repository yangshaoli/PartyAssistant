//
//  NumberLabel.h
//  PartyAssistant
//
//  Created by 超 李 on 11-12-9.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface NumberLabel : UILabel

- (id)initWithNumber:(NSString *)strValue withFrame:(CGRect)lbFrame andColor:(UIColor *)color;
- (id)initWithBlueNumber:(NSString *)strValue withFrame:(CGRect)lbFrame;
- (id)initWithRedNumber:(NSString *)strValue withFrame:(CGRect)lbFrame;
- (id)initWithGreenNumber:(NSString *)strValue withFrame:(CGRect)lbFrame;

@end
