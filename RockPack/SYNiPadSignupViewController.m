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
#import "SYNiPadIntroToSignupAnimator.h"
#import "SYNiPadIntroViewController.h"


@interface SYNIPadSignupViewController () <SYNImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) IBOutlet SYNTextFieldLogin *emailTextField;
@property (nonatomic, strong) IBOutlet SYNTextFieldLogin *firstNameTextField;
@property (nonatomic, strong) IBOutlet SYNTextFieldLogin *lastNameTextField;
@property (nonatomic, strong) IBOutlet SYNTextFieldLogin *usernameTextField;
@property (nonatomic, strong) IBOutlet SYNTextFieldLogin *passwordTextField;

@property (strong, nonatomic) IBOutlet UILabel *addPhotoLabel;


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
	
	
	self.emailErrorLabel.font = [UIFont lightCustomFontOfSize:self.emailErrorLabel.font.pointSize];
	self.usernameErrorLabel.font = [UIFont lightCustomFontOfSize:self.usernameErrorLabel.font.pointSize];
	self.passwordErrorLabel.font = [UIFont lightCustomFontOfSize:self.passwordErrorLabel.font.pointSize];
	self.dobErrorLabel.font = [UIFont lightCustomFontOfSize:self.dobErrorLabel.font.pointSize];
	
	self.textFields = @[ self.emailTextField, self.firstNameTextField, self.lastNameTextField, self.usernameTextField, self.passwordTextField];
	self.addPhotoLabel.text = NSLocalizedString(@"Add your photo", @"Ipad add your photo label");

	self.addPhotoLabel.font = [UIFont lightCustomFontOfSize:self.addPhotoLabel.font.pointSize];
	
    [self.uploadPhotoButton.imageView setContentMode: UIViewContentModeScaleAspectFill];
    
    self.uploadPhotoButton.layer.cornerRadius = self.uploadPhotoButton.frame.size.height * 0.5;
	self.uploadPhotoButton.layer.masksToBounds = YES;
    self.uploadPhotoButton.layer.cornerRadius = self.uploadPhotoButton.frame.size.width/2;
    
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

- (BOOL)textField:(SYNTextFieldLogin *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	textField.errorMode = NO;
	UILabel *errorLabel = [self errorLabelForTextField:textField];
	errorLabel.text = nil;
	
	
	NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
	
	if (textField == self.usernameTextField && [newString length] > 20) {
		return NO;
	}
	
    return YES;
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
	
	[self.emailTextField resignFirstResponder];
	[self.passwordTextField resignFirstResponder];
	
	
	self.registerButton.enabled = NO;
		
	NSDictionary *userData = @{@"username": self.usernameTextField.text,
							   @"password": self.passwordTextField.text,
							   @"first_name": self.firstNameTextField.text,
							   @"last_name": self.lastNameTextField.text,
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



- (IBAction)goBack:(id)sender {

    [self.navigationController popViewControllerAnimated:YES];
}


@end
