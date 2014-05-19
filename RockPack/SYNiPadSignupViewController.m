//
//  SYNIPadSignupViewController.m
//  dolly
//
//  Created by Sherman Lo on 15/01/14.
//  Copyright (c) 2014 Rockpack Ltd. All rights reserved.
//

#import "SYNIPadSignupViewController.h"
#import "SYNSignupViewController+Protected.h"
#import "SYNTextFieldLogin.h"
#import "UIFont+SYNFont.h"
#import "SYNTrackingManager.h"
#import "SYNImagePickerController.h"
#import "NSString+Validation.h"
#import "SYNLoginManager.h"
#import "UIColor+SYNColor.h"

@interface SYNIPadSignupViewController () <SYNImagePickerControllerDelegate>

@property (nonatomic, strong) IBOutlet SYNTextFieldLogin *emailTextField;
@property (nonatomic, strong) IBOutlet SYNTextFieldLogin *firstNameTextField;
@property (nonatomic, strong) IBOutlet SYNTextFieldLogin *lastNameTextField;
@property (nonatomic, strong) IBOutlet SYNTextFieldLogin *usernameTextField;
@property (nonatomic, strong) IBOutlet SYNTextFieldLogin *passwordTextField;

@property (nonatomic, strong) IBOutlet SYNTextFieldLogin *dayTextField;
@property (nonatomic, strong) IBOutlet SYNTextFieldLogin *monthTextField;
@property (nonatomic, strong) IBOutlet SYNTextFieldLogin *yearTextField;
@property (strong, nonatomic) IBOutlet UILabel *addPhotoLabel;

@property (nonatomic, strong) IBOutlet UIView *dobContainerView;

@property (nonatomic, strong) IBOutlet UISegmentedControl *genderSegmentedControl;

@property (nonatomic, strong) IBOutlet UIButton *uploadPhotoButton;
@property (nonatomic, strong) IBOutlet UIButton *registerButton;

@property (nonatomic, strong) IBOutlet UILabel *emailErrorLabel;
@property (nonatomic, strong) IBOutlet UILabel *nameErrorLabel;
@property (nonatomic, strong) IBOutlet UILabel *usernameErrorLabel;
@property (nonatomic, strong) IBOutlet UILabel *passwordErrorLabel;
@property (nonatomic, strong) IBOutlet UILabel *dobErrorLabel;

@property (nonatomic, strong) NSArray *textFields;

@property (nonatomic, strong) UIImage *avatarImage;

@property (nonatomic, strong) SYNImagePickerController *imagePicker;
 
@end

@implementation SYNIPadSignupViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	

	
	self.emailTextField.font = [UIFont lightCustomFontOfSize:self.emailTextField.font.pointSize];
	self.passwordTextField.font = [UIFont lightCustomFontOfSize:self.passwordTextField.font.pointSize];
	
	self.dayTextField.font = [UIFont lightCustomFontOfSize:self.dayTextField.font.pointSize];
	self.monthTextField.font = [UIFont lightCustomFontOfSize:self.monthTextField.font.pointSize];
	self.yearTextField.font = [UIFont lightCustomFontOfSize:self.yearTextField.font.pointSize];
	
	self.emailErrorLabel.font = [UIFont lightCustomFontOfSize:self.emailErrorLabel.font.pointSize];
	self.usernameErrorLabel.font = [UIFont lightCustomFontOfSize:self.usernameErrorLabel.font.pointSize];
	self.passwordErrorLabel.font = [UIFont lightCustomFontOfSize:self.passwordErrorLabel.font.pointSize];
	self.dobErrorLabel.font = [UIFont lightCustomFontOfSize:self.dobErrorLabel.font.pointSize];
	
	self.textFields = @[ self.emailTextField, self.firstNameTextField, self.lastNameTextField, self.usernameTextField, self.passwordTextField, self.dayTextField, self.monthTextField, self.yearTextField ];
	self.addPhotoLabel.text = NSLocalizedString(@"Add your photo", @"Ipad add your photo label");

	self.addPhotoLabel.font = [UIFont lightCustomFontOfSize:self.addPhotoLabel.font.pointSize];
	
    self.uploadPhotoButton.layer.borderColor = [UIColor colorWithWhite:167.0f/255.0f alpha:1.0f].CGColor;
    self.uploadPhotoButton.layer.borderWidth = 1.0f;
    self.uploadPhotoButton.layer.cornerRadius = self.uploadPhotoButton.frame.size.width * 0.5f;
    self.uploadPhotoButton.clipsToBounds = YES;
    [self.uploadPhotoButton.imageView setContentMode: UIViewContentModeScaleAspectFill];
	[self updateDateOfBirthFieldsForLocale];
}


