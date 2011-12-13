//
//  PeopleCountInPartyListCellSubView.h
//  PartyAssistant
//
//  Created by 超 李 on 11-12-11.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PeopleCountInPartyListCellSubView : UIView
{
    NSNumber *appliedClientcount;
    NSNumber *newAppliedClientcount;
    NSNumber *donothingClientcount;
    NSNumber *refusedClientcount;
    NSNumber *newRefusedClientcount;
}

- (id)initWithPeopleCount:(NSDictionary *)peopleCount;
- (id)initWithFrame:(CGRect)frame andWithPeopleCount:(NSDictionary *)peopleCount;
- (UIView *)drawAppliedView;
@end
