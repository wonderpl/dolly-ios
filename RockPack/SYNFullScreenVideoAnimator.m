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
#import <Masonry.h>

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
	SYNVideoPlayerViewController *videoPlayerViewController = (SYNVideoPlayerViewController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
	SYNFullScreenVideoViewController *fullScreenViewController = (SYNFullScreenVideoViewController *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
	UIView *containerView = [transitionContext containerView];
	
	UICollectionView *collectionView = videoPlayerViewController.videosCollectionView;
	
	[fullScreenViewController.videoContainerView addSubview:collectionView];
	[collectionView mas_updateConstraints:^(MASConstraintMaker *make) {
		make.centerX.equalTo(fullScreenViewController.videoContainerView.mas_centerX);
		make.centerY.equalTo(fullScreenViewController.videoContainerView.mas_centerY);
		make.width.equalTo(fullScreenViewController.videoContainerView.mas_width);
		make.height.equalTo(fullScreenViewController.videoContainerView.mas_height);
	}];
	
	[collectionView.collectionViewLayout invalidateLayout];
	[collectionView layoutIfNeeded];
	
	[containerView addSubview:fullScreenViewController.view];
	
	fullScreenViewController.view.alpha = 0.0;
    fullScreenViewController.collectionView = collectionView;

    if (IS_IPHONE) {
        collectionView.contentOffset = CGPointMake(videoPlayerViewController.selectedIndex * CGRectGetWidth(fullScreenViewController.view.bounds), 0);
    } else {
        collectionView.contentOffset = CGPointMake(videoPlayerViewController.selectedIndex * CGRectGetWidth(fullScreenViewController.view.bounds), 0);
    }

	[UIView animateWithDuration:AnimationDuration
					 animations:^{
						 fullScreenViewController.view.alpha = 1.0;
					 } completion:^(BOOL finished) {
						 [transitionContext completeTransition:YES];
					 }];
}

- (void)animateDismissingTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
	SYNFullScreenVideoViewController *fullScreenViewController = (SYNFullScreenVideoViewController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
	SYNVideoPlayerViewController *videoPlayerViewController = (SYNVideoPlayerViewController *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
	UIView *containerView = [transitionContext containerView];
	
	UICollectionView *collectionView = fullScreenViewController.collectionView;
	
	[containerView insertSubview:videoPlayerViewController.view belowSubview:fullScreenViewController.view];
	
	[UIView animateWithDuration:AnimationDuration
					 animations:^{
						 fullScreenViewController.view.alpha = 0.0;
					 } completion:^(BOOL finished) {
						 [videoPlayerViewController.videoPlayerContainerView addSubview:collectionView];
						 [collectionView mas_updateConstraints:^(MASConstraintMaker *make) {
							 make.centerX.equalTo(videoPlayerViewController.videoPlayerContainerView.mas_centerX);
							 make.centerY.equalTo(videoPlayerViewController.videoPlayerContainerView.mas_centerY);
							 make.width.equalTo(videoPlayerViewController.videoPlayerContainerView.mas_width);
							 make.height.equalTo(videoPlayerViewController.videoPlayerContainerView.mas_height);
						 }];
						 
						 [collectionView.collectionViewLayout invalidateLayout];
						 [collectionView layoutIfNeeded];
						 if (IS_IPHONE) {
							 collectionView.contentOffset = CGPointMake(videoPlayerViewController.selectedIndex * 320, 0);
						 } else {
							 collectionView.contentOffset = CGPointMake(videoPlayerViewController.selectedIndex * 768, 0);
						 }
						 
						 [transitionContext completeTransition:YES];
					 }];
}

@end
