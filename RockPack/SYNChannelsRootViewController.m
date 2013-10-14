//
//  SYNChannelsTopTabViewController.m
//  rockpack
//
//  Created by Nick Banks on 01/12/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import "AppConstants.h"
#import "Channel.h"
#import "ChannelCover.h"
#import "ChannelOwner.h"
#import "GAI.h"
#import "Genre.h"
#import "SYNAppDelegate.h"
#import "SYNChannelCategoryTableViewController.h"
#import "SYNChannelDetailViewController.h"
#import "SYNChannelThumbnailCell.h"
#import "SYNChannelsRootViewController.h"
#import "SYNDeviceManager.h"
#import "SYNFeedMessagesView.h"
#import "SYNGenreItemView.h"
#import "SYNIntegralCollectionViewFlowLayout.h"
#import "SYNMainRegistry.h"
#import "SYNNetworkEngine.h"
#import "SYNOAuthNetworkEngine.h"
#import "SubGenre.h"
#import "UIFont+SYNFont.h"
#import "SYNTrackableFrameView.h"
#import "UIImageView+WebCache.h"
#import "SYNInstructionsToShareControllerViewController.h"
#import "Video.h"
#import "VideoInstance.h"


#define kChannelsCache @"ChannelsCache"



@interface SYNChannelsRootViewController () <UIScrollViewDelegate,
                                             SYNChannelCategoryTableViewDelegate,
                                             SYNChannelThumbnailCellDelegate> {
    NSString* StartingCategoryText;
}

@property (nonatomic, assign) BOOL ignoreRefresh;
@property (nonatomic, strong) Genre *allGenre;
@property (nonatomic, strong) Genre *currentGenre;
@property (nonatomic, strong) NSMutableArray *channels;
@property (nonatomic, strong) NSString *currentCategoryId;
@property (nonatomic, strong) SYNChannelCategoryTableViewController *categoryTableViewController;
@property (nonatomic, strong) SYNFeedMessagesView *emptyGenreMessageView;
@property (nonatomic, strong) UIButton *categorySelectButton;
@property (nonatomic, strong) UIControl *categorySelectDismissControl;
@property (nonatomic, strong) UIImageView *arrowImage;
@property (nonatomic, strong) UILabel *categoryNameLabel;
@property (nonatomic, strong) UILabel *subCategoryNameLabel;
@property (nonatomic, weak) SYNMainRegistry *mainRegistry;

@end

@implementation SYNChannelsRootViewController

@synthesize dataRequestRange;
@synthesize dataItemsAvailable;
@synthesize channels;
@synthesize runningNetworkOperation = _runningNetworkOperation;


#pragma mark - Object lifecycle

- (void) dealloc
{
    // Defensive programming
    self.channelThumbnailCollectionView.delegate = nil;
    self.channelThumbnailCollectionView.dataSource = nil;
}


#pragma mark - View lifecycle

