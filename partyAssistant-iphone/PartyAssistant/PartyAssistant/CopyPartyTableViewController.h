//
//  CopyPartyTableViewController.h
//  PartyAssistant
//
//  Created by 超 李 on 11-11-7.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseInfoObject.h"
#import "UITableViewControllerExtra.h"
#import "ASIHTTPRequest.h"
#import "JSON.h"
#import "URLSettings.h"
#import "SendSMSInCopyPartyTableViewController.h"
#import "SendEmailInCopyPartyTableViewController.h"
#import "ClientObject.h"

@interface CopyPartyTableViewController : UITableViewController<UITableViewDelegate,UIActionSheetDelegate,UITextFieldDelegate,UIPickerViewDelegate>
{
    BaseInfoObject *baseinfo;
    UIDatePicker *datePicker;
    UIPickerView *peoplemaxiumPicker;
    UITextField *locationTextField;
    UITextView *descriptionTextView;
}

@property(nonatomic, retain)BaseInfoObject *baseinfo;
@property(nonatomic, retain)UIDatePicker *datePicker;
@property(nonatomic, retain)UIPickerView *peoplemaxiumPicker;
@property(nonatomic, retain)UITextField *locationTextField;
@property(nonatomic, retain)UITextView *descriptionTextView;

- (void)nextBtnAction;

@end
