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
#import "ChannelOwner.h"
#import "FeedItem.h"
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
#import "SYNFeedOverlayViewController.h"
#import "SYNVideoPlayerViewController.h"
#import "SYNFeedVideoCell.h"
#import "SYNAddToChannelViewController.h"
#import "SYNFeedChannelCell.h"
#import "SYNOneToOneSharingController.h"

@interface SYNFeedRootViewController () <UIViewControllerTransitioningDelegate, SYNPagingModelDelegate, SYNVideoPlayerAnimatorDelegate, SYNFeedVideoCellDelegate>

@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) IBOutlet UICollectionView* feedCollectionView;

@property (nonatomic, strong) SYNFeedModel *model;
@property (nonatomic, strong) SYNVideoPlayerAnimator *videoPlayerAnimator;

@end


@implementation SYNFeedRootViewController

#pragma mark - Object lifecycle

- (void) dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];

	self.feedCollectionView.delegate = nil;
	self.feedCollectionView.dataSource = nil;
}


#pragma mark - View lifecycle

- (void) viewDidLoad
{
    [super viewDidLoad];
	
	self.model = [[SYNFeedModel alloc] init];
	self.model.delegate = self;
	
    self.feedCollectionView.contentInset = UIEdgeInsetsMake(64.0, 0.0, 0.0, 0.0);

    [self displayPopupMessage: NSLocalizedString(@"feed_screen_loading_message", nil)
                   withLoader: YES];
	
	[self.feedCollectionView registerNib:[SYNFeedVideoCell nib]
			  forCellWithReuseIdentifier:[SYNFeedVideoCell reuseIdentifier]];
	
	[self.feedCollectionView registerNib:[SYNFeedChannelCell nib]
			  forCellWithReuseIdentifier:[SYNFeedChannelCell reuseIdentifier]];
	
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
    
    [[NSNotificationCenter defaultCenter] postNotificationName: kScrollMovement
                                                        object: self
                                                      userInfo: @{kScrollingDirection:@(ScrollingDirectionUp)}];
	
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetData) name:kReloadFeed object:nil];
}

- (void) viewWillAppear: (BOOL) animated {
    [super viewWillAppear: animated];
	
	if (![self isBeingPresented]) {
		self.model.delegate = self;
	}
    [self.feedCollectionView reloadData];
   
    [self showInboarding];
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
	
    [self.feedCollectionView.collectionViewLayout invalidateLayout];
}

- (void)clearedLocationBoundData {
	[self resetData];

	[self.feedCollectionView reloadData];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
	return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
	return [self.model itemCount];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	
	FeedItem *feedItem = [self.model feedItemAtindex:indexPath.row];
	
	if (feedItem.resourceTypeValue == FeedItemResourceTypeChannel) {
		
		SYNFeedChannelCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[SYNFeedChannelCell reuseIdentifier]
																			 forIndexPath:indexPath];
		
		VideoInstance *videoInstance = [self.model itemAtIndex:indexPath.row];
		cell.channel = videoInstance.channel;
		
		return cell;
	} else {
		
		SYNFeedVideoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[SYNFeedVideoCell reuseIdentifier]
																		   forIndexPath:indexPath];
		
		VideoInstance *videoInstance = [self.model itemAtIndex:indexPath.row];
		cell.videoInstance = videoInstance;
		cell.delegate = self;
		
		return cell;
	}
}

