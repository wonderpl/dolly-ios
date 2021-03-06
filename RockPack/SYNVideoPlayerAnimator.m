//
//  SYNVideoPlayerAnimator.m
//  dolly
//
//  Created by Sherman Lo on 16/01/14.
//  Copyright (c) 2014 Rockpack Ltd. All rights reserved.
//

#import "SYNVideoPlayerAnimator.h"
#import "SYNVideoPlayerViewController.h"
#import "SYNVideoPlayer.h"
#import "UIImage+Blur.h"
#import "SYNVideoInfoCell.h"

static const CGFloat AnimationDuration = 0.3;

@interface SYNVideoPlayerAnimator ()

@property (nonatomic, strong) UIImageView *blurredImageView;
@property (nonatomic, assign) BOOL presenting;

@end

@implementation SYNVideoPlayerAnimator

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
	return AnimationDuration;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
	if (self.presenting) {
		UIView *containerView = [transitionContext containerView];
		
		UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
		SYNVideoPlayerViewController *videoPlayerViewController = (SYNVideoPlayerViewController *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
		
		id<SYNVideoInfoCell> infoCell = (id<SYNVideoInfoCell>)[self.delegate videoCellForIndexPath:self.cellIndexPath];
		
		[containerView addSubview:videoPlayerViewController.view];
		[videoPlayerViewController.view layoutIfNeeded];
		
		videoPlayerViewController.view.alpha = 0.0;
		
		UIImageView *blurredImageView = [self blurredImageViewFromCell:infoCell];
		self.blurredImageView = blurredImageView;
		
		UIView *videoPlayerContainerView = videoPlayerViewController.videoPlayerContainerView;
		
		CGRect videoPlayerFrame = [videoPlayerViewController.view convertRect:videoPlayerContainerView.bounds
																	 fromView:videoPlayerContainerView];
		
		CGRect cellImageFrame = [fromViewController.view convertRect:infoCell.imageView.bounds
															fromView:infoCell.imageView];
		
		blurredImageView.frame = cellImageFrame;
		blurredImageView.alpha = 0.0;
		[containerView addSubview:blurredImageView];
		
		videoPlayerContainerView.alpha = 0.0;
		
		[UIView animateKeyframesWithDuration:AnimationDuration
									   delay:0.0
									 options:UIViewKeyframeAnimationOptionCalculationModeCubic
								  animations:^{
									  [UIView addKeyframeWithRelativeStartTime:0.0
															  relativeDuration:0.15
																	animations:^{
																		blurredImageView.alpha = 1.0;
																		infoCell.imageView.alpha = 0.0;
																	}];
									  
									  [UIView addKeyframeWithRelativeStartTime:0.15
															  relativeDuration:0.85
																	animations:^{
																		videoPlayerViewController.view.alpha = 1.0;
																		blurredImageView.frame = videoPlayerFrame;
																	}];
									  
									  [UIView addKeyframeWithRelativeStartTime:0.85
															  relativeDuration:1.0
																	animations:^{
																		videoPlayerViewController.videoPlayerContainerView.alpha = 1.0;
																		blurredImageView.alpha = 0.0;
																	}];
								  } completion:^(BOOL finished) {
									  videoPlayerViewController.videoPlayerContainerView.alpha = 1.0;
									  infoCell.imageView.alpha = 1.0;
									  
									  [transitionContext completeTransition:YES];
								  }];
	} else {
		UIView *containerView = [transitionContext containerView];
		
		UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
		SYNVideoPlayerViewController *videoPlayerViewController = (SYNVideoPlayerViewController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
		
		[containerView insertSubview:toViewController.view belowSubview:videoPlayerViewController.view];
		[toViewController.view layoutIfNeeded];
		
		id<SYNVideoInfoCell> infoCell = (id<SYNVideoInfoCell>)[self.delegate videoCellForIndexPath:self.cellIndexPath];
		
		CGRect cellImageFrame = CGRectZero;
		if (infoCell) {
			cellImageFrame = [toViewController.view convertRect:infoCell.imageView.bounds
													   fromView:infoCell.imageView];
		}
		
		UIImageView *blurredImageView = [self blurredImageViewFromCell:infoCell];
		self.blurredImageView = blurredImageView;

		blurredImageView.alpha = 0.0;
		blurredImageView.frame = [videoPlayerViewController.view convertRect:videoPlayerViewController.videoPlayerContainerView.bounds
																	fromView:videoPlayerViewController.videoPlayerContainerView];
		
		[containerView addSubview:blurredImageView];
		
		videoPlayerViewController.videoPlayerContainerView.alpha = 0.0;
		infoCell.imageView.alpha = 0.0;
		
		[UIView animateKeyframesWithDuration:AnimationDuration
									   delay:0.0
									 options:0
								  animations:^{
									  [UIView addKeyframeWithRelativeStartTime:0.0
															  relativeDuration:0.1
																	animations:^{
																		blurredImageView.alpha = 1.0;
																	}];
									  
									  [UIView addKeyframeWithRelativeStartTime:0.1
															  relativeDuration:0.9
																	animations:^{
																		videoPlayerViewController.view.alpha = 0.0;
																		if (!CGRectIsEmpty(cellImageFrame)) {
																			blurredImageView.frame = cellImageFrame;
																		}
																	}];
									  
									  [UIView addKeyframeWithRelativeStartTime:0.9
															  relativeDuration:1.0
																	animations:^{
																		blurredImageView.alpha = 0.0;
																		infoCell.imageView.alpha = 1.0;
																	}];
								  } completion:^(BOOL finished) {
									  [transitionContext completeTransition:YES];
								  }];
	}
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
	self.presenting = YES;
	return self;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
	self.presenting = NO;
	return self;
}


- (UIImageView*)blurredImageViewFromCell:(id<SYNVideoInfoCell>)cell {
 
    UIImage *blurredImage = [UIImage blurredImageFromImage:cell.imageView.image];
    UIImageView *blurredImageView = [[UIImageView alloc] initWithImage:blurredImage];
    blurredImageView.backgroundColor = [UIColor whiteColor];

    return blurredImageView;
}
@end
