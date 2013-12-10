//
//  SYNFullScreenVideoAnimator.m
//  dolly
//
//  Created by Sherman Lo on 20/11/13.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNFullScreenVideoAnimator.h"
#import "SYNVideoPlayerViewController.h"
#import "SYNFullScreenVideoViewController.h"
#import "SYNVideoPlayer.h"
#import "SYNDeviceManager.h"

static const CGFloat AnimationDuration = 0.3;

@interface SYNFullScreenVideoAnimator ()

@property (nonatomic, assign) BOOL presenting;

@end

@implementation SYNFullScreenVideoAnimator

#pragma mark - Public class methods

+ (instancetype)animatorForPresentation:(BOOL)presenting {
	return [[self alloc] initForPresentation:presenting];
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
	return AnimationDuration;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
	if (self.presenting) {
		[self animatePresentingTransition:transitionContext];
	} else {
		[self animateDismissingTransition:transitionContext];
	}
}

#pragma mark - Private

- (void)animatePresentingTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
	SYNVideoPlayerViewController *fromViewController = (SYNVideoPlayerViewController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
	SYNFullScreenVideoViewController *toViewController = (SYNFullScreenVideoViewController *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
	UIView *containerView = [transitionContext containerView];
	SYNVideoPlayer *videoPlayer = fromViewController.currentVideoPlayer;
	
	videoPlayer.frame = [fromViewController.view convertRect:videoPlayer.frame fromView:videoPlayer.superview];
	[toViewController.view addSubview:videoPlayer];
	
	toViewController.backgroundView.alpha = 0.0;
	[containerView addSubview:toViewController.view];
	
	[UIView animateWithDuration:AnimationDuration animations:^{
		if (IS_IPHONE) {
			UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
			CGFloat angle = (orientation == UIDeviceOrientationLandscapeLeft ? M_PI_2 : M_PI_2 * 3);
			videoPlayer.bounds = CGRectMake(0, 0, CGRectGetHeight(toViewController.view.bounds), CGRectGetWidth(toViewController.view.bounds));
			videoPlayer.transform = CGAffineTransformMakeRotation(angle);
		} else {
			CGFloat aspectRatio = CGRectGetWidth(videoPlayer.bounds) / CGRectGetHeight(videoPlayer.bounds);
			CGFloat toViewWidth = CGRectGetWidth(toViewController.view.bounds);
			videoPlayer.bounds = CGRectMake(0, 0, toViewWidth, toViewWidth / aspectRatio);
		}
		videoPlayer.center = toViewController.view.center;
		
		toViewController.backgroundView.alpha = 1.0;
	} completion:^(BOOL finished) {
		toViewController.videoPlayer = videoPlayer;
		
		[transitionContext completeTransition:YES];
	}];
}

- (void)animateDismissingTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
	SYNFullScreenVideoViewController *fromViewController = (SYNFullScreenVideoViewController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
	SYNVideoPlayerViewController *toViewController = (SYNVideoPlayerViewController *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
	UIView *containerView = [transitionContext containerView];
	SYNVideoPlayer *videoPlayer = fromViewController.videoPlayer;
	UIView *playerContainerView = toViewController.videoPlayerContainerView;
	
	[containerView insertSubview:toViewController.view belowSubview:fromViewController.view];
	
	fromViewController.backgroundView.alpha = 1.0;
	
	// This is dispatch_async is to handle the case where the iPad has been rotated while the video is playing.
	//
	// The SYNChannelVideoPlayerViewController's view will still be in the same orientation as it was prior to presenting
	// the full screen view controller and it's layout won't get updated until the end of the run loop. This means that
	// we'd have the wrong frames for the video player container when we're animating to it
	//
	// Starting the animation on the next run loop means that the layout will be updated and the frames will be correct
	dispatch_async(dispatch_get_main_queue(), ^{
		[UIView animateWithDuration:AnimationDuration animations:^{
			if (IS_IPHONE) {
				videoPlayer.transform = CGAffineTransformIdentity;
			}
			
			CGRect videoPlayerFrame = [toViewController.view convertRect:playerContainerView.frame fromView:playerContainerView.superview];
			videoPlayer.frame = videoPlayerFrame;
			
			fromViewController.backgroundView.alpha = 0.0;
		} completion:^(BOOL finished) {
			videoPlayer.frame = playerContainerView.bounds;
			[playerContainerView addSubview:videoPlayer];
			
			[transitionContext completeTransition:YES];
		}];
	});
}

@end
