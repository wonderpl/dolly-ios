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
#import "SYNFeedChannelCell.h"
#import "SYNOneToOneSharingController.h"
#import "UIDevice+Helpers.h"
#import "SYNIPhoneFeedRootViewController.h"
#import "SYNIPadFeedRootViewController.h"
#import "SYNFeedOverlayLovingViewController.h"
#import "UINavigationBar+Appearance.h"
#import "SYNIPadFeedLayout.h"
#import <TestFlight.h>
#import "SYNVideoPlayerDismissIndex.h"
#import "SYNFeedAvatarOverlayViewController.h"
#import "SYNActivityManager.h"
#import "NSString+Timecode.h"

static const CGFloat heightLandscape = 703;
static const CGFloat heightPortrait = 985;

@interface SYNFeedRootViewController () <UIViewControllerTransitioningDelegate, SYNPagingModelDelegate, SYNVideoPlayerAnimatorDelegate, SYNFeedVideoCellDelegate, SYNFeedChannelCellDelegate,SYNVideoPlayerDismissIndex>

@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) IBOutlet UICollectionView *feedCollectionView;

@property (nonatomic, strong) SYNFeedModel *model;
@property (nonatomic, strong) SYNVideoPlayerAnimator *videoPlayerAnimator;

@property (nonatomic, assign) BOOL shownInboarding;

@property (nonatomic, assign) CGFloat lastYOffset;
@property (nonatomic, assign) UIInterfaceOrientation lastOrientation;

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
	
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadData)
                                                 name:kReloadFeed
                                               object:nil];
    
	[self reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	
	if (![self isBeingPresented]) {
		self.model.delegate = self;
	}

    if (IS_IPAD) {
        [self.feedCollectionView.collectionViewLayout invalidateLayout];
    }
    
    [self.feedCollectionView reloadData];
	self.shownInboarding = NO;
    [self showInboarding];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[[SYNTrackingManager sharedManager] trackFeedScreenView];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.lastYOffset = self.feedCollectionView.contentOffset.y;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.lastOrientation = [[UIApplication sharedApplication] statusBarOrientation];
}

- (void)scrollToTopIPad:(UIGestureRecognizer *)gestureRecognizer {
	[self scrollToTop];
}

- (void)scrollToTopIPhone:(UIGestureRecognizer *)gestureRecognizer {
	[self scrollToTop];
}

- (void)scrollToTop {
    [self.feedCollectionView setContentOffset:CGPointMake(0, -self.feedCollectionView.contentInset.top) animated:YES];
}


- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self calculateRotationOffSet];
    self.feedCollectionView.alpha = 1.0;
}

