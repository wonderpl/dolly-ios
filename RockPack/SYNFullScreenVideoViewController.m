//
//  SYNFullScreenVideoViewController.m
//  dolly
//
//  Created by Sherman Lo on 20/11/13.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNFullScreenVideoViewController.h"
#import "SYNVideoPlayer.h"

@interface SYNFullScreenVideoViewController ()

@property (nonatomic, strong) UIView *backgroundView;

@end

@implementation SYNFullScreenVideoViewController

#pragma mark - Init / Dealloc

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UIViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	[self.view addSubview:self.backgroundView];
	
	if (IS_IPHONE) {
		// For the iPhone we only officially supports portrait orientation so we have to manually transform the video on rotation
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(deviceOrientationChanged:)
													 name:UIDeviceOrientationDidChangeNotification
												   object:nil];
	}
}

- (BOOL)prefersStatusBarHidden {
	return YES;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	[super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
	
	CGFloat aspectRatio = CGRectGetWidth(self.videoPlayer.bounds) / CGRectGetHeight(self.videoPlayer.bounds);
	CGFloat width = CGRectGetWidth(self.view.bounds);
	self.videoPlayer.bounds = CGRectMake(0, 0, width, width / aspectRatio);
	self.videoPlayer.center = CGPointMake(CGRectGetWidth(self.view.bounds) / 2.0, CGRectGetHeight(self.view.bounds) / 2.0);
}

#pragma mark - Getters / Setters

- (void)setVideoPlayer:(SYNVideoPlayer *)videoPlayer {
	_videoPlayer = videoPlayer;
	
	if (IS_IPHONE) {
		UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
		CGFloat angle = (orientation == UIDeviceOrientationLandscapeLeft ? M_PI_2 : M_PI_2 * 3);
		videoPlayer.bounds = CGRectMake(0, 0, CGRectGetHeight(self.view.bounds), CGRectGetWidth(self.view.bounds));
		videoPlayer.transform = CGAffineTransformMakeRotation(angle);
	} else {
		CGFloat aspectRatio = CGRectGetWidth(videoPlayer.bounds) / CGRectGetHeight(videoPlayer.bounds);
		CGFloat viewWidth = CGRectGetWidth(self.view.bounds);
		videoPlayer.bounds = CGRectMake(0, 0, viewWidth, round(viewWidth / aspectRatio));
	}
	self.videoPlayer.center = CGPointMake(CGRectGetWidth(self.view.bounds) / 2.0, CGRectGetHeight(self.view.bounds) / 2.0);

	[self.view addSubview:videoPlayer];
}

- (UIView *)backgroundView {
	if (!_backgroundView) {
		UIView *view = [[UIView alloc] initWithFrame:self.view.bounds];
		view.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
		view.backgroundColor = [UIColor blackColor];
		
		self.backgroundView = view;
	}
	return _backgroundView;
}

#pragma mark - Private

- (void)deviceOrientationChanged:(NSNotification *)notification {
	UIDevice *device = [notification object];
	UIDeviceOrientation orientation = [device orientation];
	
	if (UIDeviceOrientationIsLandscape(orientation)) {
		[UIView animateWithDuration:0.3 animations:^{
			if (orientation == UIDeviceOrientationLandscapeLeft) {
				self.videoPlayer.transform = CGAffineTransformMakeRotation(M_PI_2);
			} else {
				self.videoPlayer.transform = CGAffineTransformMakeRotation(M_PI_2 * 3);
			}
		}];
	}
}

@end
