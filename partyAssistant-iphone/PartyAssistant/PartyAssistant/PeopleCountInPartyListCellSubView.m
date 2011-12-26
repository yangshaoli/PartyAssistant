//
//  PeopleCountInPartyListCellSubView.m
//  PartyAssistant
//
//  Created by 超 李 on 11-12-11.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "PeopleCountInPartyListCellSubView.h"

#define DEFAULT_VIEW_WIDTH 100.0f
#define DEFAULT_VIEW_HEIGHT 55.0f
#define DEFAULT_VIEW_X 200.0f
#define DEFAULT_VIEW_Y 0.0f

#define DEFAULT_UP_VIEW_HEIGHT 35.0f
#define DEFAULT_DOWN_VIEW_HEIGHT 20.0f

#define APPLIED_LABEL_HEIGHT 30.0f
#define NEW_APPLIED_LABEL_HEIGHT 15.0f
#define REJECTED_LABEL_HEIGHT 20.0f
#define NEW_REJECTED_LABEL_HEIGHT 15.0f

#define APPLIED_LABEL_FONT_SIZE 24.0f
#define NEW_APPLIED_LABEL_FONT_SIZE 12.0f
#define REJECTED_LABEL_FONT_SIZE 18.0f
#define NEW_REJECTED_LABEL_FONT_SIZE 12.0f

#define APPLIED_LABEL_FONT_COLOR [UIColor colorWithRed:0.0f green:0.872f blue:0.0f alpha:1]
#define NEW_APPLIED_LABEL_FONT_COLOR [UIColor colorWithRed:0.0f green:0.872f blue:0.0f alpha:1]
#define REJECTED_LABEL_FONT_COLOR [UIColor colorWithRed:0.794f green:0.0f blue:0.0f alpha:1]
#define NEW_REJECTED_LABEL_FONT_COLOR [UIColor colorWithRed:0.794f green:0.0f blue:0.0f alpha:1]
#define DONOTHING_LABEL_FONT_COLOR [UIColor lightGrayColor]

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
    self.backgroundColor = [UIColor clearColor];
    if (self) {
        // Initialization code
        appliedClientcount = [peopleCount objectForKey:@"appliedClientcount"];
        newAppliedClientcount = [peopleCount objectForKey:@"newAppliedClientcount"];
        donothingClientcount = [peopleCount objectForKey:@"donothingClientcount"];
        refusedClientcount = [peopleCount objectForKey:@"refusedClientcount"];
        newRefusedClientcount = [peopleCount objectForKey:@"newRefusedClientcount"];
    }
    [self drawLabels];
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
    lbl.textColor = APPLIED_LABEL_FONT_COLOR;
    lbl.backgroundColor = [UIColor clearColor];
    [v addSubview:lbl];
    if ([newAppliedClientcount intValue] != 0) {
        NSString *newAppliedClientcountString = [NSString stringWithFormat:@"(%@)",newAppliedClientcount];
        UIFont *newAppliedFont = [UIFont systemFontOfSize:NEW_APPLIED_LABEL_FONT_SIZE];
        CGSize nsize = [newAppliedClientcountString sizeWithFont:newAppliedFont];
        UILabel *nlbl = [[UILabel alloc] initWithFrame:CGRectMake((self.frame.size.width+size.width)/2, 0, nsize.width, NEW_APPLIED_LABEL_HEIGHT)];
        nlbl.textColor = NEW_APPLIED_LABEL_FONT_COLOR;
        nlbl.text = newAppliedClientcountString;
        nlbl.font = newAppliedFont;
        nlbl.backgroundColor = [UIColor clearColor];
        [v addSubview:nlbl];
    }
    return v;
}

- (UIView *)drawRejectedView
{
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, DEFAULT_UP_VIEW_HEIGHT, DEFAULT_VIEW_WIDTH , DEFAULT_DOWN_VIEW_HEIGHT)];
    v.backgroundColor = [UIColor clearColor];
    UIFont *rejectedFont = [UIFont systemFontOfSize:REJECTED_LABEL_FONT_SIZE];
    
    //Middel Slash Label
    UILabel *middleLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, DEFAULT_VIEW_WIDTH, DEFAULT_DOWN_VIEW_HEIGHT)];
    middleLbl.text = @"/";
    middleLbl.backgroundColor = [UIColor clearColor];
    middleLbl.textAlignment = UITextAlignmentCenter;
    middleLbl.font = rejectedFont;
    [v addSubview:middleLbl];
    
    //New Rejected Label
    CGSize nsize;
    if ([newRefusedClientcount intValue] != 0) {
        NSString *newRejectedClientcountstring = [NSString stringWithFormat:@"(%@)",[newRefusedClientcount stringValue]];
        UIFont *newRejectedFont = [UIFont systemFontOfSize:NEW_REJECTED_LABEL_FONT_SIZE];
        nsize = [newRejectedClientcountstring sizeWithFont:newRejectedFont];
        UILabel *nlbl = [[UILabel alloc] initWithFrame:CGRectMake((self.frame.size.width/2 - nsize.width - 5), 0, nsize.width, NEW_REJECTED_LABEL_HEIGHT)];
        nlbl.text = newRejectedClientcountstring;
        nlbl.textColor = NEW_REJECTED_LABEL_FONT_COLOR;
        nlbl.font = newRejectedFont;
        nlbl.backgroundColor = [UIColor clearColor];
        [v addSubview:nlbl];
    }
    
    //Rejcected Label
    NSString *rejectedClientcountString = [refusedClientcount stringValue];
    
    CGSize size = [rejectedClientcountString sizeWithFont:rejectedFont];
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake((self.frame.size.width/2 - nsize.width- size.width-10), 0, size.width, REJECTED_LABEL_HEIGHT)];
    lbl.text = rejectedClientcountString;
    lbl.textColor = REJECTED_LABEL_FONT_COLOR;
    lbl.font = rejectedFont;
    lbl.backgroundColor = [UIColor clearColor];
    [v addSubview:lbl];
    
    
    //Do Nothing Label
    NSString *donothingClientcountStr = [donothingClientcount stringValue];
    
    CGSize nnsize = [donothingClientcountStr sizeWithFont:rejectedFont];
    UILabel *nnlbl = [[UILabel alloc] initWithFrame:CGRectMake((self.frame.size.width/2+10), 0, nnsize.width, REJECTED_LABEL_HEIGHT)];
    nnlbl.text = donothingClientcountStr;
    nnlbl.font = rejectedFont;
    nnlbl.textColor = DONOTHING_LABEL_FONT_COLOR;
    nnlbl.backgroundColor = [UIColor clearColor];
    [v addSubview:nnlbl];

    return v;
}

- (void)drawLabels
{
    UIView *appliedView = [self drawAppliedView];
    [self addSubview:appliedView];
    UIView *rejectView = [self drawRejectedView];
    [self addSubview:rejectView];
}

@end
