//
//  SYNVideoPlayerViewController.m
//  dolly
//
//  Created by Sherman Lo on 27/11/13.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNVideoPlayerViewController.h"
#import "VideoInstance.h"
#import "Video.h"
#import "SYNButton.h"
#import "SYNFullScreenVideoViewController.h"
#import "SYNFullScreenVideoAnimator.h"
#import "SYNVideoPlayer.h"
#import "SYNOAuthNetworkEngine.h"
#import "SYNSocialButton.h"
#import "UIFont+SYNFont.h"
#import "SYNTrackingManager.h"
#import "SYNOneToOneSharingController.h"
#import "SYNPopoverAnimator.h"
#import "SYNActivityManager.h"
#import "SYNAddToChannelViewController.h"
#import "SYNCommentingViewController.h"
#import "SYNRotatingPopoverController.h"
#import "UINavigationBar+Appearance.h"
#import "UILabel+Animation.h"
#import "SYNWebViewController.h"
#import "SYNGenreManager.h"
#import "SYNMasterViewController.h"
#import <SDWebImageManager.h>
@import AVFoundation;
@import MediaPlayer;

@interface SYNVideoPlayerViewController () <UIViewControllerTransitioningDelegate, UIPopoverControllerDelegate, SYNVideoPlayerDelegate>

@property (nonatomic, strong) IBOutlet UILabel *videoTitleLabel;
@property (nonatomic, strong) IBOutlet UIView *videoPlayerContainerView;
@property (nonatomic, strong) IBOutlet UIButton *commentButton;
@property (nonatomic, strong) IBOutlet SYNSocialButton *addButton;
@property (nonatomic, strong) IBOutlet SYNButton *likeButton;
@property (nonatomic, strong) IBOutlet UIButton *linkButton;

@property (nonatomic, assign) BOOL hasTrackedAirPlayUse;

@property (nonatomic, strong) SYNVideoPlayer *currentVideoPlayer;

@property (nonatomic, assign) NSTimeInterval autoplayStartTime;

@property (nonatomic, strong) SYNRotatingPopoverController *commentPopoverController;

@end

@implementation SYNVideoPlayerViewController

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UIViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	appDelegate = [[UIApplication sharedApplication] delegate];
	
	self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
																			 style:UIBarButtonItemStylePlain
																			target:nil
																			action:nil];
	
	self.videoTitleLabel.font = [UIFont lightCustomFontOfSize:self.videoTitleLabel.font.pointSize];
	
	self.linkButton.backgroundColor = [UIColor colorWithWhite:241/255.0 alpha:1.0];
	self.linkButton.layer.borderColor = [[UIColor colorWithWhite:212/255.0 alpha:1.0] CGColor];
	self.linkButton.layer.borderWidth = 1.0;
	self.linkButton.layer.cornerRadius = CGRectGetHeight(self.linkButton.frame) / 2.0;
	
	self.linkButton.titleLabel.font = [UIFont lightCustomFontOfSize:self.linkButton.titleLabel.font.pointSize];
    
    [self.commentButton setTitle:@"0" forState:UIControlStateNormal];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(activeWirelessRouteChanged:)
												 name:MPVolumeViewWirelessRouteActiveDidChangeNotification
											   object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	[self.navigationController.navigationBar setBackgroundTransparent:YES];
	
	[self updateVideoInstanceDetails:self.videoInstance];
	
	if ([self.navigationController isBeingPresented]) {
		[self playCurrentVideo];
	}
	
	AVAudioSession *audioSession = [AVAudioSession sharedInstance];
	[audioSession setActive:YES withOptions:0 error:nil];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	Genre *genre = [[SYNGenreManager sharedManager] genreWithId:self.videoInstance.channel.categoryId];
	[[SYNTrackingManager sharedManager] setCategoryDimension:genre.name];
	
	if (IS_IPHONE) {
		UIDevice *device = [UIDevice currentDevice];
		BOOL rotated = [self handleRotationToOrientation:device.orientation];
		
		// We only want to add an observer in the case where we haven't displayed the video full screen since
		// in that case viewWillDisappear is called before the observer is added meaning it isn't removed properly
		if (!rotated) {
			[[NSNotificationCenter defaultCenter] addObserver:self
													 selector:@selector(deviceOrientationChanged:)
														 name:UIDeviceOrientationDidChangeNotification
													   object:nil];
		}
	}
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	
	if (IS_IPHONE && ![self.navigationController isBeingDismissed]) {
		[self.navigationController.navigationBar setBackgroundTransparent:NO];
	}
	
	// If viewWillDisappear is being triggered from viewDidAppear then the isBeingDismissed flag is YES for some reason.
	// This is to check for this case and work around the issue
	BOOL isActuallyBeingDismissed = (![self.navigationController isBeingPresented] && [self.navigationController isBeingDismissed]);
	if (isActuallyBeingDismissed) {
		[self trackViewingStatisticsForCurrentVideo];
		
		[self.currentVideoPlayer pause];
	}
	
	if (IS_IPHONE) {
		[[NSNotificationCenter defaultCenter] removeObserver:self
														name:UIDeviceOrientationDidChangeNotification
													  object:nil];
	}
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	
	AVAudioSession *audioSession = [AVAudioSession sharedInstance];
	[audioSession setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
	return UIStatusBarStyleDefault;
}

