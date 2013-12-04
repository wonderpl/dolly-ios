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
#import "SYNIntegralCollectionViewFlowLayout.h"
#import "SYNMasterViewController.h"
#import "SYNNetworkEngine.h"
#import "SYNOAuthNetworkEngine.h"
#import <UIButton+WebCache.h>
#import <UIImageView+WebCache.h>
#import "Video.h"
#import "VideoInstance.h"
#import "UICollectionReusableView+Helpers.h"

typedef void(^FeedDataErrorBlock)(void);

@interface SYNFeedRootViewController () 

@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) NSArray* feedItemsData;
@property (nonatomic, strong) NSDictionary* feedVideosById;
@property (nonatomic, strong) NSDictionary* feedChannelsById;
@property (nonatomic, strong) NSDictionary* feedItemByPosition;
@property (nonatomic, strong) IBOutlet UICollectionView* feedCollectionView;

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

    self.feedItemsData = @[];

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
                            action: @selector(loadAndUpdateOriginalFeedData)
                  forControlEvents: UIControlEventValueChanged];
    
    [self.feedCollectionView addSubview: self.refreshControl];
}


- (void) viewWillAppear: (BOOL) animated
{
    [super viewWillAppear: animated];

    // Google analytics support
    [self updateAnalytics];
}


- (void) viewDidAppear: (BOOL) animated {
	[super viewDidAppear: animated];

	[self loadAndUpdateFeedData];
}


#pragma mark - Container Scroll Delegates

- (void) updateAnalytics
{
    // Google analytics support
    id tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set: kGAIScreenName
           value: @"Feed"];
    
    [tracker send: [[GAIDictionaryBuilder createAppView] build]];
}


- (void) willRotateToInterfaceOrientation: (UIInterfaceOrientation) toInterfaceOrientation
                                 duration: (NSTimeInterval) duration
{
    [super willRotateToInterfaceOrientation: toInterfaceOrientation
                                   duration: duration];
    
    // NOTE: WE might not need to reload, just invalidate the layout

    [self.feedCollectionView.collectionViewLayout invalidateLayout];
}


- (void) loadAndUpdateOriginalFeedData
{
    [self resetDataRequestRange];
    [self loadAndUpdateFeedData];
}


- (void) loadAndUpdateFeedData
{
    self.loadingMoreContent = YES;
    
    if (!appDelegate.currentOAuth2Credentials.userId)
    {
        return;
    }

    __weak typeof(self) wself = self;
    
    FeedDataErrorBlock errorBlock = ^{
        
        [wself handleRefreshComplete];
        
        [wself removePopupMessage];
        
        if (wself.feedItemsData.count == 0)
        {
            [wself displayPopupMessage: NSLocalizedString(@"feed_screen_loading_error", nil)
                            withLoader: NO];
        }
        else
        {
            [wself displayPopupMessage: NSLocalizedString(@"feed_screen_updating_error", nil)
                            withLoader: NO];
        }
        
        self.loadingMoreContent = NO;
        
        DebugLog(@"Refresh subscription updates failed");
    };
    
    [appDelegate.oAuthNetworkEngine feedUpdatesForUserId: appDelegate.currentOAuth2Credentials.userId
                                                   start: self.dataRequestRange.location
                                                    size: self.dataRequestRange.length
                                       completionHandler: ^(NSDictionary *responseDictionary) {
                                           BOOL toAppend = (self.dataRequestRange.location > 0);

                                           NSDictionary *contentItems = responseDictionary[@"content"];
                                           
                                           if (!contentItems || ![contentItems isKindOfClass: [NSDictionary class]])
                                           {
                                               errorBlock();
                                               
                                               return;
                                           }
                                           
                                           [appDelegate.mainRegistry performInBackground: ^BOOL (NSManagedObjectContext *backgroundContext) {
                                               BOOL result = [appDelegate.mainRegistry
                                                              registerDataForSocialFeedFromItemsDictionary: contentItems
                                                              byAppending: toAppend];
                                               
                                               return result;
                                           } completionBlock: ^(BOOL registryResultOk) {
                                               NSNumber *totalNumber = [contentItems[@"total"]
                                                                        isKindOfClass: [NSNumber class]] ? contentItems[@"total"] : @0;
                                               wself.dataItemsAvailable = [totalNumber integerValue];
                                               
                                               if (!registryResultOk)
                                               {
                                                   DebugLog(@"Refresh subscription updates failed");
                                                   errorBlock();
                                               }
                                               
                                               [wself removePopupMessage];
                                               
                                               [wself fetchAndDisplayFeedItems];
                                               
                                               wself.loadingMoreContent = NO;
                                               
                                               [wself handleRefreshComplete];
                                               
                                               if (wself.dataItemsAvailable == 0)
                                               {
                                                   [wself displayPopupMessage: NSLocalizedString(@"feed_screen_empty_message", nil)
                                                                   withLoader: NO];
                                               }
                                           }];
                                       } errorHandler: ^(NSDictionary *errorDictionary) {
                                           errorBlock();
                                       }];
}


