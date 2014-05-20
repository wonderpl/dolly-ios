//
//  SYNiPadIntroToSignupAnimator.m
//  dolly
//
//  Created by Sherman Lo on 15/01/14.
//  Copyright (c) 2014 Rockpack Ltd. All rights reserved.
//

#import "SYNiPadIntroToSignupAnimator.h"
#import "SYNIPadSignupViewController.h"
#import "SYNiPadIntroViewController.h"

static const CGFloat AnimationDuration = 0.3;

@interface SYNiPadIntroToSignupAnimator ()

@property (nonatomic, assign) BOOL presenting;

@end

@implementation SYNiPadIntroToSignupAnimator


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
        SYNIPadSignupViewController *signupViewController = (SYNIPadSignupViewController *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
        
        [containerView addSubview:signupViewController.view];
        
        [signupViewController.view setNeedsLayout];
        [signupViewController.view layoutIfNeeded];
        
        signupViewController.view.alpha = 0.0;
 
        [UIView animateWithDuration:AnimationDuration
                         animations:^{
                             signupViewController.view.alpha = 1.0;
                             //						 loginViewController.forgotPasswordButton.alpha = 1.0;
                         } completion:^(BOOL finished) {
                             [transitionContext completeTransition:YES];
                         }];

    } else {
        UIView *containerView = [transitionContext containerView];
        SYNiPadIntroViewController *introViewController = (SYNiPadIntroViewController *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
        
        [containerView addSubview:introViewController.view];
        
        [introViewController.view setNeedsLayout];
        [introViewController.view layoutIfNeeded];
        
        introViewController.view.alpha = 0.0;
        
        [UIView animateWithDuration:AnimationDuration
                         animations:^{
                             introViewController.view.alpha = 1.0;
                             //						 loginViewController.forgotPasswordButton.alpha = 1.0;
                         } completion:^(BOOL finished) {
                             [transitionContext completeTransition:YES];
                         }];

    }
}

@end
