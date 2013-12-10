//
//  SYNPopoverAnimator.m
//  dolly
//
//  Created by Sherman Lo on 12/11/13.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNPopoverAnimator.h"
#import "SYNiPadPopoverAnimator.h"
#import "SYNiPhonePopoverAnimator.h"

static const CGFloat TransitionDuration = 0.3;

@interface SYNPopoverAnimator ()

@property (nonatomic, assign) BOOL presenting;

@end

@implementation SYNPopoverAnimator

#pragma mark - Class methods

+ (instancetype)animatorForPresentation:(BOOL)presenting {
	return (IS_IPAD ? [[SYNiPadPopoverAnimator alloc] initForPresentation:presenting] : [[SYNiPhonePopoverAnimator alloc] initForPresentation:presenting]);
}

#pragma mark - Init / Dealloc

- (instancetype)initForPresentation:(BOOL)presenting {
	if (self = [super init]) {
		self.presenting = presenting;
	}
	return self;
}

#pragma mark - UIViewControllerAnimatedTransitioning

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
	return TransitionDuration;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
	
}

@end