- (void)calculateRotationOffSet {
    CGPoint newOffset = CGPointZero;
    if (UIDeviceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
        newOffset = CGPointMake(0, self.lastYOffset*heightPortrait/heightLandscape);
    } else {
        newOffset = CGPointMake(0, self.lastYOffset*heightLandscape/heightPortrait);
    }
    
    BOOL offsetOutOfBounds = newOffset.y+self.feedCollectionView.frame.size.height > self.feedCollectionView.contentSize.height;
    BOOL lowOffSet = newOffset.y < 300;

    if (offsetOutOfBounds) {
        newOffset.y = self.feedCollectionView.contentSize.height - self.feedCollectionView.frame.size.height;
        [self.feedCollectionView setContentOffset:newOffset animated:NO];
    } else if (lowOffSet) {
        [self.feedCollectionView setContentOffset:CGPointMake(0, -self.feedCollectionView.contentInset.top) animated:NO];
    } else {
        [self.feedCollectionView setContentOffset:newOffset animated:NO];
    }
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	[super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    self.feedCollectionView.alpha = 0.0;
    self.lastYOffset = self.feedCollectionView.contentOffset.y;
    [self.feedCollectionView.collectionViewLayout invalidateLayout];
    [self.feedCollectionView reloadData];

}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    self.feedCollectionView.alpha = 1.0;
    [self calculateRotationOffSet];
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
        if (channel) {
            cell.channel = channel;
            cell.delegate = self;
        }
		return cell;
	} else {
		SYNFeedVideoCell *cell = [self videoCellForIndexPath:indexPath collectionView:collectionView];
		
		VideoInstance *videoInstance = [self.model resourceForFeedItem:feedItem];
        if (videoInstance) {
            cell.videoInstance = videoInstance;
            cell.delegate = self;
        }
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
        
        [self setFeedWidgetItem];
        [self.refreshControl endRefreshing];
        [self removePopupMessage];
        
        [self.feedCollectionView reloadData];
        
        if (self.isViewLoaded && self.view.window) {
            [self showInboarding];
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
    if (value < 6 && self.shownInboarding == NO) {
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
            
            if (value == 5) {
                SYNFeedAvatarOverlayViewController *overlay = [[SYNFeedAvatarOverlayViewController alloc] init];
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
	SYNVideoPlayerViewController *viewController = [SYNVideoPlayerViewController viewControllerWithModel:self.model
																			   selectedIndex:itemIndex];
	
	SYNVideoPlayerAnimator *animator = [[SYNVideoPlayerAnimator alloc] init];
	animator.delegate = self;
	animator.cellIndexPath = indexPath;
	self.videoPlayerAnimator = animator;
	viewController.transitioningDelegate = animator;
	viewController.dismissDelegate = self;
	[self presentViewController:viewController animated:YES completion:nil];
}

- (void)videoCell:(SYNFeedVideoCell *)cell favouritePressed:(UIButton *)button {
    
	[self favouriteButtonPressed:button videoInstance:cell.videoInstance];
}

- (void)videoCell:(SYNFeedVideoCell *)cell addToChannelPressed:(UIButton *)button {
    NSIndexPath *indexPath = [self.feedCollectionView indexPathForCell:cell];
	TFLog(@"Feed: Video Instance from model :%@", [self.model itemAtIndex:indexPath.row]);
    [self addToChannelButtonPressed:button videoInstance:cell.videoInstance];
    self.lastOrientation = [[UIApplication sharedApplication] statusBarOrientation];
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


#pragma mark - SYNVideoPlayerDismissIndex

- (void)dismissPosition:(NSInteger)index {
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:[self.model videoIndexForFeedIndex:index] inSection:0];
    self.videoPlayerAnimator.cellIndexPath = indexPath;
    
    if (IS_IPHONE) {
        [self.feedCollectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollDirectionVertical animated:NO];
    } else {
        [self scrollToItemAtIndex:index];
    }
}

- (void)scrollToItemAtIndex:(NSInteger)index {
    int height = 0;
    if (UIDeviceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
        height = heightPortrait;
    } else {
        height = heightLandscape;
    }
    
    NSInteger point = ([self.model videoIndexForFeedIndex:index] / 3) * height;
    [self.feedCollectionView setContentOffset:CGPointMake(0, point) animated:NO];
}

- (IBAction)buttonTapped:(id)sender {
    [self setFeedWidgetItem];
}

- (void)setFeedWidgetItem {
    FeedItem *feedItem = [self.model feedItemAtindex:0];
    
    if (feedItem.resourceTypeValue == FeedItemResourceTypeVideo) {
        VideoInstance *videoInstance = [self.model resourceForFeedItem:feedItem];
        NSUserDefaults *mySharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.wonderapps"];
        
        NSDictionary *videoData = @{
                                    @"title":videoInstance.title,
                                    @"channelId":videoInstance.channel.uniqueId,
                                    @"videoId":videoInstance.uniqueId,
                                    @"userId":appDelegate.currentUser.uniqueId,
                                    @"thumbnailURL":videoInstance.thumbnailURL,
                                    @"videoDescription":videoInstance.video.videoDescription,
                                    @"linkURL":videoInstance.video.linkURL,
                                    @"linkTitle":videoInstance.video.linkTitle,
                                    @"label":videoInstance.label,
                                    @"channelOwnerName":videoInstance.channel.channelOwner.displayName,
                                    @"duration": [NSString friendlyLengthFromTimeInterval:videoInstance.video.durationValue]
                                    };
        
        [mySharedDefaults setBool:YES forKey:@"isVideo"];
        
        [mySharedDefaults setObject:videoInstance.title forKey:@"title"];
        [mySharedDefaults setObject:videoInstance.channel.uniqueId forKey:@"channelId"];
        [mySharedDefaults setObject:videoInstance.uniqueId forKey:@"videoId"];
        [mySharedDefaults setObject:videoInstance.channel.channelOwner.uniqueId forKey:@"channelOwnerId"];
        
        [mySharedDefaults setObject:appDelegate.currentUser.uniqueId forKey:@"userId"];
        [mySharedDefaults setObject:videoInstance.thumbnailURL forKey:@"thumbnailURL"];
        [mySharedDefaults setObject:videoInstance.video.videoDescription forKey:@"videoDescription"];
        [mySharedDefaults setObject:videoInstance.video.linkURL forKey:@"linkURL"];
        [mySharedDefaults setObject:videoInstance.video.linkTitle forKey:@"linkTitle"];
        
        [mySharedDefaults setObject:videoData forKey:@"videoData"];
        [mySharedDefaults synchronize];
    }
    
}

- (void)setChannelValuesForWidget:(Channel*)channel {
    NSUserDefaults *mySharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.wonderapps"];
    [mySharedDefaults setBool:NO forKey:@"isVideo"];
    
    BOOL followingChannel = [[SYNActivityManager sharedInstance] isSubscribedToChannelId:channel.uniqueId];
    NSDictionary *channelData = @{
                                  @"channelTitle":channel.title,
                                  @"channelId":channel.uniqueId,
                                  @"userId":appDelegate.currentUser.uniqueId,
                                  @"channelOwnerDisplayName":channel.channelOwner.displayName,
                                  @"channelOwnerId":channel.channelOwner.uniqueId,
                                  @"avatarURL":channel.channelOwner.thumbnailURL,
                                  @"followingChannel": [NSNumber numberWithBool:followingChannel]
                                  };
    
    [mySharedDefaults setObject:channel.title forKey:@"channelTitle"];
    [mySharedDefaults setObject:channel.channelOwner.thumbnailURL forKey:@"avatarURL"];
    [mySharedDefaults setObject:channel.uniqueId forKey:@"channelId"];
    [mySharedDefaults setObject:appDelegate.currentUser.uniqueId forKey:@"userId"];
    [mySharedDefaults setObject:channel.channelOwner.displayName forKey:@"channelOwnerDisplayName"];
    [mySharedDefaults setObject:channel.channelOwner.uniqueId forKey:@"channelOwnerId"];
    [mySharedDefaults setBool:followingChannel forKey:@"followingChannel"];
    [mySharedDefaults setObject:channelData forKey:@"channelData"];
}

- (FeedItem*) firstVideoFeedItem {
    for (int i = 0; i < self.model.itemCount; i++) {
        FeedItem* feedItem = [self.model itemAtIndex:i];
        if (feedItem.resourceTypeValue == FeedItemResourceTypeVideo) {
            return feedItem;
        }
    }
    
    return nil;
}

@end
