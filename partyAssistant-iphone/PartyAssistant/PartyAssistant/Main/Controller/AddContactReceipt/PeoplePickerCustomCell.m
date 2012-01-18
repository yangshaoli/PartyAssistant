//
//  PeoplePickerCustomCell.m
//  ButtonPeoplePicker
//
//  Created by Wang Jun on 12/24/11.
//  Copyright 2011 shrtlist.com. All rights reserved.
//

#define CELL_PADDING 10
#define CELL_GAP     10
#define CELL_Orign_X 10
#define CELL_Orign_Y 25

#import "PeoplePickerCustomCell.h"

@implementation PeoplePickerCustomCell
@synthesize phoneNumberTF;
@synthesize phoneNumber;
@synthesize labelTF;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        phoneNumberTF = [[UILabel alloc] initWithFrame:CGRectZero];
        phoneNumberTF.font = [UIFont systemFontOfSize:14];
        phoneNumberTF.textColor = [UIColor lightGrayColor];
        phoneNumberTF.backgroundColor = [UIColor clearColor];
        [self addSubview:phoneNumberTF];
        
        labelTF = [[UILabel alloc] initWithFrame:CGRectZero];
        labelTF.font = [UIFont boldSystemFontOfSize:14];
        labelTF.textColor = [UIColor lightGrayColor];
        labelTF.backgroundColor = [UIColor clearColor];
        [self addSubview:labelTF];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) setPhoneNumber:(NSString *)m_phoneNumber {
    CGSize labelSize = [self.labelTF.text sizeWithFont:[UIFont boldSystemFontOfSize:14.0]];
    self.labelTF.frame = CGRectMake(CELL_Orign_X, CELL_Orign_Y, labelSize.width, labelSize.height);
    
    CGSize phoneSize = [m_phoneNumber sizeWithFont:[UIFont systemFontOfSize:14.0]];
    CGFloat phoneTFLength = 0.f;
    if (phoneSize.width < (320 - CELL_PADDING * 2 - CELL_GAP)) {
        //self.detailTextLabel.hidden = NO;
        
        CGRect from = self.labelTF.frame;
        CGRect to = from;
        if (labelSize.width > (320 - CELL_PADDING * 2 - CELL_GAP - phoneSize.width)) {
            to.size.width = (320 - CELL_PADDING * 2 - CELL_GAP - phoneSize.width) > 0 ? (320 - CELL_PADDING * 2 - CELL_GAP - phoneSize.width) : 0.f;
            self.labelTF.frame = to;
        } else {
            self.labelTF.frame = to;
        }
        
        self.phoneNumberTF.frame = CGRectMake((from.origin.x + CELL_GAP + to.size.width), CELL_Orign_Y, phoneSize.width, to.size.height);
    } else {
        //self.detailTextLabel.hidden = YES;
        labelTF.frame = CGRectZero;
        
        CGSize phoneSize = [m_phoneNumber sizeWithFont:[UIFont systemFontOfSize:14.0]];
        phoneTFLength = (320 - CELL_PADDING * 2);
        self.phoneNumberTF.frame = CGRectMake(CELL_PADDING, CELL_Orign_Y, phoneTFLength, phoneSize.height); 
    }
    
    self.phoneNumberTF.text = m_phoneNumber;
}
@end
