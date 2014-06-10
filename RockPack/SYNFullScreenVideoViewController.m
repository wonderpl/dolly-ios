//
//  SYNFullScreenVideoViewController.m
//  dolly
//
//  Created by Sherman Lo on 20/11/13.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNFullScreenVideoViewController.h"
#import "SYNVideoPlayerViewController.h"
#import "SYNVideoPlayer.h"

static const CGFloat VideoAspectRatio = 16.0 / 9.0;

@interface SYNFullScreenVideoViewController ()

@property (nonatomic, strong) UIView *backgroundView;

@property (nonatomic, strong) UIView *videoContainerView;

@property (nonatomic, assign) UIDeviceOrientation videoOrientation;

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
	[self.view addSubview:self.videoContainerView];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
	if (UIDeviceOrientationIsLandscape(orientation)) {
		self.videoOrientation = orientation;
	}
	
	self.videoContainerView.frame = [self videoContainerFrame];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	if (IS_IPHONE) {
		self.videoOrientation = [[UIDevice currentDevice] orientation];
		
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(deviceOrientationChanged:)
													 name:UIDeviceOrientationDidChangeNotification
												   object:nil];
        
        

	}
    
    NSIndexPath* indexPath = [NSIndexPath indexPathForItem:self.videoPlayerViewController.selectedIndex
                                                 inSection:0];
    
    [self.collectionView scrollToItemAtIndexPath:indexPath
                                atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally
                                        animated:NO];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	
	if (IS_IPHONE) {
		[[NSNotificationCenter defaultCenter] removeObserver:self
														name:UIDeviceOrientationDidChangeNotification
													  object:nil];
	}
}

- (NSUInteger)supportedInterfaceOrientations {
	return (IS_IPHONE ? UIInterfaceOrientationMaskLandscape : UIInterfaceOrientationMaskAll);
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	[super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
	
	self.videoContainerView.frame = [self videoContainerFrame];
	
    
    [self.collectionView setContentOffset:CGPointMake(self.videoPlayerViewController.selectedIndex * CGRectGetWidth(self.view.bounds), 0.0f)
                                 animated:YES];
    
	[self.collectionView.collectionViewLayout invalidateLayout];
}

- (BOOL)prefersStatusBarHidden {
	return YES;
}

#pragma mark - Getters / Setters

- (UIView *)backgroundView {
	if (!_backgroundView) {
		UIView *view = [[UIView alloc] initWithFrame:self.view.bounds];
		view.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
		view.backgroundColor = [UIColor blackColor];
		
		self.backgroundView = view;
	}
	return _backgroundView;
}

- (UIView *)videoContainerView {
	if (!_videoContainerView) {
		self.videoContainerView = [[UIView alloc] init];
	}
	return _videoContainerView;
}

#pragma mark - Private

- (void)deviceOrientationChanged:(NSNotification *)notification {
	UIDevice *device = [notification object];
	
	if (device.orientation == UIDeviceOrientationPortrait) {
		[self dismissViewControllerAnimated:YES completion:nil];
	} else if (UIDeviceOrientationIsLandscape(device.orientation)) {
		self.videoOrientation = device.orientation;
	}
}

- (CGRect)videoContainerFrame {
	CGFloat width = CGRectGetWidth(self.view.bounds);
	CGFloat height = width / VideoAspectRatio;
    
	return CGRectMake(0,
					  (CGRectGetHeight(self.view.bounds) - height) / 2.0,
					  width,
					  height);
}

@end