- (void) loadView
{
    
    
    StartingCategoryText  = NSLocalizedString(@"ALL PACKS", nil);
    
    
    SYNIntegralCollectionViewFlowLayout *flowLayout;
    
    if (IS_IPHONE)
    {
        flowLayout = [SYNIntegralCollectionViewFlowLayout layoutWithItemSize: CGSizeMake(158.0f, IS_IOS_7_OR_GREATER ? 172.0f : 169.0f)
                                                     minimumInterItemSpacing: 0.0
                                                          minimumLineSpacing: 6.0
                                                             scrollDirection: UICollectionViewScrollDirectionVertical
                                                                sectionInset: UIEdgeInsetsMake(2.0, 2.0, 46.0, 2.0)];
    }
    else
    {
        flowLayout = [SYNIntegralCollectionViewFlowLayout layoutWithItemSize: [self itemSize]
                                                     minimumInterItemSpacing: 0.0
                                                          minimumLineSpacing: 2.0
                                                             scrollDirection: UICollectionViewScrollDirectionVertical
                                                                sectionInset: UIEdgeInsetsMake(6.0, 6.0, 5.0, 6.0)];
    }
    
    flowLayout.footerReferenceSize = [self footerSize];
    
    // Work out how hight the inital tab bar is
    CGFloat topTabBarHeight = [UIImage imageNamed: @"CategoryBar"].size.height;
    
    CGRect channelCollectionViewFrame = CGRectZero;
    
    if (IS_IPHONE)
    {
        CGFloat offsetY = 103.0f;
        channelCollectionViewFrame = CGRectMake(0.0f,
                                                offsetY,
                                                [SYNDeviceManager.sharedInstance currentScreenWidth],
                                                [SYNDeviceManager.sharedInstance currentScreenHeightWithStatusBar] - offsetY);
    }
    else
    {
        channelCollectionViewFrame.origin.x = 0.0f;
        
        channelCollectionViewFrame.size.height = [SYNDeviceManager.sharedInstance currentScreenHeightWithStatusBar];
        
        channelCollectionViewFrame.origin.y = kStandardCollectionViewOffsetY + topTabBarHeight;
        channelCollectionViewFrame.size.height -= kStandardCollectionViewOffsetY;
        channelCollectionViewFrame.size.height -= topTabBarHeight;
        
        
        channelCollectionViewFrame.size.width = [SYNDeviceManager.sharedInstance currentScreenWidth];
        
    }
    
    self.channelThumbnailCollectionView = [[UICollectionView alloc] initWithFrame: channelCollectionViewFrame
                                                             collectionViewLayout: flowLayout];
    self.channelThumbnailCollectionView.dataSource = self;
    self.channelThumbnailCollectionView.delegate = self;
    self.channelThumbnailCollectionView.backgroundColor = [UIColor clearColor];
    self.channelThumbnailCollectionView.showsVerticalScrollIndicator = NO;
    
    self.channelThumbnailCollectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.channelThumbnailCollectionView.scrollsToTop = NO;
    
    CGRect newFrame;
    
    if (IS_IPHONE)
    {
        newFrame = CGRectMake(0.0f, 0.0f,
                              [SYNDeviceManager.sharedInstance currentScreenWidth],
                              [SYNDeviceManager.sharedInstance currentScreenHeightWithStatusBar]);
    }
    else
    {
        newFrame = [SYNDeviceManager.sharedInstance isLandscape] ?
        CGRectMake(0.0, 0.0, kFullScreenWidthLandscape, kFullScreenHeightLandscapeMinusStatusBar) :
        CGRectMake(0.0f, 0.0f, kFullScreenWidthPortrait, kFullScreenHeightPortraitMinusStatusBar);
    }
    
    self.view = [[UIView alloc] initWithFrame: newFrame];
    
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    [self.view addSubview: self.channelThumbnailCollectionView];
    
    if (self.enableCategoryTable)

    {[self layoutChannelsCategoryTable];}
    
    
    
    self.channelThumbnailCollectionView.showsVerticalScrollIndicator = YES;
}


- (void) viewDidLoad
{
    [super viewDidLoad];
    
    self.mainRegistry = appDelegate.mainRegistry;
    
    
    self.view.multipleTouchEnabled = NO;
    
    self.channels = [NSMutableArray array];
    
    // Register Cells
    UINib *thumbnailCellNib = [UINib nibWithNibName: @"SYNChannelThumbnailCell"
                                             bundle: nil];
    
    [self.channelThumbnailCollectionView registerNib: thumbnailCellNib
                          forCellWithReuseIdentifier: @"SYNChannelThumbnailCell"];
    
    // Register Footer
    UINib *footerViewNib = [UINib nibWithNibName: @"SYNChannelFooterMoreView"
                                          bundle: nil];
    
    [self.channelThumbnailCollectionView registerNib: footerViewNib
                          forSupplementaryViewOfKind: UICollectionElementKindSectionFooter
                                 withReuseIdentifier: @"SYNChannelFooterMoreView"];
    
    
    self.currentGenre = nil;
    
    [self displayChannelsForGenre: self.currentGenre];
    
    [self loadChannelsForGenre: self.currentGenre];
    
    
    
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void) viewDidScrollToFront
{
    [self updateAnalytics];
    
    self.channelThumbnailCollectionView.scrollsToTop = YES;
    
    
    
    
    // if the user has requested 'Load More' channels then dont refresh the page cause he is in the middle of a search
    if (self.dataRequestRange.location == 0)
    {
        [self loadChannelsForGenre: self.currentGenre];
    }
}

-(void)checkForOnBoarding
{
    if(![appDelegate.viewStackManager controllerViewIsVisible:self])
        return;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL onBoarding1State = [defaults boolForKey:kInstruction1OnBoardingState];
    if(!onBoarding1State) // 1rst card
    {
        SYNInstructionsToShareControllerViewController* itsVC = [[SYNInstructionsToShareControllerViewController alloc] initWithDelegate:self andState:InstructionsShareStatePacks];
        
        [appDelegate.viewStackManager presentCoverViewController:itsVC];
        
        [defaults setBool:YES forKey:kInstruction1OnBoardingState];
        
    }
}