- (void) handleRefreshComplete
{
    [self.refreshControl endRefreshing];
}


- (void) clearedLocationBoundData
{
    // to clear
    [self fetchAndDisplayFeedItems];
    
    [self.feedCollectionView reloadData];
    
    [self loadAndUpdateFeedData];
}


#pragma mark - Fetch Feed Data

- (void) fetchAndDisplayFeedItems
{
    [self fetchVideoItems];
    [self fetchChannelItems];
    
	NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[FeedItem entityName]];
	
    // if the aggregate has a parent FeedItem then it should NOT be displayed since it is going to be part of an aggregate...
    NSPredicate* predicate = [NSPredicate predicateWithFormat: [NSString stringWithFormat: @"viewId == \"%@\" AND aggregate == nil", self.viewId]]; // kFeedViewId
 
    fetchRequest.predicate = predicate;

    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey: @"dateAdded" ascending: NO],
                                     [NSSortDescriptor sortDescriptorWithKey: @"position" ascending: YES]];
    
    NSError* error;
    
    NSArray *resultsArray = [appDelegate.mainManagedObjectContext executeFetchRequest: fetchRequest
                                                                                error: &error];
    if (!resultsArray)
        return;
	
	self.feedItemsData = resultsArray;
    [self.feedCollectionView reloadData];
}


- (void) fetchVideoItems
{
	NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[VideoInstance entityName]];
    
    NSPredicate* predicate = [NSPredicate predicateWithFormat: [NSString stringWithFormat:@"viewId == \"%@\"", self.viewId]]; // kFeedViewId
    
    fetchRequest.predicate = predicate;
    
//    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey: @"position"
//                                                                     ascending: YES];
//    fetchRequest.sortDescriptors = @[sortDescriptor];
    
    NSError* error;
    NSArray *resultsArray = [appDelegate.mainManagedObjectContext executeFetchRequest: fetchRequest
                                                                                error: &error];
    
    if (!resultsArray)
        return;
    
    NSMutableDictionary* mutDictionary = [[NSMutableDictionary alloc] initWithCapacity:resultsArray.count];
    
    for (VideoInstance* vi in resultsArray) {
        mutDictionary[vi.uniqueId] = vi;
    }
    
    self.feedVideosById = [NSDictionary dictionaryWithDictionary: mutDictionary];
}


- (void) fetchChannelItems
{
	NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[Channel entityName]];
    
    NSPredicate* predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"viewId == \"%@\"", self.viewId]]; // kFeedViewId
    
    fetchRequest.predicate = predicate;
    
    NSError* error;
    NSArray *resultsArray = [appDelegate.mainManagedObjectContext executeFetchRequest: fetchRequest error: &error];
    if (!resultsArray)
        return;
    
    NSMutableDictionary* mutDictionary = [[NSMutableDictionary alloc] initWithCapacity:resultsArray.count];
    for (Channel* ch in resultsArray) {
        mutDictionary[ch.uniqueId] = ch;
    }
    
    self.feedChannelsById = [NSDictionary dictionaryWithDictionary:mutDictionary];
}


#pragma mark - UICollectionView Delegate/Data Source

- (NSInteger) numberOfSectionsInCollectionView: (UICollectionView *) collectionView {
	return 1;
}


- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger) section {
	return [self.feedItemsData count];
}


