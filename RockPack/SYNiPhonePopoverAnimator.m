//
//  SYNiPhonePopoverAnimator.m
//  dolly
//
//  Created by Sherman Lo on 12/11/13.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNiPhonePopoverAnimator.h"
#import "SYNTapDismissView.h"

@implementation SYNiPhonePopoverAnimator

#pragma mark - UIViewControllerAnimatedTransitioning

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
	UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
	UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
	UIView *containerView = [transitionContext containerView];
	
	if (self.presenting) {
		SYNTapDismissView *tapDismissView = [[SYNTapDismissView alloc] initWithFrame:containerView.frame];
		tapDismissView.parentViewController = fromViewController;
		tapDismissView.center = containerView.center;
		
		CGRect startFrame = CGRectMake(CGRectGetMinX(toViewController.view.frame),
									   CGRectGetHeight(containerView.frame),
									   CGRectGetWidth(toViewController.view.frame),
									   CGRectGetHeight(toViewController.view.frame));
		toViewController.view.frame = startFrame;
		
		[containerView addSubview:tapDismissView];
		[containerView addSubview:toViewController.view];
		
		[UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
			
			toViewController.view.frame = CGRectMake(CGRectGetMinX(startFrame),
													 CGRectGetMinY(startFrame) - CGRectGetHeight(startFrame),
													 CGRectGetWidth(startFrame),
													 CGRectGetHeight(startFrame));
		} completion:^(BOOL finished) {
			[transitionContext completeTransition:YES];
		}];
	} else {
		NSUInteger index = [containerView.subviews indexOfObjectPassingTest:^BOOL(UIView *view, NSUInteger idx, BOOL *stop) {
			return [view isMemberOfClass:[SYNTapDismissView class]];
		}];
		SYNTapDismissView *tapDismissView = containerView.subviews[index];
		
		[UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
			tapDismissView.alpha = 0.0;
			fromViewController.view.frame = CGRectMake(CGRectGetMinX(toViewController.view.frame),
													 CGRectGetMaxY(containerView.frame),
													 CGRectGetWidth(toViewController.view.frame),
													 CGRectGetHeight(toViewController.view.frame));
		} completion:^(BOOL finished) {
			[tapDismissView removeFromSuperview];
			[fromViewController.view removeFromSuperview];
			
			[transitionContext completeTransition:YES];
		}];
	}
}

@end
