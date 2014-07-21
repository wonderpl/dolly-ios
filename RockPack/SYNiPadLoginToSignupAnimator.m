//
//  SYNiPadLoginToSignupAnimator.m
//  dolly
//
//  Created by Sherman Lo on 15/01/14.
//  Copyright (c) 2014 Rockpack Ltd. All rights reserved.
//

#import "SYNiPadLoginToSignupAnimator.h"
#import "SYNiPadLoginViewController.h"
#import "SYNIPadSignupViewController.h"
#import "SYNTextFieldLogin.h"

static const CGFloat AnimationDuration = 0.3;
static const CGFloat FieldOffset = 60.0;

@interface SYNiPadLoginToSignupAnimator ()

@property (nonatomic, assign) BOOL presenting;

@end

@implementation SYNiPadLoginToSignupAnimator

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
		SYNIPadSignupViewController *signupViewController = (SYNIPadSignupViewController *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
		
		[containerView addSubview:signupViewController.view];
		[signupViewController.view setNeedsLayout];
		[signupViewController.view layoutIfNeeded];
		
		signupViewController.view.alpha = 0.0;
		
		CGPoint emailCenter = signupViewController.emailTextField.center;
		signupViewController.emailTextField.center = CGPointMake(emailCenter.x - FieldOffset, emailCenter.y);
				
		CGPoint genderCenter = signupViewController.genderSegmentedControl.center;
		signupViewController.genderSegmentedControl.center = CGPointMake(genderCenter.x - FieldOffset, genderCenter.y);
		
		CGPoint uploadCenter = signupViewController.uploadPhotoButton.center;
		signupViewController.uploadPhotoButton.center = CGPointMake(uploadCenter.x - FieldOffset, uploadCenter.y);
		
		[UIView animateWithDuration:AnimationDuration
						 animations:^{
							 signupViewController.view.alpha = 1.0;
							 
							 CGPoint facebookCenter = loginViewController.facebookButton.center;
							 loginViewController.facebookButton.center = CGPointMake(facebookCenter.x + FieldOffset, facebookCenter.y);
							 
							 CGPoint loginCenter = loginViewController.loginButton.center;
							 loginViewController.loginButton.center = CGPointMake(loginCenter.x + FieldOffset, loginCenter.y);
							 
							 signupViewController.emailTextField.center = emailCenter;
							 signupViewController.genderSegmentedControl.center = genderCenter;
							 signupViewController.uploadPhotoButton.center = uploadCenter;
						 } completion:^(BOOL finished) {
							 [transitionContext completeTransition:YES];
						 }];
	} else {
		UIView *containerView = [transitionContext containerView];
		SYNIPadSignupViewController *signupViewController = (SYNIPadSignupViewController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
		SYNiPadLoginViewController *loginViewController = (SYNiPadLoginViewController *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
		
		[containerView addSubview:loginViewController.view];
		[loginViewController.view setNeedsLayout];
		[loginViewController.view layoutIfNeeded];
		
		loginViewController.view.alpha = 0.0;
		
		CGPoint facebookCenter = loginViewController.facebookButton.center;
		loginViewController.facebookButton.center = CGPointMake(facebookCenter.x + FieldOffset, facebookCenter.y);
		
		CGPoint loginCenter = loginViewController.loginButton.center;
		loginViewController.loginButton.center = CGPointMake(loginCenter.x + FieldOffset, loginCenter.y);
		
		[UIView animateWithDuration:AnimationDuration
						 animations:^{
							 loginViewController.view.alpha = 1.0;
							 
							 loginViewController.facebookButton.center = facebookCenter;
							 loginViewController.loginButton.center = loginCenter;
							 
							 CGPoint emailCenter = signupViewController.emailTextField.center;
							 signupViewController.emailTextField.center = CGPointMake(emailCenter.x - FieldOffset, emailCenter.y);
							 							 
							 CGPoint genderCenter = signupViewController.genderSegmentedControl.center;
							 signupViewController.genderSegmentedControl.center = CGPointMake(genderCenter.x - FieldOffset, genderCenter.y);
							 
							 CGPoint uploadCenter = signupViewController.uploadPhotoButton.center;
							 signupViewController.uploadPhotoButton.center = CGPointMake(uploadCenter.x - FieldOffset, uploadCenter.y);
							 
						 } completion:^(BOOL finished) {
							 [transitionContext completeTransition:YES];
						 }];
	}
}

@end
