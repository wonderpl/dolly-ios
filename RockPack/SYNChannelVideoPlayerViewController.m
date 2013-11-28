//
//  SYNChannelVideoPlayerViewController.m
//  dolly
//
//  Created by Sherman Lo on 15/11/13.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNChannelVideoPlayerViewController.h"
#import "SYNVideoThumbnailCell.h"
#import "SYNVideoViewerThumbnailLayoutAttributes.h"
#import "VideoInstance.h"
#import "Video.h"
#import "Channel.h"
#import "ChannelOwner.h"
#import "SYNVideoPlayer.h"
#import "UIFont+SYNFont.h"
#import "ExternalAccount.h"
#import "SYNAppDelegate.h"
#import "SYNFacebookManager.h"
#import "SYNImplicitSharingController.h"
#import "SYNNetworkOperationJsonObject.h"
#import "SYNOAuthNetworkEngine.h"
#import "SYNDeviceManager.h"
#import "ChannelCover.h"
#import "SYNFullScreenVideoAnimator.h"
#import "SYNFullScreenVideoViewController.h"
#import "SYNButton.h"
#import <UIImageView+WebCache.h>
#import <Appirater.h>

@interface SYNChannelVideoPlayerViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIViewControllerTransitioningDelegate, SYNVideoPlayerDelegate>

@property (nonatomic, strong) NSArray *videoInstances;

@property (nonatomic, strong) IBOutlet UIImageView *channelThumbnailImageView;
@property (nonatomic, strong) IBOutlet UILabel *channelTitleLabel;
@property (nonatomic, strong) IBOutlet UILabel *channelOwnerLabel;
@property (nonatomic, strong) IBOutlet UILabel *videoTitleLabel;

@property (nonatomic, strong) IBOutlet UIView *videoPlayerContainerView;

@property (nonatomic, strong) IBOutlet SYNSocialButton *addButton;

@property (nonatomic, strong) IBOutlet UICollectionView *thumbnailCollectionView;

@property (nonatomic, strong) IBOutlet SYNButton *likeButton;

@property (nonatomic, strong) UIImageView *loadingImageView;

@property (nonatomic, strong) SYNVideoPlayer *currentVideoPlayer;

@property (nonatomic, assign) NSInteger selectedIndex;

@end

@implementation SYNChannelVideoPlayerViewController

#pragma mark - Public class

+ (instancetype)viewControllerWithVideoInstances:(NSArray *)videoInstances selectedIndex:(NSInteger)selectedIndex {
	NSString *suffix = (IS_IPAD ? @"ipad" : (IS_IPHONE_5 ? @"iphone" : @"iphone4" ));
	NSString *filename = [NSString stringWithFormat:@"%@_%@", NSStringFromClass(self), suffix];
	UIStoryboard *storyboard = [UIStoryboard storyboardWithName:filename bundle:nil];
	
	SYNChannelVideoPlayerViewController *viewController = [storyboard instantiateInitialViewController];
	viewController.videoInstances = videoInstances;
	viewController.selectedIndex = selectedIndex;
	
	return viewController;
}

#pragma mark - UIViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	appDelegate = [[UIApplication sharedApplication] delegate];
	
	if (IS_IPHONE) {
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(deviceOrientationChanged:)
													 name:UIDeviceOrientationDidChangeNotification
												   object:nil];
	}
	
	self.channelThumbnailImageView.layer.cornerRadius = CGRectGetWidth(self.channelThumbnailImageView.frame) / 2.0;
	self.channelThumbnailImageView.layer.masksToBounds = YES;
	
	self.channelTitleLabel.font = [UIFont lightCustomFontOfSize:self.channelTitleLabel.font.pointSize];
	self.channelOwnerLabel.font = [UIFont lightCustomFontOfSize:self.channelOwnerLabel.font.pointSize];
	self.videoTitleLabel.font = [UIFont lightCustomFontOfSize:self.videoTitleLabel.font.pointSize];

	UINib *videoThumbnailCellNib = [SYNVideoThumbnailCell nib];
	[self.thumbnailCollectionView registerNib:videoThumbnailCellNib
				   forCellWithReuseIdentifier:[SYNVideoThumbnailCell reuseIdentifier]];
	
	[self playVideoAtIndex:self.selectedIndex];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	// Invalidate the layout so the section insets are recalculated when returning from full screen video
	[self.thumbnailCollectionView.collectionViewLayout invalidateLayout];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.selectedIndex inSection:0];
	[self.thumbnailCollectionView selectItemAtIndexPath:indexPath
											   animated:YES
										 scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	[super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
	
	// We need to invalidate the layout to make sure that the section insets are changed
	[self.thumbnailCollectionView.collectionViewLayout invalidateLayout];
}

#pragma mark - Getters / Setters

- (void)setSelectedIndex:(NSInteger)selectedIndex {
	_selectedIndex = selectedIndex;
	
	NSIndexPath *selectedIndexPath = [NSIndexPath indexPathForRow:selectedIndex inSection:0];
	
	[self.thumbnailCollectionView selectItemAtIndexPath:selectedIndexPath animated:YES scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.videoInstances count];
}

- (NSInteger) numberOfSectionsInCollectionView: (UICollectionView *) collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SYNVideoThumbnailCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[SYNVideoThumbnailCell reuseIdentifier]
																			forIndexPath:indexPath];
    
    VideoInstance *videoInstance = self.videoInstances[indexPath.item];
    
    cell.titleLabel.text = videoInstance.title;
	[cell setImageWithURL:videoInstance.video.thumbnailURL];
    
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
	
    [tracker send: [[GAIDictionaryBuilder createEventWithCategory:@"uiAction"
                                                           action:@"videoBarClick"
                                                            label:nil
                                                            value:nil] build]];
	
	if (indexPath.row == self.selectedIndex) {
		if (self.currentVideoPlayer.state == SYNVideoPlayerStatePlaying) {
			[self.currentVideoPlayer pause];
		} else {
			[self.currentVideoPlayer play];
		}
	} else {
		[self playVideoAtIndex:indexPath.item];
		
		self.selectedIndex = indexPath.row;
	}
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
						layout:(UICollectionViewFlowLayout *)collectionViewFlowLayout
		insetForSectionAtIndex:(NSInteger)section {
	
	// We want to add an offset to the beginning and end of the collection view to ensure that the first and
	// last item are centered
	CGFloat insetWidth = (CGRectGetWidth(collectionView.frame) - collectionViewFlowLayout.itemSize.width) / 2;
    return UIEdgeInsetsMake (0, insetWidth, 0, insetWidth);
}

