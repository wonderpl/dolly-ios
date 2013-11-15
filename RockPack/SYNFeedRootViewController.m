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
#import "NSDate-Utilities.h"
#import "SYNAggregateCell.h"
#import "SYNAggregateChannelCell.h"
#import "SYNAggregateVideoCell.h"
#import "SYNAppDelegate.h"
#import "SYNDeviceManager.h"
#import "SYNFeedRootViewController.h"
#import "SYNHomeSectionHeaderView.h"
#import "SYNIntegralCollectionViewFlowLayout.h"
#import "SYNMasterViewController.h"
#import "SYNNetworkEngine.h"
#import "SYNOAuthNetworkEngine.h"
#import "UIButton+WebCache.h"
#import "UIImageView+WebCache.h"
#import "Video.h"
#import "VideoInstance.h"

typedef void(^FeedDataErrorBlock)(void);

@interface SYNFeedRootViewController () 

@property (nonatomic, assign) BOOL refreshing;
@property (nonatomic, assign) BOOL shouldReloadCollectionView;
@property (nonatomic, strong) NSBlockOperation *blockOperation;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, weak)   SYNAggregateVideoCell* selectedVideoCell;
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
    [self.feedCollectionView registerNib: [UINib nibWithNibName: @"SYNAggregateVideoCell" bundle: nil]
              forCellWithReuseIdentifier: @"SYNAggregateVideoCell"];
    
    [self.feedCollectionView registerNib: [UINib nibWithNibName: @"SYNAggregateChannelCell" bundle: nil]
              forCellWithReuseIdentifier: @"SYNAggregateChannelCell"];
    
#ifdef SHOW_DATE_HEADERS
    [self.feedCollectionView registerNib: [UINib nibWithNibName: @"SYNHomeSectionHeaderView" bundle: nil]
              forSupplementaryViewOfKind: UICollectionElementKindSectionHeader
                     withReuseIdentifier: @"SYNHomeSectionHeaderView"];
#endif

    [self.feedCollectionView registerNib: [UINib nibWithNibName: @"SYNChannelFooterMoreView" bundle: nil]
              forSupplementaryViewOfKind: UICollectionElementKindSectionFooter
                     withReuseIdentifier: @"SYNChannelFooterMoreView"];
    
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
    
    // We should only setup our date formatter once
    self.dateFormatter = [[NSDateFormatter alloc] init];
    self.dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss Z";
}


- (void) viewWillAppear: (BOOL) animated
{
    [super viewWillAppear: animated];

    // Google analytics support
    [self updateAnalytics];
}


- (void) viewDidAppear: (BOOL) animated
{
    [super viewDidAppear: animated];
    
    if ([self class] == [SYNFeedRootViewController class])
    {
        [self loadAndUpdateFeedData];
    }
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
            
            [NSTimer scheduledTimerWithTimeInterval: 3.0f
                                             target: self
                                           selector: @selector(removeEmptyGenreMessage)
                                           userInfo: nil
                                            repeats: NO];
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
    self.refreshing = NO;
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
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    // Edit the entity name as appropriate.
    fetchRequest.entity = [NSEntityDescription entityForName: kFeedItem
                                      inManagedObjectContext: appDelegate.mainManagedObjectContext];
    
    // if the aggregate has a parent FeedItem then it should NOT be displayed since it is going to be part of an aggregate...
    NSPredicate* predicate = [NSPredicate predicateWithFormat: [NSString stringWithFormat: @"viewId == \"%@\" AND aggregate == nil", self.viewId]]; // kFeedViewId
 
    fetchRequest.predicate = predicate;

    fetchRequest.sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey: @"dateAdded" ascending: NO],
                                     [[NSSortDescriptor alloc] initWithKey: @"position" ascending: YES]];
    
    NSError* error;
    
    NSArray *resultsArray = [appDelegate.mainManagedObjectContext executeFetchRequest: fetchRequest
                                                                                error: &error];
    if (!resultsArray)
        return;
    
    // sort results in categories
    if(resultsArray.count == 0)
    {
        self.feedItemsData = @[];
        [self.feedCollectionView reloadData];
        return;
    }
    
    NSMutableDictionary* buckets = [NSMutableDictionary dictionary];
    NSDate* dateNoTime;
    
    for (FeedItem* feedItem in resultsArray)
    {
        dateNoTime = [feedItem.dateAdded dateIgnoringTime];
        
        NSMutableArray* bucket = buckets[dateNoTime];
        if(!bucket) { // if the bucket has not been created already, create it
            bucket = [NSMutableArray array];
            buckets[dateNoTime] = bucket;
        }
            
        [bucket addObject:feedItem];
    }
    
    NSArray* sortedDateKeys = [[buckets allKeys] sortedArrayUsingComparator:^NSComparisonResult(NSDate* date1, NSDate* date2) {
        return [date2 compare:date1];
    }];
    
    NSMutableArray* sortedItemsArray = [NSMutableArray array];
    for (NSDate* dateKey in sortedDateKeys)
    {
        [sortedItemsArray addObject:buckets[dateKey]];
        
    }
    self.feedItemsData = sortedItemsArray;
    
    [self.feedCollectionView reloadData];
}


