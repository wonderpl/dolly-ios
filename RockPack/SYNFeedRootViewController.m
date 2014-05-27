//
//  SYNHomeTopTabViewController.m
//  rockpack
//
//  Created by Nick Banks on 07/12/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import "SYNFeedRootViewController.h"
#import "SYNMasterViewController.h"
#import "Channel.h"
#import "ChannelOwner.h"
#import "FeedItem.h"
#import <UIButton+WebCache.h>
#import <UIImageView+WebCache.h>
#import "Video.h"
#import "VideoInstance.h"
#import "UICollectionReusableView+Helpers.h"
#import "SYNFeedModel.h"
#import "SYNVideoPlayerAnimator.h"
#import "UIColor+SYNColor.h"
#import "SYNTrackingManager.h"
#import "SYNFeedOverlayAddingViewController.h"
#import "SYNVideoPlayerViewController.h"
#import "SYNFeedVideoCell.h"
#import "SYNAddToChannelViewController.h"
#import "SYNFeedChannelCell.h"
#import "SYNOneToOneSharingController.h"
#import "UIDevice+Helpers.h"
#import "SYNIPhoneFeedRootViewController.h"
#import "SYNIPadFeedRootViewController.h"
#import "SYNFeedOverlayLovingViewController.h"
#import "UINavigationBar+Appearance.h"
#import "SYNIPadFeedLayout.h"

@interface SYNFeedRootViewController () <UIViewControllerTransitioningDelegate, SYNPagingModelDelegate, SYNVideoPlayerAnimatorDelegate, SYNFeedVideoCellDelegate, SYNFeedChannelCellDelegate>

@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) IBOutlet UICollectionView *feedCollectionView;

@property (nonatomic, strong) SYNFeedModel *model;
@property (nonatomic, strong) SYNVideoPlayerAnimator *videoPlayerAnimator;

@property (nonatomic, assign) BOOL shownInboarding;

@end


@implementation SYNFeedRootViewController

+ (instancetype)viewController {
	Class class = ([[UIDevice currentDevice] isPhone] ? [SYNIPhoneFeedRootViewController class] : [SYNIPadFeedRootViewController class]);
	return [[class alloc] initWithViewId:kFeedViewId];
}

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
	
	self.model = [SYNFeedModel sharedModel];
	self.model.delegate = self;
	
    self.feedCollectionView.contentInset = UIEdgeInsetsMake(64.0, 0.0, 0.0, 0.0);
	
	if (![self.model itemCount]) {
		[self displayPopupMessage: NSLocalizedString(@"feed_screen_loading_message", nil)
					   withLoader: YES];
	}
	
    [self.feedCollectionView registerNib:[SYNChannelFooterMoreView nib]
              forSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                     withReuseIdentifier:[SYNChannelFooterMoreView reuseIdentifier]];
    
    // Refresh control
    self.refreshControl = [[UIRefreshControl alloc] initWithFrame: CGRectMake(0, -44, 320, 44)];
    
    [self.refreshControl setTintColor:[UIColor dollyActivityIndicator]];
    
    [self.refreshControl addTarget: self
                            action: @selector(reloadData)
                  forControlEvents: UIControlEventValueChanged];
    
    [self.feedCollectionView addSubview: self.refreshControl];
    
    [[NSNotificationCenter defaultCenter] postNotificationName: kScrollMovement
                                                        object: self
                                                      userInfo: @{kScrollingDirection:@(ScrollingDirectionUp)}];
	
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:kReloadFeed object:nil];
	
	[self reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	
	if (![self isBeingPresented]) {
		self.model.delegate = self;
	}
	
	self.shownInboarding = NO;
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	[[SYNTrackingManager sharedManager] trackFeedScreenView];
}

- (void)scrollToTop:(UIGestureRecognizer *)gestureRecognizer {
	[self.feedCollectionView setContentOffset:CGPointMake(0, -self.feedCollectionView.contentInset.top) animated:YES];
}

- (void) willRotateToInterfaceOrientation: (UIInterfaceOrientation) toInterfaceOrientation
                                 duration: (NSTimeInterval) duration
{
    [super willRotateToInterfaceOrientation: toInterfaceOrientation
                                   duration: duration];
	
    [self.feedCollectionView.collectionViewLayout invalidateLayout];
}

