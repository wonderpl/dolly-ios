//
//  SYNiPadSignupViewController.m
//  dolly
//
//  Created by Sherman Lo on 15/01/14.
//  Copyright (c) 2014 Rockpack Ltd. All rights reserved.
//

#import "SYNiPadSignupViewController.h"
#import "SYNTextFieldLogin.h"
#import "UIFont+SYNFont.h"
#import "GAI+Tracking.h"
#import "SYNImagePickerController.h"
#import "NSString+Validation.h"
#import "SYNLoginManager.h"

@interface SYNiPadSignupViewController () <SYNImagePickerControllerDelegate>

@property (nonatomic, strong) IBOutlet SYNTextFieldLogin *emailTextField;
@property (nonatomic, strong) IBOutlet SYNTextFieldLogin *usernameTextField;
@property (nonatomic, strong) IBOutlet SYNTextFieldLogin *passwordTextField;

@property (nonatomic, strong) IBOutlet SYNTextFieldLogin *dayTextField;
@property (nonatomic, strong) IBOutlet SYNTextFieldLogin *monthTextField;
@property (nonatomic, strong) IBOutlet SYNTextFieldLogin *yearTextField;

@property (nonatomic, strong) IBOutlet UIView *dobContainerView;

@property (nonatomic, strong) IBOutlet UISegmentedControl *genderSegmentedControl;

@property (nonatomic, strong) IBOutlet UIButton *uploadPhotoButton;
@property (nonatomic, strong) IBOutlet UIButton *registerButton;

@property (nonatomic, strong) IBOutlet UILabel *emailErrorLabel;
@property (nonatomic, strong) IBOutlet UILabel *usernameErrorLabel;
@property (nonatomic, strong) IBOutlet UILabel *passwordErrorLabel;
@property (nonatomic, strong) IBOutlet UILabel *dobErrorLabel;

@property (nonatomic, strong) NSArray *textFields;

@property (nonatomic, strong) UIImage *avatarImage;

@property (nonatomic, strong) SYNImagePickerController *imagePicker;
 
@end

@implementation SYNiPadSignupViewController


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
	
	self.textFields = @[ self.emailTextField, self.usernameTextField, self.passwordTextField, self.dayTextField, self.monthTextField, self.yearTextField ];
	
    self.uploadPhotoButton.layer.borderColor = [UIColor colorWithRed:(167.0f/255.0f) green:(167.0f/255.0f) blue:(167.0f/255.0f) alpha:1.0f].CGColor;
    self.uploadPhotoButton.layer.borderWidth = 1.0f;
    self.uploadPhotoButton.layer.cornerRadius = self.uploadPhotoButton.frame.size.width * 0.5f;
    self.uploadPhotoButton.clipsToBounds = YES;
	
	[self updateDateOfBirthFieldsForLocale];
}


- (IBAction)uploadPhotoButtonPressed:(UIButton *) button {
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
	
	[[GAI sharedInstance] trackRegisterScreenView];
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
//	textField.errorMode = NO;
//	self.errorLabel.text = nil;
	
	
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
			[self dateValidForDd: self.dayTextField
							  mm: self.monthTextField
							yyyy: self.yearTextField];
		}
	}
	
	if (textField == self.monthTextField && [textField.text length] == 2) {
		[[self nextTextFieldAfter:textField] becomeFirstResponder];
		
		if ([self.dayTextField.text length] && [self.yearTextField.text length]) {
			[self dateValidForDd: self.dayTextField
							  mm: self.monthTextField
							yyyy: self.yearTextField];
		}
	}
	
	if (textField == self.yearTextField && [textField.text length] == 4) {
		[textField resignFirstResponder];
		
		if ([self.dayTextField.text length] && [self.monthTextField.text length]) {
			[self dateValidForDd: self.dayTextField
							  mm: self.monthTextField
							yyyy: self.yearTextField];
		}
    }
}

