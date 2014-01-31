//
//  SYNiPadIntroToSignupAnimator.m
//  dolly
//
//  Created by Sherman Lo on 15/01/14.
//  Copyright (c) 2014 Rockpack Ltd. All rights reserved.
//

#import "SYNiPadIntroToSignupAnimator.h"
#import "SYNIPadSignupViewController.h"

static const CGFloat AnimationDuration = 0.3;

@interface SYNiPadIntroToSignupAnimator ()

@end

@implementation SYNiPadIntroToSignupAnimator

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
	return AnimationDuration;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
	UIView *containerView = [transitionContext containerView];
	SYNIPadSignupViewController *signupViewController = (SYNIPadSignupViewController *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
	
	[containerView addSubview:signupViewController.view];
	
	[signupViewController.view setNeedsLayout];
	[signupViewController.view layoutIfNeeded];
	
	signupViewController.view.alpha = 0.0;
	
//	NSArray *fields = @[ loginViewController.facebookButton,
//						 loginViewController.emailUsernameTextField,
//						 loginViewController.passwordTextField,
//						 loginViewController.loginButton ];
//	
//	[fields enumerateObjectsUsingBlock:^(UIView *field, NSUInteger idx, BOOL *stop) {
//		field.alpha = 0.0;
//		CGPoint center = field.center;
//		field.center = CGPointMake(center.x, containerView.center.y + center.y);
//		
//		[UIView animateWithDuration:AnimationDuration
//							  delay:idx * 0.05
//							options:UIViewAnimationCurveEaseInOut
//						 animations:^{
//							 field.alpha = 1.0;
//							 field.center = center;
//						 } completion:^(BOOL finished) {
//							 
//						 }];
//	}];
//	
//	loginViewController.forgotPasswordButton.alpha = 0.0;
	
	[UIView animateWithDuration:AnimationDuration
					 animations:^{
						 signupViewController.view.alpha = 1.0;
//						 loginViewController.forgotPasswordButton.alpha = 1.0;
					 } completion:^(BOOL finished) {
						 [transitionContext completeTransition:YES];
					 }];
}

@end
