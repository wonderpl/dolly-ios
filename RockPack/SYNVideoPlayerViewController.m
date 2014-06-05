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
#import "UIFont+SYNFont.h"
#import "SYNTrackingManager.h"
#import "SYNOneToOneSharingController.h"
#import "SYNPopoverAnimator.h"
#import "SYNActivityManager.h"
#import "SYNAddToChannelViewController.h"
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
#import "VideoAnnotation.h"
#import "SYNVideoInfoViewController.h"
#import "SYNShopMotionOverlayViewController.h"

@import AVFoundation;
@import MediaPlayer;
@import MessageUI;

@interface SYNVideoPlayerViewController () <UIViewControllerTransitioningDelegate, UIPopoverControllerDelegate, UIScrollViewDelegate, SYNVideoPlayerDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, SYNVideoInfoViewControllerDelegate>

@property (nonatomic, strong) IBOutlet UIButton *avatarButton;

@property (nonatomic, strong) IBOutlet UIButton *followingButton;

@property (nonatomic, strong) IBOutlet UILabel *videoTitleLabel;

@property (nonatomic, assign) BOOL hasTrackedAirPlayUse;

@property (nonatomic, strong) SYNVideoPlayer *currentVideoPlayer;

@property (nonatomic, assign) NSTimeInterval autoplayStartTime;

@property (nonatomic, assign) NSInteger selectedIndex;

@property (nonatomic, strong) SYNPagingModel *model;

@property (nonatomic, strong) IBOutlet UIView *videoPlayerContainerView;

@property (nonatomic, strong) IBOutlet UICollectionView *videosCollectionView;

@property (nonatomic, strong) SYNFullScreenVideoViewController *fullscreenViewController;

@property (nonatomic, strong) SYNVideoInfoViewController *videoInfoViewController;

@property (nonatomic, strong) VideoInstance *videoInstance;

// Used for animation
@property (nonatomic, weak) UIImageView *annotationImageView;

@end


@implementation SYNVideoPlayerViewController

#pragma mark - Factory

+ (instancetype)viewControllerWithModel:(SYNPagingModel *)model selectedIndex:(NSInteger)selectedIndex {
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
	[[SYNTrackingManager sharedManager] trackVideoPlayerScreenView];
	
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
	
	BOOL isShowingMail = [self.presentedViewController isKindOfClass:[MFMailComposeViewController class]];
	BOOL isShowingFullScreen = [self.presentedViewController isKindOfClass:[SYNFullScreenVideoViewController class]];
	
	// If we're showing another view controller which isn't full screen or mail then we want to pause the video
	if (!isShowingFullScreen && !isShowingMail) {
		[self.currentVideoPlayer pause];
	}
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
    //If there are annotations do not play the next video
    if (!self.videoInfoViewController.hasAnnotations) {
        [self playNextVideo];
    }
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

- (void)videoPlayerAnnotationSelected:(VideoAnnotation *)annotation button:(UIButton *)button {
    
    BOOL didAdd = [self.videoInfoViewController addVideoAnnotation:annotation];
	if (!didAdd) {
		return;
	}
	
    [[SYNTrackingManager sharedManager] trackShopMotionAnnotationPressForTitle:self.videoInstance.title];
	
    
	UIView *containerView = self.currentVideoPlayer.maximised ? self.fullscreenViewController.view : self.view;
    
	CGPoint buttonCenter = [containerView convertPoint:button.center fromView:button.superview];
	
	UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ShopMotionBagItem"]];
    
	imageView.center = buttonCenter;
	self.annotationImageView = imageView;

    if (self.currentVideoPlayer.maximised) {
        [self.fullscreenViewController.view addSubview:imageView];
    } else {
        [self.view addSubview:imageView];
    }
    
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
	UIBezierPath *path = [UIBezierPath bezierPath];
	[path moveToPoint:imageView.center];
	
	CGRect videoPlayerFrame = [containerView convertRect:self.currentVideoPlayer.bounds fromView:self.currentVideoPlayer];
	
	CGPoint destinationPoint = CGPointMake(CGRectGetMaxX(videoPlayerFrame) - 100.0, CGRectGetMaxY(videoPlayerFrame));
	[path addQuadCurveToPoint:destinationPoint controlPoint:CGPointMake(destinationPoint.x, imageView.center.y)];
	
	animation.path = [path CGPath];
	animation.duration = 0.6;
	animation.delegate = self;
	animation.removedOnCompletion = YES;
	
	[imageView.layer addAnimation:animation forKey:nil];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
	[self.annotationImageView removeFromSuperview];
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
	VideoInstance *videoInstance = [self.model itemAtIndex:index];
	[[SYNTrackingManager sharedManager] trackUpcomingVideoSelectedForTitle:videoInstance.title];
	self.selectedIndex = index;
}

#pragma mark - IBActions

- (IBAction)closeButtonPressed:(UIButton *)barButton {
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)followButtonPressed:(UIButton *)button {
	[self followControlPressed:button withChannelOwner:self.videoInstance.originator completion:^{
		
	}];
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
	[self.currentVideoPlayer stop];
	
	NSIndexPath *indexPath = [NSIndexPath indexPathForItem:self.selectedIndex inSection:0];
	SYNVideoPlayerCell *cell = (SYNVideoPlayerCell *)[self.videosCollectionView cellForItemAtIndexPath:indexPath];
	
	SYNVideoPlayer *videoPlayer = cell.videoPlayer;
	[videoPlayer play];
	
	self.currentVideoPlayer = videoPlayer;
}

- (void)maximiseVideoPlayer {
	self.fullscreenViewController = [[SYNFullScreenVideoViewController alloc] init];
	self.fullscreenViewController.videoPlayerViewController = self;
	self.fullscreenViewController.transitioningDelegate = self;
	
	[self presentViewController:self.fullscreenViewController animated:YES completion:nil];
}

- (void)minimiseVideoPlayer {
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)updateVideoInstanceDetails:(VideoInstance *)videoInstance {
	NSURL *avatarURL = [NSURL URLWithString:videoInstance.originator.thumbnailURL];

	[self.avatarButton setImageWithURL:avatarURL
							  forState:UIControlStateNormal
					  placeholderImage:[UIImage imageNamed:@"PlaceholderAvatarProfile"]
							   options:SDWebImageRetryFailed];
    
	[self.videoTitleLabel setText:videoInstance.title animated:YES];
	
	self.followingButton.selected = [[SYNActivityManager sharedInstance] isSubscribedToUserId:videoInstance.originator.uniqueId];
	[self.followingButton invalidateIntrinsicContentSize];
    [self showInboarding:videoInstance];
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

- (void) showInboarding :(VideoInstance*) videoInstance {
    
    BOOL hasAnnotations = [videoInstance.video.videoAnnotations count] > 0;
    
    if (!hasAnnotations) {
        return;
    }
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:kUserDefaultsShopMotionFirstTime]) {
    
                SYNShopMotionOverlayViewController *overlay = [[SYNShopMotionOverlayViewController alloc] init];
                [overlay addToViewController:self];
        
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kUserDefaultsShopMotionFirstTime];
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
							  NSStringFromClass([SYNAddToChannelViewController class])    : [SYNPopoverAnimator class]
							  };
	return mapping[NSStringFromClass([viewController class])];
}

@end
