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

@protocol AddPersonViewControllerDelegate;

@interface AddPersonViewController : UIViewController <UITextFieldDelegate>

@property (nonatomic, unsafe_unretained) id <AddPersonViewControllerDelegate> delegate;
@property (nonatomic, strong) NSString *firstName;
@property (nonatomic, strong) NSString *lastName;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, unsafe_unretained) NSString *initialText;

@property (nonatomic, strong) IBOutlet UITextField *firstNameTextField;
@property (nonatomic, strong) IBOutlet UITextField *lastNameTextField;
@property (nonatomic, strong) IBOutlet UITextField *emailTextField;
@property (nonatomic, strong) IBOutlet UIButton *addButton;

- (IBAction)addClick:(id)sender;
- (IBAction)cancelClick:(id)sender;

@end

@protocol AddPersonViewControllerDelegate
- (void)addPersonViewControllerDidFinish:(AddPersonViewController *)controller;
@end