- (BOOL)dateValidForDd:(SYNTextFieldLogin *)ddInputField
					mm:(SYNTextFieldLogin *)mmInputField
				  yyyy:(SYNTextFieldLogin *)yyyyInputField {
    // == Check for date == //
    
    NSArray *dobTextFields = @[ddInputField, mmInputField, yyyyInputField];
    
    // == Check wether the DOB fields contain numbers == //
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    
    for (SYNTextFieldLogin *dobField in dobTextFields) {
        if (dobField.text.length == 0) {
			dobField.errorMode = YES;
			self.dobErrorLabel.text = NSLocalizedString(@"register_screen_form_error_invalid_date", nil);
            
            [ddInputField becomeFirstResponder];
            
            return NO;
        }
        
        if (dobField.text.length == 1) {
            dobField.text = [NSString stringWithFormat: @"0%@", dobField.text]; // add a trailing 0
        }
        
        if (![numberFormatter numberFromString: dobField.text]) {
			dobField.errorMode = YES;
			self.dobErrorLabel.text = NSLocalizedString(@"register_screen_form_error_invalid_date", nil);
			
            [dobField becomeFirstResponder];
            
            return NO;
        }
    }
    
    if (yyyyInputField.text.length < 4) {
		yyyyInputField.errorMode = YES;
		self.dobErrorLabel.text = NSLocalizedString(@"register_screen_form_error_invalid_date", nil);
		
        return NO;
    }
	
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat: @"yyyy-MM-dd"];
    NSDate *potentialDate = [dateFormatter dateFromString: [NSString stringWithFormat: @"%@-%@-%@", yyyyInputField.text, [self zeroPadIfOneCharacter: mmInputField.text], [self zeroPadIfOneCharacter: ddInputField.text]]];
    
    // == Not a real date == //
    
    if (!potentialDate) {
		self.yearTextField.errorMode = YES;
		self.dobErrorLabel.text = NSLocalizedString(@"register_screen_form_error_invalid_date", nil);
		
        return NO;
    }
    
    NSDate *nowDate = [NSDate date];
    
    // == In the future == //
    
    if ([nowDate compare: potentialDate] == NSOrderedAscending) {
		self.yearTextField.errorMode = YES;
		self.dobErrorLabel.text = NSLocalizedString(@"register_screen_form_error_future", nil);
		
        return NO;
    }
    
    // == Yonger than 13 == //
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier: NSGregorianCalendar];
    NSDateComponents *nowDateComponents = [gregorian components: (NSYearCalendarUnit)
                                                       fromDate: nowDate];
    nowDateComponents.year -= 13;
    
    NSDate *tooYoungDate = [gregorian dateFromComponents: nowDateComponents];
    
    if ([tooYoungDate compare: potentialDate] == NSOrderedAscending) {
		self.yearTextField.errorMode = YES;
		self.dobErrorLabel.text = NSLocalizedString(@"register_screen_form_error_under_13", nil);
		
        return NO;
    }
    
    return YES;
}

- (NSString *)zeroPadIfOneCharacter:(NSString *)inputString {
    if ([inputString length] == 1) {
        return [NSString stringWithFormat: @"0%@", inputString];
    }
    
    return inputString;
}

- (IBAction)registerButtonPressed:(UIButton *)button {
	[self submitSignUp];
}