#pragma mark - Getters / Setters

- (void)setVideoInstance:(VideoInstance *)videoInstance {
    if (self.videoInstance) {
        [self trackViewingStatisticsForCurrentVideo];
    }
    
    if (!videoInstance) {
        return;
    }

	_videoInstance = videoInstance;
    
	if ([self isViewLoaded]) {
		[self updateVideoInstanceDetails:videoInstance];
		[self playCurrentVideo];
	}
}

#pragma mark - UIViewControllerTransitioningDelegate

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
	Class animationClass = [self animationClassForViewController:presented];
	return [animationClass animatorForPresentation:YES];
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
	Class animationClass = [self animationClassForViewController:dismissed];
	return [animationClass animatorForPresentation:NO];
}

#pragma mark - SYNVideoPlayerDelegate

- (void)videoPlayerMaximise {
	[[SYNTrackingManager sharedManager] trackVideoMaximise];
	
	[self maximiseVideoPlayer];
}

- (void)videoPlayerMinimise {
	[self minimiseVideoPlayer];
}

- (void)videoPlayerVideoViewed {
	[appDelegate.oAuthNetworkEngine recordActivityForUserId:appDelegate.currentOAuth2Credentials.userId
													 action:@"view"
											videoInstanceId:self.videoInstance.uniqueId
										  completionHandler:nil
											   errorHandler:^(NSDictionary* errorDictionary) {
												   DebugLog(@"View action failed");
											   }];
}

- (void)videoPlayerStartedPlaying {
	if (self.autoplayStartTime) {
		NSTimeInterval currentTime = [NSDate timeIntervalSinceReferenceDate];
		
		[[SYNTrackingManager sharedManager] trackVideoLoadTime:currentTime - self.autoplayStartTime];
		self.autoplayStartTime = 0;
	}
}

- (void)videoPlayerFinishedPlaying {
	
}

- (void)videoPlayerErrorOccurred:(NSString *)reason {
	[appDelegate.oAuthNetworkEngine reportPlayerErrorForVideoInstanceId:self.videoInstance.uniqueId
													   errorDescription:reason
													  completionHandler:^(NSDictionary *dictionary) {
														  DebugLog(@"Reported video error");
													  }
														   errorHandler:^(NSError* error) {
															   DebugLog(@"Report concern failed");
															   DebugLog(@"%@", [error debugDescription]);
														   }];
}

#pragma mark - IBActions

