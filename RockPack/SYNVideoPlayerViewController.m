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
#import <UIButton+WebCache.h>
#import "UIDevice+Helpers.h"
#import "SYNPagingModel.h"
#import "SYNVideoPlayerCell.h"
#import "SYNVideoInfoViewController.h"
@import AVFoundation;
@import MediaPlayer;

@interface SYNVideoPlayerViewController () <UIViewControllerTransitioningDelegate, UIPopoverControllerDelegate, UIScrollViewDelegate, SYNVideoPlayerDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, SYNVideoInfoViewControllerDelegate>

@property (nonatomic, strong) IBOutlet UIButton *avatarButton;

@property (nonatomic, strong) IBOutlet UILabel *videoTitleLabel;

@property (nonatomic, assign) BOOL hasTrackedAirPlayUse;

@property (nonatomic, strong) SYNVideoPlayer *currentVideoPlayer;

@property (nonatomic, assign) NSTimeInterval autoplayStartTime;

@property (nonatomic, assign) NSInteger selectedIndex;

@property (nonatomic, strong) SYNRotatingPopoverController *commentPopoverController;

@property (nonatomic, strong) SYNPagingModel *model;

@property (nonatomic, strong) IBOutlet UIView *videoPlayerContainerView;

@property (nonatomic, strong) IBOutlet UICollectionView *videosCollectionView;

@property (nonatomic, strong) SYNVideoInfoViewController *videoInfoViewController;

@property (nonatomic, strong) VideoInstance *videoInstance;

@end


@implementation SYNVideoPlayerViewController

#pragma mark - Factory

+ (UIViewController *)viewControllerWithModel:(SYNPagingModel *)model selectedIndex:(NSInteger)selectedIndex {
	NSString *suffix = ([[UIDevice currentDevice] isPhone] ? @"iphone" : @"ipad");
	NSString *storyboardName = [NSString stringWithFormat:@"%@_%@", NSStringFromClass(self), suffix];
	UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:nil];
	
	SYNVideoPlayerViewController *viewController = [storyboard instantiateInitialViewController];
	viewController.model = model;
	viewController.selectedIndex = selectedIndex;
	
	return viewController;
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UIViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	appDelegate = [[UIApplication sharedApplication] delegate];
	
	self.videoTitleLabel.font = [UIFont boldCustomFontOfSize:self.videoTitleLabel.font.pointSize];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(activeWirelessRouteChanged:)
												 name:MPVolumeViewWirelessRouteActiveDidChangeNotification
											   object:nil];
}

