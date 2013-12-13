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
#import "GAI.h"
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
#import "SYNCarouselVideoPlayerViewController.h"

typedef void(^FeedDataErrorBlock)(void);

@interface SYNFeedRootViewController () <SYNPagingModelDelegate>

@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) IBOutlet UICollectionView* feedCollectionView;

@property (nonatomic, strong) SYNFeedModel *model;

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

    // Register XIBs for Cell
    [self.feedCollectionView registerNib:[SYNAggregateVideoCell nib]
              forCellWithReuseIdentifier:[SYNAggregateVideoCell reuseIdentifier]];
    
    [self.feedCollectionView registerNib:[SYNAggregateChannelCell nib]
              forCellWithReuseIdentifier:[SYNAggregateChannelCell reuseIdentifier]];
	
    [self.feedCollectionView registerNib:[SYNChannelFooterMoreView nib]
              forSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                     withReuseIdentifier:[SYNChannelFooterMoreView reuseIdentifier]];
    
    // Refresh control
    self.refreshControl = [[UIRefreshControl alloc] initWithFrame: CGRectMake(0, -44, 320, 44)];
    
    self.refreshControl.tintColor = [UIColor colorWithRed: (11.0/255.0)
                                                    green: (166.0/255.0)
                                                     blue: (171.0/255.0)
                                                    alpha: (1.0)];
    
    [self.refreshControl addTarget: self
                            action: @selector(resetData)
                  forControlEvents: UIControlEventValueChanged];
    
    [self.feedCollectionView addSubview: self.refreshControl];
}


- (void) viewWillAppear: (BOOL) animated {
    [super viewWillAppear: animated];
	
	if (![self isBeingPresented]) {
		self.model.mode = SYNFeedModelModeFeed;
		self.model.delegate = self;
		[self.feedCollectionView reloadData];
	}

    // Google analytics support
    [self updateAnalytics];
}

#pragma mark - Container Scroll Delegates

- (void) updateAnalytics {
	// Google analytics support
	id tracker = [[GAI sharedInstance] defaultTracker];

	[tracker set:kGAIScreenName value: @"Feed"];

	[tracker send:[[GAIDictionaryBuilder createAppView] build]];
}


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
							 placeholderImage:[UIImage imageNamed: @"PlaceholderChannelSmall.png"]
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
			self.footerView.showsLoading = YES;
			
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
    
    if (feedItem.resourceTypeValue == FeedItemResourceTypeVideo) {
		return (IS_IPAD ? CGSizeMake(927.0, 457.0) : CGSizeMake(320.0, 369.0));
    } else {
        if ([SYNDeviceManager.sharedInstance isPortrait]) {
			return (IS_IPAD ? CGSizeMake(671.0, 330.0) : CGSizeMake(320.0f, 264.0));
		} else {
			return (IS_IPAD ? CGSizeMake(927.0, 330.0) : CGSizeMake(320.0, 264.0));
        }
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
	return ([self.model hasMoreItems] ? [self footerSize] : CGSizeZero);
}

#pragma mark - SYNPagingModelDelegate

- (void)pagingModelDataUpdated {
	[self.refreshControl endRefreshing];
	[self removePopupMessage];

	[self.feedCollectionView reloadData];
}

- (void)pagingModelErrorOccurred {
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
	return [self.model itemAtIndex:indexPath];
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


- (IBAction) channelButtonTapped: (UIButton *) channelButton {
	FeedItem *feedItem = [self feedItemFromView: channelButton];
	
	[self viewChannelDetails:[self.model channelForFeedItem:feedItem]];
}

- (void)displayVideoViewerFromCell:(UICollectionViewCell *)cell
						andSubCell:(UICollectionViewCell *)subCell
					atSubCellIndex:(NSInteger)subCellIndex {
	NSIndexPath *cellIndexPath = [self.feedCollectionView indexPathForCell:cell];
	
	NSIndexPath *indexPath = [NSIndexPath indexPathForItem:subCellIndex inSection:cellIndexPath.row];
	
	self.model.mode = SYNFeedModelModeVideo;
	UIViewController *viewController = [SYNCarouselVideoPlayerViewController viewControllerWithModel:self.model
																					   selectedIndex:[self.model videoIndexForIndexPath:indexPath]];
	[self presentViewController:viewController animated:YES completion:nil];
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
