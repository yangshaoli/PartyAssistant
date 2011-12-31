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

#import "AddPersonViewController.h"

@implementation AddPersonViewController

@synthesize delegate;
@synthesize initialText;
@synthesize firstName;
@synthesize lastName;
@synthesize email;
@synthesize firstNameTextField;
@synthesize lastNameTextField;
@synthesize emailTextField;
@synthesize addButton;

#pragma mark - View lifecycle methods

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
	
	[firstNameTextField setText:initialText];
	[firstNameTextField becomeFirstResponder];
}

#pragma mark - Memory management

- (void)dealloc
{
	delegate = nil;
}

#pragma mark - Button actions

// Action receiver for the clicking of Add button
- (IBAction)addClick:(id)sender
{
	self.firstName = firstNameTextField.text;
	self.lastName = lastNameTextField.text;
	self.email = emailTextField.text;

	[delegate addPersonViewControllerDidFinish:self];
}

// Action receiver for the clicking of Cancel button
- (IBAction)cancelClick:(id)sender
{	
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark - UITextFieldDelegate methods

// Allow user to navigate textfields using the Next key on the keyboard
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{	
	if (textField == firstNameTextField)
    {
		[lastNameTextField becomeFirstResponder];
	}
	else if (textField == lastNameTextField)
    {
		[emailTextField becomeFirstResponder];
	}

	return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
	if (textField == emailTextField)
	{
		addButton.alpha = 1.0;
		addButton.enabled = YES;
	}
}

@end