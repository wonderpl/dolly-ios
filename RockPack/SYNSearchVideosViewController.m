//
//  SYNSearchRootViewController.m
//  rockpack
//
//  Created by Michael Michailidis on 27/02/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import "Channel.h"
#import "ChannelOwner.h"
#import "GAI.h"
#import "MKNetworkOperation.h"
#import "NSDate-Utilities.h"
#import "SYNAppDelegate.h"
#import "SYNDeviceManager.h"
#import "SYNIntegralCollectionViewFlowLayout.h"
#import "SYNMasterViewController.h"
#import "SYNOAuthNetworkEngine.h"
#import "SYNSearchRootViewController.h"
#import "SYNSearchTabView.h"
#import "SYNSearchVideosViewController.h"
#import "SYNVideoThumbnailRegularCell.h"
#import "SYNVideoThumbnailWideCell.h"
#import "UIImageView+WebCache.h"
#import "Video.h"
#import "SYNFeedMessagesView.h"
#import "VideoInstance.h"

@interface SYNSearchVideosViewController ()

@property (nonatomic, assign) BOOL isIPhone;
@property (nonatomic, strong) NSCalendar *currentCalendar;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, weak) MKNetworkOperation *runningSearchOperation;
@property (nonatomic, weak) NSString *searchTerm;
@property (nonatomic, strong) SYNFeedMessagesView* emptyGenreMessageView;
@end


@implementation SYNSearchVideosViewController

// FIXME: NOT QUITE SURE WHY THESE ARE REQUIRED
@synthesize dataRequestRange;


- (void) dealloc
{
    self.videoThumbnailCollectionView.delegate = self;
    self.videoThumbnailCollectionView.dataSource = self;
}