- (NSUInteger)supportedInterfaceOrientations {
	return ([[UIDevice currentDevice] isPhone] ? UIInterfaceOrientationMaskPortrait : UIInterfaceOrientationMaskAll);
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	if ([self isBeingPresented]) {
		NSIndexPath *indexPath = [NSIndexPath indexPathForItem:self.selectedIndex inSection:0];
		[self.videosCollectionView scrollToItemAtIndexPath:indexPath
										  atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally
												  animated:NO];
	}
	[self updateVideoInstanceDetails:self.videoInstance];
	
	if (self.currentVideoPlayer) {
		[self.currentVideoPlayer play];
	}
	
	AVAudioSession *audioSession = [AVAudioSession sharedInstance];
	[audioSession setActive:YES withOptions:0 error:nil];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	if ([self isBeingPresented]) {
		[self playCurrentVideo];
	}
	
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
	
	// If viewWillDisappear is being triggered from viewDidAppear then the isBeingDismissed flag is YES for some reason.
	// This is to check for this case and work around the issue
	BOOL isActuallyBeingDismissed = (![self isBeingPresented] && [self isBeingDismissed]);
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([segue.identifier isEqualToString:@"VideoInfo"]) {
		SYNVideoInfoViewController *viewController = segue.destinationViewController;
		viewController.model = self.model;
		viewController.selectedIndex = self.selectedIndex;
		viewController.delegate = self;
		
		self.videoInfoViewController = viewController;
	}
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

- (void)setSelectedIndex:(NSInteger)selectedIndex {
	_selectedIndex = selectedIndex;
	
	NSIndexPath *indexPath = [NSIndexPath indexPathForItem:self.selectedIndex inSection:0];
	[self.videosCollectionView scrollToItemAtIndexPath:indexPath
									  atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally
											  animated:YES];
	
	self.videoInstance = [self.model itemAtIndex:selectedIndex];
	
	self.videoInfoViewController.selectedIndex = selectedIndex;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
	return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
	return [self.model itemCount];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	SYNVideoPlayerCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"VideoPlayerCell"
																		 forIndexPath:indexPath];
	
	if (indexPath.item == self.selectedIndex && self.currentVideoPlayer) {
		cell.videoPlayer = self.currentVideoPlayer;
	} else {
		VideoInstance *videoInstance = [self.model itemAtIndex:indexPath.row];
		
		SYNVideoPlayer *videoPlayer = [SYNVideoPlayer playerForVideoInstance:videoInstance];
		videoPlayer.delegate = self;
		
		cell.videoPlayer = videoPlayer;
	}
	
	return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
	return collectionView.frame.size;
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
	[self playNextVideo];
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

#pragma mark - SYNVideoInfoViewControllerDelegate

- (void)videoInfoViewController:(SYNVideoInfoViewController *)viewController didScrollToContentOffset:(CGPoint)contentOffset {
	if (contentOffset.y > 0) {
		CGFloat opacity = 1.0 - (0.88 * MIN(1.0, contentOffset.y / 60.0));
		self.avatarButton.alpha = opacity;
		self.videoTitleLabel.alpha = opacity;
	} else {
		self.avatarButton.alpha = 1.0;
		self.videoTitleLabel.alpha = 1.0;
	}
}

- (void)videoInfoViewController:(SYNVideoInfoViewController *)viewController didSelectVideoAtIndex:(NSInteger)index {
	self.selectedIndex = index;
}

#pragma mark - IBActions

- (IBAction)closeButtonPressed:(UIButton *)barButton {
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
	
	if (!self.presentedViewController) {
		[self handleRotationToOrientation:device.orientation];
	}
}

#pragma mark - Private

- (void)playCurrentVideo {
	[self.currentVideoPlayer pause];
	
	NSIndexPath *indexPath = [NSIndexPath indexPathForItem:self.selectedIndex inSection:0];
	SYNVideoPlayerCell *cell = (SYNVideoPlayerCell *)[self.videosCollectionView cellForItemAtIndexPath:indexPath];
	
	SYNVideoPlayer *videoPlayer = cell.videoPlayer;
	[videoPlayer play];
	
	self.currentVideoPlayer = videoPlayer;
}

- (void)maximiseVideoPlayer {
	SYNFullScreenVideoViewController *viewController = [[SYNFullScreenVideoViewController alloc] init];
	viewController.videoPlayerViewController = self;
	viewController.transitioningDelegate = self;
	
	[self presentViewController:viewController animated:YES completion:nil];
}

- (void)minimiseVideoPlayer {
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)updateVideoInstanceDetails:(VideoInstance *)videoInstance {
	NSURL *avatarThumbnailURL = [NSURL URLWithString:videoInstance.originator.thumbnailURL];
	[self.avatarButton setImageWithURL:avatarThumbnailURL forState:UIControlStateNormal];
	
	[self.videoTitleLabel setText:videoInstance.title animated:YES];
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

#pragma mark - UIScrollViewDelegate

// These are implemented and empty to make sure that the AbstractViewController's methods aren't being called

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
	
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
	
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	if (scrollView == self.videosCollectionView) {
		self.selectedIndex = (NSInteger)(scrollView.contentOffset.x / scrollView.frame.size.width);
	}
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
	if (scrollView == self.videosCollectionView) {
		self.selectedIndex = (NSInteger)(scrollView.contentOffset.x / scrollView.frame.size.width);
	}
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	
}

- (void)trackViewingStatisticsForCurrentVideo {
	[[SYNTrackingManager sharedManager] trackVideoView:self.videoInstance.video.sourceId
										   currentTime:self.currentVideoPlayer.currentTime
											  duration:self.currentVideoPlayer.duration];
}

- (NSInteger)nextVideoIndex {
	return ((self.selectedIndex + 1) % [self.model itemCount]);
}

- (void)playNextVideo {
	NSIndexPath *indexPath = [NSIndexPath indexPathForItem:[self nextVideoIndex] inSection:0];
	[self.videosCollectionView scrollToItemAtIndexPath:indexPath
									  atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally
											  animated:YES];
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
