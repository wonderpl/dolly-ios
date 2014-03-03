//
//  SYNHomeTopTabViewController.m
//  rockpack
//
//  Created by Nick Banks on 07/12/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import "AppConstants.h"
#import "Appirater.h"
#import "Channel.h"
#import "ChannelCover.h"
#import "ChannelOwner.h"
#import "FeedItem.h"
#import "SYNAggregateCell.h"
#import "SYNAggregateChannelCell.h"
#import "SYNAggregateVideoCell.h"
#import "SYNAppDelegate.h"
#import "SYNDeviceManager.h"
#import "SYNFeedRootViewController.h"
#import "SYNMasterViewController.h"
#import "SYNNetworkEngine.h"
#import "SYNOAuthNetworkEngine.h"
#import <UIButton+WebCache.h>
#import <UIImageView+WebCache.h>
#import "Video.h"
#import "VideoInstance.h"
#import "UICollectionReusableView+Helpers.h"
#import "SYNPagingModel.h"
#import "SYNFeedModel.h"
#import "SYNAggregateVideoItemCell.h"
#import "SYNCarouselVideoPlayerViewController.h"
#import "SYNVideoPlayerAnimator.h"
#import "UIColor+SYNColor.h"
#import "SYNTrackingManager.h"

typedef void(^FeedDataErrorBlock)(void);

@interface SYNFeedRootViewController () <UIViewControllerTransitioningDelegate, SYNPagingModelDelegate, SYNVideoPlayerAnimatorDelegate>

@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) IBOutlet UICollectionView* feedCollectionView;

@property (nonatomic, strong) SYNFeedModel *model;
@property (nonatomic, strong) SYNVideoPlayerAnimator *videoPlayerAnimator;

@end


@implementation SYNFeedRootViewController

#pragma mark - Object lifecycle

- (void) dealloc
{
    // No harm in removing all notifications, as we are being de-alloced after all..
    [[NSNotificationCenter defaultCenter] removeObserver: self];
    
    // Defensive programming
    self.feedCollectionView.delegate = nil;
    self.feedCollectionView.dataSource = nil;
}


#pragma mark - View lifecycle

- (void) viewDidLoad
{
    [super viewDidLoad];
	
	self.model = [[SYNFeedModel alloc] init];
	self.model.delegate = self;

    self.feedCollectionView.contentInset = UIEdgeInsetsMake(90.0f, 0.0f, 10.0f, 0.0f);

    [self displayPopupMessage: NSLocalizedString(@"feed_screen_loading_message", nil)
                   withLoader: YES];

    [self.feedCollectionView registerNib:[SYNAggregateVideoCell nib]
              forCellWithReuseIdentifier:[SYNAggregateVideoCell reuseIdentifier]];
    
    [self.feedCollectionView registerNib:[SYNAggregateChannelCell nib]
              forCellWithReuseIdentifier:[SYNAggregateChannelCell reuseIdentifier]];
	
    [self.feedCollectionView registerNib:[SYNChannelFooterMoreView nib]
              forSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                     withReuseIdentifier:[SYNChannelFooterMoreView reuseIdentifier]];
    
    // Refresh control
    self.refreshControl = [[UIRefreshControl alloc] initWithFrame: CGRectMake(0, -44, 320, 44)];
    
    [self.refreshControl setTintColor:[UIColor dollyActivityIndicator]];
    
    [self.refreshControl addTarget: self
                            action: @selector(resetData)
                  forControlEvents: UIControlEventValueChanged];
    
    [self.feedCollectionView addSubview: self.refreshControl];
    
    if (!IS_IPHONE_5) {
        UIEdgeInsets tmpInsets = self.feedCollectionView.contentInset;
        tmpInsets.bottom += 88;
        [self.feedCollectionView setContentInset: tmpInsets];
    }

    [[NSNotificationCenter defaultCenter] postNotificationName: kScrollMovement
                                                        object: self
                                                      userInfo: @{kScrollingDirection:@(ScrollingDirectionUp)}];

}