- (void) viewDidScrollToBack
{
    self.channelThumbnailCollectionView.scrollsToTop = NO;
}


- (void) updateAnalytics
{
    // Google analytics support
    id tracker = [[GAI sharedInstance] defaultTracker];

    [tracker set: kGAIScreenName
           value: @"Channels - Root"    ];
    
    [tracker send: [[GAIDictionaryBuilder createAppView] build]];
}


#pragma mark - Loading of Channels

- (void) loadChannelsForGenre: (Genre *) genre
{
    [self loadChannelsForGenre: genre
                   byAppending: NO];
}


- (void) loadChannelsForGenre: (Genre *) genre
                  byAppending: (BOOL) append
{
    void (^completeBlock) (NSDictionary *) = ^(NSDictionary *response) {
        
        NSDictionary *channelsDictionary = response[@"channels"];
        
        if (!channelsDictionary || ![channelsDictionary isKindOfClass: [NSDictionary class]])
        {
            return;
        }
        
        NSArray *itemArray = channelsDictionary[@"items"];
        
        if (![itemArray isKindOfClass: [NSArray class]])
        {
            return;
        }
        
        dataRequestRange.length = itemArray.count;
        
        
        
        NSNumber *totalNumber = channelsDictionary[@"total"];
        
        if (![totalNumber isKindOfClass: [NSNumber class]])
        {
            return;
        }
        
        self.dataItemsAvailable = [totalNumber integerValue];
        
        [self.mainRegistry performInBackground:^BOOL(NSManagedObjectContext *backgroundContext) {
            
            BOOL registryResultOk = [appDelegate.mainRegistry registerChannelsFromDictionary: response
                                                                                    forGenre: genre
                                                                                 byAppending: append];
            
            return registryResultOk;
            
        } completionBlock:^(BOOL registryResultOk) {
            
            self.loadingMoreContent = NO;
            
            if (!registryResultOk)
            {
                DebugLog(@"Registration of Channel Failed for: %@", self.currentCategoryId);
                return;
            }
            
            [self displayChannelsForGenre: genre];
            
            if (self.emptyGenreMessageView)
            {
                [self.emptyGenreMessageView removeFromSuperview];
                self.emptyGenreMessageView = nil;
            }
            
            if (self.channels.count == 0)
            {
                [self displayEmptyGenreMessage: @"No Channels Found"];
            }
            else
            {
                // show on boarding when we have channels after a delay to allow them to display
                [self performSelector: @selector(checkForOnBoarding)
                           withObject: nil
                           afterDelay: 0.5f];
            }
            
        }]; // end of background registry operation
        
        
    }; // end of completion block

    void (^errorBlock) (NSDictionary *) = ^(NSDictionary *errorInfo) {
        DebugLog(@"Could not load channels: %@", errorInfo);
        self.loadingMoreContent = NO;
    };
    
    if (genre)
    {
        self.runningNetworkOperation = [appDelegate.networkEngine
                                        updateChannelsScreenForCategory: (genre ? genre.uniqueId : @"all")
                                        forRange: self.dataRequestRange
                                        ignoringCache: NO
                                        onCompletion: completeBlock
                                        onError: errorBlock];
    }
    else
    {
        self.runningNetworkOperation = [appDelegate.oAuthNetworkEngine
                                        updateRecommendedChannelsScreenForUserId: appDelegate.currentOAuth2Credentials.userId
                                        forRange: self.dataRequestRange
                                        ignoringCache: NO
                                        onCompletion: completeBlock
                                        onError: errorBlock];
    }
}


- (void) loadMoreChannels
{
    // Check to see if we have loaded all items already
    if (self.moreItemsToLoad)
    {
        self.loadingMoreContent = YES;
        
        
        [self incrementRangeForNextRequest];
        
        
        [self loadChannelsForGenre: self.currentGenre
                       byAppending: YES];
    }
}


- (void) scrollViewDidScroll: (UIScrollView *) scrollView
{
    // when reaching far right hand side, load a new page
    if (scrollView.contentOffset.y >= scrollView.contentSize.height - scrollView.bounds.size.height - kLoadMoreFooterViewHeight
        && self.isLoadingMoreContent == NO)
    {
        [self loadMoreChannels];
    }
}


