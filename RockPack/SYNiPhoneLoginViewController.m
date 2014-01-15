//
//  SYNiPhoneLoginViewController.m
//  dolly
//
//  Created by Sherman Lo on 8/01/14.
//  Copyright (c) 2014 Rockpack Ltd. All rights reserved.
//

#import "SYNiPhoneLoginViewController.h"
#import "SYNLoginManager.h"
#import "GAI+Tracking.h"
#import "UIFont+SYNFont.h"
#import "SYNTextFieldLogin.h"

@interface SYNiPhoneLoginViewController () <UITextFieldDelegate, UIBarPositioningDelegate>

@property (nonatomic, strong) IBOutlet UIView *backgroundView;

@property (nonatomic, strong) IBOutlet UIView *containerView;

@property (nonatomic, strong) IBOutlet SYNTextFieldLogin *emailUsernameTextField;
@property (nonatomic, strong) IBOutlet SYNTextFieldLogin *passwordTextField;

@property (nonatomic, strong) IBOutlet UIButton *forgotPasswordButton;

@property (nonatomic, strong) IBOutlet UILabel *errorLabel;

@property (nonatomic, strong) IBOutlet UINavigationBar *navigationBar;

@property (nonatomic, strong) IBOutlet UIBarButtonItem *backBarButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *loginBarButton;

@end

@implementation SYNiPhoneLoginViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.emailUsernameTextField.font = [UIFont lightCustomFontOfSize:self.emailUsernameTextField.font.pointSize];
	self.passwordTextField.font = [UIFont lightCustomFontOfSize:self.passwordTextField.font.pointSize];
	
    self.forgotPasswordButton.titleLabel.font = [UIFont lightCustomFontOfSize:self.forgotPasswordButton.titleLabel.font.pointSize];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	[self.emailUsernameTextField becomeFirstResponder];
}

- (BOOL)textField:(SYNTextFieldLogin *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	
	textField.errorMode = NO;
	self.errorLabel.text = nil;
	
	return YES;
}

- (BOOL)textFieldShouldReturn:(SYNTextFieldLogin *)textField {
	if (self.emailUsernameTextField == textField) {
		[self.passwordTextField becomeFirstResponder];
	}
	
	if (self.passwordTextField == textField) {
		[self submitLogin];
	}
	return YES;
}

- (BOOL)loginFormIsValidForUsername:(SYNTextFieldLogin *)userNameInputField
						   password:(SYNTextFieldLogin *)passwordInputField {
	
    if (userNameInputField.text.length < 1) {
		userNameInputField.errorMode = YES;
		self.errorLabel.text = NSLocalizedString(@"login_screen_form_field_username_error_empty", nil);
		
        [userNameInputField becomeFirstResponder];
        
        return NO;
    }
    
    if (passwordInputField.text.length < 1) {
		passwordInputField.errorMode = YES;
		self.errorLabel.text = NSLocalizedString(@"login_screen_form_field_password_error_empty", nil);
		
        [passwordInputField becomeFirstResponder];
        
        return NO;
    }
    
    return YES;
}

- (UIBarPosition)positionForBar:(id<UIBarPositioning>)bar {
	return UIBarPositionTopAttached;
}

#pragma mark - IBActions

- (IBAction)backButtonPressed:(UIBarButtonItem *)barButton {
	[self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)loginButtonPressed:(UIBarButtonItem *)barButton {
	[self submitLogin];
}

- (void)submitLogin {
	BOOL valid = [self loginFormIsValidForUsername:self.emailUsernameTextField
										  password:self.passwordTextField];
	
	if (valid) {
		[self.emailUsernameTextField resignFirstResponder];
		[self.passwordTextField resignFirstResponder];
		
		UINavigationItem *navigationItem = self.navigationBar.topItem;
		
		//TODO: Show network error?
		
		[navigationItem setLeftBarButtonItem:nil animated:YES];
		[navigationItem setRightBarButtonItem:nil animated:YES];
		
		//TODO: Activity indicator
		
		[[SYNLoginManager sharedManager] loginForUsername:self.emailUsernameTextField.text
											  forPassword:self.passwordTextField.text
										completionHandler:^(NSDictionary *dictionary) {
											
											[[NSNotificationCenter defaultCenter] postNotificationName:kLoginCompleted
																								object:self];
											
											[[GAI sharedInstance] trackUserLoginFromOrigin:kOriginRockpack];
										} errorHandler:^(NSDictionary *errorDictionary) {
											[navigationItem setLeftBarButtonItem:self.backBarButton animated:YES];
											[navigationItem setRightBarButtonItem:self.loginBarButton animated:YES];
											
											NSError *networkError = errorDictionary[@"nserror"];
											
											if (networkError.code >= 500 && networkError.code < 600) {
												return;
											}
											
											NSString *savingError = errorDictionary[@"saving_error"];
											if (savingError) {
												self.errorLabel.text = NSLocalizedString(@"login_screen_saving_error", nil);
											} else {
												self.errorLabel.text = NSLocalizedString(@"login_screen_form_field_username_password_error_incorrect", nil);
											}
											
										}];
	}
}

@end
