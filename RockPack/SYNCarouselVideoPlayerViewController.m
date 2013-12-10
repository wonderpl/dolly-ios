//
//  SYNCarouselVideoPlayerViewController.m
//  dolly
//
//  Created by Sherman Lo on 15/11/13.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNCarouselVideoPlayerViewController.h"
#import "SYNVideoPlayerViewController+Protected.h"
#import "SYNVideoThumbnailCell.h"
#import "VideoInstance.h"
#import "Video.h"
#import "Channel.h"
#import "ChannelOwner.h"
#import "SYNVideoPlayer.h"
#import "UIFont+SYNFont.h"
#import "SYNAppDelegate.h"
#import "SYNFacebookManager.h"
#import "ChannelCover.h"
#import "SYNButton.h"
#import "UICollectionReusableView+Helpers.h"
#import "SYNFeedModel.h"
#import "SYNStaticModel.h"
#import "SYNChannelFooterMoreView.h"
#import <UIImageView+WebCache.h>

@interface SYNCarouselVideoPlayerViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIViewControllerTransitioningDelegate, SYNPagingModelDelegate>

@property (nonatomic, strong) IBOutlet UIImageView *channelThumbnailImageView;
@property (nonatomic, strong) IBOutlet UILabel *channelTitleLabel;
@property (nonatomic, strong) IBOutlet UILabel *channelOwnerLabel;

@property (nonatomic, strong) IBOutlet UICollectionView *thumbnailCollectionView;

@property (nonatomic, assign) NSInteger selectedIndex;

@property (nonatomic, strong) SYNPagingModel *model;

@end

@implementation SYNCarouselVideoPlayerViewController

#pragma mark - Public class

+ (instancetype)viewControllerWithModel:(SYNPagingModel *)model selectedIndex:(NSInteger)selectedIndex {
	NSString *suffix = (IS_IPAD ? @"ipad" : (IS_IPHONE_5 ? @"iphone" : @"iphone4" ));
	NSString *filename = [NSString stringWithFormat:@"%@_%@", NSStringFromClass(self), suffix];
	UIStoryboard *storyboard = [UIStoryboard storyboardWithName:filename bundle:nil];
	
	SYNCarouselVideoPlayerViewController *viewController = [storyboard instantiateInitialViewController];
	viewController.model = model;
	viewController.selectedIndex = selectedIndex;
	
	return viewController;
}

+ (instancetype)viewControllerWithVideoInstances:(NSArray *)videoInstances selectedIndex:(NSInteger)selectedIndex {
	NSString *suffix = (IS_IPAD ? @"ipad" : (IS_IPHONE_5 ? @"iphone" : @"iphone4" ));
	NSString *filename = [NSString stringWithFormat:@"%@_%@", NSStringFromClass(self), suffix];
	UIStoryboard *storyboard = [UIStoryboard storyboardWithName:filename bundle:nil];
	
	SYNCarouselVideoPlayerViewController *viewController = [storyboard instantiateInitialViewController];
	viewController.model = [[SYNStaticModel alloc] initWithLoadedItems:videoInstances];
	viewController.selectedIndex = selectedIndex;
	
	return viewController;
}

#pragma mark - UIViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.channelThumbnailImageView.layer.cornerRadius = CGRectGetWidth(self.channelThumbnailImageView.frame) / 2.0;
	self.channelThumbnailImageView.layer.masksToBounds = YES;
	
	self.channelTitleLabel.font = [UIFont lightCustomFontOfSize:self.channelTitleLabel.font.pointSize];
	self.channelOwnerLabel.font = [UIFont lightCustomFontOfSize:self.channelOwnerLabel.font.pointSize];
	
	[self.thumbnailCollectionView registerNib:[SYNVideoThumbnailCell nib]
				   forCellWithReuseIdentifier:[SYNVideoThumbnailCell reuseIdentifier]];
	
	[self.thumbnailCollectionView registerNib:[SYNChannelFooterMoreView nib]
				   forSupplementaryViewOfKind:UICollectionElementKindSectionFooter
						  withReuseIdentifier:[SYNChannelFooterMoreView reuseIdentifier]];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	self.model.delegate = self;
	
	if (![self isBeingPresented]) {
		// Invalidate the layout so the section insets are recalculated when returning from full screen video
		[self.thumbnailCollectionView.collectionViewLayout invalidateLayout];
	}
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	if ([self isBeingPresented]) {
		NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.selectedIndex inSection:0];
		[self.thumbnailCollectionView selectItemAtIndexPath:indexPath
												   animated:YES
											 scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
	}
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	[super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
	
	// We need to invalidate the layout to make sure that the section insets are changed
	[self.thumbnailCollectionView.collectionViewLayout invalidateLayout];
}

- (void)videoPlayerFinishedPlaying {
	[self playNextVideo];
}

#pragma mark - Getters / Setters

- (void)setSelectedIndex:(NSInteger)selectedIndex {
	_selectedIndex = selectedIndex;
	
	self.videoInstance = [self.model itemAtIndex:selectedIndex];
	
	NSIndexPath *selectedIndexPath = [NSIndexPath indexPathForRow:selectedIndex inSection:0];
	[self.thumbnailCollectionView selectItemAtIndexPath:selectedIndexPath animated:YES scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
	return [self.model itemCount];
}

- (NSInteger) numberOfSectionsInCollectionView: (UICollectionView *) collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SYNVideoThumbnailCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[SYNVideoThumbnailCell reuseIdentifier]
																			forIndexPath:indexPath];
    
	VideoInstance *videoInstance = [self.model itemAtIndex:indexPath.item];
    
    cell.titleLabel.text = videoInstance.title;
	[cell setImageWithURL:videoInstance.video.thumbnailURL];
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
	if ([kind isEqualToString:UICollectionElementKindSectionFooter]) {
		SYNChannelFooterMoreView *footerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind
																				  withReuseIdentifier:[SYNChannelFooterMoreView reuseIdentifier]
																						 forIndexPath:indexPath];
		footerView.showsLoading = YES;
		
		if ([self.model hasMoreItems]) {
			[self.model loadNextPage];
		}
		
		return footerView;
	}
	return nil;
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
		self.selectedIndex = indexPath.row;
	}
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView
				  layout:(UICollectionViewFlowLayout *)collectionViewFlowLayout
referenceSizeForFooterInSection:(NSInteger)section {
	return ([self.model hasMoreItems] ? collectionViewFlowLayout.itemSize : CGSizeZero);
}

#pragma mark - UIScrollViewDelegate

// These are implemented and empty to make sure that the AbstractViewController's methods aren't being called

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
	
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
	
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	
}

#pragma mark - SYNPagingModelDelegate

- (void)pagingModelDataUpdated {
	[self.thumbnailCollectionView reloadData];
}

- (void)pagingModelErrorOccurred {
	
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

#pragma mark - Private

- (void)updateVideoInstanceDetails:(VideoInstance *)videoInstance {
	[super updateVideoInstanceDetails:(VideoInstance *)videoInstance];
	
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
}

- (void)playNextVideo {
	NSInteger nextIndex = (self.selectedIndex + 1) % [self.model itemCount];
	self.selectedIndex = nextIndex;
}

- (void)playPreviousVideo {
	NSInteger previousIndex = ((self.selectedIndex - 1) + [self.model itemCount]) % [self.model itemCount];
	self.selectedIndex = previousIndex;
}

@end