- (void) displayChannelsForGenre: (Genre *) genre
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity: [NSEntityDescription entityForName: @"Channel"
                                    inManagedObjectContext: appDelegate.mainManagedObjectContext]];
    
    NSPredicate *genrePredicate;
    
    if (!genre) // @"all" category
    {
        genrePredicate = [NSPredicate predicateWithFormat: @"popular == YES"];
    }
    else
    {
        if ([genre isMemberOfClass: [Genre class]]) // no isKindOfClass: which will always return true in this case
        {
            genrePredicate = [NSPredicate predicateWithFormat: @"categoryId IN %@", [genre getSubGenreIdArray]];
        }
        else
        {
            genrePredicate = [NSPredicate predicateWithFormat: @"categoryId == %@", genre.uniqueId];
        }
    }
    
    NSPredicate *viewIdPredicate = [NSPredicate predicateWithFormat: @"viewId == %@", kChannelsViewId];
    
    // only get the channels marked as fresh //
    
    
    
    
    NSPredicate *finalPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:
                                   @[genrePredicate, viewIdPredicate]];
    
    [request setPredicate: finalPredicate];
    
    NSSortDescriptor *positionDescriptor = [[NSSortDescriptor alloc] initWithKey: @"position"
                                                                       ascending: YES];
    
    [request setSortDescriptors: @[positionDescriptor]];
    
    NSError *error = nil;
    
    NSArray *resultsArray = [appDelegate.mainManagedObjectContext
                             executeFetchRequest: request
                             error: &error];
    
    if (!resultsArray)
    {
        return;
    }
    
    self.channels = [NSMutableArray arrayWithArray: resultsArray];
    
    
    [self.channelThumbnailCollectionView reloadData];
    
    
}


- (void) displayEmptyGenreMessage: (NSString *) message
{
    if (self.emptyGenreMessageView) // add no more than one
    {
        return;
    }
    
    self.emptyGenreMessageView = [SYNFeedMessagesView withMessage: message];
    
    self.emptyGenreMessageView.center = CGPointMake(self.view.center.x, 280.0);
    self.emptyGenreMessageView.frame = CGRectIntegral(self.emptyGenreMessageView.frame);
    
    [self.view insertSubview: self.emptyGenreMessageView
                belowSubview: self.categoryTableViewController.view];
}


#pragma mark - Helper Methods


- (CGSize) itemSize
{
    return IS_IPHONE ? CGSizeMake(152.0f, 152.0f) : CGSizeMake(251.0, 274.0);
}


#pragma mark - CollectionView Delegate

- (NSInteger) numberOfSectionsInCollectionView: (UICollectionView *) collectionView
{
    return 1;
}


- (NSInteger) collectionView: (UICollectionView *) view
      numberOfItemsInSection: (NSInteger) section
{
    return self.channels.count;
}


- (UICollectionViewCell *) collectionView: (UICollectionView *) collectionView
                   cellForItemAtIndexPath: (NSIndexPath *) indexPath
{
    Channel *channel = self.channels[indexPath.row];
    
    SYNChannelThumbnailCell *channelThumbnailCell = [collectionView dequeueReusableCellWithReuseIdentifier: @"SYNChannelThumbnailCell"
                                                                                              forIndexPath: indexPath];
    
    
    if (channel.favouritesValue)
    {
        if ([appDelegate.currentUser.uniqueId
             isEqualToString: channel.channelOwner.uniqueId])
        {
            [channelThumbnailCell setChannelTitle: [NSString stringWithFormat: @"MY %@", NSLocalizedString(@"FAVORITES", nil)] ];
        }
        else
        {
            [channelThumbnailCell setChannelTitle:
             [NSString stringWithFormat: @"%@'S %@", [channel.channelOwner.displayName uppercaseString], NSLocalizedString(@"FAVORITES", nil)]];
        }
    }
    else
    {
        [channelThumbnailCell setChannelTitle: channel.title];
    }
    
    [channelThumbnailCell.imageView
     setImageWithURL: [NSURL URLWithString: channel.channelCover.imageLargeUrl]
     placeholderImage: [UIImage imageNamed: @"PlaceholderChannel.png"]
     options: SDWebImageRetryFailed];
    
    channelThumbnailCell.displayNameLabel.text = [NSString stringWithFormat: @"By %@", channel.channelOwner.displayName];
    channelThumbnailCell.viewControllerDelegate =  self;
    
    
    return channelThumbnailCell;
}


- (void)  collectionView: (UICollectionView *) collectionView
    didEndDisplayingCell: (UICollectionViewCell *) cell
      forItemAtIndexPath: (NSIndexPath *) indexPath
{
    [((SYNChannelThumbnailCell *) cell).imageView cancelCurrentImageLoad];
}