- (void) viewDidLoad
{
    [super viewDidLoad];
    
    // ==============================
    
    SYNIntegralCollectionViewFlowLayout *standardFlowLayout;
    UIEdgeInsets sectionInset;
    CGRect videoCollectionViewFrame, calculatedViewFrame;
    CGSize screenSize;
    CGFloat minimumLineSpacing;
    
    // Setup device dependent parametes/dimensions
    if (IS_IPHONE)
    {
        // Calculate frame size
        screenSize = CGSizeMake([SYNDeviceManager.sharedInstance currentScreenWidth], [SYNDeviceManager.sharedInstance currentScreenHeight]);
        
        calculatedViewFrame = CGRectMake(0.0, 0.0, screenSize.width, screenSize.height - 20.0f);
        
        videoCollectionViewFrame = CGRectMake(0.0, kStandardCollectionViewOffsetYiPhone, screenSize.width, screenSize.height - 20.0f - kStandardCollectionViewOffsetYiPhone);
        
        
        sectionInset = UIEdgeInsetsMake(0.0f, 5.0f, 15.0f, 5.0f);
        minimumLineSpacing = 10.0f;
    }
    else
    {
        calculatedViewFrame = CGRectMake(0.0, 0.0,
                                         [[SYNDeviceManager sharedInstance] currentScreenWidth],
                                         [[SYNDeviceManager sharedInstance] currentScreenHeightWithStatusBar]);
        
        CGFloat adjustmentY = 0;
        
        if (IS_IOS_7_OR_GREATER)
            adjustmentY = 15.0f;
        
        videoCollectionViewFrame = CGRectMake(0.0,
                                              kStandardCollectionViewOffsetY + 40.0f + adjustmentY,
                                              [[SYNDeviceManager sharedInstance] currentScreenWidth],
                                              [[SYNDeviceManager sharedInstance] currentScreenHeightWithStatusBar] - kStandardCollectionViewOffsetY - 36.0f - adjustmentY);
        
        
        sectionInset = UIEdgeInsetsMake(0.0f, 10.0f, 15.0f, 10.0f);
        minimumLineSpacing = 30.0f;
    }
    
    // Set our view frame and attributes
    self.view.frame = calculatedViewFrame;
    self.view.backgroundColor = [UIColor clearColor];
    
    // Setup out collection view layout
    standardFlowLayout = [SYNIntegralCollectionViewFlowLayout layoutWithItemSize: self.videoCellSize
                                                         minimumInterItemSpacing: 0.0f
                                                              minimumLineSpacing: minimumLineSpacing
                                                                 scrollDirection: UICollectionViewScrollDirectionVertical
                                                                    sectionInset: sectionInset];
    standardFlowLayout.footerReferenceSize = [self footerSize];
    
    // Setup the collection view itself
    self.videoThumbnailCollectionView = [[UICollectionView alloc] initWithFrame: videoCollectionViewFrame
                                                           collectionViewLayout: standardFlowLayout];
    
    self.videoThumbnailCollectionView.delegate = self;
    self.videoThumbnailCollectionView.dataSource = self;
    self.videoThumbnailCollectionView.backgroundColor = [UIColor clearColor];
    self.videoThumbnailCollectionView.scrollsToTop = NO;
    self.videoThumbnailCollectionView.contentInset = UIEdgeInsetsZero;
    self.videoThumbnailCollectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    [self.view addSubview: self.videoThumbnailCollectionView];
    
    
    self.videoThumbnailCollectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    // Register collection view cells
    UINib *videoThumbnailCellNib = [UINib nibWithNibName: @"SYNVideoThumbnailWideCell"
                                                  bundle: nil];
    
    [self.videoThumbnailCollectionView registerNib: videoThumbnailCellNib
                        forCellWithReuseIdentifier: @"SYNVideoThumbnailWideCell"];
    
    // Register collection view header view
    UINib *headerViewNib = [UINib nibWithNibName: @"SYNHomeSectionHeaderView"
                                          bundle: nil];
    
    [self.videoThumbnailCollectionView registerNib: headerViewNib
                        forSupplementaryViewOfKind: UICollectionElementKindSectionHeader
                               withReuseIdentifier: @"SYNHomeSectionHeaderView"];
    
    // Register Footer
    UINib *footerViewNib = [UINib nibWithNibName: @"SYNChannelFooterMoreView"
                                          bundle: nil];
    
    [self.videoThumbnailCollectionView registerNib: footerViewNib
                        forSupplementaryViewOfKind: UICollectionElementKindSectionFooter
                               withReuseIdentifier: @"SYNChannelFooterMoreView"];
    
    
    
    // We should only setup our date formatter once
    self.dateFormatter = [[NSDateFormatter alloc] init];
    self.dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss Z";
    
    // Log
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(videoQueueCleared)
                                                 name: kVideoQueueClear
                                               object: nil];
    
    // =============================
    
    self.isIPhone = IS_IPHONE;
    
    if (self.isIPhone)
    {
        CGRect collectionFrame = self.videoThumbnailCollectionView.frame;
        collectionFrame.origin.y += 40.0;
        collectionFrame.size.width = [SYNDeviceManager.sharedInstance currentScreenWidth];
        collectionFrame.size.height = [SYNDeviceManager.sharedInstance currentScreenHeight] - 190.0;
        self.videoThumbnailCollectionView.frame = collectionFrame;
    }
    else
    {
        
        
    }
    
    CGRect videoThumbFrame = self.videoThumbnailCollectionView.frame;
    videoThumbFrame.size.height -= 4.0;
    self.videoThumbnailCollectionView.frame = videoThumbFrame;
    
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    self.currentCalendar = [NSCalendar currentCalendar];
}


- (CGSize) videoCellSize
{
    if (IS_IPHONE)
    {
        return CGSizeMake(310, 221);
    }
    else if ([SYNDeviceManager.sharedInstance isLandscape])
    {
        return CGSizeMake(497, 140);
    }
    else
    {
        return CGSizeMake(370, 140);
    }
}


- (void) viewWillAppear: (BOOL) animated
{
    [super viewWillAppear: animated];
    
    
    [self removeEmptyGenreMessage];
}


