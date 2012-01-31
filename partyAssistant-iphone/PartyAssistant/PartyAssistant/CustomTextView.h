//
//  CustomTextView.h
//  PartyAssistant
//
//  Created by Wang Jun on 1/16/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomTextView : UITextView {
    NSString *placeholder;
    UIColor *placeholderColor;

    @private
    UILabel *placeHolderLabel;
}

@property (nonatomic, strong) UILabel *placeHolderLabel;
@property (nonatomic, strong) NSString *placeholder;
@property (nonatomic, strong) UIColor *placeholderColor;

-(void)textChanged:(NSNotification*)notification;

- (UIEdgeInsets)contentInset;

@end