- (UICollectionReusableView *) collectionView: (UICollectionView *) collectionView
            viewForSupplementaryElementOfKind: (NSString *) kind
                                  atIndexPath: (NSIndexPath *) indexPath
{
    UICollectionReusableView *supplementaryView;
    
    if (collectionView == self.channelThumbnailCollectionView)
    {
        if (kind == UICollectionElementKindSectionFooter)
        {
            self.footerView = [self.channelThumbnailCollectionView dequeueReusableSupplementaryViewOfKind: kind
                                                                                      withReuseIdentifier: @"SYNChannelFooterMoreView"
                                                                                             forIndexPath: indexPath];
            
            supplementaryView = self.footerView;
            
            if (self.channels.count > 0)
            {
                self.footerView.showsLoading = self.isLoadingMoreContent;
            }
        }
    }
    
    return supplementaryView;
}


- (CGSize)			 collectionView: (UICollectionView *) collectionView
                      layout: (UICollectionViewLayout *) collectionViewLayout
referenceSizeForFooterInSection: (NSInteger) section
{
    CGSize footerSize;
    
    if (collectionView == self.channelThumbnailCollectionView && self.channels.count != 0)
    {
        footerSize = [self footerSize];
        
        
        // Now set to zero anyway if we have already read in all the items
        NSInteger nextStart = self.dataRequestRange.location + self.dataRequestRange.length; // one is subtracted when the call happens for 0 indexing
        
        // FIXME: Is this comparison correct?  Should it just be self.dataRequestRange.location >= self.dataItemsAvailable?
        if (nextStart >= self.dataItemsAvailable)
        {
            footerSize = CGSizeMake(1.0f, 5.0f);
        }
    }
    else
    {
        footerSize = CGSizeZero;
    }
    
    return footerSize;
}



- (void) channelTapped: (UICollectionViewCell *) cell
{
    SYNChannelThumbnailCell *selectedCell = (SYNChannelThumbnailCell *) cell;
    NSIndexPath *indexPath = [self.channelThumbnailCollectionView indexPathForItemAtPoint: selectedCell.center];
    
    if (self.isAnimating) // prevent double clicking
    {
        return;
    }

    Channel *channel = (Channel *) self.channels[indexPath.row];

    [appDelegate.viewStackManager viewChannelDetails: channel];
}


- (void) handleMainTap: (UIView *) tab
{
    [super handleMainTap: tab];
    
    if (!tab || tab.tag == 0)
    {
        // then home button was pressed in either its icon or "all" mode respectively
        if (tabExpanded && !self.isAnimating)
        {
            [self animateCollectionViewDown: NO];
        }
        
        return;
    }
    
    if (tabExpanded || self.isAnimating)
    {
        return;
    }
    
    [self animateCollectionViewDown: YES];
}


#pragma mark - Pushing UICollectionView up and down

- (void) animateCollectionViewDown: (BOOL) down
{
    if (down && !tabExpanded)
    {
        self.isAnimating = YES;
        
        [UIView animateWithDuration: 0.4
                              delay: 0.0
                            options: UIViewAnimationCurveEaseInOut
                         animations: ^{
                             CGRect currentCollectionViewFrame = self.channelThumbnailCollectionView.frame;
                             currentCollectionViewFrame.origin.y += kCategorySecondRowHeight;
                             //
                             self.channelThumbnailCollectionView.frame = currentCollectionViewFrame;
                         }
         
         
                         completion: ^(BOOL result) {
                             tabExpanded = YES;
                             self.isAnimating = NO;
                             [self.channelThumbnailCollectionView reloadData];
                             CGRect currentCollectionViewFrame = self.channelThumbnailCollectionView.frame;
                             currentCollectionViewFrame.size.height -= kCategorySecondRowHeight;
                             self.channelThumbnailCollectionView.frame = currentCollectionViewFrame;
                         }];
    }
    else if (tabExpanded)
    {
        self.isAnimating = YES;
        
        [UIView animateWithDuration: 0.4
                              delay: 0.1
                            options: UIViewAnimationCurveEaseInOut
                         animations: ^{
                             CGRect currentCollectionViewFrame = self.channelThumbnailCollectionView.frame;
                             currentCollectionViewFrame.origin.y -= kCategorySecondRowHeight;
                             //
                             self.channelThumbnailCollectionView.frame = currentCollectionViewFrame;
                         }
         
         
                         completion: ^(BOOL result) {
                             tabExpanded = NO;
                             self.isAnimating = NO;
                             
                             [self.channelThumbnailCollectionView reloadData];
                             
                             CGRect currentCollectionViewFrame = self.channelThumbnailCollectionView.frame;
                             currentCollectionViewFrame.size.height += kCategorySecondRowHeight;
                             self.channelThumbnailCollectionView.frame = currentCollectionViewFrame;
                         }];
    }
}