- (void) removeEmptyGenreMessage
{
    if (!self.emptyGenreMessageView)
        return;
    
    [self.emptyGenreMessageView removeFromSuperview];
}


- (void) displayEmptyGenreMessage: (NSString*) messageKey
                        andLoader: (BOOL) isLoader
{
    
    if (self.emptyGenreMessageView)
    {
        [self.emptyGenreMessageView removeFromSuperview];
        self.emptyGenreMessageView = nil;
    }
    
    self.emptyGenreMessageView = [SYNFeedMessagesView withMessage:NSLocalizedString(messageKey ,nil) andLoader:isLoader];
    
    CGRect messageFrame = self.emptyGenreMessageView.frame;
    messageFrame.origin.y = ([[SYNDeviceManager sharedInstance] currentScreenHeight] * 0.5) - (messageFrame.size.height * 0.5) - self.view.frame.origin.y;
    messageFrame.origin.x = ([[SYNDeviceManager sharedInstance] currentScreenWidth] * 0.5) - (messageFrame.size.width * 0.5);
    
    messageFrame = CGRectIntegral(messageFrame);
    self.emptyGenreMessageView.frame = messageFrame;
    self.emptyGenreMessageView.autoresizingMask =
    UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
    
    [self.view addSubview: self.emptyGenreMessageView];
}


- (NSFetchedResultsController *) fetchedResultsController
{
    if (fetchedResultsController != nil)
    {
        return fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    
    fetchRequest.entity = [NSEntityDescription entityForName: @"VideoInstance"
                                      inManagedObjectContext: self.appDelegate.searchManagedObjectContext];
    
    
    [fetchRequest setPredicate: [NSPredicate predicateWithFormat: @"viewId == %@", self.viewId]];
    
    fetchRequest.sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey: @"position"
                                                                 ascending: YES]];
    
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest: fetchRequest
                                                                        managedObjectContext: appDelegate.searchManagedObjectContext
                                                                          sectionNameKeyPath: nil
                                                                                   cacheName: nil];
    fetchedResultsController.delegate = self;
    
    
    
    NSError *error = nil;
    
    if (![fetchedResultsController performFetch: &error])
    {
        AssertOrLog(@"Search Videos Fetch Request Failed: %@\n%@", [error localizedDescription], [error userInfo]);
    }
    
    return fetchedResultsController;
}


- (void) performNewSearchWithTerm: (NSString *) term
{
    if (!appDelegate)
    {
        appDelegate = (SYNAppDelegate *) [[UIApplication sharedApplication] delegate];
    }
    
    [self removeEmptyGenreMessage];
    
    [self displayEmptyGenreMessage:@"Searching for Videos" andLoader:YES];
    
    self.dataRequestRange = NSMakeRange(0, kAPIInitialBatchSize);
    
    
    self.runningSearchOperation = [self.appDelegate.networkEngine searchVideosForTerm: term
                                                                              inRange: self.dataRequestRange
                                                                           onComplete: ^(int itemsCount) {
                                                                               self.dataItemsAvailable = itemsCount;
                                                                               
                                                                               if (self.itemToUpdate)
                                                                               {
                                                                                   [self.itemToUpdate
                                                                                    setNumberOfItems: self.dataItemsAvailable
                                                                                    animated: YES];
                                                                               }
                                                                               
                                                                               [self removeEmptyGenreMessage];
                                                                               
                                                                               if (itemsCount == 0)
                                                                               {
                                                                                   [self displayEmptyGenreMessage:[NSString stringWithFormat:@"There are no videos called '%@'",term] andLoader:NO];
                                                                               }
                                                                           }];
    self.searchTerm = term;
}


- (void) controllerDidChangeContent: (NSFetchedResultsController *) controller
{
    //    DebugLog(@"Total Search Items: %i", controller.fetchedObjects.count);
    
    [self.videoThumbnailCollectionView reloadData];
}


