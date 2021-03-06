/*
 * Copyright 2011 Marco Abundo
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import <AddressBook/AddressBook.h>
#import "ShadowedTableView.h"
#import "BottomSepratorLineView.h"
#import "SegmentManagingViewController.h"
#import "PhoneNumberFormatter.h"

typedef enum {
    ButtonPeoplePickerStatusShowing,
    ButtonPeoplePickerStatusSearching
}ButtonPeoplePickerStatus;

@protocol ButtonPeoplePickerDelegate;

@class ClientObject;
@interface ButtonPeoplePicker : UIViewController <UITableViewDataSource,
												  UITableViewDelegate,
												  UIKeyInput,               
                                                  UITextFieldDelegate,
                                                  ContactDataDelegate>
{
	UIButton *selectedButton;
    UIButton *lastButton;
    
    ABAddressBookRef addressBook;
    
    ButtonPeoplePickerStatus pickerStatus;
}

@property (nonatomic, unsafe_unretained) id <ButtonPeoplePickerDelegate> delegate;
@property (nonatomic, strong) NSMutableArray *group;
@property (nonatomic, strong) NSArray *people;

@property (nonatomic, strong) UIView *addReceiptBGView;
@property (nonatomic, strong) UIButton *addReceiptButton;
@property (nonatomic, strong) IBOutlet UILabel *deleteLabel;
@property (nonatomic, strong) IBOutlet BottomSepratorLineView *buttonView;
@property (nonatomic, strong) IBOutlet ShadowedTableView *uiTableView;
@property (nonatomic, strong) IBOutlet UITextField *searchField;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *doneButton;

@property (nonatomic, strong) IBOutlet UIToolbar *toolbar;
@property (nonatomic, strong) IBOutlet UIView *footerView;

@property (nonatomic, strong) PhoneNumberFormatter *inputPhoneFormatter;

- (IBAction)cancelClick:(id)sender;
- (IBAction)doneClick:(id)sender;
- (void)findLastButton;
- (void)changePickerViewToStatus:(ButtonPeoplePickerStatus)newStatus;
- (void)resetData;
- (ClientObject *)scanAddressBookAndSearch:(ClientObject *)client;

void pickerAddressBookChanged (ABAddressBookRef addressBook,
                         CFDictionaryRef info,
                         void *context);
@end

@protocol ButtonPeoplePickerDelegate
- (void)buttonPeoplePickerDidFinish:(ButtonPeoplePicker *)controller;

@optional
- (NSMutableArray *)getCurrentContactDataSource;
@end