- (void) collapseToParentCategory
{
    [((SYNGenreTabView *) self.tabViewController.tabView)hideSecondaryTabs];
    [self animateCollectionViewDown: NO];
}


- (void) handleNewTabSelectionWithId: (NSString *) selectionId
{
}


- (void) handleNewTabSelectionWithGenre: (Genre *) genre
{
    [appDelegate.viewStackManager hideSideNavigator];
    
    if ([self.currentGenre.uniqueId
         isEqualToString: genre.uniqueId])
    {
        return;
    }
    
    self.currentCategoryId = genre.uniqueId;
    
    dataRequestRange = NSMakeRange(0, STANDARD_REQUEST_LENGTH);
    
    if (genre == nil)
    {
        // all category chosen
        self.currentCategoryId = @"all";
        self.currentGenre = nil;
    }
    else
    {
        self.currentCategoryId = genre.uniqueId;
        self.currentGenre = genre;
    }
    
    CGPoint currentOffset = self.channelThumbnailCollectionView.contentOffset;
    currentOffset.y = 0;
    
    // Need to do this immediately, as opposed to animated or we may get strange offsets //
    
    [self.channelThumbnailCollectionView setContentOffset: currentOffset
                                                 animated: NO];
    
    // display what is already in the DB and then load and display again
    
    [self displayChannelsForGenre: genre];
    
    if (self.channels.count > 0)
    {
        if (self.emptyGenreMessageView)
        {
            [self.emptyGenreMessageView removeFromSuperview];
            self.emptyGenreMessageView = nil;
        }
    }
    else
    {
        [self displayEmptyGenreMessage: @"Loading Channels"];
    }
    
    [self loadChannelsForGenre: genre];
}


- (void) clearedLocationBoundData
{
    [self animateCollectionViewDown: NO];
    
    self.dataRequestRange = NSMakeRange(0, STANDARD_REQUEST_LENGTH);
    
    self.currentGenre = nil;
    
    [self loadChannelsForGenre: nil];
}


#pragma mark - categories tableview

- (void) layoutChannelsCategoryTable
{
    self.categorySelectDismissControl = [[UIControl alloc] initWithFrame: self.view.bounds];
    [self.view addSubview: self.categorySelectDismissControl];
    
    [self.categorySelectDismissControl addTarget: self
                                          action: @selector(toggleChannelsCategoryTable:)
                                forControlEvents: UIControlEventTouchDown];
    
    self.categorySelectDismissControl.hidden = YES;
    
    
    self.categoryTableViewController = [[SYNChannelCategoryTableViewController alloc] init];
    CGRect newFrame = self.channelThumbnailCollectionView.frame;
//    newFrame.size.height += IS_IOS_7_OR_GREATER ? 20.0f : 0.0f;
    newFrame.size.width = self.categoryTableViewController.view.frame.size.width;
    self.categoryTableViewController.view.frame = newFrame;
    [self.view addSubview: self.categoryTableViewController.view];
    [self addChildViewController: self.categoryTableViewController];
    self.categoryTableViewController.categoryTableControllerDelegate = self;
    self.categoryTableViewController.view.hidden = YES;
    
    // the top bar that you click to bring the table view for iPhone's categories
    newFrame.origin.y -= 44.0f;
    newFrame.size.height = 44.0f;
    newFrame.size.width = 320.0f;
    self.categorySelectButton = [[UIButton alloc] initWithFrame: newFrame];
    
    [self.categorySelectButton setBackgroundImage: [UIImage imageNamed: @"CategoryBar"]
                                         forState: UIControlStateNormal];
    
    [self.categorySelectButton setBackgroundImage: [UIImage imageNamed: @"CategoryBarHighlighted"]
                                         forState: UIControlStateHighlighted];
    
    [self.categorySelectButton addTarget: self
                                  action: @selector(toggleChannelsCategoryTable:)
                        forControlEvents: UIControlEventTouchUpInside];
    
    [self.view addSubview: self.categorySelectButton];
    
    newFrame.origin.x = 42.0f;
    newFrame.origin.y += 2.0f;
    newFrame.size.width = 280.0f;
    
    UILabel *newLabel = [[UILabel alloc] initWithFrame: newFrame];

    newLabel.font = [UIFont boldRockpackFontOfSize: 15.0f];
    
    newLabel.textColor = [UIColor colorWithRed: 40.0f / 255.0f
                                         green: 45.0f / 255.0f
                                          blue: 51.0f / 255.0f
                                         alpha: 1.0f];
    
    
    newLabel.shadowColor = [UIColor colorWithWhite: 1.0f
                                             alpha: 0.75f];

    
    newLabel.shadowOffset = CGSizeMake(0.0f, 2.0f);
    newLabel.text = StartingCategoryText;

    newLabel.backgroundColor = [UIColor clearColor];
    CGPoint center = newLabel.center;
    [newLabel sizeToFit];
    center.x = newLabel.center.x;
    newLabel.center = center;
    self.categoryNameLabel = newLabel;
    [self.view addSubview: self.categoryNameLabel];
    
    
    newLabel = [[UILabel alloc] initWithFrame: self.categoryNameLabel.frame];
    newLabel.font = self.categoryNameLabel.font;
    newLabel.textColor = self.categoryNameLabel.textColor;
    newLabel.shadowColor = self.categoryNameLabel.shadowColor;
    newLabel.shadowOffset = self.categoryNameLabel.shadowOffset;
    newLabel.backgroundColor = self.categoryNameLabel.backgroundColor;
    newLabel.hidden = YES;
    newLabel.center = center;
    
    self.subCategoryNameLabel = newLabel;
    [self.view addSubview: self.subCategoryNameLabel];
    
    self.arrowImage = [[UIImageView alloc] initWithImage: [UIImage imageNamed: @"IconCategoryBarChevron~iphone"]];
    center.y -= 4.0f;
    self.arrowImage.center = center;
    self.arrowImage.hidden = YES;
    [self.view addSubview: self.arrowImage];
}

