//
//  SYNIPhoneSignupDetailsViewController.m
//  dolly
//
//  Created by Sherman Lo on 14/01/14.
//  Copyright (c) 2014 Rockpack Ltd. All rights reserved.
//

#import "SYNIPhoneSignupDetailsViewController.h"
#import "SYNSignupViewController+Protected.h"
#import "UIFont+SYNFont.h"
#import "NSString+Validation.h"
#import "SYNTextFieldLogin.h"
#import "SYNLoginManager.h"
#import "SYNTrackingManager.h"

@interface SYNIPhoneSignupDetailsViewController () <UIBarPositioningDelegate, UITextFieldDelegate>

@property (nonatomic, strong) IBOutlet UIView *backgroundView;
@property (nonatomic, strong) IBOutlet UIView *containerView;

@property (nonatomic, strong) IBOutlet UINavigationBar *navigationBar;

@property (nonatomic, strong) IBOutlet SYNTextFieldLogin *emailTextField;
@property (nonatomic, strong) IBOutlet SYNTextFieldLogin *passwordTextField;

@property (nonatomic, strong) NSArray *textFields;

@property (nonatomic, strong) IBOutlet UIBarButtonItem *backBarButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *signUpBarButton;

@property (nonatomic, strong) IBOutlet UILabel *errorLabel;

@property (nonatomic, strong) IBOutlet UISegmentedControl *genderSegmentedControl;

@end

@implementation SYNIPhoneSignupDetailsViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.emailTextField.font = [UIFont lightCustomFontOfSize:self.emailTextField.font.pointSize];
	self.passwordTextField.font = [UIFont lightCustomFontOfSize:self.passwordTextField.font.pointSize];
	
	
	self.errorLabel.font = [UIFont lightCustomFontOfSize:self.errorLabel.font.pointSize];
    
	self.textFields = @[ self.emailTextField, self.passwordTextField];
	
}


- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	[self.emailTextField becomeFirstResponder];
}

- (void)viewDidAppear:(BOOL)animated
{
    
	[super viewDidAppear:animated];
    
    if(!IS_IPHONE_5)
    {
        CGRect errorFrame = self.errorLabel.frame;
        errorFrame.origin.y = 66.0f;
        self.errorLabel.frame = errorFrame;
        
    }
	
	[[SYNTrackingManager sharedManager] trackRegistrationStep2ScreenView];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	UITextField *nextTextField = [self nextTextFieldAfter:textField];
	if (nextTextField) {
		[nextTextField becomeFirstResponder];
	} else {
		[self submitSignUp];
	}
	
	return YES;
}

- (UIBarPosition)positionForBar:(id<UIBarPositioning>)bar {
	return UIBarPositionTopAttached;
}

- (IBAction)backButtonPressed:(UIBarButtonItem *)barButton {
	[self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)signUpButtonPressed:(UIBarButtonItem *)barButton {
	[self submitSignUp];
}

- (void)submitSignUp {
	if (![self validateEmailField:self.emailTextField errorLabel:self.errorLabel]) {
		return;
	}
	
	if (![self validatePasswordField:self.passwordTextField errorLabel:self.errorLabel]) {
		return;
	}
		
	[self.emailTextField resignFirstResponder];
	[self.passwordTextField resignFirstResponder];
	
	
	UINavigationItem *navigationItem = self.navigationBar.topItem;
	[navigationItem setLeftBarButtonItem:nil animated:YES];
	[navigationItem setRightBarButtonItem:nil animated:YES];
	
	
	NSDictionary *userData = @{@"username": self.username,
							   @"password": self.passwordTextField.text,
							   @"first_name" : self.firstName,
							   @"last_name" : self.lastName,
							   @"locale": @"en-US",
							   @"email": self.emailTextField.text,
							   @"gender": self.genderSegmentedControl.selectedSegmentIndex == 0 ? @"m" : @"f"};
	
	
	[[SYNLoginManager sharedManager] registerUserWithData: userData
			 completionHandler: ^(NSDictionary *dictionary) {
				 
				 [[SYNTrackingManager sharedManager] trackUserRegistrationFromOrigin:kOriginWonderPL];
				 
				 //onboarding flag for registration
				 [SYNLoginManager sharedManager].registrationCheck = YES;

				 if (self.avatarImage) {
					 [self uploadAvatar:self.avatarImage];
				 }
				 
				 [[NSNotificationCenter defaultCenter] postNotificationName: kLoginCompleted
																	 object: self];
			 } errorHandler: ^(NSDictionary *errorDictionary) {
				 
				 [navigationItem setLeftBarButtonItem:self.backBarButton animated:YES];
				 [navigationItem setRightBarButtonItem:self.signUpBarButton animated:YES];
				 
				 NSError *networkError = [errorDictionary valueForKey: @"nserror"];
				 if (networkError.code >= 500 && networkError.code < 600) {
					 return;
				 }
				 
				 NSDictionary *formErrors = errorDictionary[@"form_errors"];
				 NSString *errorString;
				 BOOL append = NO;
				 
				 if (formErrors)
				 {
					 NSArray *usernameError = formErrors[@"username"];
					 
					 if (usernameError)
					 {
						 errorString = [NSString stringWithFormat: NSLocalizedString(@"%@: %@", nil), NSLocalizedString(@"Username", nil), usernameError[0]];
						 append = YES;
					 }
					 
					 NSArray *emailError = formErrors[@"email"];
					 
					 if (emailError)
					 {
						 NSString *emailErrorString = [NSString stringWithFormat: NSLocalizedString(@"%@: %@", nil), NSLocalizedString(@"Email", nil), emailError[0]];
						 
						 if (append)
						 {
							 errorString = [NSString stringWithFormat: @"%@\n%@", errorString, emailErrorString];
						 }
						 else
						 {
							 errorString = emailErrorString;
						 }
					 }
					 
					 NSArray *passwordError = formErrors[@"password"];
					 
					 if (passwordError)
					 {
						 NSString *passwordErrorString = [NSString stringWithFormat: NSLocalizedString(@"%@: %@", nil), NSLocalizedString(@"Password", nil), passwordError[0]];
						 
						 if (append)
						 {
							 errorString = [NSString stringWithFormat: @"%@\n%@", errorString, passwordErrorString];
						 }
						 else
						 {
							 errorString = passwordErrorString;
						 }
					 }
					 
					 NSArray *dateError = formErrors[@"date_of_birth"];
					 
					 if (dateError)
					 {
						 NSString *dateErrorString = [NSString stringWithFormat: NSLocalizedString(@"%@: %@", nil), NSLocalizedString(@"DOB", nil), dateError[0]];
						 
						 if (append)
						 {
							 errorString = [NSString stringWithFormat: @"%@\n%@", errorString, dateErrorString];
						 }
						 else
						 {
							 errorString = dateErrorString;
						 }
					 }
					 
					 self.errorLabel.text = errorString;
				 }
			 }];
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

- (BOOL)textField:(SYNTextFieldLogin *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	textField.errorMode = NO;
	self.errorLabel.text = nil;
		
    return YES;
}

- (UITextField *)nextTextFieldAfter:(UITextField *)textField {
	NSInteger index = [self.textFields indexOfObject:textField];
	if (index < [self.textFields count] - 1) {
		return self.textFields[index + 1];
	}
	return nil;
}

@end