- (void)submitSignUp {
	
	BOOL valid = [self registrationFormIsValidForEmail:self.emailTextField
											  userName:self.usernameTextField
											  password:self.passwordTextField
													dd:self.dayTextField
													mm: self.monthTextField
												  yyyy: self.yearTextField];
	if (valid) {
		[self.emailTextField resignFirstResponder];
		[self.passwordTextField resignFirstResponder];
		
		[self.dayTextField resignFirstResponder];
		[self.monthTextField resignFirstResponder];
		[self.yearTextField resignFirstResponder];
		
		//TODO: Network Error stuff
		
		self.registerButton.enabled = NO;
		
		self.dayTextField.text = [self zeroPadIfOneCharacter:self.dayTextField.text];
		self.monthTextField.text = [self zeroPadIfOneCharacter:self.monthTextField.text];
		
		NSString* dobString = [NSString stringWithFormat: @"%@-%@-%@", self.yearTextField.text, self.monthTextField.text, self.dayTextField.text];
		NSDictionary *userData = @{@"username": self.usernameTextField.text,
								   @"password": self.passwordTextField.text,
								   @"date_of_birth": dobString,
								   @"locale": @"en-US",
								   @"email": self.emailTextField.text,
								   @"gender": self.genderSegmentedControl.selectedSegmentIndex == 0 ? @"m" : @"f"};
		
		
		[[SYNLoginManager sharedManager] registerUserWithData: userData
											completionHandler: ^(NSDictionary *dictionary) {
												
												if (self.avatarImage) {
													[self uploadAvatar:self.avatarImage];
												}
												
												[[NSNotificationCenter defaultCenter] postNotificationName: kLoginCompleted
																									object: self];
											} errorHandler: ^(NSDictionary *errorDictionary) {
												
												self.registerButton.enabled = YES;
												
												NSDictionary* formErrors = errorDictionary[@"form_errors"];
												
												if (formErrors)
												{
													[self showRegistrationError: formErrors];
												}
											}];
	}
}


- (void)showRegistrationError:(NSDictionary *)errorDictionary {
    NSArray* usernameError = errorDictionary[@"username"];
    NSArray* passwordError = errorDictionary[@"password"];
    NSArray* emailError = errorDictionary[@"email"];
    
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
- (BOOL)registrationFormIsValidForEmail:(SYNTextFieldLogin *)emailInputField
							   userName:(SYNTextFieldLogin *)userNameInputField
							   password:(SYNTextFieldLogin *)passwordInputField
									 dd:(SYNTextFieldLogin *)ddInputField
									 mm:(SYNTextFieldLogin *)mmInputField
								   yyyy:(SYNTextFieldLogin *)yyyyInputField {
	
    if (emailInputField.text.length < 1) {
		emailInputField.errorMode = YES;
		self.emailErrorLabel.text = NSLocalizedString(@"register_screen_form_field_email_error_empty", nil);
		
        [emailInputField becomeFirstResponder];
        
        return NO;
    }
    
    if (![emailInputField.text isValidEmail]) {
		emailInputField.errorMode = YES;
		self.emailErrorLabel.text = NSLocalizedString(@"register_screen_form_field_email_error_empty", nil);
		
        [emailInputField becomeFirstResponder];
        
        return NO;
    }
	
    if (userNameInputField.text.length < 1) {
		userNameInputField.errorMode = YES;
		self.usernameErrorLabel.text = NSLocalizedString(@"register_screen_form_field_username_error_empty", nil);
        
        [userNameInputField becomeFirstResponder];
        
        return NO;
    }
    
    if (![userNameInputField.text isValidUsername]) {
		userNameInputField.errorMode = YES;
		self.usernameErrorLabel.text = NSLocalizedString(@"register_screen_form_field_username_error_invalid", nil);
        
        [userNameInputField becomeFirstResponder];
        
        return NO;
    }
    
    if (userNameInputField.text.length > 20) {
		userNameInputField.errorMode = YES;
		self.usernameErrorLabel.text = NSLocalizedString(@"register_screen_form_field_username_error_too_long", nil);
        
        [userNameInputField becomeFirstResponder];
        
        return NO;
    }
	
	if (passwordInputField.text.length < 1) {
		passwordInputField.errorMode = YES;
		self.passwordErrorLabel.text = NSLocalizedString(@"register_screen_form_field_password_error_empty", nil);
		
		[passwordInputField becomeFirstResponder];
		
		return NO;
	}
	
	return [self dateValidForDd:ddInputField
							 mm:mmInputField
						   yyyy:yyyyInputField];
}


@end