// iPhone

- (void) toggleChannelsCategoryTable: (id) sender
{
    if (self.categoryTableViewController.view.hidden)
    {
        CGRect startFrame = self.categoryTableViewController.view.frame;
        
        startFrame.origin.x = -startFrame.size.width;
        
        self.categoryTableViewController.view.frame = startFrame;
        
        self.categoryTableViewController.view.hidden = NO;
        self.categorySelectDismissControl.hidden = NO;
        
        [UIView animateWithDuration: 0.2f
                              delay: 0.0f
                            options: UIViewAnimationOptionCurveEaseOut
                         animations: ^{
                             CGRect endFrame = self.categoryTableViewController.view.frame;
                             endFrame.origin.x = 0;
                             self.categoryTableViewController.view.frame = endFrame;
                         }
         
         
                         completion: nil];
    }
    else
    {
        self.categorySelectDismissControl.hidden = YES;
        [UIView animateWithDuration: 0.2f
                              delay: 0.0f
                            options: UIViewAnimationOptionCurveEaseIn
                         animations: ^{
                             CGRect endFrame = self.categoryTableViewController.view.frame;
                             endFrame.origin.x = -endFrame.size.width;
                             self.categoryTableViewController.view.frame = endFrame;
                         }
         
         
                         completion: ^(BOOL finished) {
                             self.categoryTableViewController.view.hidden = YES;
                         }];
    }
}

-(void)performAction:(NSString*)action withObject:(id)object
{
    if([action isEqualToString:@"open"] && [object isKindOfClass:[Genre class]])
    {
        Genre* genreSelected = (Genre *)object;
        [self.categoryTableViewController setSelectedCategoryForId:genreSelected.uniqueId];
        [self categoryTableController:nil didSelectCategory:genreSelected];
        
    }
}

- (void) categoryTableController: (SYNChannelCategoryTableViewController *) tableController
               didSelectCategory: (Genre *) category
{
    id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
    
    [tracker send: [[GAIDictionaryBuilder createEventWithCategory: @"uiAction"
                                                           action: @"categoryItemClick"
                                                            label: category.name
                                                            value: nil] build]];
    
    if (category)
    {
        self.categoryNameLabel.text = category.name;
        [self.categoryNameLabel sizeToFit];
        self.subCategoryNameLabel.hidden = YES;
        self.arrowImage.hidden = YES;
        [self handleNewTabSelectionWithGenre: category];
    }
    else
    {
        self.categoryNameLabel.text = StartingCategoryText;
        [self.categoryNameLabel sizeToFit];
        self.subCategoryNameLabel.hidden = YES;
        self.arrowImage.hidden = YES;
        [self handleNewTabSelectionWithGenre: nil];
    }
}