- (IBAction)uploadPhotoButtonPressed:(UIButton *) button {
	[[SYNTrackingManager sharedManager] trackAvatarUploadFromScreen:@"Registration"];
	
    self.imagePicker = [[SYNImagePickerController alloc] initWithHostViewController:self];
    self.imagePicker.delegate = self;
    [self.imagePicker presentImagePickerAsPopupFromView:button arrowDirection:UIPopoverArrowDirectionLeft];
}

- (void) picker:(SYNImagePickerController *)picker finishedWithImage:(UIImage *)image {
    self.imagePicker = nil;
	
    // Save our avatar
    self.avatarImage = image;
    
    // And update on-screen avatar
    [self.uploadPhotoButton setImage:image forState:UIControlStateNormal];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	[self.emailTextField becomeFirstResponder];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	[[SYNTrackingManager sharedManager] trackRegistrationScreenView];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	UITextField *nextTextField = [self nextTextFieldAfter:textField];
	if (nextTextField) {
		[nextTextField becomeFirstResponder];
	}
	
	return YES;
}

- (UITextField *)nextTextFieldAfter:(UITextField *)textField {
	NSInteger index = [self.textFields indexOfObject:textField];
	if (index < [self.textFields count] - 1) {
		return self.textFields[index + 1];
	}
	return nil;
}

- (void)updateDateOfBirthFieldsForLocale {
	NSString *localeIdentifier = [[NSLocale autoupdatingCurrentLocale] localeIdentifier];
	NSString *languageIdentifier = [NSLocale canonicalLanguageIdentifierFromString:localeIdentifier];
	
	// If we're in the US then we want to switch the day and month fields around since they have
	// a non-intuitive date format
	if ([languageIdentifier isEqualToString:@"en-US"]) {
		SYNTextFieldLogin *dayTextField = self.monthTextField;
		dayTextField.placeholder = @"DD";
		
		SYNTextFieldLogin *monthTextField = self.dayTextField;
		monthTextField.placeholder = @"MM";
		
		self.dayTextField = dayTextField;
		self.monthTextField = monthTextField;
	}
}

- (BOOL)textField:(SYNTextFieldLogin *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	textField.errorMode = NO;
	UILabel *errorLabel = [self errorLabelForTextField:textField];
	errorLabel.text = nil;
	
	BOOL isDateField = (textField == self.dayTextField || textField == self.monthTextField || textField == self.yearTextField);
	if (isDateField) {
		self.dayTextField.errorMode = NO;
		self.monthTextField.errorMode = NO;
		self.yearTextField.errorMode = NO;
	}
	
	NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
	NSUInteger newLength = [newString length];
	
	if (textField == self.usernameTextField && [newString length] > 20) {
		return NO;
	}
    
    if ((textField == self.dayTextField || textField == self.monthTextField) && newLength > 2) {
        return NO;
    }
    
    if (textField == self.yearTextField && newLength > 4) {
        return NO;
    }
	
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    
    if (textField == self.dayTextField || textField == self.monthTextField || textField == self.yearTextField) {
        if (([newString length] > 0) && ![numberFormatter numberFromString:newString]) {
            return NO;
        }
    }
	
    return YES;
}

- (IBAction)textFieldDidChange:(SYNTextFieldLogin *)textField {
	if (textField == self.dayTextField && [textField.text length] == 2) {
		[[self nextTextFieldAfter:textField] becomeFirstResponder];
		
		if ([self.monthTextField.text length] && [self.yearTextField.text length]) {
			[self validateDateField:self.dayTextField monthField:self.monthTextField yearField:self.yearTextField errorLabel:self.dobErrorLabel];
		}
	}
	
	if (textField == self.monthTextField && [textField.text length] == 2) {
		[[self nextTextFieldAfter:textField] becomeFirstResponder];
		
		if ([self.dayTextField.text length] && [self.yearTextField.text length]) {
			[self validateDateField:self.dayTextField monthField:self.monthTextField yearField:self.yearTextField errorLabel:self.dobErrorLabel];
		}
	}
	
	if (textField == self.yearTextField && [textField.text length] == 4) {
		[textField resignFirstResponder];
		
		if ([self.dayTextField.text length] && [self.monthTextField.text length]) {
			[self validateDateField:self.dayTextField monthField:self.monthTextField yearField:self.yearTextField errorLabel:self.dobErrorLabel];
		}
    }
}

- (IBAction)registerButtonPressed:(UIButton *)button {
	[self submitSignUp];
}

