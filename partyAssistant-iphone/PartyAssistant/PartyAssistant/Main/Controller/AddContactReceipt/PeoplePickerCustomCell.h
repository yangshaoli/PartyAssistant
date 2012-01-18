//
//  PeoplePickerCustomCell.h
//  ButtonPeoplePicker
//
//  Created by Wang Jun on 12/24/11.
//  Copyright 2011 shrtlist.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PeoplePickerCustomCell : UITableViewCell {
    UILabel *phoneNumberTF;
    NSString *phoneNumber;
    UILabel *labelTF;
}

@property (nonatomic, strong) UILabel *phoneNumberTF;
@property (nonatomic, strong) NSString *phoneNumber;
@property (nonatomic, strong) UILabel *labelTF;

@end
