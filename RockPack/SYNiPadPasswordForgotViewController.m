//
//  SYNiPadPasswordForgotViewController.m
//  dolly
//
//  Created by Sherman Lo on 15/01/14.
//  Copyright (c) 2014 Rockpack Ltd. All rights reserved.
//

#import "SYNiPadPasswordForgotViewController.h"
#import "UIFont+SYNFont.h"
#import "GAI+Tracking.h"
#import "SYNTextFieldLogin.h"
#import "SYNLoginManager.h"

@interface SYNiPadPasswordForgotViewController () <UITextFieldDelegate>

@property (nonatomic, strong) IBOutlet SYNTextFieldLogin *emailUsernameTextField;
@property (nonatomic, strong) IBOutlet UILabel *errorLabel;
@property (nonatomic, strong) IBOutlet UIButton *registerButton;

@property (nonatomic, strong) IBOutlet UILabel *accountLabel;
@property (nonatomic, strong) IBOutlet UILabel *termsLabel;
@property (nonatomic, strong) IBOutlet UIButton *loginButton;

@end

@implementation SYNiPadPasswordForgotViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	[self.emailUsernameTextField becomeFirstResponder];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	[[GAI sharedInstance] trackForgotPasswordScreenView];
}

- (IBAction)loginButtonPressed:(UIButton *)button {
	[self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)passwordButtonPressed:(UIButton *)button {
	[self submitForgotPassword];
}

- (BOOL)resetPasswordFormIsValidForTextField:(SYNTextFieldLogin *)textField {
    if (textField.text.length < 1) {
		textField.errorMode = YES;
		self.errorLabel.text = NSLocalizedString(@"forgot_password_screen_form_field_username_error_empty", nil);
        
        [textField becomeFirstResponder];
        
        return NO;
    }
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	self.emailUsernameTextField.errorMode = NO;
	self.errorLabel.text = nil;
	
	return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[self submitForgotPassword];
	
	return YES;
}

- (void)submitForgotPassword {
	if ([self resetPasswordFormIsValidForTextField:self.emailUsernameTextField]) {
//		self.loginButton.enabled = NO;
//		self.registerButton.enabled = NO;
		
		[[SYNLoginManager sharedManager] doRequestPasswordResetForUsername:self.emailUsernameTextField.text
														 completionHandler:^(NSDictionary *completionInfo) {
															 if (completionInfo[@"error"]) {
																 self.errorLabel.text = NSLocalizedString(@"forgot_password_screen_form_field_username_user_unknown", nil);
																 self.emailUsernameTextField.errorMode = YES;
																 
//																 self.loginButton.enabled = YES;
//																 self.registerButton.enabled = YES;
															 } else {
																 NSString *title = NSLocalizedString(@"forgot_password_screen_complete_title", nil);
																 NSString *message = NSLocalizedString(@"forgot_password_screen_complete_message", nil);
																 
																 [[[UIAlertView alloc] initWithTitle:title
																							 message:message
																							delegate:nil
																				   cancelButtonTitle:NSLocalizedString(@"OK", nil)
																				   otherButtonTitles:nil] show];
															 }
														 } errorHandler:^(NSError *error) {
															 if (error.code<500 || error.code >= 600) {
																 [[[UIAlertView alloc] initWithTitle: NSLocalizedString(@"forgot_password_screen_complete_title", nil)
																							 message: NSLocalizedString(@"forgot_password_screen_form_field_request_failed_error", nil)
																							delegate: nil
																				   cancelButtonTitle: NSLocalizedString(@"OK", nil)
																				   otherButtonTitles: nil] show];
															 }
														 }];
	}
}


@end