#pragma mark - Collection View Delegate

- (NSInteger) numberOfSectionsInCollectionView: (UICollectionView *) collectionView
{
    return 1;
}


- (NSInteger) collectionView: (UICollectionView *) collectionView numberOfItemsInSection: (NSInteger) section
{
    return self.fetchedResultsController.fetchedObjects.count;
}


- (UICollectionViewCell *) collectionView: (UICollectionView *) cv
                   cellForItemAtIndexPath: (NSIndexPath *) indexPath
{
    VideoInstance *videoInstance = [self.fetchedResultsController
                                    objectAtIndexPath: indexPath];
    
    SYNVideoThumbnailWideCell *videoThumbnailCell = [cv dequeueReusableCellWithReuseIdentifier: @"SYNVideoThumbnailWideCell"
                                                                                  forIndexPath: indexPath];
    
    videoThumbnailCell.displayMode = kVideoThumbnailDisplayModeYoutube;
    [videoThumbnailCell.videoImageView setImageWithURL: [NSURL URLWithString: videoInstance.video.thumbnailURL]
                                      placeholderImage: [UIImage imageNamed: @"PlaceholderVideoWide.png"]];
    
    videoThumbnailCell.videoTitle.text = videoInstance.title;
    videoThumbnailCell.videoInstance = videoInstance;
    
    Video *video = videoInstance.video;
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle: NSNumberFormatterDecimalStyle];
    NSString *viewsNumberString = [numberFormatter stringFromNumber: video.viewCount];
    
    videoThumbnailCell.numberOfViewLabel.text = [[NSString stringWithFormat: @"%@ views", viewsNumberString] uppercaseString];
    
    
    NSDateComponents *differenceDateComponents = [self.currentCalendar
                                                  components: (NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit)
                                                  fromDate: video.dateUploaded
                                                  toDate: [NSDate date]
                                                  options: 0];
    
    NSMutableString *format = [[NSMutableString alloc] init];
    
    if (differenceDateComponents.year > 0)
    {
        [format appendFormat: @"%i Year%@ Ago", differenceDateComponents.year, (differenceDateComponents.year > 1 ? @"s" : @"")];
    }
    else if (differenceDateComponents.month > 0)
    {
        [format appendFormat: @"%i Month%@ Ago", differenceDateComponents.month, (differenceDateComponents.month > 1 ? @"s" : @"")];
    }
    else if (differenceDateComponents.day > 1)
    {
        [format appendFormat: @"%i %@", differenceDateComponents.day, NSLocalizedString(@"Days Ago", nil)];
    }
    else if (differenceDateComponents.day > 0)
    {
        [format appendString: NSLocalizedString(@"Yesterday", nil)];
    }
    else
    {
        [format appendString: NSLocalizedString(@"Today", nil)];
    }
    
    if (self.isIPhone)
    {
        //On iPhone, append You Tube User name to the date label
        videoThumbnailCell.dateAddedLabel.text = [NSString stringWithFormat: @"%@ By %@", format , video.sourceUsername];
    }
    else
    {
        //On iPad a separate label is used for the youtube user name
        videoThumbnailCell.dateAddedLabel.text = format;
        videoThumbnailCell.youTubeUserLabel.text = [NSString stringWithFormat: @"By %@", video.sourceUsername];
    }
    
    NSUInteger hours = video.duration.integerValue / (60 * 60);
    NSUInteger minutes = ([video.duration integerValue] / 60) % 60;
    NSUInteger seconds = [video.duration integerValue] % 60;
    
    
    NSString *hoursString = [NSString stringWithFormat: @"%i", hours];
    NSString *minutesString = minutes > 9 ? [NSString stringWithFormat: @"%i", minutes] : [NSString stringWithFormat: @"0%i", minutes];
    NSString *secondsString = seconds > 9 ? [NSString stringWithFormat: @"%i", seconds] : [NSString stringWithFormat: @"0%i", seconds];
    
    if (hours > 0)
    {
        videoThumbnailCell.durationLabel.text = [NSString stringWithFormat: @"%@:%@:%@", hoursString, minutesString, secondsString];
    }
    else
    {
        videoThumbnailCell.durationLabel.text = [NSString stringWithFormat: @"%@:%@", minutesString, secondsString];
    }
    
    videoThumbnailCell.viewControllerDelegate = (id<SYNVideoThumbnailWideCellDelegate>) self;
    
    
    
    videoThumbnailCell.addItButton.highlighted = NO;
    videoThumbnailCell.addItButton.selected = [appDelegate.videoQueue videoInstanceIsAddedToChannel: videoInstance];
    
    
    
    return videoThumbnailCell;
}


