//
//  ReceiverView.m
//  PartyAssistant
//
//  Created by 超 李 on 11-10-31.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "ReceiverLabel.h"

#define MAX_LABLEL_WIDTH 140
#define MIN_LABLEL_WIDTH 20
@implementation ReceiverLabel


- (id)initWithReceiverObject:(ClientObject *)receiver lbFrame:(CGRect)lbFrame
{
    self = [self initWithFrame:lbFrame];
    //if ([receiver.cName ]) {
        
    //}
    self.text = receiver.cName;
    self.font = [UIFont systemFontOfSize:10.0f];
    self.backgroundColor = [UIColor colorWithRed:0.4549 green:0.7176 blue:0.9373 alpha:1];
    self.layer.cornerRadius = 10;
    self.lineBreakMode = UILineBreakModeWordWrap | UILineBreakModeTailTruncation;  
    self.numberOfLines = 1;
    self.textAlignment = UITextAlignmentLeft;
    //[self sizeToFit];
//    self.adjustsFontSizeToFitWidth = YES;
    return self;
}




// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawTextInRect:(CGRect)rect
{
    // Drawing code
    rect.origin.x +=10;
    [super drawTextInRect:rect];
}

- (void)setText:(NSString *)text {
    CGSize size = [text sizeWithFont:self.font];
    CGRect oldFrame = self.frame;
    if (size.width > MAX_LABLEL_WIDTH) {
        size.width = MAX_LABLEL_WIDTH;
    }
    oldFrame.size.width = size.width+MIN_LABLEL_WIDTH;//wxz控制最小区域宽度
    self.frame = oldFrame;
    self.textAlignment = UITextAlignmentLeft;
    [super setText:text];
}

@end
