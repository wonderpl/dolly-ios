//
//  SYNiPadLoginToForgotPasswordAnimator.m
//  dolly
//
//  Created by Sherman Lo on 15/01/14.
//  Copyright (c) 2014 Rockpack Ltd. All rights reserved.
//

#import "SYNiPadLoginToForgotPasswordAnimator.h"
#import "SYNiPadPasswordForgotViewController.h"
#import "SYNiPadLoginViewController.h"
#import "SYNTextFieldLogin.h"

static const CGFloat AnimationDuration = 0.3;

@interface SYNiPadLoginToForgotPasswordAnimator ()

@property (nonatomic, assign) BOOL presenting;

@end

@implementation SYNiPadLoginToForgotPasswordAnimator

+ (instancetype)animatorForPresentation:(BOOL)presenting {
	return [[self alloc] initForPresentation:presenting];
}

- (instancetype)initForPresentation:(BOOL)presenting {
	if (self = [super init]) {
		self.presenting = presenting;
	}
	return self;
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
	return AnimationDuration;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
	if (self.presenting) {
		UIView *containerView = [transitionContext containerView];
		SYNiPadLoginViewController *loginViewController = (SYNiPadLoginViewController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
		SYNiPadPasswordForgotViewController *passwordViewController = (SYNiPadPasswordForgotViewController *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
		
		[containerView addSubview:passwordViewController.view];
		
		CGRect initialFrame = loginViewController.emailUsernameTextField.frame;
		CGRect finalFrame = passwordViewController.emailUsernameTextField.frame;
		
		passwordViewController.emailUsernameTextField.frame = initialFrame;
		passwordViewController.view.alpha = 0.0;
		
		[UIView animateWithDuration:AnimationDuration animations:^{
			passwordViewController.emailUsernameTextField.frame = finalFrame;
			
			passwordViewController.view.alpha = 1.0;
		} completion:^(BOOL finished) {
			[transitionContext completeTransition:YES];
		}];
	} else {
		UIView *containerView = [transitionContext containerView];
		SYNiPadPasswordForgotViewController *passwordViewController = (SYNiPadPasswordForgotViewController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
		SYNiPadLoginViewController *loginViewController = (SYNiPadLoginViewController *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
		
		[containerView insertSubview:loginViewController.view belowSubview:passwordViewController.view];
		[loginViewController.view setNeedsLayout];
		[loginViewController.view layoutIfNeeded];
			
		CGRect initialFrame = loginViewController.emailUsernameTextField.frame;
		CGRect finalFrame = passwordViewController.emailUsernameTextField.frame;
		
		passwordViewController.emailUsernameTextField.frame = initialFrame;
		
		[UIView animateWithDuration:AnimationDuration animations:^{
			passwordViewController.emailUsernameTextField.frame = finalFrame;
			
			passwordViewController.view.alpha = 0.0;
		} completion:^(BOOL finished) {
			[transitionContext completeTransition:YES];
		}];
	}
}

@end