- (UICollectionViewCell *) collectionView: (UICollectionView *) cv
                   cellForItemAtIndexPath: (NSIndexPath *) indexPath
{
    // common types
    SYNAggregateCell *cell = nil;
    
    FeedItem* feedItem = [self feedItemAtIndexPath: indexPath];
    
    ChannelOwner* channelOwner;
    
    // there are 2 types, video and channel (collection) types
    
    if (feedItem.resourceTypeValue == FeedItemResourceTypeVideo)
    {
        cell = [cv dequeueReusableCellWithReuseIdentifier:[SYNAggregateVideoCell reuseIdentifier]
                                             forIndexPath:indexPath];
        
        NSMutableArray* videosArray = [NSMutableArray array];
        
        // NOTE: the data containes either an aggragate or a single item, handle both cases here
        if (feedItem.itemTypeValue == FeedItemTypeAggregate)
        {
            for (FeedItem* childFeedItem in feedItem.feedItems)
            {
                // they have also the same type (video)
                VideoInstance* vi = (VideoInstance*)((self.feedVideosById)[childFeedItem.resourceId]);
                [videosArray addObject:vi];
                channelOwner = vi.channel.channelOwner; // will get the last (to avoid conditionals) as a heuristic but they all should belong to the same channel
            }
        }
        else
        {
            VideoInstance* vi = (VideoInstance*)((self.feedVideosById)[feedItem.resourceId]);
            [videosArray addObject:vi];
            channelOwner = vi.channel.channelOwner;
        }
        
        cell.collectionData = videosArray;
    }
    else if (feedItem.resourceTypeValue == FeedItemResourceTypeChannel)
    {
        cell = [cv dequeueReusableCellWithReuseIdentifier:[SYNAggregateChannelCell reuseIdentifier]
                                             forIndexPath:indexPath];
        
        Channel* channel;
        
        NSMutableArray* channelsMutArray = [NSMutableArray array];
        
        // NOTE: the data containes either an aggragate or a single item, handle both cases here
        if (feedItem.itemTypeValue == FeedItemTypeAggregate)
        {
            for (FeedItem* childFeedItem in feedItem.feedItems)
            {
                channel = (Channel*)(self.feedChannelsById[childFeedItem.resourceId]);
                [channelsMutArray addObject:channel];
            }
        }
        else
        {
            channel = (Channel*)(self.feedChannelsById)[feedItem.resourceId];
            [channelsMutArray addObject:channel];
        }
        
        cell.collectionData = [NSArray arrayWithArray:channelsMutArray];
        
        channelOwner = channel.channelOwner;
        
    }
    
    // common for both types
    cell.delegate = self;
    
    [cell.userThumbnailButton setImageWithURL: [NSURL URLWithString: channelOwner.thumbnailURL]
                                     forState: UIControlStateNormal
                             placeholderImage: [UIImage imageNamed: @"PlaceholderChannelSmall.png"]
                                      options: SDWebImageRetryFailed];

    return cell;
}


- (CGSize)	collectionView: (UICollectionView *) collectionView
                    layout: (UICollectionViewLayout *) collectionViewLayout
    sizeForItemAtIndexPath: (NSIndexPath *) indexPath
{
    FeedItem *feedItem = [self feedItemAtIndexPath: indexPath];
    CGSize size;
    
    if (feedItem.resourceTypeValue == FeedItemResourceTypeVideo)
    {
        size.width = IS_IPAD ? 927.0f : 320.0f;
        size.height = IS_IPAD ? 457.0f : 369.0f;
    }
    else
    {
        if (SYNDeviceManager.sharedInstance.isPortrait)
        {
            size.width = IS_IPAD ? 671.0f : 320.0f;
            size.height = IS_IPAD ? 330.0f : 264.0f;
        }
        else
        {
            size.width = IS_IPAD ? 927.0f : 320.0f;
            size.height = IS_IPAD ? 330.0f : 264.0f;
        }
    }
    
    return size;
}


- (CGSize) collectionView: (UICollectionView *) collectionView
                   layout: (UICollectionViewLayout*) collectionViewLayout
                   referenceSizeForFooterInSection: (NSInteger) section
{
    if ((self.dataRequestRange.location + self.dataRequestRange.length < self.dataItemsAvailable)) {
		return [self footerSize];
	}
    return CGSizeZero;
}


