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
#define SCROLL_VIEW_WIDTH 200.0f
#define SCROLL_VIEW_HEIGHT 44.0f*3

#define FIRST_LABEL_X 0.0f
#define FIRST_LABEL_Y 5.0f
#define FIRST_LABEL_WIDTH 140.0f
#define FIRST_LABEL_HEIGHT 20.0f
#define LABEL_Y_DISTANCE 1.0F
#define LABEL_X_DISTANCE 5.0F

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
        receiversScrollView.scrollEnabled = YES;
        self.receiversScrollView.contentSize = CGSizeMake(SCROLL_VIEW_WIDTH, SCROLL_VIEW_HEIGHT+10);
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
//        [self addSubview:countlbl];
    }
    [self setupCellData];
    return self;
}

- (void)setupCellData{
    //self.countlbl.text = [NSString stringWithFormat:@"共%d人",[self.receiverArray count]];
    
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
    CGRect lFrame = CGRectMake(FIRST_LABEL_X, FIRST_LABEL_Y, FIRST_LABEL_WIDTH, FIRST_LABEL_HEIGHT);
    for (int i=0; i<[self.receiverArray count]; i++) {
        ReceiverLabel *receiverLb = [[ReceiverLabel alloc] initWithReceiverObject:[self.receiverArray objectAtIndex:i] lbFrame:lFrame];
        lFrame = receiverLb.frame;
        if (lFrame.origin.x + lFrame.size.width > SCROLL_VIEW_WIDTH) {
            receiverLb.frame = CGRectMake(FIRST_LABEL_X, lFrame.origin.y + FIRST_LABEL_HEIGHT + LABEL_Y_DISTANCE, lFrame.size.width, FIRST_LABEL_HEIGHT);
        }
        [self.receiversScrollView addSubview:receiverLb];
        lFrame = CGRectMake(receiverLb.frame.origin.x + receiverLb.frame.size.width + LABEL_X_DISTANCE, receiverLb.frame.origin.y, receiverLb.frame.size.width, receiverLb.frame.size.height);
    }
    if (lFrame.origin.y + lFrame.size.height > SCROLL_VIEW_HEIGHT) {
        self.receiversScrollView.contentSize = CGSizeMake(SCROLL_VIEW_WIDTH, lFrame.origin.y + lFrame.size.height);
    }
}
@end