- (CGSize) collectionView: (UICollectionView *) collectionView
                   layout: (UICollectionViewLayout *) collectionViewLayout
           referenceSizeForHeaderInSection: (NSInteger) section
{
    return CGSizeZero;
}


- (CGSize) collectionView: (UICollectionView *) collectionView
                   layout: (UICollectionViewLayout *) collectionViewLayout
   sizeForItemAtIndexPath: (NSIndexPath *) indexPath
{
    if (IS_IPAD)
        return ([SYNDeviceManager.sharedInstance isLandscape] ? CGSizeMake(497, 140) : CGSizeMake(370, 140));
    else
        return CGSizeMake(310, 221);
    
}

- (VideoInstance *) videoInstanceForIndexPath: (NSIndexPath *) indexPath
{
    return [self.fetchedResultsController objectAtIndexPath: indexPath];
}


- (void) willAnimateRotationToInterfaceOrientation: (UIInterfaceOrientation) toInterfaceOrientation
                                          duration: (NSTimeInterval) duration
{
    [super willAnimateRotationToInterfaceOrientation: toInterfaceOrientation
                                            duration: duration];
    
    
}


- (void) didRotateFromInterfaceOrientation: (UIInterfaceOrientation) fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation: fromInterfaceOrientation];
    
    [self.videoThumbnailCollectionView performBatchUpdates:nil completion:nil];
    [self reloadCollectionViews];
}


- (void) willRotateToInterfaceOrientation: (UIInterfaceOrientation) toInterfaceOrientation
                                 duration: (NSTimeInterval) duration
{
    [super willRotateToInterfaceOrientation: toInterfaceOrientation
                                   duration: duration];
    
}


- (void) loadMoreVideos
{
    if (self.moreItemsToLoad == TRUE)
    {
        self.loadingMoreContent = YES;
        
        [self incrementRangeForNextRequest];
        
        __weak typeof(self) weakSelf = self;
        
        [appDelegate.networkEngine searchVideosForTerm: self.searchTerm
                                               inRange: self.dataRequestRange
                                            onComplete: ^(int itemsCount) {
                                                weakSelf.dataItemsAvailable = itemsCount;
                                                weakSelf.loadingMoreContent = NO;
                                                [weakSelf.videoThumbnailCollectionView reloadData];
                                            }];
    }
}


//- (CGSize) footerSize
//{
//    return [SYNDeviceManager.sharedInstance isIPhone] ? CGSizeMake(320.0f, 64.0f) : CGSizeMake(1024.0, 64.0);
//}


- (SYNAppDelegate *) appDelegate
{
    if (!appDelegate)
    {
        appDelegate = (SYNAppDelegate *) [[UIApplication sharedApplication] delegate];
    }
    
    return appDelegate;
}


- (NSRange) dataRequestRange
{
    if (dataRequestRange.length == 0)
    {
        dataRequestRange = NSMakeRange(0, kAPIInitialBatchSize);
    }
    
    return dataRequestRange;
}


- (void) setRunningSearchOperation: (MKNetworkOperation *) runningSearchOperation
{
    if (_runningSearchOperation)
    {
        [_runningSearchOperation cancel];
    }
    
    _runningSearchOperation = runningSearchOperation;
}





