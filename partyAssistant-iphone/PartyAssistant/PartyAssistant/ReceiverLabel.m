//
//  ReceiverView.m
//  PartyAssistant
//
//  Created by 超 李 on 11-10-31.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "ReceiverLabel.h"

@implementation ReceiverLabel
@synthesize maxWidth,maxHeight;


- (id)initWithReceiverObject:(ClientObject *)receiver index:(NSInteger)lbIndex
{
    self.maxWidth = 140.0f;
    self.maxHeight = 20.0f;
    self = [self initWithFrame:CGRectMake(0,4 + 20.0 * lbIndex,self.maxWidth,self.maxHeight)];
    //if ([receiver.cName ]) {
        
    //}
    self.text = receiver.cName;
    self.font = [UIFont systemFontOfSize:10.0f];
    self.backgroundColor = [UIColor colorWithRed:0.4549 green:0.7176 blue:0.9373 alpha:1];
    self.layer.cornerRadius = 10;
    self.lineBreakMode = UILineBreakModeWordWrap | UILineBreakModeTailTruncation;  
    self.numberOfLines = 0;
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
    rect.origin.x += 20;
    [super drawTextInRect:rect];
}

- (void)setText:(NSString *)text {
    CGSize size = [text sizeWithFont:self.font];
    CGRect oldFrame = self.frame;
    oldFrame.size.width = size.width;
    self.frame = oldFrame;
    self.textAlignment = UITextAlignmentLeft;
    [super setText:text];
}

@end