- (void)clearedLocationBoundData {
	[self reloadData];

	[self.feedCollectionView reloadData];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
	return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
	return [self.model feedItemCount];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	
	FeedItem *feedItem = [self.model feedItemAtindex:indexPath.row];
	
	if (feedItem.resourceTypeValue == FeedItemResourceTypeChannel) {
		
		SYNFeedChannelCell *cell = [self channelCellForIndexPath:indexPath collectionView:collectionView];
		
		Channel *channel = [self.model resourceForFeedItem:feedItem];
		cell.channel = channel;
		cell.delegate = self;
		
		return cell;
	} else {
		SYNFeedVideoCell *cell = [self videoCellForIndexPath:indexPath collectionView:collectionView];
		
		VideoInstance *videoInstance = [self.model resourceForFeedItem:feedItem];
		cell.videoInstance = videoInstance;
		cell.delegate = self;
		
		return cell;
	}
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

- (SYNFeedChannelCell *)channelCellForIndexPath:(NSIndexPath *)indexPath
								 collectionView:(UICollectionView *)collectionView {
	return nil;
}

- (SYNFeedVideoCell *)videoCellForIndexPath:(NSIndexPath *)indexPath
							 collectionView:(UICollectionView *)collectionView {
	return nil;
}

#pragma mark - SYNVideoInfoCell

- (id<SYNVideoInfoCell>)videoCellForIndexPath:(NSIndexPath *)indexPath {
	UICollectionViewCell *cell = [self.feedCollectionView cellForItemAtIndexPath:indexPath];
	if ([cell conformsToProtocol:@protocol(SYNVideoInfoCell)]) {
		return (id<SYNVideoInfoCell>)cell;
	}
	return nil;
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

- (NSString *)trackingScreenName {
	return @"MyWonders";
}

- (void)reloadDataAndSwitchToFeed:(BOOL)shouldSwitch {
	[self.model reloadInitialPageWithCompletionHandler:^(BOOL success, BOOL hasChanged) {
		if (shouldSwitch && hasChanged) {
			[appDelegate.navigationManager switchToFeed];
		}
	}];
}

- (void)reloadData {
	[self reloadDataAndSwitchToFeed:NO];
}

- (void) applicationWillEnterForeground: (UIApplication *) application {
	[super applicationWillEnterForeground: application];
	
	if (appDelegate.currentOAuth2Credentials.userId) {
		[self reloadDataAndSwitchToFeed:YES];
	}
}

- (void) showInboarding {
    NSInteger value = [[NSUserDefaults standardUserDefaults] integerForKey: kUserDefaultsFeedCount];

    if (value < 3 && self.shownInboarding == NO) {
        if ([self.model itemCount]>0 && [self.model itemIndexForFeedIndex:0] == FeedItemResourceTypeVideo ) {
            
            [self.feedCollectionView setContentOffset:CGPointMake(0, -self.feedCollectionView.contentInset.top) animated:NO];

            if (value == 1) {
                SYNFeedOverlayAddingViewController* feedOverlay = [[SYNFeedOverlayAddingViewController alloc] init];
                [feedOverlay addToViewController:appDelegate.masterViewController];
            }
            
            if (value == 2) {
                SYNFeedOverlayLovingViewController* overlay = [[SYNFeedOverlayLovingViewController alloc] init];
                [overlay addToViewController:appDelegate.masterViewController];
            }
            
            self.shownInboarding = YES;
            
            value+=1;
            [[NSUserDefaults standardUserDefaults] setInteger:value forKey:kUserDefaultsFeedCount];
        }
    }
}

#pragma mark - SYNFeedVideoCellDelegate

- (void)videoCellAvatarPressed:(SYNFeedVideoCell *)cell {
	VideoInstance *videoInstance = cell.videoInstance;
	
	[[SYNTrackingManager sharedManager] trackVideoOriginatorPressed:videoInstance.originator.displayName];
	[self viewProfileDetails:videoInstance.originator];
}

- (void)videoCellThumbnailPressed:(SYNFeedVideoCell *)cell {
	NSIndexPath *indexPath = [self.feedCollectionView indexPathForCell:cell];
	
	// We need to convert it to the index in the array of videos since the player doesn't know about channels
	NSInteger itemIndex = [self.model itemIndexForFeedIndex:indexPath.row];
	UIViewController *viewController = [SYNVideoPlayerViewController viewControllerWithModel:self.model
																			   selectedIndex:itemIndex];
	
	SYNVideoPlayerAnimator *animator = [[SYNVideoPlayerAnimator alloc] init];
	animator.delegate = self;
	animator.cellIndexPath = indexPath;
	self.videoPlayerAnimator = animator;
	viewController.transitioningDelegate = animator;
	
	[self presentViewController:viewController animated:YES completion:nil];
}

- (void)videoCell:(SYNFeedVideoCell *)cell favouritePressed:(UIButton *)button {
	[self favouriteButtonPressed:button videoInstance:cell.videoInstance];
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
	[self shareVideoInstance:cell.videoInstance];
}

- (void)videoCell:(SYNFeedVideoCell *)cell addedByPressed:(UIButton *)button {
	VideoInstance *videoInstance = cell.videoInstance;
	
	[[SYNTrackingManager sharedManager] trackVideoAddedByPressed:videoInstance.channel.channelOwner.displayName];
	[self viewProfileDetails:videoInstance.channel.channelOwner];
}

#pragma mark - SYNFeedChannelCellDelegate

- (void)channelCellAvatarPressed:(SYNFeedChannelCell *)cell {
	[self viewProfileDetails:cell.channel.channelOwner];
}

- (void)channelCellTitlePressed:(SYNFeedChannelCell *)cell {
	[self viewChannelDetails:cell.channel withAnimation:YES];
}

- (void)channelCell:(SYNFeedChannelCell *)cell followPressed:(UIButton *)button {
	[self followButtonPressed:button withChannel:cell.channel completion:nil];
}

- (void)channelCell:(SYNFeedChannelCell *)cell sharePressed:(UIButton *)button {
	[self shareChannel:cell.channel];
}

@end