- (void) categoryTableController: (SYNChannelCategoryTableViewController *) tableController
            didSelectSubCategory: (SubGenre *) subCategory
{
    id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;

    [tracker send: [[GAIDictionaryBuilder createEventWithCategory: @"uiAction"
                                                           action: @"categoryItemClick"
                                                            label: subCategory.name
                                                            value: nil] build]];
    
    self.categoryNameLabel.text = subCategory.genre.name;
    [self.categoryNameLabel sizeToFit];
    self.subCategoryNameLabel.text = subCategory.name;
    self.subCategoryNameLabel.hidden = NO;
    [self.subCategoryNameLabel sizeToFit];
    self.arrowImage.hidden = NO;
    
    CGRect newFrame = self.arrowImage.frame;
    newFrame.origin.x = self.categoryNameLabel.frame.origin.x + self.categoryNameLabel.frame.size.width + 5.0f;
    self.arrowImage.frame = newFrame;
    
    newFrame = self.subCategoryNameLabel.frame;
    newFrame.origin.x = self.arrowImage.frame.origin.x + self.arrowImage.frame.size.width + 5.0f;
    self.subCategoryNameLabel.frame = newFrame;
    
    [self handleNewTabSelectionWithGenre: subCategory];
    
    [self toggleChannelsCategoryTable: nil];
}


- (void) setRunningNetworkOperation: (MKNetworkOperation *) runningNetworkOperation
{
    if (_runningNetworkOperation)
    {
        [_runningNetworkOperation cancel];
    }
    
    _runningNetworkOperation = runningNetworkOperation;
}


- (void) categoryTableControllerDeselectedAll: (SYNChannelCategoryTableViewController *) tableController
{
    self.categoryNameLabel.text = StartingCategoryText;
    [self.categoryNameLabel sizeToFit];
    self.subCategoryNameLabel.hidden = YES;
    self.arrowImage.hidden = YES;
    
    [self handleNewTabSelectionWithGenre: nil];
    
    if (!self.categoryTableViewController.view.hidden)
    {
        [self toggleChannelsCategoryTable: nil];
    }
}


- (void) headerTapped
{
    [self.channelThumbnailCollectionView setContentOffset: CGPointZero
                                                 animated: YES];
}

#pragma mark - Arc menu support

- (void) arcMenuUpdateState: (UIGestureRecognizer *) recognizer
{
    [super arcMenuUpdateState: recognizer];
    
    if (recognizer.state == UIGestureRecognizerStateBegan)
    {
        Channel *channel = [self channelInstanceForIndexPath: self.arcMenuIndexPath
                                           andComponentIndex: kArcMenuInvalidComponentIndex];
        
        [self requestShareLinkWithObjectType: @"channel"
                                    objectId: channel.uniqueId];
    }
}


// Bypass implementation for derived classes
- (void) superArcMenuUpdateState: (UIGestureRecognizer *) recognizer
{
    [super arcMenuUpdateState: recognizer];
}


- (void) arcMenu: (SYNArcMenuView *) menu
         didSelectMenuName: (NSString *) menuName
         forCellAtIndex: (NSIndexPath *) cellIndexPath
         andComponentIndex: (NSInteger) componentIndex
{
    if ([menuName isEqualToString: kActionShareVideo])
    {
        [self shareVideoAtIndexPath: cellIndexPath];
    }
    else if ([menuName isEqualToString: kActionShareChannel])
    {
        [self shareChannelAtIndexPath: cellIndexPath
                    andComponentIndex: componentIndex];
    }
    else
    {
        AssertOrLog(@"Invalid Arc Menu index selected");
    }
}


- (Channel *) channelInstanceForIndexPath: (NSIndexPath *) indexPath
                        andComponentIndex: (NSInteger) componentIndex
{
    if (componentIndex != kArcMenuInvalidComponentIndex)
    {
        AssertOrLog(@"Unexpectedly valid componentIndex");
    }
    
    Channel *channel = (Channel *) self.channels[indexPath.row];
    
    return channel;
}


- (NSIndexPath *) indexPathForChannelCell: (UICollectionViewCell *) cell
{
    NSIndexPath *indexPath = [self.channelThumbnailCollectionView indexPathForCell: cell];
    return  indexPath;
}


- (void) displayNameButtonPressed: (UIButton *) button
{
    SYNChannelThumbnailCell *parent = (SYNChannelThumbnailCell *) [[button superview] superview];
    
    NSIndexPath *indexPath = [self.channelThumbnailCollectionView indexPathForCell: parent];
    
    Channel *channel = (Channel *) self.channels[indexPath.row];
    
    [appDelegate.viewStackManager
     viewProfileDetails: channel.channelOwner];
}

@end
