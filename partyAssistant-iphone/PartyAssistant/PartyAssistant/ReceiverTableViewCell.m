//
//  ReceiverTableViewCell.m
//  PartyAssistant
//
//  Created by 超 李 on 11-11-12.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "ReceiverTableViewCell.h"

#define SCROLL_VIEW_X 80.0f
#define SCROLL_VIEW_Y 0.0f
#define SCROLL_VIEW_WIDTH 140.0f
#define SCROLL_VIEW_HEIGHT 44.0f*3

@implementation ReceiverTableViewCell
@synthesize receiversScrollView,receiverArray,countlbl,defaultLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.textLabel.text = @"收件人:";
        
        self.receiversScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(SCROLL_VIEW_X, SCROLL_VIEW_Y, SCROLL_VIEW_WIDTH, SCROLL_VIEW_HEIGHT)];
        receiversScrollView.backgroundColor = [UIColor clearColor];
        [self addSubview:receiversScrollView];
        
        self.countlbl = [[UILabel alloc] initWithFrame:CGRectMake(receiversScrollView.frame.origin.x+receiversScrollView.frame.size.width+5, 0, 50, 44)];
        countlbl.text = [NSString stringWithFormat:@"共%d人",[self.receiverArray count]];
        countlbl.backgroundColor = [UIColor clearColor];
        countlbl.adjustsFontSizeToFitWidth = YES;
        
        self.defaultLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 0, 140, 44)];
        defaultLabel.backgroundColor = [UIColor clearColor];
        defaultLabel.text = @"请添加收件人";
        defaultLabel.textColor = [UIColor lightGrayColor];
        
        [self addSubview:defaultLabel];
        [self addSubview:countlbl];
    }
    [self setupCellData];
    return self;
}

- (void)setupCellData{
    self.countlbl.text = [NSString stringWithFormat:@"共%d人",[self.receiverArray count]];
    
    for (int i = 0; i<[[self.receiversScrollView subviews] count]; i++) {
        if ([[[receiversScrollView subviews] objectAtIndex:i] isMemberOfClass:[ReceiverLabel class]]){
            [[[receiversScrollView subviews] objectAtIndex:i] removeFromSuperview];
        }
    }
    if ([self.receiverArray count] == 0) {
        defaultLabel.hidden = NO;
    }else{
        defaultLabel.hidden = YES;
    }
    for (int i=0; i<[self.receiverArray count]; i++) {
        ReceiverLabel *receiverLb = [[ReceiverLabel alloc] initWithReceiverObject:[self.receiverArray objectAtIndex:i] index:i];
        NSLog(@"name:%@",receiverLb.text);
        [self.receiversScrollView addSubview:receiverLb];
    }
}
@end