- (void)submitSignUp {
	if (![self validateEmailField:self.emailTextField errorLabel:self.emailErrorLabel]) {
		return;
	}
	
	if (![self validateFirstNameField:self.firstNameTextField errorLabel:self.nameErrorLabel]) {
		return;
	}
	
	if (![self validateLastNameField:self.lastNameTextField errorLabel:self.nameErrorLabel]) {
		return;
	}
	
	if (![self validateUsernameField:self.usernameTextField errorLabel:self.usernameErrorLabel]) {
		return;
	}
	
	if (![self validatePasswordField:self.passwordTextField errorLabel:self.passwordErrorLabel]) {
		return;
	}
	
	if (![self validateDateField:self.dayTextField
					  monthField:self.monthTextField
					   yearField:self.yearTextField
					  errorLabel:self.dobErrorLabel]) {
		return;
	}
	
	[self.emailTextField resignFirstResponder];
	[self.passwordTextField resignFirstResponder];
	
	[self.dayTextField resignFirstResponder];
	[self.monthTextField resignFirstResponder];
	[self.yearTextField resignFirstResponder];
	
	self.registerButton.enabled = NO;
	
	self.dayTextField.text = [self zeroPadIfOneCharacter:self.dayTextField.text];
	self.monthTextField.text = [self zeroPadIfOneCharacter:self.monthTextField.text];
	
	NSString* dobString = [NSString stringWithFormat: @"%@-%@-%@", self.yearTextField.text, self.monthTextField.text, self.dayTextField.text];
	NSDictionary *userData = @{@"username": self.usernameTextField.text,
							   @"password": self.passwordTextField.text,
							   @"first_name": self.firstNameTextField.text,
							   @"last_name": self.lastNameTextField.text,
							   @"date_of_birth": dobString,
							   @"locale": @"en-US",
							   @"email": self.emailTextField.text,
							   @"gender": self.genderSegmentedControl.selectedSegmentIndex == 0 ? @"m" : @"f"};
	
	[[SYNLoginManager sharedManager] registerUserWithData: userData
										completionHandler: ^(NSDictionary *dictionary) {
											
											[[SYNTrackingManager sharedManager] trackUserRegistrationFromOrigin:kOriginWonderPL];
											
											//Onboarding registration check
											[SYNLoginManager sharedManager].registrationCheck = YES;

											if (self.avatarImage) {
												[self uploadAvatar:self.avatarImage];
											}
											
											[[NSNotificationCenter defaultCenter] postNotificationName: kLoginCompleted
																								object: self];
										} errorHandler: ^(NSDictionary *errorDictionary) {
											
											self.registerButton.enabled = YES;
											
											NSDictionary* formErrors = errorDictionary[@"form_errors"];
											if (formErrors) {
												[self showRegistrationError:formErrors];
											}
										}];
}

- (void)showRegistrationError:(NSDictionary *)errorDictionary {
    NSArray *usernameError = errorDictionary[@"username"];
    NSArray *passwordError = errorDictionary[@"password"];
    NSArray *emailError = errorDictionary[@"email"];
    
	if (usernameError) {
		self.usernameErrorLabel.text = [usernameError firstObject];
		self.usernameTextField.errorMode = YES;
	}
    if (passwordError) {
		self.passwordErrorLabel.text = [passwordError firstObject];
		self.passwordTextField.errorMode = YES;
	}
	
    if (emailError) {
		self.emailErrorLabel.text = [emailError firstObject];
		self.emailTextField.errorMode = YES;
	}
}

- (UILabel *)errorLabelForTextField:(UITextField *)textField {
	if (textField == self.emailTextField) {
		return self.emailErrorLabel;
	}
	if (textField == self.firstNameTextField || textField == self.lastNameTextField) {
		return self.nameErrorLabel;
	}
	if (textField == self.usernameTextField) {
		return self.usernameErrorLabel;
	}
	if (textField == self.passwordTextField) {
		return self.passwordErrorLabel;
	}
	if (textField == self.dayTextField || textField == self.monthTextField || textField == self.yearTextField) {
		return self.dobErrorLabel;
	}
	return nil;
}

- (void)uploadAvatar:(UIImage *)avatarImage {
	[[SYNLoginManager sharedManager] uploadAvatarImage:avatarImage
									 completionHandler: ^(id dummy) {
									 }
										  errorHandler: ^(id dictionary) {
											  [[[UIAlertView alloc]  initWithTitle: NSLocalizedString(@"register_screen_form_avatar_upload_title", nil)
																		   message: NSLocalizedString(@"register_screen_form_avatar_upload_description", nil)
																		  delegate: nil
																 cancelButtonTitle: NSLocalizedString(@"OK", nil)
																 otherButtonTitles: nil] show];
										  }];
}

@end
