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
#import "SYNFeedOverlayViewController.h"
#import "SYNVideoPlayerViewController.h"
#import "SYNFeedVideoCell.h"
#import "SYNAddToChannelViewController.h"
#import "SYNFeedChannelCell.h"
#import "SYNOneToOneSharingController.h"
#import "UIDevice+Helpers.h"
#import "SYNIPhoneFeedRootViewController.h"
#import "SYNIPadFeedRootViewController.h"
#import "UINavigationBar+Appearance.h"

@interface SYNFeedRootViewController () <UIViewControllerTransitioningDelegate, SYNPagingModelDelegate, SYNVideoPlayerAnimatorDelegate, SYNFeedVideoCellDelegate, SYNFeedChannelCellDelegate>

@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) IBOutlet UICollectionView *feedCollectionView;

@property (nonatomic, strong) SYNFeedModel *model;
@property (nonatomic, strong) SYNVideoPlayerAnimator *videoPlayerAnimator;

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
	
	[self resetData];
}

- (void)scrollToTop:(UIGestureRecognizer *)gestureRecognizer {
	[self.feedCollectionView setContentOffset:CGPointZero animated:YES];
}

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
	return (SYNFeedVideoCell *)[self.feedCollectionView cellForItemAtIndexPath:indexPath];
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

- (NSString *)trackingScreenName {
	return @"MyWonders";
}

- (void)resetData {
	[self.model reloadInitialPageWithCompletionHandler:^(BOOL success, BOOL hasChanged) {
		if (hasChanged) {
			self.feedCollectionView.contentOffset = CGPointMake(0, -self.feedCollectionView.contentInset.top);
			[appDelegate.navigationManager switchToFeed];
		}
	}];
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

#pragma mark - SYNFeedVideoCellDelegate

- (void)videoCellAvatarPressed:(SYNFeedVideoCell *)cell {
	VideoInstance *videoInstance = cell.videoInstance;
	
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
    VideoInstance *videoInstance = cell.videoInstance;
    
	[[SYNTrackingManager sharedManager] trackVideoLikeFromScreenName:[self trackingScreenName]];
	
    BOOL didStar = (button.selected == NO);
    
    button.enabled = NO;
	
	SYNAppDelegate *localAppDelegate = appDelegate;
    
    [appDelegate.oAuthNetworkEngine recordActivityForUserId: appDelegate.currentUser.uniqueId
                                                     action: (didStar ? @"star" : @"unstar")
                                            videoInstanceId: videoInstance.uniqueId
                                          completionHandler: ^(id response) {
                                              BOOL previousStarringState = videoInstance.starredByUserValue;
                                              
                                              if (didStar) {
                                                  // Currently highlighted, so increment
                                                  videoInstance.starredByUserValue = YES;
                                                  
                                                  button.selected = YES;
                                                  
                                                  [videoInstance addStarrersObject:localAppDelegate.currentUser];
                                              } else {
                                                  // Currently highlighted, so decrement
                                                  videoInstance.starredByUserValue = NO;
                                                  
                                                  button.selected = NO;
                                              }
                                              
                                              if (![videoInstance.managedObjectContext save:nil]) {
                                                  videoInstance.starredByUserValue = previousStarringState;
                                              }
                                              
                                              button.enabled = YES;
                                          } errorHandler: ^(id error) {
                                              button.enabled = YES;
                                          }];
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
	[self followButtonPressed:button withChannel:cell.channel];
}

- (void)channelCell:(SYNFeedChannelCell *)cell sharePressed:(UIButton *)button {
	[self shareChannel:cell.channel];
}

@end