- (void) viewWillAppear: (BOOL) animated {
    [super viewWillAppear: animated];
	
	if (![self isBeingPresented]) {
		self.model.mode = SYNFeedModelModeFeed;
		self.model.delegate = self;
		[self.feedCollectionView reloadData];
	}
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	[[SYNTrackingManager sharedManager] trackFeedScreenView];
}


#pragma mark - Container Scroll Delegates

- (void) willRotateToInterfaceOrientation: (UIInterfaceOrientation) toInterfaceOrientation
                                 duration: (NSTimeInterval) duration
{
    [super willRotateToInterfaceOrientation: toInterfaceOrientation
                                   duration: duration];
    
    // NOTE: WE might not need to reload, just invalidate the layout

    [self.feedCollectionView.collectionViewLayout invalidateLayout];
}

- (void) clearedLocationBoundData {
	[self resetData];

	[self.feedCollectionView reloadData];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger) numberOfSectionsInCollectionView: (UICollectionView *) collectionView {
	return 1;
}

- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger) section {
	return [self.model itemCount];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	FeedItem *feedItem = [self.model itemAtIndex:indexPath.item];
	
	SYNAggregateCell *cell = nil;
	
	if (feedItem.resourceTypeValue == FeedItemResourceTypeVideo) {
		cell = [collectionView dequeueReusableCellWithReuseIdentifier:[SYNAggregateVideoCell reuseIdentifier]
														 forIndexPath:indexPath];
		
		
		cell.collectionData = [self.model videoInstancesForFeedItem:feedItem];
		cell.delegate = self;
	} else if (feedItem.resourceTypeValue == FeedItemResourceTypeChannel) {
		cell = [collectionView dequeueReusableCellWithReuseIdentifier:[SYNAggregateChannelCell reuseIdentifier]
														 forIndexPath:indexPath];
		
		cell.collectionData = [self.model channelsForFeedItem:feedItem];
	}
	
	cell.delegate = self;
	
	Channel *channel = [self.model channelForFeedItem:feedItem];
	[cell.userThumbnailButton setImageWithURL:[NSURL URLWithString:channel.channelOwner.thumbnailURL]
									 forState:UIControlStateNormal
							 placeholderImage:[UIImage imageNamed: @"PlaceholderAvatarProfile"]
									  options:SDWebImageRetryFailed];
	
	return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
		   viewForSupplementaryElementOfKind:(NSString *)kind
								 atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *supplementaryView = nil;
	if (kind == UICollectionElementKindSectionFooter) {
        self.footerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                             withReuseIdentifier:[SYNChannelFooterMoreView reuseIdentifier]
                                                                    forIndexPath:indexPath];
        supplementaryView = self.footerView;
		
		if ([self.model hasMoreItems]) {
            //hide footer on first load, need more obvious solution
            if ([self.model itemCount]>1) {
                self.footerView.showsLoading = YES;
            }
			
			[self.model loadNextPage];
		}
    }
	
    return supplementaryView;
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView
				  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
	FeedItem *feedItem = [self.model itemAtIndex:indexPath.item];
	
	CGFloat collectionViewWidth = CGRectGetWidth(collectionView.bounds);
    
    if (feedItem.resourceTypeValue == FeedItemResourceTypeVideo) {
		return (IS_IPAD ? CGSizeMake(collectionViewWidth, 457.0) : CGSizeMake(collectionViewWidth, 369.0));
    } else {
		return (IS_IPAD ? CGSizeMake(collectionViewWidth, 330.0) : CGSizeMake(collectionViewWidth, 264.0));
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
	return ([self.model hasMoreItems] ? [self footerSize] : CGSizeZero);
}

#pragma mark - SYNPagingModelDelegate

- (void)pagingModelDataUpdated:(SYNPagingModel *)pagingModel {
	[self.refreshControl endRefreshing];
	[self removePopupMessage];

	[self.feedCollectionView reloadData];
}

