//
//  NumberLabel.m
//  PartyAssistant
//
//  Created by 超 李 on 11-12-9.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "NumberLabel.h"

#define LIGHT_BLUE_COLOR [UIColor colorWithRed:0.4549 green:0.7176 blue:0.9373 alpha:1]
#define LIGHT_RED_COLOR [UIColor redColor]
#define LIGHT_GREEN_COLOR [UIColor greenColor]
#define MAX_LABLEL_WIDTH 100
#define MIN_LABLEL_WIDTH 20
#define MIN_LABLEL_HIGHT 20
#define MAX_LABLEL_X 270

@implementation NumberLabel

- (id)initWithNumber:(NSString *)strValue withFrame:(CGRect)lbFrame andColor:(UIColor *)color
{
    self = [self initWithFrame:lbFrame];
    //if ([receiver.cName ]) {
    NSLog(@"strValue:%@",strValue);
    //}
    self.text = strValue;
    self.font = [UIFont systemFontOfSize:16.0f];
    //self.backgroundColor = [UIColor colorWithRed:0.4549 green:0.7176 blue:0.9373 alpha:1];
    self.backgroundColor = color;
    self.layer.cornerRadius = 10;
    self.lineBreakMode = UILineBreakModeWordWrap | UILineBreakModeTailTruncation;  
    self.numberOfLines = 1;
    self.textAlignment = UITextAlignmentLeft;
    //[self sizeToFit];
    //    self.adjustsFontSizeToFitWidth = YES;
    return self;
}

- (id)initWithBlueNumber:(NSString *)strValue withFrame:(CGRect)lbFrame
{
    return [self initWithNumber:strValue withFrame:lbFrame andColor:LIGHT_BLUE_COLOR];
}

- (id)initWithRedNumber:(NSString *)strValue withFrame:(CGRect)lbFrame
{
    return [self initWithNumber:strValue withFrame:lbFrame andColor:LIGHT_RED_COLOR];
}

- (id)initWithGreenNumber:(NSString *)strValue withFrame:(CGRect)lbFrame
{
    return [self initWithNumber:strValue withFrame:lbFrame andColor:LIGHT_GREEN_COLOR];
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawTextInRect:(CGRect)rect
{
    // Drawing code
    rect.origin.x -= 10;
    [super drawTextInRect:rect];
}

- (void)setText:(NSString *)text {
    CGSize size = [text sizeWithFont:self.font];
    CGRect oldFrame = self.frame;
    if (size.width > MAX_LABLEL_WIDTH) {
        size.width = MAX_LABLEL_WIDTH;
    }
    oldFrame.size.width = size.width + MIN_LABLEL_WIDTH;//wxz控制最小区域宽度
    oldFrame.size.height = MIN_LABLEL_HIGHT;//wxz控制最小区域高度
    oldFrame.origin.x = MAX_LABLEL_X - oldFrame.origin.x;
    self.frame = oldFrame;
    self.textAlignment = UITextAlignmentLeft;
    [super setText:text];
}

@end
