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
		tapDismissView.alpha = 0.0;
		tapDismissView.center = containerView.center;
		
		CGRect startFrame = CGRectMake(CGRectGetMinX(toViewController.view.frame),
									   CGRectGetHeight(containerView.frame),
									   CGRectGetWidth(fromViewController.view.frame),
									   CGRectGetHeight(toViewController.view.frame));
		toViewController.view.frame = startFrame;
		
        if ([[UIApplication sharedApplication] statusBarOrientation] == UIDeviceOrientationPortrait) {
            CGRect startFrame = CGRectMake(CGRectGetMinX(toViewController.view.frame),
                                           CGRectGetHeight(containerView.frame),
                                           CGRectGetWidth(fromViewController.view.frame),
                                           CGRectGetHeight(toViewController.view.frame));
            toViewController.view.frame = startFrame;
        }
        
        if ([[UIApplication sharedApplication] statusBarOrientation] == UIDeviceOrientationLandscapeLeft) {
            CGRect startFrame = CGRectMake(-CGRectGetHeight(fromViewController.view.frame)-CGRectGetHeight(fromViewController.view.frame),
                                           0,
                                           CGRectGetWidth(fromViewController.view.frame),
                                           CGRectGetHeight(fromViewController.view.frame));
            toViewController.view.frame = startFrame;
        }
        
        if ([[UIApplication sharedApplication] statusBarOrientation] == UIDeviceOrientationLandscapeRight) {

            CGRect startFrame = CGRectMake(CGRectGetHeight(fromViewController.view.frame)+CGRectGetHeight(fromViewController.view.frame),
                                           0,
                                           CGRectGetWidth(fromViewController.view.frame),
                                           CGRectGetHeight(fromViewController.view.frame));
            toViewController.view.frame = startFrame;
        }
        
        if ([[UIApplication sharedApplication] statusBarOrientation] == UIDeviceOrientationPortraitUpsideDown) {
            CGRect startFrame = CGRectMake(CGRectGetMinX(toViewController.view.frame),
                                           -CGRectGetHeight(toViewController.view.frame),
                                           CGRectGetWidth(fromViewController.view.frame),
                                           CGRectGetHeight(toViewController.view.frame));
            toViewController.view.frame = startFrame;
        }
        
		[containerView addSubview:tapDismissView];
		[containerView addSubview:toViewController.view];
		
		[UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
			tapDismissView.alpha = 1.0;
            
            if ([[UIApplication sharedApplication] statusBarOrientation] == UIDeviceOrientationPortrait) {
                toViewController.view.frame = CGRectMake(CGRectGetMinX(toViewController.view.frame),
                                                         CGRectGetHeight(containerView.frame) - CGRectGetHeight(toViewController.view.frame),
                                                         CGRectGetWidth(fromViewController.view.frame),
                                                         CGRectGetHeight(toViewController.view.frame));
            }

            if ([[UIApplication sharedApplication] statusBarOrientation] == UIDeviceOrientationLandscapeLeft) {
                toViewController.view.frame = CGRectMake(0,
                                                         0,
                                                         CGRectGetHeight(startFrame),
                                                         CGRectGetHeight(fromViewController.view.frame));

            }
            
            if ([[UIApplication sharedApplication] statusBarOrientation] == UIDeviceOrientationLandscapeRight) {
                
                toViewController.view.frame = CGRectMake(CGRectGetWidth(fromViewController.view.frame) - CGRectGetHeight(startFrame),
                                                         0,
                                                         CGRectGetHeight(startFrame),
                                                         CGRectGetHeight(fromViewController.view.frame));
            }

            if ([[UIApplication sharedApplication] statusBarOrientation] == UIDeviceOrientationPortraitUpsideDown) {
                toViewController.view.frame = CGRectMake(CGRectGetMinX(toViewController.view.frame),
                                                         0,
                                                         CGRectGetWidth(fromViewController.view.frame),
                                                         CGRectGetHeight(toViewController.view.frame));
            }
            
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
            
            if ([[UIApplication sharedApplication] statusBarOrientation] == UIDeviceOrientationPortrait) {
                CGRect endFrame = CGRectMake(CGRectGetMinX(toViewController.view.frame),
                                               CGRectGetHeight(containerView.frame),
                                               CGRectGetWidth(fromViewController.view.frame),
                                               CGRectGetHeight(toViewController.view.frame));
                fromViewController.view.frame = endFrame;
            }
            
            if ([[UIApplication sharedApplication] statusBarOrientation] == UIDeviceOrientationLandscapeLeft) {
                CGRect endFrame = CGRectMake(-CGRectGetHeight(fromViewController.view.frame)-CGRectGetHeight(fromViewController.view.frame),
                                               0,
                                               CGRectGetWidth(fromViewController.view.frame),
                                               CGRectGetHeight(fromViewController.view.frame));
                fromViewController.view.frame = endFrame;
            }
            
            if ([[UIApplication sharedApplication] statusBarOrientation] == UIDeviceOrientationLandscapeRight) {
                
                CGRect endFrame = CGRectMake(CGRectGetHeight(fromViewController.view.frame)+CGRectGetHeight(fromViewController.view.frame),
                                               0,
                                               CGRectGetWidth(fromViewController.view.frame),
                                               CGRectGetHeight(fromViewController.view.frame));
                fromViewController.view.frame = endFrame;
            }
            
            if ([[UIApplication sharedApplication] statusBarOrientation] == UIDeviceOrientationPortraitUpsideDown) {
                CGRect endFrame = CGRectMake(CGRectGetMinX(toViewController.view.frame),
                                               -CGRectGetHeight(toViewController.view.frame),
                                               CGRectGetWidth(fromViewController.view.frame),
                                               CGRectGetHeight(toViewController.view.frame));
                fromViewController.view.frame = endFrame;
            }

		} completion:^(BOOL finished) {
			[tapDismissView removeFromSuperview];
			[fromViewController.view removeFromSuperview];
			
			[transitionContext completeTransition:YES];
			
			fromViewController.transitioningDelegate = nil;
		}];
	}
}

@end