// Used for the collection view header
- (UICollectionReusableView *) collectionView: (UICollectionView *) collectionView
            viewForSupplementaryElementOfKind: (NSString *) kind
                                  atIndexPath: (NSIndexPath *) indexPath
{
    UICollectionReusableView *supplementaryView = nil;
	if (kind == UICollectionElementKindSectionFooter)
    {
        self.footerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                             withReuseIdentifier:[SYNChannelFooterMoreView reuseIdentifier]
                                                                    forIndexPath:indexPath];
        supplementaryView = self.footerView;
        
        if ((self.dataRequestRange.location + self.dataRequestRange.length) < self.dataItemsAvailable) {
            self.footerView.showsLoading = self.isLoadingMoreContent;
        }
    }

    return supplementaryView;
}


#pragma mark - Helper Methods to get AggreagateCell's Data

- (FeedItem *)feedItemAtIndexPath:(NSIndexPath*) indexPath {
    return self.feedItemsData[indexPath.row];
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
	
	Channel *channel = [self channelForFeedItem:feedItem];

	[self viewProfileDetails:channel.channelOwner];
}


- (IBAction) channelButtonTapped: (UIButton *) channelButton {
	FeedItem *feedItem = [self feedItemFromView: channelButton];
	
	[self viewChannelDetails:[self channelForFeedItem:feedItem]];
}

- (Channel *)channelForFeedItem:(FeedItem *)feedItem {
	FeedItem *actualFeedItem = feedItem;
	if (feedItem.itemTypeValue == FeedItemTypeAggregate) {
		actualFeedItem = [feedItem.feedItems anyObject];
	}
	
	Channel *channel = nil;
	if (actualFeedItem.resourceTypeValue == FeedItemResourceTypeVideo) {
		VideoInstance *videoInstance = self.feedVideosById[actualFeedItem.resourceId];
		channel = videoInstance.channel;
	} else if (actualFeedItem.resourceTypeValue == FeedItemResourceTypeChannel) {
		channel = self.feedChannelsById[actualFeedItem.resourceId];
	}
	return channel;
}

- (void)displayVideoViewerFromCell:(UICollectionViewCell *)cell
						andSubCell:(UICollectionViewCell *)subCell
					atSubCellIndex:(NSInteger)subCellIndex
{
    NSMutableArray *videosArray = [NSMutableArray array];
	
	NSIndexPath *indexPath = [self.feedCollectionView indexPathForCell:cell];
	
	for (FeedItem *feedItem in self.feedItemsData) {
		if (feedItem.resourceTypeValue == FeedItemResourceTypeVideo) {
			if (feedItem.itemTypeValue == FeedItemTypeAggregate) {
				for (FeedItem *childFeedItem in feedItem.feedItems) {
					[videosArray addObject:self.feedVideosById[childFeedItem.resourceId]];
				}
			} else {
				[videosArray addObject:self.feedVideosById[feedItem.resourceId]];
			}
		}
	}
	
	CGPoint center = (subCell ? [self.view convertPoint:subCell.center fromView:subCell.superview] : self.view.center);
	
	[self displayVideoViewerWithVideoInstanceArray:videosArray
								  andSelectedIndex:[self videoIndexForIndexPath:indexPath subCellIndex:subCellIndex]
											center:center];
}

- (NSInteger)videoIndexForIndexPath:(NSIndexPath *)indexPath subCellIndex:(NSInteger)subCellIndex {
	__block NSInteger index = 0;
	[self.feedItemsData enumerateObjectsUsingBlock:^(FeedItem *feedItem, NSUInteger idx, BOOL *stop) {
		if (idx >= indexPath.row) {
			*stop = YES;
			return;
		}
		if (feedItem.resourceTypeValue == FeedItemResourceTypeVideo) {
			index += feedItem.itemCountValue;
		}
	}];
	return index + subCellIndex;
}

#pragma mark - Load More Footer

- (void) loadMoreVideos
{
    if (self.moreItemsToLoad == YES)
    {
        [self incrementRangeForNextRequest];
        [self loadAndUpdateFeedData];
    }
}


- (void) scrollViewDidScroll: (UIScrollView *) scrollView
{
    [super scrollViewDidScroll:scrollView];
    
    if (scrollView.contentOffset.y >= scrollView.contentSize.height - scrollView.bounds.size.height - kLoadMoreFooterViewHeight &&
        self.isLoadingMoreContent == NO &&
        self.moreItemsToLoad == YES)
    {
        
        [self loadMoreVideos];
        
    }
}


- (void) applicationWillEnterForeground: (UIApplication *) application
{
    // set the data request range back to 0, 48 and refresh
    [super applicationWillEnterForeground: application];
    
    [self loadAndUpdateFeedData];
}


@end
