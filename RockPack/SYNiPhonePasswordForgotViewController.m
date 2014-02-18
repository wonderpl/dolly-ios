//
//  SYNiPhonePasswordForgotViewController.m
//  dolly
//
//  Created by Sherman Lo on 13/01/14.
//  Copyright (c) 2014 Rockpack Ltd. All rights reserved.
//

#import "SYNiPhonePasswordForgotViewController.h"
#import "SYNTextFieldLogin.h"
#import "SYNLoginManager.h"
#import "UIFont+SYNFont.h"
#import "SYNTrackingManager.h"

@interface SYNiPhonePasswordForgotViewController () <UIBarPositioningDelegate, UITextFieldDelegate>

@property (nonatomic, strong) IBOutlet UINavigationBar *navigationBar;
@property (nonatomic, strong) IBOutlet UIView *backgroundView;
@property (nonatomic, strong) IBOutlet UIView *containerView;

@property (nonatomic, strong) IBOutlet SYNTextFieldLogin *emailUsernameTextField;

@property (nonatomic, strong) IBOutlet UILabel *errorLabel;

@property (nonatomic, strong) IBOutlet UIBarButtonItem *backBarButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *confirmBarButton;

@end

@implementation SYNiPhonePasswordForgotViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.emailUsernameTextField.font = [UIFont lightCustomFontOfSize:self.emailUsernameTextField.font.pointSize];
	self.errorLabel.font = [UIFont lightCustomFontOfSize:self.errorLabel.font.pointSize];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	[self.emailUsernameTextField becomeFirstResponder];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	[[SYNTrackingManager sharedManager] trackForgotPasswordScreenView];
}

#pragma mark - UIBarPositioningDelegate

- (UIBarPosition)positionForBar:(id<UIBarPositioning>)bar {
	return UIBarPositionTopAttached;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	self.emailUsernameTextField.errorMode = NO;
	self.errorLabel.text = nil;
	
	return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[self submitForgotPassword];
	
	return YES;
}

#pragma mark - IBActions

- (IBAction)backButtonPressed:(UIBarButtonItem *)barButton {
	[self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)confirmButtonPressed:(UIBarButtonItem *)barButton {
	[self submitForgotPassword];
}

#pragma mark - Private

- (BOOL)resetPasswordFormIsValidForTextField:(SYNTextFieldLogin *)textField {
    if (textField.text.length < 1) {
		((SYNTextFieldLogin *)textField).errorMode = YES;
		self.errorLabel.text = NSLocalizedString(@"forgot_password_screen_form_field_username_error_empty", nil);
        
        [textField becomeFirstResponder];
        
        return NO;
    }
    
    return YES;
}

- (void)submitForgotPassword {
	if ([self resetPasswordFormIsValidForTextField:self.emailUsernameTextField]) {
		UINavigationItem *navigationItem = self.navigationBar.topItem;
		
		[navigationItem setLeftBarButtonItem:nil animated:YES];
		[navigationItem setRightBarButtonItem:nil animated:YES];
		
		[[SYNLoginManager sharedManager] doRequestPasswordResetForUsername:self.emailUsernameTextField.text
														 completionHandler:^(NSDictionary *completionInfo) {
															 if (completionInfo[@"error"]) {
																 self.errorLabel.text = NSLocalizedString(@"forgot_password_screen_form_field_username_user_unknown", nil);
																 
																 [navigationItem setLeftBarButtonItem:self.backBarButton animated:YES];
																 [navigationItem setRightBarButtonItem:self.confirmBarButton animated:YES];
															 } else {
																 NSString *title = NSLocalizedString(@"forgot_password_screen_complete_title", nil);
																 NSString *message = NSLocalizedString(@"forgot_password_screen_complete_message", nil);
																 
																 [[[UIAlertView alloc] initWithTitle:title
																							 message:message
																							delegate:nil
																				   cancelButtonTitle:NSLocalizedString(@"OK", nil)
																				   otherButtonTitles:nil] show];
																 
																 [navigationItem setLeftBarButtonItem:self.backBarButton animated:YES];
															 }
														 } errorHandler:^(NSError *error) {
															 
														 }];
	}
}

@end