#pragma mark - UIViewControllerTransitioningDelegate

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
	return [SYNFullScreenVideoAnimator animatorForPresentating:YES];
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
	return [SYNFullScreenVideoAnimator animatorForPresentating:NO];
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
	VideoInstance *videoInstance = self.videoInstances[self.selectedIndex];
	
	[appDelegate.oAuthNetworkEngine recordActivityForUserId:appDelegate.currentOAuth2Credentials.userId
													 action:@"view"
											videoInstanceId:videoInstance.uniqueId
										  completionHandler:nil
											   errorHandler:^(NSDictionary* errorDictionary) {
												   DebugLog(@"View action failed");
											   }];
}

- (void)videoPlayerFinishedPlaying {
	[self playNextVideo];
}

- (void)videoPlayerErrorOccurred:(NSString *)reason {
	VideoInstance *videoInstance = self.videoInstances[self.selectedIndex];
	
	[appDelegate.oAuthNetworkEngine reportPlayerErrorForVideoInstanceId:videoInstance.uniqueId
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

- (IBAction)closeButtonPressed:(UIButton *)close {
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)swipedRight:(UISwipeGestureRecognizer *)gestureRecognizer {
	[self playPreviousVideo];
}

- (IBAction)swipedLeft:(UISwipeGestureRecognizer *)gestureRecognizer {
	[self playNextVideo];
}

- (IBAction)likeButtonPressed:(SYNSocialButton *)button {
	[self likeControlPressed:button];
}

- (IBAction)addButtonPressed:(SYNSocialButton *)button {
	[self addControlPressed:button];
}

- (IBAction)shareButtonPressed:(UIButton *)videoShareButton {
	VideoInstance *videoInstance = self.videoInstances[self.selectedIndex];
	
	[self shareVideoInstance: videoInstance];
}

#pragma mark - Notifications

- (void)deviceOrientationChanged:(NSNotification *)notification {
	UIDevice *device = [notification object];
	BOOL isShowingFullScreenVideo = [self.presentedViewController isKindOfClass:[SYNFullScreenVideoViewController class]];
	
	if (isShowingFullScreenVideo && [device orientation] == UIDeviceOrientationPortrait) {
		[self videoPlayerMinimise];
	}
	
	if (!isShowingFullScreenVideo && UIDeviceOrientationIsLandscape([device orientation])) {
		[self videoPlayerMaximise];
	}
}

#pragma mark - Private

- (void)playVideoAtIndex:(NSInteger)index {
	if (self.currentVideoPlayer) {
		[self.currentVideoPlayer removeFromSuperview];
		self.currentVideoPlayer = nil;
	}
	
	[self updateVideoDetailsForIndex:index];
	
	VideoInstance *videoInstance = self.videoInstances[index];
	
	SYNVideoPlayer *videoPlayer = [SYNVideoPlayer playerForVideoInstance:videoInstance];
	videoPlayer.delegate = self;
	videoPlayer.frame = self.videoPlayerContainerView.bounds;
	
	self.currentVideoPlayer = videoPlayer;
	[self.videoPlayerContainerView addSubview:videoPlayer];
	
	[videoPlayer play];
}

- (void)updateVideoDetailsForIndex:(NSInteger)index {
	VideoInstance *videoInstance = self.videoInstances[index];
	
	if ([videoInstance.channel.channelOwner.displayName length]) {
		[self.channelThumbnailImageView setImageWithURL:[NSURL URLWithString:videoInstance.channel.channelCover.imageSmallUrl]
									   placeholderImage:[UIImage imageNamed:@"PlaceholderChannelSmall.png"]
												options:SDWebImageRetryFailed];
	} else {
		self.channelThumbnailImageView.image = nil;
	}
	
	NSString *channelOwnerName = videoInstance.channel.channelOwner.displayName;
	self.channelOwnerLabel.text = ([channelOwnerName length] ? [NSString stringWithFormat: @"By %@", channelOwnerName] : @"");
	self.channelTitleLabel.text = videoInstance.channel.title;
	self.videoTitleLabel.text = videoInstance.title;
	
	self.likeButton.dataItemLinked = videoInstance;
	self.addButton.dataItemLinked = videoInstance;
	
	self.likeButton.selected = videoInstance.starredByUserValue;
	[self.likeButton setTitle:@"likes" andCount:[videoInstance.video.starCount integerValue]];
}

- (void)playNextVideo {
	NSInteger nextIndex = (self.selectedIndex + 1) % [self.videoInstances count];
	[self playVideoAtIndex:nextIndex];
	
	self.selectedIndex = nextIndex;
}

- (void)playPreviousVideo {
	NSInteger previousIndex = ((self.selectedIndex - 1) + [self.videoInstances count]) % [self.videoInstances count];
	[self playVideoAtIndex:previousIndex];
	
	self.selectedIndex = previousIndex;
}

@end
