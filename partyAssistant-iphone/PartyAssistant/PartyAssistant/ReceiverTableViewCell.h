//
//  ReceiverTableViewCell.h
//  PartyAssistant
//
//  Created by 超 李 on 11-11-12.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ReceiverLabel.h"

@interface ReceiverTableViewCell : UITableViewCell{
    UIScrollView *receiversScrollView;
    NSMutableArray *receiverArray;
    UILabel *countlbl;
    UILabel *defaultLabel;
}

@property(nonatomic, retain)UIScrollView *receiversScrollView;
@property(nonatomic, retain)NSMutableArray *receiverArray;
@property(nonatomic, retain)UILabel *countlbl;
@property(nonatomic, retain)UILabel *defaultLabel;

- (void)setupCellData;

@end
