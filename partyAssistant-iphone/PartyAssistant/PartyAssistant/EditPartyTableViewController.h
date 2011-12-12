//
//  EditPartyTableViewController.h
//  PartyAssistant
//
//  Created by 超 李 on 11-11-12.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UITableViewControllerExtra.h"
#import "NotificationSettings.h"
#import "BaseInfoObject.h"
#import "URLSettings.h"
#import "JSON.h"
#import "ASIFormDataRequest.h"
#import "HTTPRequestErrorMSG.h"

@interface EditPartyTableViewController : UITableViewController<UITableViewDelegate,UIActionSheetDelegate,UITextFieldDelegate,UIPickerViewDelegate>
{
    BaseInfoObject *baseInfoObject;
    UIDatePicker *datePicker;
    UIPickerView *peoplemaxiumPicker;
    UITextField *locationTextField;
    UITextView *descriptionTextView;
    UILabel *starttimeLabel2;
}

@property(nonatomic, retain)BaseInfoObject *baseInfoObject;
@property(nonatomic, retain)UIDatePicker *datePicker;
@property(nonatomic, retain)UIPickerView *peoplemaxiumPicker;
@property(nonatomic, retain)UITextField *locationTextField;
@property(nonatomic, retain)UITextView *descriptionTextView;
@property(nonatomic, retain)UILabel *starttimeLabel2;
@end