- (void) videoButtonPressed: (UIView *) surfacePressed
{
    UIView *candidateCell = surfacePressed;
    
    while (![candidateCell isKindOfClass: [SYNVideoThumbnailWideCell class]])
    {
        candidateCell = candidateCell.superview;
    }
    
    SYNVideoThumbnailWideCell *selectedCell = (SYNVideoThumbnailWideCell *) candidateCell;
    NSIndexPath *indexPath = [self.videoThumbnailCollectionView indexPathForItemAtPoint: selectedCell.center];
    
    SYNMasterViewController *masterViewController = (SYNMasterViewController *) appDelegate.masterViewController;
    
    NSArray *videoInstancesToPlayArray = self.fetchedResultsController.fetchedObjects;
    
    [masterViewController addVideoOverlayToViewController: self
                                   withVideoInstanceArray: videoInstancesToPlayArray
                                         andSelectedIndex: indexPath.item
                                               fromCenter: self.view.center];
}


- (void) videoAddButtonTapped: (UIButton *) _addButton
{
    if (_addButton.selected)
    {
        return;
    }
    
    UIView *v = _addButton.superview.superview;
    NSIndexPath *indexPath = [self.videoThumbnailCollectionView indexPathForItemAtPoint: v.center];
    VideoInstance *videoInstance = [self.fetchedResultsController objectAtIndexPath: indexPath];
    
    if (videoInstance)
    {
        id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
        
        [tracker send: [[GAIDictionaryBuilder createEventWithCategory: @"uiAction"
                                                               action: @"videoPlusButtonClick"
                                                                label: nil
                                                                value: nil] build]];
        
        [appDelegate.oAuthNetworkEngine recordActivityForUserId: appDelegate.currentUser.uniqueId
                                                         action: @"select"
                                                videoInstanceId: videoInstance.uniqueId
                                              completionHandler: ^(id response) {
                                              }
                                                   errorHandler: ^(id error) {
                                                       DebugLog(@"Could not record videoAddButtonTapped: activity");
                                                   }];
        
        [[NSNotificationCenter defaultCenter] postNotificationName: kVideoQueueAdd
                                                            object: self
                                                          userInfo: @{@"VideoInstance": videoInstance}];
    }
    
    [self.videoThumbnailCollectionView reloadData];
    
    
    _addButton.selected = !_addButton.selected; // switch to on/off
}


- (void) videoQueueCleared
{
    // this will remove the '+' from the videos that where selected
    [self.videoThumbnailCollectionView reloadData];
}


#pragma mark - Infinite scrolling

- (void) scrollViewDidScroll: (UIScrollView *) scrollView
{
    // when reaching far right hand side, load a new page
    if (scrollView.contentOffset.y >= scrollView.contentSize.height - scrollView.bounds.size.height - kLoadMoreFooterViewHeight
        && self.isLoadingMoreContent == NO)
    {
        [self loadMoreVideos];
    }
}


-(EntityType)associatedEntity
{
    return EntityTypeVideoInstance;
}

- (UICollectionReusableView *) collectionView: (UICollectionView *) collectionView
            viewForSupplementaryElementOfKind: (NSString *) kind
                                  atIndexPath: (NSIndexPath *) indexPath
{
    UICollectionReusableView *supplementaryView;
    
    if (collectionView == self.videoThumbnailCollectionView)
    {
        if (kind == UICollectionElementKindSectionFooter)
        {
            self.footerView = [self.videoThumbnailCollectionView dequeueReusableSupplementaryViewOfKind: kind
                                                                                      withReuseIdentifier: @"SYNChannelFooterMoreView"
                                                                                             forIndexPath: indexPath];
            
            supplementaryView = self.footerView;
            
            if (self.fetchedResultsController.fetchedObjects.count > 0)
            {
                self.footerView.showsLoading = self.isLoadingMoreContent;
            }
        }
    }
    
    return supplementaryView;
}



@end
