//
//  SYNiPadLoginViewController.m
//  dolly
//
//  Created by Sherman Lo on 15/01/14.
//  Copyright (c) 2014 Rockpack Ltd. All rights reserved.
//

#import "SYNiPadLoginViewController.h"
#import "SYNTrackingManager.h"
#import "AppConstants.h"
#import "SYNTextFieldLogin.h"
#import "SYNLoginManager.h"
#import "UIFont+SYNFont.h"
#import "SYNiPadLoginToForgotPasswordAnimator.h"
#import "SYNiPadPasswordForgotViewController.h"

@interface SYNiPadLoginViewController () <UITextFieldDelegate, UIViewControllerTransitioningDelegate>

@property (nonatomic, strong) IBOutlet UIButton *facebookButton;
@property (nonatomic, strong) IBOutlet SYNTextFieldLogin *emailUsernameTextField;
@property (nonatomic, strong) IBOutlet UILabel *emailUsernameErrorLabel;
@property (nonatomic, strong) IBOutlet SYNTextFieldLogin *passwordTextField;
@property (nonatomic, strong) IBOutlet UILabel *passwordErrorLabel;
@property (nonatomic, strong) IBOutlet UIButton *loginButton;
@property (nonatomic, strong) IBOutlet UIButton *forgotPasswordButton;
@property (nonatomic, strong) NSMutableArray *errorMessageLabels;

@end

@implementation SYNiPadLoginViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.loginButton.titleLabel.font = [UIFont lightCustomFontOfSize:self.loginButton.titleLabel.font.pointSize];
    
    [self.CreateAnAccountLabel setFont:[UIFont regularCustomFontOfSize:19]];
    
    [self.forgotPasswordButton.titleLabel setFont:[UIFont regularCustomFontOfSize:15]];
    
    
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	[self.emailUsernameTextField becomeFirstResponder];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	[[SYNTrackingManager sharedManager] trackLoginScreenView];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(applicationWillEnterForeground:)
												 name:UIApplicationWillEnterForegroundNotification
											   object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([segue.identifier isEqualToString:@"ForgotPassword"]) {
		SYNiPadPasswordForgotViewController *passwordViewController = segue.destinationViewController;
		passwordViewController.transitioningDelegate = self;
	}
}

- (BOOL)textField:(SYNTextFieldLogin *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	if (textField == self.emailUsernameTextField) {
		textField.errorMode = NO;
		self.emailUsernameErrorLabel.text = nil;
	}
	if (textField == self.passwordTextField) {
		textField.errorMode = NO;
		self.passwordErrorLabel.text = nil;
	}
	
	return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	if (self.emailUsernameTextField.text.length < 1) {
		[self.emailUsernameTextField becomeFirstResponder];
		return YES;
	}
	if (self.passwordTextField.text.length < 1) {
		[self.passwordTextField becomeFirstResponder];
		return YES;
	}
	
	[self submitLogin];
	
	return YES;
}

- (IBAction)facebookButtonPressed:(UIButton *)button {
	[self disableLoginButtons];
	
	__weak typeof(self) weakSelf = self;
	
	[[SYNLoginManager sharedManager] loginThroughFacebookWithCompletionHandler:^(NSDictionary *dictionary) {
		[[NSNotificationCenter defaultCenter] postNotificationName:kLoginCompleted
															object:self];
	} errorHandler:^(id error) {
		[weakSelf enableLoginButtons];

        if ([error isKindOfClass:[NSString class]]) {

        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"facebook_login_error_title", nil)
									message:error
								   delegate:nil
						  cancelButtonTitle:NSLocalizedString(@"OK", nil)
						  otherButtonTitles:nil] show];
		
        } else if ([error isKindOfClass:[NSDictionary class]])
        {
            
            [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"facebook_login_error_title", nil)
                                        message:error[@"error"]
                                       delegate:nil
                              cancelButtonTitle:NSLocalizedString(@"OK", nil)
                              otherButtonTitles:nil] show];

            
        }
		DebugLog(@"Log in failed!");
	}];
}

- (IBAction)loginButtonPressed:(UIButton *)button {
	[self submitLogin];
}

- (void)submitLogin {
	[[SYNTrackingManager sharedManager] trackUserLoginFromOrigin:kOriginWonderPL];
	
//    [self clearAllErrorArrows];
//    
//    [self resignAllFirstResponders];
    
	if (![self loginFormIsValidForUsername:self.emailUsernameTextField password:self.passwordTextField]) {
		return;
	}
    
	[self disableLoginButtons];
	
	[[SYNLoginManager sharedManager] loginForUsername:self.emailUsernameTextField.text
										  forPassword:self.passwordTextField.text
									completionHandler:^(NSDictionary *dictionary) {
										[[NSNotificationCenter defaultCenter] postNotificationName:kLoginCompleted
																							object:self];
									} errorHandler:^(NSDictionary *errorDictionary) {
										[self enableLoginButtons];
										[self.emailUsernameTextField becomeFirstResponder];
										
										NSDictionary* errors = errorDictionary [@"error"];
										if (errors) {
											self.emailUsernameErrorLabel.text = NSLocalizedString(@"login_screen_form_field_username_password_error_incorrect", nil);
											self.emailUsernameTextField.errorMode = YES;
											
											self.passwordErrorLabel.text = NSLocalizedString(@"login_screen_form_field_username_password_error_incorrect", nil);
											self.passwordTextField.errorMode = YES;
										}
										
										NSDictionary* savingError = errorDictionary [@"saving_error"];
										if (savingError) {
											self.passwordErrorLabel.text = NSLocalizedString(@"login_screen_saving_error", nil);
											self.passwordTextField.errorMode = YES;
										}
										
									}];
}

- (void)applicationWillEnterForeground:(NSNotification *)notification {
	[self enableLoginButtons];
}

- (BOOL) loginFormIsValidForUsername: (SYNTextFieldLogin *) userNameInputField
                            password: (SYNTextFieldLogin *) passwordInputField {
    if (userNameInputField.text.length < 1) {
		self.emailUsernameErrorLabel.text = NSLocalizedString(@"login_screen_form_field_username_error_empty", nil);
		userNameInputField.errorMode = YES;
        
        [userNameInputField becomeFirstResponder];
        
        return NO;
    }
    
    if (passwordInputField.text.length < 1) {
		self.passwordErrorLabel.text = NSLocalizedString(@"login_screen_form_field_username_error_empty", nil);
		passwordInputField.errorMode = YES;
		
        [passwordInputField becomeFirstResponder];
        
        return NO;
    }
    
    return YES;
}

- (void)disableLoginButtons {
	self.loginButton.enabled = NO;
	self.facebookButton.enabled = NO;
	
	self.emailUsernameTextField.enabled = NO;
	self.passwordTextField.enabled = NO;
}

- (void)enableLoginButtons {
	self.loginButton.enabled = YES;
	self.facebookButton.enabled = YES;
	
	self.emailUsernameTextField.enabled = YES;
	self.passwordTextField.enabled = YES;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
	return [SYNiPadLoginToForgotPasswordAnimator animatorForPresentation:YES];
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
	return [SYNiPadLoginToForgotPasswordAnimator animatorForPresentation:NO];
}

@end
