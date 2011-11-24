//
//  AddNewPartyBaseInfoTableViewController.h
//  PartyAssistant
//
//  Created by 超 李 on 11-10-26.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseInfoObject.h"
#import "BaseInfoService.h"
#import "SendSMSToClientsViewController.h"
#import "SendEmailToClientsViewController.h"
@interface AddNewPartyBaseInfoTableViewController : UITableViewController<UITableViewDelegate,UIActionSheetDelegate,UITextFieldDelegate,UIPickerViewDelegate>{
    BaseInfoObject *baseInfoObject;
    UIDatePicker *datePicker;
    UIPickerView *peoplemaxiumPicker;
    UITextField *locationTextField;
    UITextView *descriptionTextView;
}

@property(nonatomic, retain)BaseInfoObject *baseInfoObject;
@property(nonatomic, retain)UIDatePicker *datePicker;
@property(nonatomic, retain)UIPickerView *peoplemaxiumPicker;
@property(nonatomic, retain)UITextField *locationTextField;
@property(nonatomic, retain)UITextView *descriptionTextView;

- (void)goToSMS;
- (NSString *)getDefaultContent:(BaseInfoObject *)paraBaseInfo;

@end