- (void)pagingModelErrorOccurred:(SYNPagingModel *)pagingModel {
	[self.refreshControl endRefreshing];
	[self removePopupMessage];
	
	if ([self.model itemCount]) {
		[self displayPopupMessage:NSLocalizedString(@"feed_screen_updating_error", nil) withLoader:NO];
	} else {
		[self displayPopupMessage:NSLocalizedString(@"feed_screen_loading_error", nil) withLoader:NO];
	}
}

#pragma mark - Helper Methods to get AggreagateCell's Data

- (FeedItem *)feedItemAtIndexPath:(NSIndexPath *)indexPath {
	return [self.model itemAtIndex:indexPath.item];
}

- (NSString *)trackingScreenName {
	return @"MyWonders";
}

#pragma mark - Click Cell Delegates

- (SYNAggregateCell *) aggregateCellFromSubview: (UIView *) view
{
    UIView *candidateCell = view;
    
    while (![candidateCell isKindOfClass: [SYNAggregateCell class]])
    {
        candidateCell = candidateCell.superview;
    }
    
    return (SYNAggregateCell *) candidateCell;
}


- (NSIndexPath *) indexPathFromView: (UIView *) view
{
    SYNAggregateCell *aggregateCellSelected = [self aggregateCellFromSubview: view];
    NSIndexPath *indexPath = [self.feedCollectionView indexPathForItemAtPoint: aggregateCellSelected.center];
    
    return indexPath;
}


- (FeedItem *) feedItemFromView: (UIView *) view
{
    NSIndexPath *indexPath = [self indexPathFromView: view];
    FeedItem *selectedFeedItem = [self feedItemAtIndexPath: indexPath];
    
    return selectedFeedItem;
}

- (void) profileButtonTapped: (UIButton *) profileButton {
    
	FeedItem *feedItem = [self feedItemFromView: profileButton];
	
	Channel *channel = [self.model channelForFeedItem:feedItem];

	[self viewProfileDetails:channel.channelOwner];
}

- (void)channelControlPressed:(UICollectionViewCell*)sender {
    FeedItem *feedItem = [self feedItemFromView: sender];
	[self viewChannelDetails:[self.model channelForFeedItem:feedItem] withAnimation:YES];
    
}

- (void)displayVideoViewerFromCell:(UICollectionViewCell *)cell
						andSubCell:(UICollectionViewCell *)subCell
					atSubCellIndex:(NSInteger)subCellIndex {
	NSIndexPath *cellIndexPath = [self.feedCollectionView indexPathForCell:cell];
	
	NSIndexPath *indexPath = [NSIndexPath indexPathForItem:subCellIndex inSection:cellIndexPath.row];
	
	self.model.mode = SYNFeedModelModeVideo;
	UIViewController *viewController = [SYNCarouselVideoPlayerViewController viewControllerWithModel:self.model
																					   selectedIndex:[self.model videoIndexForIndexPath:indexPath]];
	SYNVideoPlayerAnimator *animator = [[SYNVideoPlayerAnimator alloc] init];
	animator.delegate = self;
	animator.cellIndexPath = indexPath;
	self.videoPlayerAnimator = animator;
	viewController.transitioningDelegate = animator;
	
	[self presentViewController:viewController animated:YES completion:nil];
}

- (id<SYNVideoInfoCell>)videoCellForIndexPath:(NSIndexPath *)indexPath {
	NSIndexPath *feedIndexPath = [NSIndexPath indexPathForItem:indexPath.section inSection:0];
	SYNAggregateCell *aggregateCell = (SYNAggregateCell *)[self.feedCollectionView cellForItemAtIndexPath:feedIndexPath];
	
	NSIndexPath *cellIndexPath = [NSIndexPath indexPathForItem:indexPath.row inSection:0];
	return (SYNAggregateVideoItemCell *)[aggregateCell.collectionView cellForItemAtIndexPath:cellIndexPath];
}

- (void)resetData {
	[self.model reset];
	[self.model loadNextPage];
}

- (void) applicationWillEnterForeground: (UIApplication *) application {
	[super applicationWillEnterForeground: application];
	
	[self resetData];
}

@end
