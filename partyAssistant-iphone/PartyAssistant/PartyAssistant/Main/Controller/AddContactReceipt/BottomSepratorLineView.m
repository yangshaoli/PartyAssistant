//
//  BottomSepratorLineView.m
//  PartyAssistant
//
//  Created by Wang Jun on 12/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BottomSepratorLineView.h"

@implementation BottomSepratorLineView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)drawRect:(CGRect)rect {
    CGFloat startYPosition = CGRectGetMaxY(rect);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 2.0f);
    CGContextSetStrokeColorWithColor(context, [[UIColor grayColor] CGColor]);
    
    CGContextMoveToPoint(context, 0, startYPosition);
    CGContextAddLineToPoint(context, CGRectGetMaxX(rect), startYPosition);
    CGContextStrokePath(context);
}
@end
