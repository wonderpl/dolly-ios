//
//  SYNiPhoneIntroViewController.m
//  dolly
//
//  Created by Sherman Lo on 7/01/14.
//  Copyright (c) 2014 Rockpack Ltd. All rights reserved.
//

#import "SYNiPhoneIntroViewController.h"
#import "UIFont+SYNFont.h"
#import "SYNAppDelegate.h"
#import "SYNNetworkEngine.h"
#import "SYNFacebookManager.h"
#import "SYNOAuthNetworkEngine.h"
#import "NSString+Utils.h"
#import "SYNiPhoneLoginViewController.h"
#import "SYNiPhoneLoginAnimator.h"
#import "SYNLoginManager.h"
#import "GAI+Tracking.h"
#import <FacebookSDK/FacebookSDK.h>
#import <Reachability.h>
#import "SYNExampleUsersViewController.h"
@interface SYNiPhoneIntroViewController () <UINavigationControllerDelegate, UIViewControllerTransitioningDelegate>

@property (nonatomic, strong) SYNAppDelegate *appDelegate;

@property (nonatomic, strong) IBOutlet UILabel *subtitleLabel;

@property (nonatomic, strong) IBOutlet UIView *containerView;

@property (nonatomic, strong) IBOutlet UIButton *facebookButton;
@property (nonatomic, strong) IBOutlet UIButton *loginButton;
@property (strong, nonatomic) IBOutlet UIView *userContainerView;
@property (nonatomic, strong) IBOutlet UIButton *signupButton;
@property (strong, nonatomic) IBOutlet UIImageView *logoImageView;

@property (strong, nonatomic) IBOutlet UILabel *sloganView;



@end

@implementation SYNiPhoneIntroViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	NSDictionary *textAttributes = @{ NSFontAttributeName : [UIFont regularCustomFontOfSize:15.0],
									  NSForegroundColorAttributeName : [UIColor colorWithWhite:167/255.0 alpha:1.0] };
	[[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil] setTitleTextAttributes:textAttributes
																							forState:UIControlStateNormal];
	
	self.navigationController.delegate = self;
	
	self.appDelegate = [[UIApplication sharedApplication] delegate];
	
	self.subtitleLabel.font = [UIFont lightCustomFontOfSize:15.0];
	
	self.loginButton.titleLabel.font = [UIFont lightCustomFontOfSize:20.0];
	self.signupButton.titleLabel.font = [UIFont lightCustomFontOfSize:20.0];
    
    
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
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
        self.containerView.hidden = NO;
        self.containerView.alpha = 0.0f;
        
        [UIView animateWithDuration:1.0 animations:^{
            
            self.containerView.alpha = 1.0f;
            
        } completion:^(BOOL finished) {
            self.userContainerView.hidden = NO;
            
            
        }];
        
    }];

	[[GAI sharedInstance] trackStartScreenView];
}

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
								  animationControllerForOperation:(UINavigationControllerOperation)operation
											   fromViewController:(UIViewController *)fromVC
												 toViewController:(UIViewController *)toVC {
	return [SYNiPhoneLoginAnimator animatorForPresentation:(operation == UINavigationControllerOperationPush)];
}

#pragma mark - button IBActions

- (IBAction)fadebookButtonPressed:(UIButton *)button {
    id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
    
    [tracker send: [[GAIDictionaryBuilder createEventWithCategory: @"uiAction"
                                                           action: @"facebookLogin"
                                                            label: nil
                                                            value: nil] build]];
	
	Reachability *reachability = [Reachability reachabilityWithHostname:self.appDelegate.networkEngine.hostName];
    BOOL isReachable = ([reachability currentReachabilityStatus] != NotReachable);
	if (!isReachable) {
		[self showNetworkInacessibleAlert];
		return;
	}
    
	[[SYNLoginManager sharedManager] loginThroughFacebookWithCompletionHandler:^(NSDictionary* dictionary) {
		[[NSNotificationCenter defaultCenter] postNotificationName:kLoginCompleted object:self];
	} errorHandler:^(id error) {
		if ([error isKindOfClass:[NSDictionary class]]) {
			NSDictionary *formErrors = error[@"form_errors"];
			
			if (formErrors) {
				[[[UIAlertView alloc] initWithTitle: NSLocalizedString(@"facebook_login_error_title", nil)
											message: NSLocalizedString(@"facebook_login_error_description", nil)
										   delegate: nil
								  cancelButtonTitle: NSLocalizedString(@"OK", nil)
								  otherButtonTitles: nil] show];
			}
        } else if ([error isKindOfClass:[NSString class]]) {
            [[[UIAlertView alloc] initWithTitle: NSLocalizedString(@"facebook_login_error_title", nil)
                                        message: error
                                       delegate: nil
                              cancelButtonTitle: NSLocalizedString(@"OK", nil)
                              otherButtonTitles: nil] show];
            
            DebugLog(@"Log in failed!");
        }
	}];
}

- (void)showNetworkInacessibleAlert {
	[[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"login_screen_form_no_connection_dialog_title", nil)
								message:NSLocalizedString(@"login_screen_form_no_connection_dialog_message", nil)
							   delegate:nil
					  cancelButtonTitle:nil
					  otherButtonTitles:NSLocalizedString(@"OK", nil), nil] show];
}

@end
