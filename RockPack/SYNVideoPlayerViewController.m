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
#import "GAI+Tracking.h"
#import "SYNOneToOneSharingController.h"
#import "SYNPopoverAnimator.h"
#import "SYNActivityManager.h"
#import "SYNAddToChannelViewController.h"
#import <SDWebImageManager.h>

@interface SYNVideoPlayerViewController () <UIViewControllerTransitioningDelegate, SYNVideoPlayerDelegate>

@property (nonatomic, strong) IBOutlet UILabel *videoTitleLabel;
@property (nonatomic, strong) IBOutlet UIView *videoPlayerContainerView;
@property (nonatomic, strong) IBOutlet UIButton *followButton;
@property (nonatomic, strong) IBOutlet UIButton *commentButton;
@property (nonatomic, strong) IBOutlet SYNSocialButton *addButton;
@property (nonatomic, strong) IBOutlet SYNButton *likeButton;

@property (nonatomic, strong) SYNVideoPlayer *currentVideoPlayer;

@end

@implementation SYNVideoPlayerViewController

#pragma mark - Init / Dealloc

- (void)dealloc {
	[self removeObserver:self forKeyPath:@"videoInstance"];
}

#pragma mark - UIViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	appDelegate = [[UIApplication sharedApplication] delegate];
	
	self.videoTitleLabel.font = [UIFont lightCustomFontOfSize:self.videoTitleLabel.font.pointSize];
	
	if (IS_IPHONE) {
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(deviceOrientationChanged:)
													 name:UIDeviceOrientationDidChangeNotification
												   object:nil];
	}
	
	[self addObserver:self forKeyPath:@"videoInstance" options:NSKeyValueObservingOptionOld context:nil];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	[self updateVideoInstanceDetails:self.videoInstance];
	
	if ([self.parentViewController isBeingPresented]) {
		[self playVideo];
	}
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	
	[self trackVideoViewingStatisticsForVideoInstance:self.videoInstance withVideoPlayer:self.currentVideoPlayer];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
	return UIStatusBarStyleDefault;
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
	SYNFullScreenVideoViewController *viewController = [[SYNFullScreenVideoViewController alloc] init];
	viewController.transitioningDelegate = self;
	
	[self presentViewController:viewController animated:YES completion:nil];
}

- (void)videoPlayerMinimise {
	[self dismissViewControllerAnimated:YES completion:nil];
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
	[[GAI sharedInstance] trackVideoAdd];
	
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
	
	[[GAI sharedInstance] trackVideoShare];
    
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

}

#pragma mark - Notifications

- (void)deviceOrientationChanged:(NSNotification *)notification {
	UIDevice *device = [notification object];
	BOOL isShowingFullScreenVideo = [self.presentedViewController isKindOfClass:[SYNFullScreenVideoViewController class]];
	
	if (isShowingFullScreenVideo && [device orientation] == UIDeviceOrientationPortrait) {
		self.currentVideoPlayer.maximised = NO;
		[self videoPlayerMinimise];
	}
	
	if (!isShowingFullScreenVideo && UIDeviceOrientationIsLandscape([device orientation])) {
		self.currentVideoPlayer.maximised = YES;
		[self videoPlayerMaximise];
	}
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:@"videoInstance"]) {
		VideoInstance *previousVideoInstance = change[NSKeyValueChangeOldKey];
		[self trackVideoViewingStatisticsForVideoInstance:previousVideoInstance withVideoPlayer:self.currentVideoPlayer];
		
		[self updateVideoInstanceDetails:self.videoInstance];
		[self playVideo];
	}
}

#pragma mark - Private

- (void)playVideo {
	if (self.currentVideoPlayer) {
		[self.currentVideoPlayer removeFromSuperview];
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
	
	[videoPlayer play];
}

- (void)updateVideoInstanceDetails:(VideoInstance *)videoInstance {
	self.videoTitleLabel.text = videoInstance.title;
	
	BOOL videoOwnedByCurrentUser = [appDelegate.currentUser.uniqueId isEqualToString:videoInstance.channel.channelOwner.uniqueId];
	self.followButton.hidden = videoOwnedByCurrentUser;
	self.followButton.selected = [[SYNActivityManager sharedInstance] isSubscribedToChannelId:videoInstance.channel.uniqueId];
    
	self.likeButton.dataItemLinked = videoInstance;
	self.addButton.dataItemLinked = videoInstance;
	
	self.likeButton.selected = videoInstance.starredByUserValue;
	[self.likeButton setTitle:@"like" andCount:[videoInstance.video.starCount integerValue]];
}

- (void)trackVideoViewingStatisticsForVideoInstance:(VideoInstance *)videoInstance withVideoPlayer:(SYNVideoPlayer *)videoPlayer {
	CGFloat percentageViewed = videoPlayer.currentTime / [videoPlayer duration];
	
	id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
	
	[tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"goal"
														  action:@"videoViewed"
														   label:videoInstance.video.sourceId
														   value:@((int)(percentageViewed  * 100.0f))] build]];
	
	[tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"goal"
														  action:@"videoViewedDuration"
														   label:videoInstance.video.sourceId
														   value:@((int)(videoPlayer.currentTime))] build]];
}

- (Class)animationClassForViewController:(UIViewController *)viewController {
	NSDictionary *mapping = @{
							  NSStringFromClass([SYNFullScreenVideoViewController class]) : [SYNFullScreenVideoAnimator class],
							  NSStringFromClass([SYNOneToOneSharingController class]) : [SYNPopoverAnimator class],
							  NSStringFromClass([SYNAddToChannelViewController class]) : [SYNPopoverAnimator class]
							  };
	return mapping[NSStringFromClass([viewController class])];
}

@end