- (void) fetchVideoItems
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    // Edit the entity name as appropriate.
    fetchRequest.entity = [NSEntityDescription entityForName: kVideoInstance
                                      inManagedObjectContext: appDelegate.mainManagedObjectContext];
    
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
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    // Edit the entity name as appropriate.
    fetchRequest.entity = [NSEntityDescription entityForName: kChannel
                                      inManagedObjectContext: appDelegate.mainManagedObjectContext];
    
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

- (NSInteger) numberOfSectionsInCollectionView: (UICollectionView *) collectionView
{
    return self.feedItemsData.count; // the number of arrays included
}


- (NSInteger) collectionView: (UICollectionView *) collectionView
      numberOfItemsInSection: (NSInteger) section
{
    NSArray* sectionInfo = self.feedItemsData[section];
    return sectionInfo.count;
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
        cell = [cv dequeueReusableCellWithReuseIdentifier: @"SYNAggregateVideoCell"
                                             forIndexPath: indexPath];
        
        NSMutableArray* videosArray = @[].mutableCopy;
        
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
        cell = [cv dequeueReusableCellWithReuseIdentifier: @"SYNAggregateChannelCell"
                                             forIndexPath: indexPath];
        
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


#ifdef SHOW_DATE_HEADERS
- (CGSize) collectionView: (UICollectionView *) collectionView
                   layout: (UICollectionViewLayout *) collectionViewLayout
           referenceSizeForHeaderInSection: (NSInteger) section
{
    if (IS_IPAD)
    {
        return CGSizeMake(1024, 65);
    }
    else
    {
        return CGSizeMake(320, 34);
    }
}
#endif


- (CGSize) collectionView: (UICollectionView *) collectionView
                   layout: (UICollectionViewLayout*) collectionViewLayout
                   referenceSizeForFooterInSection: (NSInteger) section
{
    CGSize footerSize = CGSizeZero;
    
    if  (section == (self.feedItemsData.count - 1) && // only the last section can have a loader
        (self.dataRequestRange.location + self.dataRequestRange.length < self.dataItemsAvailable)) 
    {
        
        footerSize = [self footerSize];   
    }
    
    return footerSize;
}


// Used for the collection view header
- (UICollectionReusableView *) collectionView: (UICollectionView *) collectionView
            viewForSupplementaryElementOfKind: (NSString *) kind
                                  atIndexPath: (NSIndexPath *) indexPath
{
    UICollectionReusableView *supplementaryView = nil;
    
    // Work out the day
    // In the 'name' attribut of the sectionInfo we have actually the keypath data (i.e in this case Date without time)
    
    // TODO: We might want to optimise this instead of creating a new date formatter each time
#ifdef SHOW_DATE_HEADERS
    if (kind == UICollectionElementKindSectionHeader)
    {
        FeedItem* heuristicFeedItem = [self feedItemAtIndexPath:indexPath];
        NSDate* date = heuristicFeedItem.dateAdded;
        
        SYNHomeSectionHeaderView *headerSupplementaryView = [collectionView dequeueReusableSupplementaryViewOfKind: kind
                                                                                               withReuseIdentifier: @"SYNHomeSectionHeaderView"
                                                                                                      forIndexPath: indexPath];
        NSString *sectionText;
        
        // Unavoidably long if-then-else
        if ([date isToday])
        {
            sectionText = NSLocalizedString(@"TODAY", nil);
        }
        else if ([date isYesterday])
        {
            sectionText = NSLocalizedString(@"YESTERDAY", nil);
        }
        else if ([date isLast7Days])
        {
            sectionText = date.weekdayString;
        }
        else if ([date isThisYear])
        {
            sectionText = date.shortDateWithOrdinalString;
        }
        else
        {
            sectionText = date.shortDateWithOrdinalStringAndYear;
        }
        
        // Special case, remember the first section view
        headerSupplementaryView.viewControllerDelegate = self;
        headerSupplementaryView.sectionTitleLabel.text = sectionText.uppercaseString;
        
        if ([SYNDeviceManager.sharedInstance isLandscape])
        {
            headerSupplementaryView.sectionView.image = [UIImage imageNamed: @"PanelDay"];
        }
        else
        {
            headerSupplementaryView.sectionView.image = [UIImage imageNamed:@"PanelDayPortrait"];
        }
        
        supplementaryView = headerSupplementaryView;
    }
    else
#endif
    if (kind == UICollectionElementKindSectionFooter)
    {
        self.footerView = [collectionView dequeueReusableSupplementaryViewOfKind: kind
                                                             withReuseIdentifier: @"SYNChannelFooterMoreView"
                                                                    forIndexPath: indexPath];
        supplementaryView = self.footerView;
        
        // Show loading spinner if we have more datasection == )
        if ((indexPath.section == (self.feedItemsData.count - 1)) && // last item
            (self.dataRequestRange.location + self.dataRequestRange.length) < self.dataItemsAvailable)
        {
            self.footerView.showsLoading = self.isLoadingMoreContent;
        }
    }

    return supplementaryView;
}


- (void) videoOverlayDidDisappear
{
    [self.feedCollectionView reloadData];
}


#pragma mark - Helper Methods to get AggreagateCell's Data

- (FeedItem*) feedItemAtIndexPath: (NSIndexPath*) indexPath
{
    NSArray* sectionArray = self.feedItemsData[indexPath.section];
    FeedItem* feedItem = sectionArray[indexPath.row];
    return feedItem;
}


- (NSIndexPath *) indexPathForChannelCell: (UICollectionViewCell *) cell
{
    // Same mechanism as for video cell
    return  [self indexPathForVideoCell: cell];
}


- (NSIndexPath *) indexPathForVideoCell: (UICollectionViewCell *) cell
{
    NSIndexPath *indexPath = [self.feedCollectionView indexPathForItemAtPoint: cell.center];
    return indexPath;
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


- (void) profileButtonTapped: (UIButton *) profileButton
{
   FeedItem *feedItem = [self feedItemFromView: profileButton];
    
    ChannelOwner* channelOwner;
    
    // there are 2 types, video and channel (collection) types
    if (feedItem.resourceTypeValue == FeedItemResourceTypeVideo)
    {
        VideoInstance* vi;
        
        if (feedItem.itemTypeValue == FeedItemTypeAggregate)
        {
            FeedItem* firstChildFeedItem = feedItem.feedItems.anyObject;
            vi = (VideoInstance*)((self.feedVideosById)[firstChildFeedItem.resourceId]);
        }
        else
        {
            vi = (VideoInstance*)((self.feedVideosById)[feedItem.resourceId]);
        }
        
        channelOwner = vi.channel.channelOwner;
    }
    else if (feedItem.resourceTypeValue == FeedItemResourceTypeChannel)
    {
        Channel* channel;

        if (feedItem.itemTypeValue == FeedItemTypeAggregate)
        {
            FeedItem* firstChildFeedItem = feedItem.feedItems.anyObject;
            channel = (Channel*)(self.feedChannelsById[firstChildFeedItem.resourceId]);
        }
        else
        {
            channel = (Channel*)(self.feedChannelsById)[feedItem.resourceId];
        }

        channelOwner = channel.channelOwner;
    }
    
    [self viewProfileDetails: channelOwner];
}


- (IBAction) channelButtonTapped: (UIButton *) channelButton
{
    FeedItem *feedItem = [self feedItemFromView: channelButton];
    
    Channel* channel;
    
    // there are 2 types, video and channel (collection) types
    if (feedItem.resourceTypeValue == FeedItemResourceTypeVideo)
    {
        VideoInstance* vi;
        
        if (feedItem.itemTypeValue == FeedItemTypeAggregate)
        {
            FeedItem* firstChildFeedItem = feedItem.feedItems.anyObject;
            vi = (VideoInstance*)((self.feedVideosById)[firstChildFeedItem.resourceId]);
        }
        else
        {
            vi = (VideoInstance*)((self.feedVideosById)[feedItem.resourceId]);
        }
        
        channel = vi.channel;
    }
    else if (feedItem.resourceTypeValue == FeedItemResourceTypeChannel)
    {

        
        if (feedItem.itemTypeValue == FeedItemTypeAggregate)
        {
            FeedItem* firstChildFeedItem = feedItem.feedItems.anyObject;
            channel = (Channel*)(self.feedChannelsById[firstChildFeedItem.resourceId]);
        }
        else
        {
            channel = (Channel*)(self.feedChannelsById)[feedItem.resourceId];
        }
    }
    
	[self viewChannelDetails:channel];
}


- (void) displayVideoViewerFromCell: (UICollectionViewCell *) cell
                         andSubCell: (UICollectionViewCell *) subCell
                     atSubCellIndex: (NSInteger) subCellIndex
{
    NSMutableArray* videosArray = @[].mutableCopy;
    
    NSIndexPath * indexPath = [self.feedCollectionView indexPathForCell: cell];
    FeedItem* feedItem = [self feedItemAtIndexPath: indexPath];
    
    if (feedItem.resourceTypeValue == FeedItemResourceTypeVideo)
    {
        // NOTE: the data containes either an aggragate or a single item, handle both cases here
        if (feedItem.itemTypeValue == FeedItemTypeAggregate)
        {
            for (FeedItem *childFeedItem in feedItem.feedItems)
            {
                // they have also the same type (video)
                VideoInstance *vi = (VideoInstance *) ((self.feedVideosById)[childFeedItem.resourceId]);
                [videosArray addObject: vi];
            }
        }
        else
        {
            VideoInstance *vi = (VideoInstance *) ((self.feedVideosById)[feedItem.resourceId]);
            [videosArray addObject: vi];
        }

        CGPoint center;
        
        if (subCell)
        {
            center = [self.view convertPoint: subCell.center
                                    fromView: subCell.superview];
        }
        else
        {
            center = self.view.center;
        }
        
        [self displayVideoViewerWithVideoInstanceArray: videosArray
                                      andSelectedIndex: subCellIndex
                                                center: center];
    }
}


#pragma mark - Aggregate Cell Delegate

- (void) profileIconPressed: (UIButton *) sender
{
    SYNAggregateCell* cell = [self aggregateCellFromSubview: sender];
    if(!cell.channelOwner) // checking for both channel and channel owner
        return;
    
    [self viewProfileDetails: cell.channelOwner];
}


#pragma mark - Load More Footer

- (void) loadMoreVideos
{
    if (self.moreItemsToLoad == TRUE)
    {
        [self incrementRangeForNextRequest];
        [self loadAndUpdateFeedData];
    }
}


- (void) scrollViewDidScroll: (UIScrollView *) scrollView
{
    [super scrollViewDidScroll:scrollView];
    
    if (scrollView.contentOffset.y >= scrollView.contentSize.height - scrollView.bounds.size.height - kLoadMoreFooterViewHeight
        && self.isLoadingMoreContent == NO)
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
