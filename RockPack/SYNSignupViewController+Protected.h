//
//  SYNSignupViewController_Protected.h
//  dolly
//
//  Created by Sherman Lo on 31/01/14.
//  Copyright (c) 2014 Rockpack Ltd. All rights reserved.
//

#import "SYNSignupViewController.h"

@class SYNTextFieldLogin;

@interface SYNSignupViewController ()

- (BOOL)validateFirstNameField:(SYNTextFieldLogin *)textField errorLabel:(UILabel *)errorLabel;

- (BOOL)validateLastNameField:(SYNTextFieldLogin *)textField errorLabel:(UILabel *)errorLabel;

- (BOOL)validateUsernameField:(SYNTextFieldLogin *)textField errorLabel:(UILabel *)errorLabel;

- (BOOL)validateDateField:(SYNTextFieldLogin *)dateField
			   monthField:(SYNTextFieldLogin *)monthField
				yearField:(SYNTextFieldLogin *)yearField
				 errorLabel:(UILabel *)errorLabel;

- (BOOL)validateEmailField:(SYNTextFieldLogin *)textField errorLabel:(UILabel *)errorLabel;

- (BOOL)validatePasswordField:(SYNTextFieldLogin *)textField errorLabel:(UILabel *)errorLabel;

- (NSString *)zeroPadIfOneCharacter:(NSString *)inputString;

@end
