//
//  SYNiPadIntroViewController.m
//  dolly
//
//  Created by Sherman Lo on 15/01/14.
//  Copyright (c) 2014 Rockpack Ltd. All rights reserved.
//

#import "SYNiPadIntroViewController.h"
#import "SYNiPadLoginViewController.h"
#import "SYNiPadIntroToLoginAnimator.h"
#import "SYNIPadSignupViewController.h"
#import "SYNiPadLoginToSignupAnimator.h"
#import "SYNiPadLoginToForgotPasswordAnimator.h"
#import "SYNiPadPasswordForgotViewController.h"
#import "SYNiPadIntroToSignupAnimator.h"
#import "SYNLoginManager.h"
#import "GAI+Tracking.h"

@interface SYNiPadIntroViewController () <UINavigationControllerDelegate>

@property (nonatomic, strong) IBOutlet UIButton *facebookButton;
@property (nonatomic, strong) IBOutlet UIButton *signupButton;

@property (nonatomic, strong) IBOutlet UIButton *loginButton;
@property (nonatomic, strong) IBOutlet UILabel *loginLabel;
@property (strong, nonatomic) IBOutlet UIImageView *logoImageView;
@property (strong, nonatomic) IBOutlet UIView *buttonContainerView;
@property (strong, nonatomic) IBOutlet UIView *userContainerView;

@end

@implementation SYNiPadIntroViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.navigationController.delegate = self;
    
    
    CGRect tmpFrame = self.logoImageView.frame;
    CGRect finalFrame = self.logoImageView.frame;
    tmpFrame = CGRectMake(self.view.center.x-(self.logoImageView.frame.size.width/2), self.view.center.y-(self.logoImageView.frame.size.height/2), tmpFrame.size.width, tmpFrame.size.height);
    self.logoImageView.frame = tmpFrame;
    self.logoImageView.alpha = 0.0f;
    
    [UIView animateWithDuration:1.0f animations:^{
        self.logoImageView.alpha = 1.0f;
    }];
    
    
    [UIView animateWithDuration:1.2f delay:1.1f options:UIViewAnimationCurveEaseInOut animations:^{
        self.logoImageView.frame = finalFrame;
        
    } completion:^(BOOL finished) {
        self.buttonContainerView.hidden = NO;
        self.buttonContainerView.alpha = 0.0f;
        
        [UIView animateWithDuration:1.0 animations:^{
            
            self.buttonContainerView.alpha = 1.0f;
            
        } completion:^(BOOL finished) {
            self.userContainerView.hidden = NO;
            
            
        }];
        
    }];

}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

    
    
	[[GAI sharedInstance] trackStartScreenView];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(applicationWillEnterForeground:)
												 name:UIApplicationWillEnterForegroundNotification
											   object:nil];
}

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
								  animationControllerForOperation:(UINavigationControllerOperation)operation
											   fromViewController:(UIViewController *)fromVC
												 toViewController:(UIViewController *)toVC {
	if ([fromVC isKindOfClass:[SYNiPadIntroViewController class]] && [toVC isKindOfClass:[SYNiPadLoginViewController class]]) {
		return [[SYNiPadIntroToLoginAnimator alloc] init];
	}
	if ([fromVC isKindOfClass:[SYNiPadLoginViewController class]] && [toVC isKindOfClass:[SYNiPadPasswordForgotViewController class]]) {
		return [SYNiPadLoginToForgotPasswordAnimator animatorForPresentation:YES];
	}
	if ([fromVC isKindOfClass:[SYNiPadPasswordForgotViewController class]] && [toVC isKindOfClass:[SYNiPadLoginViewController class]]) {
		return [SYNiPadLoginToForgotPasswordAnimator animatorForPresentation:NO];
	}
	if ([fromVC isKindOfClass:[SYNiPadLoginViewController class]] && [toVC isKindOfClass:[SYNIPadSignupViewController class]]) {
		return [SYNiPadLoginToSignupAnimator animatorForPresentation:YES];
	}
	if ([fromVC isKindOfClass:[SYNIPadSignupViewController class]] && [toVC isKindOfClass:[SYNiPadLoginViewController class]]) {
		return [SYNiPadLoginToSignupAnimator animatorForPresentation:NO];
	}
	if ([fromVC isKindOfClass:[SYNiPadIntroViewController class]] && [toVC isKindOfClass:[SYNIPadSignupViewController class]]) {
		return [[SYNiPadIntroToSignupAnimator alloc] init];
	}
	return nil;
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (IBAction)facebookButtonPressed:(UIButton *)button {
	[self disableLoginButtons];
	
	__weak typeof(self) weakSelf = self;
	
	[[SYNLoginManager sharedManager] loginThroughFacebookWithCompletionHandler:^(NSDictionary *dictionary) {
		[[NSNotificationCenter defaultCenter] postNotificationName:kLoginCompleted
															object:self];
	} errorHandler:^(NSString *error) {
		[weakSelf enableLoginButtons];
		
		[[[UIAlertView alloc] initWithTitle: NSLocalizedString(@"facebook_login_error_title", nil)
									message: error
								   delegate: nil
						  cancelButtonTitle: NSLocalizedString(@"OK", nil)
						  otherButtonTitles: nil] show];
		
		DebugLog(@"Log in failed!");
	}];
}

- (void)applicationWillEnterForeground:(NSNotification *)notification {
	[self enableLoginButtons];
}

- (void)disableLoginButtons {
	self.signupButton.enabled = NO;
	self.loginButton.enabled = NO;
	self.facebookButton.enabled = NO;
	[UIView animateWithDuration:0.3 animations:^{
		self.signupButton.alpha = 0.0;
		self.loginButton.alpha = 0.0;
	}];
}

- (void)enableLoginButtons {
	self.signupButton.enabled = YES;
	self.loginButton.enabled = YES;
	self.facebookButton.enabled = YES;
	[UIView animateWithDuration:0.3 animations:^{
		self.signupButton.alpha = 1.0;
		self.loginButton.alpha = 1.0;
	}];
}

@end
