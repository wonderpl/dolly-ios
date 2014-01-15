//
//  SYNiPhoneLoginAnimator.m
//  dolly
//
//  Created by Sherman Lo on 13/01/14.
//  Copyright (c) 2014 Rockpack Ltd. All rights reserved.
//

#import "SYNiPhoneLoginAnimator.h"
#import "SYNiPhoneIntroViewController.h"
#import "SYNiPhoneLoginViewController.h"

static const CGFloat AnimationDuration = 0.3;

@interface SYNiPhoneLoginAnimator ()

@property (nonatomic, assign) BOOL presenting;

@end

@implementation SYNiPhoneLoginAnimator

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
		SYNiPhoneIntroViewController *fromViewController = (SYNiPhoneIntroViewController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
		SYNiPhoneLoginViewController *toViewController = (SYNiPhoneLoginViewController *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
		UIView *containerView = [transitionContext containerView];
		
		toViewController.navigationBar.alpha = 0.0;
		toViewController.backgroundView.alpha = 0.0;
		
		CGPoint fieldsCenter = toViewController.containerView.center;
		toViewController.containerView.center = CGPointMake(fieldsCenter.x + CGRectGetWidth(containerView.frame),
																  fieldsCenter.y);
		
		[containerView addSubview:toViewController.view];
		
		[UIView animateWithDuration:AnimationDuration animations:^{
			toViewController.navigationBar.alpha = 1.0;
			
			fromViewController.containerView.center = CGPointMake(fromViewController.containerView.center.x - CGRectGetWidth(containerView.frame),
																  fromViewController.containerView.center.y);
			
			toViewController.backgroundView.alpha = 1.0;
			toViewController.containerView.center = fieldsCenter;
		} completion:^(BOOL finished) {
			[transitionContext completeTransition:YES];
		}];
	} else {
		SYNiPhoneLoginViewController *fromViewController = (SYNiPhoneLoginViewController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
		SYNiPhoneIntroViewController *toViewController = (SYNiPhoneIntroViewController *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
		UIView *containerView = [transitionContext containerView];
		
		[containerView insertSubview:toViewController.view belowSubview:fromViewController.view];
		
		[UIView animateWithDuration:AnimationDuration animations:^{
			fromViewController.navigationBar.alpha = 0.0;
			fromViewController.backgroundView.alpha = 0.0;
			
			fromViewController.containerView.center = CGPointMake(fromViewController.containerView.center.x + CGRectGetWidth(containerView.frame),
																  fromViewController.containerView.center.y);
			
			toViewController.containerView.center = CGPointZero;
		} completion:^(BOOL finished) {
			[transitionContext completeTransition:YES];
		}];
	}
}

@end
