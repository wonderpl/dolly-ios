//
//  SYNiPadPopoverAnimator.m
//  dolly
//
//  Created by Sherman Lo on 12/11/13.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNiPadPopoverAnimator.h"
#import "SYNTapDismissView.h"

@interface SYNiPadPopoverAnimator ()

@property (nonatomic, strong) SYNTapDismissView *tapDismissView;

@end

@implementation SYNiPadPopoverAnimator

#pragma mark - UIViewControllerAnimatedTransitioning

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
	UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
	UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
	UIView *containerView = [transitionContext containerView];
	
	if (self.presenting) {
		SYNTapDismissView *tapDismissView = [[SYNTapDismissView alloc] initWithFrame:containerView.frame];
		
		tapDismissView.parentViewController = fromViewController;
		tapDismissView.center = containerView.center;
		tapDismissView.alpha = 0.0;
		
		toViewController.view.center = CGPointMake(CGRectGetWidth(tapDismissView.bounds) / 2.0, CGRectGetHeight(tapDismissView.bounds) / 2.0);
		toViewController.view.layer.cornerRadius = 10.0;
		toViewController.view.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin);
		
		[containerView addSubview:tapDismissView];
		[tapDismissView addSubview:toViewController.view];
		
		[UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
			tapDismissView.alpha = 1.0;
		} completion:^(BOOL finished) {
			[transitionContext completeTransition:YES];
		}];
	} else {
		NSUInteger index = [containerView.subviews indexOfObjectPassingTest:^BOOL(UIView *view, NSUInteger idx, BOOL *stop) {
			return [view isMemberOfClass:[SYNTapDismissView class]];
		}];
		SYNTapDismissView *tapDismissView = (index != NSNotFound ? containerView.subviews[index] : nil);
		
		[UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
			tapDismissView.alpha = 0.0;
		} completion:^(BOOL finished) {
			[tapDismissView removeFromSuperview];
			[fromViewController.view removeFromSuperview];
			
			[transitionContext completeTransition:YES];
			
			fromViewController.transitioningDelegate = nil;
		}];
	}
}

@end
