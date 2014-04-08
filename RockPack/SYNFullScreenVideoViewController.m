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
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
	if (UIDeviceOrientationIsLandscape(orientation)) {
		self.videoOrientation = orientation;
	}
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
	return UIInterfaceOrientationMaskLandscape;
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

#pragma mark - Private

- (void)deviceOrientationChanged:(NSNotification *)notification {
	UIDevice *device = [notification object];
	
	if (device.orientation == UIDeviceOrientationPortrait) {
		[self dismissViewControllerAnimated:YES completion:nil];
	} else if (UIDeviceOrientationIsLandscape(device.orientation)) {
		self.videoOrientation = device.orientation;
	}
}

@end