- (IBAction)closeButtonPressed:(UIBarButtonItem *)barButton {
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)likeButtonPressed:(SYNSocialButton *)button {
	[self likeControlPressed:button];
}

- (IBAction)addButtonPressed:(SYNSocialButton *)button {
	[[SYNTrackingManager sharedManager] trackVideoAddFromScreenName:[self trackingScreenName]];
	
    [appDelegate.oAuthNetworkEngine recordActivityForUserId:appDelegate.currentUser.uniqueId
                                                     action:@"select"
                                            videoInstanceId:self.videoInstance.uniqueId
                                          completionHandler:nil
                                               errorHandler:nil];
	
	SYNAddToChannelViewController *viewController = [[SYNAddToChannelViewController alloc] initWithViewId:kExistingChannelsViewId];
	viewController.modalPresentationStyle = UIModalPresentationCustom;
	viewController.transitioningDelegate = self;
	viewController.videoInstance = self.videoInstance;
	
	[self presentViewController:viewController animated:YES completion:nil];
}

- (IBAction)shareButtonPressed:(UIButton *)button {
	[self requestShareLinkWithObjectType:@"video_instance" objectId:self.videoInstance.uniqueId];
	
    // At this point it is safe to assume that the video thumbnail image is in the cache
    UIImage *thumbnailImage = [[[SDWebImageManager sharedManager] imageCache] imageFromMemoryCacheForKey:self.videoInstance.video.thumbnailURL];
	
	SYNOneToOneSharingController *viewController = [self createSharingViewControllerForObjectType:@"video_instance"
																						 objectId:self.videoInstance.video.thumbnailURL
																						  isOwner:NO
																						  isVideo:YES
																							image:thumbnailImage];
	viewController.modalPresentationStyle = UIModalPresentationCustom;
	viewController.transitioningDelegate = self;
	
	[self presentViewController:viewController animated:YES completion:nil];
}

- (IBAction)commentButtonPressed:(UIButton *)button {
    
	SYNCommentingViewController *viewController = [[SYNCommentingViewController alloc] initWithVideoInstance:self.videoInstance withButton:(SYNSocialCommentButton*)button];
	if (IS_IPHONE) {
		viewController.transitioningDelegate = self;
		viewController.modalPresentationStyle = UIModalPresentationCustom;
		
		[self presentViewController:viewController animated:YES completion:nil];
	} else {
		SYNRotatingPopoverController *popoverController = [[SYNRotatingPopoverController alloc] initWithContentViewController:viewController];
		[popoverController presentPopoverFromButton:button
											 inView:self.view
						   permittedArrowDirections:UIPopoverArrowDirectionRight
										   animated:YES];
		
		self.commentPopoverController = popoverController;
	}
}

- (IBAction)linkButtonPressed:(UIButton *)button {
	[[SYNTrackingManager sharedManager] trackClickToMoreWithTitle:self.videoInstance.title
															  URL:self.videoInstance.video.linkURL];
    
    [self.currentVideoPlayer pause];
	
	NSURL *URL = [NSURL URLWithString:self.videoInstance.video.linkURL];
	UIViewController *viewController = [SYNWebViewController webViewControllerForURL:URL withTrackingName:@"Click to more"];
    
	[self presentViewController:viewController animated:YES completion:nil];
}

#pragma mark - Notifications

- (void)deviceOrientationChanged:(NSNotification *)notification {
	UIDevice *device = [notification object];
	[self handleRotationToOrientation:device.orientation];
}

#pragma mark - Private

