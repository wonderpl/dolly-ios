//
//  SYNiPhoneSignupDetailsViewController.m
//  dolly
//
//  Created by Sherman Lo on 14/01/14.
//  Copyright (c) 2014 Rockpack Ltd. All rights reserved.
//

#import "SYNiPhoneSignupDetailsViewController.h"
#import "UIFont+SYNFont.h"
#import "NSString+Validation.h"
#import "SYNTextFieldLogin.h"
#import "SYNLoginManager.h"
#import "GAI+Tracking.h"

@interface SYNiPhoneSignupDetailsViewController () <UIBarPositioningDelegate, UITextFieldDelegate>

@property (nonatomic, strong) IBOutlet UIView *backgroundView;
@property (nonatomic, strong) IBOutlet UIView *containerView;

@property (nonatomic, strong) IBOutlet UINavigationBar *navigationBar;

@property (nonatomic, strong) IBOutlet SYNTextFieldLogin *emailTextField;
@property (nonatomic, strong) IBOutlet SYNTextFieldLogin *passwordTextField;

@property (nonatomic, strong) IBOutlet SYNTextFieldLogin *dayTextField;
@property (nonatomic, strong) IBOutlet SYNTextFieldLogin *monthTextField;
@property (nonatomic, strong) IBOutlet SYNTextFieldLogin *yearTextField;

@property (nonatomic, strong) NSArray *textFields;

@property (nonatomic, strong) IBOutlet UIBarButtonItem *backBarButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *signUpBarButton;

@property (nonatomic, strong) IBOutlet UILabel *errorLabel;

@property (nonatomic, strong) IBOutlet UISegmentedControl *genderSegmentedControl;

@end

@implementation SYNiPhoneSignupDetailsViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.emailTextField.font = [UIFont lightCustomFontOfSize:self.emailTextField.font.pointSize];
	self.passwordTextField.font = [UIFont lightCustomFontOfSize:self.passwordTextField.font.pointSize];
	
	self.dayTextField.font = [UIFont lightCustomFontOfSize:self.dayTextField.font.pointSize];
	self.monthTextField.font = [UIFont lightCustomFontOfSize:self.monthTextField.font.pointSize];
	self.yearTextField.font = [UIFont lightCustomFontOfSize:self.yearTextField.font.pointSize];
	
	self.errorLabel.font = [UIFont lightCustomFontOfSize:self.errorLabel.font.pointSize];
	
	self.textFields = @[ self.emailTextField, self.passwordTextField, self.dayTextField, self.monthTextField, self.yearTextField ];
	
	[self updateDateOfBirthFieldsForLocale];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	[self.emailTextField becomeFirstResponder];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	[[GAI sharedInstance] trackRegisterStep2ScreenView];
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
	
	BOOL valid = [self registrationFormIsValidForEmail:self.emailTextField
											  userName:nil
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
		
		UINavigationItem *navigationItem = self.navigationBar.topItem;
		[navigationItem setLeftBarButtonItem:nil animated:YES];
		[navigationItem setRightBarButtonItem:nil animated:YES];
		
		self.dayTextField.text = [self zeroPadIfOneCharacter:self.dayTextField.text];
		self.monthTextField.text = [self zeroPadIfOneCharacter:self.monthTextField.text];
		
		NSString* dobString = [NSString stringWithFormat: @"%@-%@-%@", self.yearTextField.text, self.monthTextField.text, self.dayTextField.text];
		NSDictionary *userData = @{@"username": self.username,
								   @"password": self.passwordTextField.text,
								   @"date_of_birth": dobString,
								   @"locale": @"en-US",
								   @"email": self.emailTextField.text,
								   @"gender": self.genderSegmentedControl.selectedSegmentIndex == 0 ? @"m" : @"f"};
		
		
		[[SYNLoginManager sharedManager] registerUserWithData: userData
				 completionHandler: ^(NSDictionary *dictionary) {
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
							   userName:(SYNTextFieldLogin *)userNameInputField //TODO: IPAD ONLY!1?!?
							   password:(SYNTextFieldLogin *)passwordInputField
									 dd:(SYNTextFieldLogin *)ddInputField
									 mm:(SYNTextFieldLogin *)mmInputField
								   yyyy:(SYNTextFieldLogin *)yyyyInputField {
	
    if (emailInputField.text.length < 1) {
		emailInputField.errorMode = YES;
		self.errorLabel.text = NSLocalizedString(@"register_screen_form_field_email_error_empty", nil);
		
        [emailInputField becomeFirstResponder];
        
        return NO;
    }
    
    if (![emailInputField.text isValidEmail]) {
		emailInputField.errorMode = YES;
		self.errorLabel.text = NSLocalizedString(@"register_screen_form_field_email_error_empty", nil);
		
        [emailInputField becomeFirstResponder];
        
        return NO;
    }
	
	if (passwordInputField.text.length < 1) {
		passwordInputField.errorMode = YES;
		self.errorLabel.text = NSLocalizedString(@"register_screen_form_field_password_error_empty", nil);
		
		[passwordInputField becomeFirstResponder];
		
		return NO;
	}
	
	return [self dateValidForDd:ddInputField
							 mm:mmInputField
						   yyyy:yyyyInputField];
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
			self.errorLabel.text = NSLocalizedString(@"register_screen_form_error_invalid_date", nil);
            
            [ddInputField becomeFirstResponder];
            
            return NO;
        }
        
        if (dobField.text.length == 1) {
            dobField.text = [NSString stringWithFormat: @"0%@", dobField.text]; // add a trailing 0
        }
        
        if (![numberFormatter numberFromString: dobField.text]) {
			dobField.errorMode = YES;
			self.errorLabel.text = NSLocalizedString(@"register_screen_form_error_invalid_date", nil);
			
            [dobField becomeFirstResponder];
            
            return NO;
        }
    }
    
    if (yyyyInputField.text.length < 4) {
		yyyyInputField.errorMode = YES;
		self.errorLabel.text = NSLocalizedString(@"register_screen_form_error_invalid_date", nil);
		
        return NO;
    }
	
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat: @"yyyy-MM-dd"];
    NSDate *potentialDate = [dateFormatter dateFromString: [NSString stringWithFormat: @"%@-%@-%@", yyyyInputField.text, [self zeroPadIfOneCharacter: mmInputField.text], [self zeroPadIfOneCharacter: ddInputField.text]]];
    
    // == Not a real date == //
    
    if (!potentialDate) {
		self.yearTextField.errorMode = YES;
		self.errorLabel.text = NSLocalizedString(@"register_screen_form_error_invalid_date", nil);
		
        return NO;
    }
    
    NSDate *nowDate = [NSDate date];
    
    // == In the future == //
    
    if ([nowDate compare: potentialDate] == NSOrderedAscending) {
		self.yearTextField.errorMode = YES;
		self.errorLabel.text = NSLocalizedString(@"register_screen_form_error_future", nil);
		      
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
		self.errorLabel.text = NSLocalizedString(@"register_screen_form_error_under_13", nil);
		
        return NO;
    }
    
    return YES;
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

- (NSString *)zeroPadIfOneCharacter:(NSString *)inputString {
    if ([inputString length] == 1) {
        return [NSString stringWithFormat: @"0%@", inputString];
    }
    
    return inputString;
}

- (BOOL)textField:(SYNTextFieldLogin *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	
	textField.errorMode = NO;
	self.errorLabel.text = nil;
	
	NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
	NSUInteger newLength = [newString length];
    
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

- (UITextField *)nextTextFieldAfter:(UITextField *)textField {
	NSInteger index = [self.textFields indexOfObject:textField];
	if (index < [self.textFields count] - 1) {
		return self.textFields[index + 1];
	}
	return nil;
}

@end
