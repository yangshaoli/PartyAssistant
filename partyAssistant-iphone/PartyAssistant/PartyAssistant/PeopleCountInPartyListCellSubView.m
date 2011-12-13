//
//  PeopleCountInPartyListCellSubView.m
//  PartyAssistant
//
//  Created by 超 李 on 11-12-11.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "PeopleCountInPartyListCellSubView.h"

#define DEFAULT_VIEW_WIDTH 100.0f
#define DEFAULT_VIEW_HEIGHT 50.0f
#define DEFAULT_VIEW_X 200.0f
#define DEFAULT_VIEW_Y 0.0f

#define DEFAULT_UP_VIEW_HEIGHT 60.0f
#define DEFAULT_DOWN_VIEW_HEIGHT 40.0f

#define APPLIED_LABEL_HEIGHT 30.0f
#define NEW_APPLIED_LABEL_HEIGHT 15.0f
#define REJECTED_LABEL_HEIGHT 20.0f
#define NEW_REJECTED_LABEL_HEIGHT 15.0f
#define APPLIED_LABEL_FONT_SIZE 18.0f
#define NEW_APPLIED_LABEL_FONT_SIZE 8.0f
#define REJECTED_LABEL_FONT_SIZE 10.0f
#define NEW_REJECTED_LABEL_FONT_SIZE 8.0f

@implementation PeopleCountInPartyListCellSubView


- (id)initWithPeopleCount:(NSDictionary *)peopleCount
{
    CGRect frame = CGRectMake(DEFAULT_VIEW_X, DEFAULT_VIEW_Y, DEFAULT_VIEW_WIDTH, DEFAULT_VIEW_HEIGHT);
    self = [self initWithFrame:frame andWithPeopleCount:(NSDictionary *)peopleCount];
    return self;
}

- (id)initWithFrame:(CGRect)frame andWithPeopleCount:(NSDictionary *)peopleCount
{
    self = [super initWithFrame:frame];
    self.backgroundColor = [UIColor blackColor];
    if (self) {
        // Initialization code
        appliedClientcount = [peopleCount objectForKey:@"appliedClientcount"];
        newAppliedClientcount = [peopleCount objectForKey:@"newAppliedClientcount"];
        donothingClientcount = [peopleCount objectForKey:@"donothingClientcount"];
        refusedClientcount = [peopleCount objectForKey:@"refusedClientcount"];
        newRefusedClientcount = [peopleCount objectForKey:@"newRefusedClientcount"];
    }
    UIView *v = [self drawAppliedView];
    [self addSubview:v];
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

- (UIView *)drawAppliedView
{
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DEFAULT_VIEW_WIDTH , DEFAULT_UP_VIEW_HEIGHT)];
    NSString *appliedClientcountString = [appliedClientcount stringValue];
    UIFont *appliedFont = [UIFont systemFontOfSize:APPLIED_LABEL_FONT_SIZE];
    CGSize size = [appliedClientcountString sizeWithFont:appliedFont];
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake((self.frame.size.width-size.width)/2, 0, size.width, APPLIED_LABEL_HEIGHT)];
    lbl.text = appliedClientcountString;
    lbl.font = appliedFont;
    lbl.backgroundColor = [UIColor redColor];
    [v addSubview:lbl];
    if ([newAppliedClientcount intValue] != 0) {
        NSString *newAppliedClientcountString = [NSString stringWithFormat:@"(%@)",newAppliedClientcount];
        UIFont *newAppliedFont = [UIFont systemFontOfSize:NEW_APPLIED_LABEL_FONT_SIZE];
        CGSize nsize = [newAppliedClientcountString sizeWithFont:newAppliedFont];
        UILabel *nlbl = [[UILabel alloc] initWithFrame:CGRectMake((self.frame.size.width+size.width)/2, 0, nsize.width, NEW_APPLIED_LABEL_HEIGHT)];
        nlbl.text = newAppliedClientcountString;
        nlbl.font = newAppliedFont;
        nlbl.backgroundColor = [UIColor greenColor];
        [v addSubview:nlbl];
    }
    return v;
}

- (UIView *)drawRejectedView
{
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
    return lbl;
}

- (void)drawLabels
{
    UIView *appliedView = [self drawAppliedView];
    [self addSubview:appliedView];
    UIView *rejectView = [self drawRejectedView];
    [self addSubview:rejectView];
}

@end