- (void)playCurrentVideo {
	if (self.currentVideoPlayer) {
		[self.currentVideoPlayer pause];
		[self.currentVideoPlayer removeFromSuperview];
		self.currentVideoPlayer.delegate = nil;
		self.currentVideoPlayer = nil;
	}
	
	SYNVideoPlayer *videoPlayer = [SYNVideoPlayer playerForVideoInstance:self.videoInstance];
	videoPlayer.delegate = self;
	videoPlayer.frame = self.videoPlayerContainerView.bounds;
	
	self.currentVideoPlayer = videoPlayer;
	if ([self.presentedViewController isKindOfClass:[SYNFullScreenVideoViewController class]]) {
		videoPlayer.maximised = YES;
		SYNFullScreenVideoViewController *fullScreenViewController = (SYNFullScreenVideoViewController *)self.presentedViewController;
		fullScreenViewController.videoPlayer = videoPlayer;
	} else {
		[self.videoPlayerContainerView addSubview:videoPlayer];
	}
	
	self.autoplayStartTime = [NSDate timeIntervalSinceReferenceDate];
	
	[videoPlayer play];
}

- (void)maximiseVideoPlayer {
	SYNFullScreenVideoViewController *viewController = [[SYNFullScreenVideoViewController alloc] init];
	viewController.transitioningDelegate = self;
	
	[self presentViewController:viewController animated:YES completion:nil];
}

- (void)minimiseVideoPlayer {
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)updateVideoInstanceDetails:(VideoInstance *)videoInstance {
	[self.videoTitleLabel setText:videoInstance.title animated:YES];
	
	[self.linkButton setTitle:self.videoInstance.video.linkTitle forState:UIControlStateNormal];
	[UIView animateWithDuration:0.3 animations:^{
		self.linkButton.alpha = (self.videoInstance.video.hasLink ? 1.0 : 0.0);
	}];
    
	self.likeButton.dataItemLinked = videoInstance;
	self.addButton.dataItemLinked = videoInstance;
	
	self.likeButton.selected = videoInstance.starredByUserValue;
	[self.likeButton setTitle:NSLocalizedString(@"like", nil) andCount:[videoInstance.video.starCount integerValue]];
    
    [self.commentButton setTitle:[NSString stringWithFormat:@"%d", videoInstance.commentCountValue] forState:UIControlStateNormal];
}

- (BOOL)handleRotationToOrientation:(UIDeviceOrientation)orientation {
	if (UIDeviceOrientationIsLandscape(orientation)) {
		[[SYNTrackingManager sharedManager] trackVideoMaximiseViaRotation];
		
		self.currentVideoPlayer.maximised = YES;
		[self maximiseVideoPlayer];
		return YES;
	}
	return NO;
}

- (void)activeWirelessRouteChanged:(NSNotification *)notification {
	MPVolumeView *volumeView = [notification object];
	
	if (volumeView.isWirelessRouteActive) {
		if (!self.hasTrackedAirPlayUse) {
			// This is meant to track AirPlay usage, it doesn't since there isn't a way to determine
			// if the YouTube player is using AirPlay, so we're just going to assume if they're using a wireless
			// route then they're using AirPlay for now
			[[SYNTrackingManager sharedManager] trackVideoAirPlayUsed];
			
			self.hasTrackedAirPlayUse = YES;
		}
	} else {
		self.hasTrackedAirPlayUse = NO;
	}
	
}

- (void)trackViewingStatisticsForCurrentVideo {
	[[SYNTrackingManager sharedManager] trackVideoView:self.videoInstance.video.sourceId
										   currentTime:self.currentVideoPlayer.currentTime
											  duration:self.currentVideoPlayer.duration];
}

- (Class)animationClassForViewController:(UIViewController *)viewController {
	NSDictionary *mapping = @{
							  NSStringFromClass([SYNFullScreenVideoViewController class]) : [SYNFullScreenVideoAnimator class],
							  NSStringFromClass([SYNOneToOneSharingController class])     : [SYNPopoverAnimator class],
							  NSStringFromClass([SYNAddToChannelViewController class])    : [SYNPopoverAnimator class],
							  NSStringFromClass([SYNCommentingViewController class])      : [SYNPopoverAnimator class]
							  };
	return mapping[NSStringFromClass([viewController class])];
}

@end
