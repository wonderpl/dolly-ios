//
//  SYNiPadIntroToLoginAnimator.m
//  dolly
//
//  Created by Sherman Lo on 15/01/14.
//  Copyright (c) 2014 Rockpack Ltd. All rights reserved.
//

#import "SYNiPadIntroToLoginAnimator.h"
#import "SYNiPadIntroViewController.h"
#import "SYNiPadLoginViewController.h"
#import "SYNTextFieldLogin.h"

static const CGFloat AnimationDuration = 0.3;

@interface SYNiPadIntroToLoginAnimator ()

@property (nonatomic, assign) BOOL presenting;

@end

@implementation SYNiPadIntroToLoginAnimator


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
        SYNiPadLoginViewController *loginViewController = (SYNiPadLoginViewController *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
        
        [containerView addSubview:loginViewController.view];
        
        [loginViewController.view setNeedsLayout];
        [loginViewController.view layoutIfNeeded];
        
        loginViewController.view.alpha = 0.0;
        
        NSArray *fields = @[ loginViewController.emailUsernameTextField,
                             loginViewController.passwordTextField,
                             loginViewController.loginButton ];
        
        [fields enumerateObjectsUsingBlock:^(UIView *field, NSUInteger idx, BOOL *stop) {
            field.alpha = 0.0;
            CGPoint center = field.center;
            field.center = CGPointMake(center.x, containerView.center.y + center.y);
            
            [UIView animateWithDuration:AnimationDuration
                                  delay:idx * 0.05
                                options:UIViewAnimationCurveEaseInOut
                             animations:^{
                                 field.alpha = 1.0;
                                 field.center = center;
                             } completion:^(BOOL finished) {
                                 
                             }];
        }];
        
        loginViewController.forgotPasswordButton.alpha = 0.0;
        
        [UIView animateWithDuration:AnimationDuration
                         animations:^{
                             loginViewController.view.alpha = 1.0;
                             loginViewController.forgotPasswordButton.alpha = 1.0;
                         } completion:^(BOOL finished) {
                             [transitionContext completeTransition:YES];
                         }];

    } else {
        
        
        UIView *containerView = [transitionContext containerView];
        SYNiPadIntroViewController *introViewController = (SYNiPadIntroViewController *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
        SYNiPadLoginViewController *loginViewController = (SYNiPadLoginViewController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];

        [containerView addSubview:introViewController.view];
        
        [introViewController.view setNeedsLayout];
        [introViewController.view layoutIfNeeded];
        [loginViewController.view setNeedsLayout];
        [loginViewController.view layoutIfNeeded];
        
        introViewController.view.alpha = 0.0;
        
        [UIView animateWithDuration:AnimationDuration
                         animations:^{
                             introViewController.view.alpha = 1.0;
                             loginViewController.view.alpha = 0.0;
                         } completion:^(BOOL finished) {
                             [loginViewController.view removeFromSuperview];

                             [transitionContext completeTransition:YES];
                         }];
        
        
        
    }
}

@end