- (id<SYNVideoInfoCell>)videoCellForIndexPath:(NSIndexPath *)indexPath {
	return (SYNFeedVideoCell *)[self.feedCollectionView cellForItemAtIndexPath:indexPath];
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
	FeedItem *feedItem = [self.model feedItemAtindex:indexPath.item];

	CGFloat collectionViewWidth = CGRectGetWidth(collectionView.bounds);
    
    if (feedItem.resourceTypeValue == FeedItemResourceTypeVideo) {
		return (IS_IPAD ? CGSizeMake(collectionViewWidth, 457.0) : CGSizeMake(collectionViewWidth, 401.0));
    } else {
		return (IS_IPAD ? CGSizeMake(collectionViewWidth, 330.0) : CGSizeMake(collectionViewWidth, 267.0));
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
    

    if (self.isViewLoaded && self.view.window) {
        [self showInboarding];
    
    }
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

- (void)resetData {
	[self.model reset];
	[self.model loadNextPage];
}

- (void) applicationWillEnterForeground: (UIApplication *) application {
	[super applicationWillEnterForeground: application];
	
	[self resetData];
}

- (void) showInboarding {
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey: kUserDefaultsFeedFirstTime]) {
        if ([self.model itemCount]>0) {
            SYNFeedOverlayViewController* feedOverlay = [[SYNFeedOverlayViewController alloc] init];
            [feedOverlay addToViewController:appDelegate.masterViewController];
            [[NSUserDefaults standardUserDefaults] setBool: YES
                                                    forKey: kUserDefaultsFeedFirstTime];
        }
    }
}

- (void)videoCellAvatarPressed:(SYNFeedVideoCell *)cell {
	VideoInstance *videoInstance = cell.videoInstance;
	
	Channel *channel = videoInstance.channel;
	
	[self viewProfileDetails:channel.channelOwner];
}

- (void)videoCellThumbnailPressed:(SYNFeedVideoCell *)cell {
	NSIndexPath *indexPath = [self.feedCollectionView indexPathForCell:cell];
	
	UIViewController *viewController = [SYNVideoPlayerViewController viewControllerWithModel:self.model
																			   selectedIndex:indexPath.row];
	
	SYNVideoPlayerAnimator *animator = [[SYNVideoPlayerAnimator alloc] init];
	animator.delegate = self;
	animator.cellIndexPath = indexPath;
	self.videoPlayerAnimator = animator;
	viewController.transitioningDelegate = animator;
	
	[self presentViewController:viewController animated:YES completion:nil];
}

- (void)videoCell:(SYNFeedVideoCell *)cell favouritePressed:(UIButton *)button {
	
}

- (void)videoCell:(SYNFeedVideoCell *)cell addToChannelPressed:(UIButton *)button {
	VideoInstance *videoInstance = cell.videoInstance;
	
	[[SYNTrackingManager sharedManager] trackVideoAddFromScreenName:[self trackingScreenName]];
	
    [appDelegate.oAuthNetworkEngine recordActivityForUserId:appDelegate.currentUser.uniqueId
                                                     action:@"select"
                                            videoInstanceId:videoInstance.uniqueId
                                          completionHandler:nil
                                               errorHandler:nil];
	
	SYNAddToChannelViewController *viewController = [[SYNAddToChannelViewController alloc] initWithViewId:kExistingChannelsViewId];
	viewController.modalPresentationStyle = UIModalPresentationCustom;
	viewController.transitioningDelegate = self;
	viewController.videoInstance = videoInstance;
	
	[self presentViewController:viewController animated:YES completion:nil];
}

- (void)videoCell:(SYNFeedVideoCell *)cell sharePressed:(UIButton *)button {
	VideoInstance *videoInstance = cell.videoInstance;

	[self requestShareLinkWithObjectType:@"video_instance" objectId:videoInstance.uniqueId];
	
    // At this point it is safe to assume that the video thumbnail image is in the cache
    UIImage *thumbnailImage = [[[SDWebImageManager sharedManager] imageCache] imageFromMemoryCacheForKey:videoInstance.video.thumbnailURL];
	
	SYNOneToOneSharingController *viewController = [self createSharingViewControllerForObjectType:@"video_instance"
																						 objectId:videoInstance.video.thumbnailURL
																						  isOwner:NO
																						  isVideo:YES
																							image:thumbnailImage];
	viewController.modalPresentationStyle = UIModalPresentationCustom;
	viewController.transitioningDelegate = self;
	
	[self presentViewController:viewController animated:YES completion:nil];
}

@end
