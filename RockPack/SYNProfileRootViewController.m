    //
//  SYNProfileRootViewController.m
//  rockpack
//
//  Created by Nick Banks on 24/01/2013.
//  Copysubscriptions (c) Rockpack Ltd. All subscriptionss reserved.
//

#import "Channel.h"
#import "ChannelCover.h"
#import "GAI.h"
#import "SYNChannelCreateNewCell.h"
#import "SYNChannelDetailViewController.h"
#import "SYNChannelMidCell.h"
#import "SYNChannelThumbnailCell.h"
#import "SYNDeletionWobbleLayout.h"
#import "SYNDeviceManager.h"
#import "SYNImagePickerController.h"
#import "SYNIntegralCollectionViewFlowLayout.h"
#import "SYNOAuthNetworkEngine.h"
#import "SYNPassthroughView.h"
#import "SYNProfileRootViewController.h"
#import "SYNSubscriptionsViewController.h"
#import "SYNUserProfileViewController.h"
#import "SYNYouHeaderView.h"
#import "UIFont+SYNFont.h"
#import "UIImageView+WebCache.h"
#import "Video.h"
#import <QuartzCore/QuartzCore.h>

#define kInterRowMargin 8.0f

@interface SYNProfileRootViewController () <SYNDeletionWobbleLayoutDelegate,
                                            UIGestureRecognizerDelegate,
                                            SYNImagePickerControllerDelegate>

@property (nonatomic) BOOL deleteCellModeOn;
@property (nonatomic) BOOL isIPhone;
@property (nonatomic) BOOL isUserProfile;
@property (nonatomic) BOOL trackView;
@property (nonatomic, assign) BOOL subscriptionsTabActive;
@property (nonatomic, assign, getter = isDeletionModeActive) BOOL deletionModeActive;
@property (nonatomic, strong) IBOutlet UICollectionView *channelThumbnailCollectionView;
@property (nonatomic, strong) NSArray *sortDescriptors;
@property (nonatomic, strong) NSIndexPath *channelsIndexPath;
@property (nonatomic, strong) NSIndexPath *indexPathToDelete;
@property (nonatomic, strong) NSIndexPath *subscriptionsIndexPath;
@property (nonatomic, strong) SYNDeletionWobbleLayout *channelsLandscapeLayout;
@property (nonatomic, strong) SYNDeletionWobbleLayout *channelsPortraitLayout;
@property (nonatomic, strong) SYNDeletionWobbleLayout *subscriptionsLandscapeLayout;
@property (nonatomic, strong) SYNDeletionWobbleLayout *subscriptionsPortraitLayout;
@property (nonatomic, strong) SYNSubscriptionsViewController *subscriptionsViewController;
@property (nonatomic, strong) SYNUserProfileViewController *userProfileController;
@property (nonatomic, strong) SYNYouHeaderView *headerChannelsView;
@property (nonatomic, strong) SYNYouHeaderView *headerSubscriptionsView;
@property (nonatomic, strong) id orientationDesicionmaker;
@property (nonatomic, weak) UIButton *channelsTabButton;
@property (nonatomic, weak) UIButton *subscriptionsTabButton;

@end


@implementation SYNProfileRootViewController

#pragma mark - Object lifecycle

- (void) dealloc
{
    self.user = nil;
    
    // Defensive programming
    self.channelThumbnailCollectionView.delegate = nil;
    self.channelThumbnailCollectionView.dataSource = nil;
    self.subscriptionsViewController.collectionView.delegate = nil;
    self.subscriptionsViewController.collectionView.dataSource = nil;
}


#pragma mark - View lifecycle

- (void) loadView
{
    self.isIPhone = IS_IPHONE;
    
    // User Profile
    if (!self.hideUserProfile)
    {
        self.userProfileController = [[SYNUserProfileViewController alloc] init];
        
    }
    
    // Main Collection View
    self.channelsLandscapeLayout = [SYNDeletionWobbleLayout layoutWithItemSize: CGSizeMake(192.0f, 192.0f)
                                                       minimumInterItemSpacing: 0.0
                                                            minimumLineSpacing: 5.0
                                                               scrollDirection: UICollectionViewScrollDirectionVertical
                                                                  sectionInset: UIEdgeInsetsMake(kInterRowMargin - 8.0, 8.0, kInterRowMargin, 18.0)];
    
    
    self.subscriptionsLandscapeLayout = [SYNDeletionWobbleLayout layoutWithItemSize: CGSizeMake(192.0, 192.0f)
                                                            minimumInterItemSpacing: 0.0
                                                                 minimumLineSpacing: 5.0
                                                                    scrollDirection: UICollectionViewScrollDirectionVertical
                                                                       sectionInset: UIEdgeInsetsMake(kInterRowMargin - 8.0, 12.0, kInterRowMargin, 11.0)];
    
    if (self.isIPhone)
    {
        self.channelsPortraitLayout = [SYNDeletionWobbleLayout layoutWithItemSize: CGSizeMake(158.0f, 158.0f)
                                                          minimumInterItemSpacing: 0.0f
                                                               minimumLineSpacing: 0.0f
                                                                  scrollDirection: UICollectionViewScrollDirectionVertical
                                                                     sectionInset: UIEdgeInsetsMake(3.0, 2.0, 0.0, 2.0)];
        
        self.subscriptionsPortraitLayout = [SYNDeletionWobbleLayout layoutWithItemSize: CGSizeMake(158.0f, 158.0f)
                                                               minimumInterItemSpacing: 0.0f
                                                                    minimumLineSpacing: 0.0f
                                                                       scrollDirection: UICollectionViewScrollDirectionVertical
                                                                          sectionInset: UIEdgeInsetsMake(3.0, 2.0, 0.0, 2.0)];
    }
    else
    {
        self.channelsPortraitLayout = [SYNDeletionWobbleLayout layoutWithItemSize: CGSizeMake(192.0, 192.0)
                                                          minimumInterItemSpacing: 0.0f
                                                               minimumLineSpacing: 0.0f
                                                                  scrollDirection: UICollectionViewScrollDirectionVertical
                                                                     sectionInset: UIEdgeInsetsMake(kInterRowMargin, 0.0, kInterRowMargin, 0.0)];
        
        self.subscriptionsPortraitLayout = [SYNDeletionWobbleLayout layoutWithItemSize: CGSizeMake(192.0, 192.0)
                                                               minimumInterItemSpacing: 0.0f
                                                                    minimumLineSpacing: 0.0f
                                                                       scrollDirection: UICollectionViewScrollDirectionVertical
                                                                          sectionInset: UIEdgeInsetsMake(kInterRowMargin, 0.0, kInterRowMargin, 0.0)];
        self.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey: @"section"
                                                               ascending: YES], [NSSortDescriptor sortDescriptorWithKey: @"row"
                                                                                                              ascending: YES]];
    }
    
    CGFloat correctWidth = [SYNDeviceManager.sharedInstance isLandscape] ? 600.0 : 400.0;
    
    self.headerChannelsView = [SYNYouHeaderView headerViewForWidth: correctWidth];
    
    if (self.isIPhone)
    {
        CGRect newFrame = self.headerChannelsView.frame;
        newFrame.origin.y = 59.0f;
        newFrame.size.height = 43.0f;
        self.headerChannelsView.frame = newFrame;
        [self.headerChannelsView setFontSize: 12.0f];
        
        
        self.headerChannelsView.userInteractionEnabled = NO;
    }
    else
    {
        [self.headerChannelsView setBackgroundImage: ([SYNDeviceManager.sharedInstance isLandscape] ?
                                                      [UIImage imageNamed: @"HeaderProfileChannelsLandscape"] :
                                                      [UIImage imageNamed: @"HeaderProfilePortraitBoth"])];
    }
    
    [self.headerChannelsView setTitle: [self getHeaderTitleForChannels]
                            andNumber: 0];
    
    CGRect collectionViewFrame = CGRectZero;
    collectionViewFrame.origin.x = 0.0f;
    collectionViewFrame.origin.y = self.headerChannelsView.frame.origin.y + self.headerChannelsView.currentHeight;
    collectionViewFrame.size.width = correctWidth;
    collectionViewFrame.size.height = [SYNDeviceManager.sharedInstance currentScreenHeightWithStatusBar] - collectionViewFrame.origin.y;
    
    self.channelThumbnailCollectionView = [[UICollectionView alloc] initWithFrame: collectionViewFrame
                                                             collectionViewLayout: self.channelsLandscapeLayout];
    
    
    self.channelThumbnailCollectionView.dataSource = self;
    self.channelThumbnailCollectionView.delegate = self;
    self.channelThumbnailCollectionView.backgroundColor = [UIColor clearColor];
    self.channelThumbnailCollectionView.showsVerticalScrollIndicator = NO;
    self.channelThumbnailCollectionView.alwaysBounceVertical = YES;
    
    // Subscriptions Collection View
    self.subscriptionsViewController = [[SYNSubscriptionsViewController alloc] initWithViewId: kProfileViewId];
    CGRect subColViewFrame = self.subscriptionsViewController.view.frame;
    subColViewFrame.origin.x = self.isIPhone ? 0.0f : collectionViewFrame.origin.x + collectionViewFrame.size.width + 10.0;
    subColViewFrame.origin.y = collectionViewFrame.origin.y;
    subColViewFrame.size.height = collectionViewFrame.size.height;
    subColViewFrame.size.width = [SYNDeviceManager.sharedInstance currentScreenWidth] - subColViewFrame.origin.x - 10.0;
    [self.subscriptionsViewController setViewFrame: subColViewFrame];
    
    self.headerSubscriptionsView = [SYNYouHeaderView headerViewForWidth: 384];
    
    if (self.isIPhone)
    {
        CGRect newFrame = self.headerSubscriptionsView.frame;
        newFrame.origin.y = 59.0f;
        newFrame.size.height = 44.0f;
        self.headerSubscriptionsView.frame = newFrame;
        [self.headerSubscriptionsView setFontSize: 12.0f];
        
        
        
        
        self.headerSubscriptionsView.userInteractionEnabled = NO;
    }
    else
    {
        
        [self.headerSubscriptionsView setBackgroundImage: ([SYNDeviceManager.sharedInstance isLandscape] ?
                                                           [UIImage imageNamed: @"HeaderProfileSubscriptionsLandscape"] :
                                                           [UIImage imageNamed: @"HeaderProfilePortraitBoth"])];
    }
    
    CGRect headerSubFrame = self.headerSubscriptionsView.frame;
    headerSubFrame.origin.x = subColViewFrame.origin.x;
    self.headerSubscriptionsView.frame = headerSubFrame;
    
    self.view = [[UIView alloc] initWithFrame: CGRectMake(0.0f,
                                                          0.0f,
                                                          [SYNDeviceManager.sharedInstance currentScreenWidth],
                                                          [SYNDeviceManager.sharedInstance currentScreenHeightWithStatusBar])];
    
    
    self.subscriptionsViewController.headerView = self.headerSubscriptionsView;
    
    [self.view addSubview: self.headerChannelsView];
    [self.view addSubview: self.headerSubscriptionsView];
    [self.view addSubview: self.userProfileController.view];
    
    if (self.isIPhone)
    {
        self.userProfileController.view.center = CGPointMake(160.0f, IS_IOS_7_OR_GREATER ? 38.0f : 28.0f);
    }
    else
    {
        CGRect userProfileFrame = self.userProfileController.view.frame;
        userProfileFrame.origin.y = 80.0;
        self.userProfileController.view.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
        self.userProfileController.view.frame = userProfileFrame;
    }
    
    [self.view addSubview: self.channelThumbnailCollectionView];
    [self.view  addSubview: self.subscriptionsViewController.view];
    
    if (self.isIPhone)
    {
        UIImage *tabButtonImage = [UIImage imageNamed: @"ButtonProfileChannels"];
        
        UIButton *tabButton = [[UIButton alloc] initWithFrame: CGRectMake(0.0f,
                                                                          self.headerChannelsView.frame.origin.y,
                                                                          tabButtonImage.size.width,
                                                                          tabButtonImage.size.height)];
        [tabButton setImage: tabButtonImage
                   forState: UIControlStateNormal];
        
        [tabButton setImage: [UIImage imageNamed: @"ButtonProfileChannelsHighlighted"]
                   forState: UIControlStateHighlighted];
        
        [tabButton setImage: [UIImage imageNamed: @"ButtonProfileChannelsSelected"]
                   forState: UIControlStateSelected];
        
        [self.view insertSubview: tabButton
                    belowSubview: self.headerChannelsView];
        
        [tabButton addTarget: self
                      action: @selector(channelsTabTapped:)
            forControlEvents: UIControlEventTouchUpInside];
        
        tabButton.showsTouchWhenHighlighted = NO;
        self.channelsTabButton = tabButton;
        
        tabButton = [[UIButton alloc]initWithFrame: CGRectMake(160.0f,
                                                               self.headerSubscriptionsView.frame.origin.y,
                                                               tabButtonImage.size.width,
                                                               tabButtonImage.size.height)];
        [tabButton setImage: tabButtonImage
                   forState: UIControlStateNormal];
        
        [tabButton setImage: [UIImage imageNamed: @"ButtonProfileChannelsHighlighted"]
                   forState: UIControlStateHighlighted];
        
        [tabButton setImage: [UIImage imageNamed: @"ButtonProfileChannelsSelected"]
                   forState: UIControlStateSelected];
        
        [self.view insertSubview: tabButton
                    belowSubview: self.headerChannelsView];
        
        tabButton.showsTouchWhenHighlighted = NO;
        
        [tabButton addTarget: self
                      action: @selector(subscriptionsTabTapped:)
            forControlEvents: UIControlEventTouchUpInside];
        
        self.subscriptionsTabButton = tabButton;
        
        [self updateTabStates];
    }
    
    self.subscriptionsViewController.channelThumbnailCollectionView.scrollsToTop = NO;
    self.channelThumbnailCollectionView.scrollsToTop = NO;
    
    
}


#pragma mark - View Lifecycle

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    UINib *createCellNib = [UINib nibWithNibName: @"SYNChannelCreateNewCell"
                                          bundle: nil];
    
    [self.channelThumbnailCollectionView registerNib: createCellNib
                          forCellWithReuseIdentifier: @"SYNChannelCreateNewCell"];
    
    // Init collection view
    UINib *thumbnailCellNib = [UINib nibWithNibName: @"SYNChannelMidCell"
                                             bundle: nil];
    
    [self.channelThumbnailCollectionView registerNib: thumbnailCellNib
                          forCellWithReuseIdentifier: @"SYNChannelMidCell"];
}


- (void) viewWillAppear: (BOOL) animated
{
    [super viewWillAppear: animated];
    
    
    if (self.user == appDelegate.currentUser)
    {
        // Don't track the very first user view
        if (self.trackView == false)
        {
            self.trackView = TRUE;
        }
        else
        {
            // Google analytics support
            id tracker = [[GAI sharedInstance] defaultTracker];
            
            [tracker set: kGAIScreenName
                   value: @"Own Profile"];
            
            [tracker send: [[GAIDictionaryBuilder createAppView] build]];
        }
    }
    else
    {
        if (self.isIPhone)
        {
            self.channelThumbnailCollectionView.scrollsToTop = !self.subscriptionsTabActive;
            
            self.subscriptionsViewController.channelThumbnailCollectionView.scrollsToTop = self.subscriptionsTabActive;
        }
        else
        {
            self.channelThumbnailCollectionView.scrollsToTop = YES;
            
            self.subscriptionsViewController.channelThumbnailCollectionView.scrollsToTop = NO;
        }
        
        // Google analytics support
        id tracker = [[GAI sharedInstance] defaultTracker];
        
        [tracker set: kGAIScreenName
               value: @"User Profile"];
        
        [tracker send: [[GAIDictionaryBuilder createAppView] build]];
    }
    
    self.channelThumbnailCollectionView.delegate = self;
    
    self.deletionModeActive = NO;
    
    self.subscriptionsViewController.collectionView.delegate = self;
    
    
    self.subscriptionsViewController.user = self.user;
    
    [self updateLayoutForOrientation: [SYNDeviceManager.sharedInstance orientation]];
    
    [self.channelThumbnailCollectionView reloadData];
}


- (void) viewWillDisappear: (BOOL) animated
{
    self.channelThumbnailCollectionView.delegate = nil;
    
    self.deletionModeActive = NO;
    
    [super viewWillDisappear: animated];
}


#pragma mark - Container Scroll Delegates

- (void) viewDidScrollToFront
{
    [self updateAnalytics];
    
    if (self.isIPhone)
    {
        self.channelThumbnailCollectionView.scrollsToTop = !self.subscriptionsTabActive;
        
        self.subscriptionsViewController.channelThumbnailCollectionView.scrollsToTop = self.subscriptionsTabActive;
    }
    else
    {
        self.channelThumbnailCollectionView.scrollsToTop = YES;
        
        self.subscriptionsViewController.channelThumbnailCollectionView.scrollsToTop = YES;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName: kChannelOwnerUpdateRequest
                                                        object: self
                                                      userInfo: @{kChannelOwner: self.user}];
}


- (void) viewDidScrollToBack
{
    self.channelThumbnailCollectionView.scrollsToTop = NO;
    
    self.subscriptionsViewController.channelThumbnailCollectionView.scrollsToTop = NO;
}


- (void) updateAnalytics
{
    // Google analytics support
    id tracker = [[GAI sharedInstance] defaultTracker];
    
    // Google analytics support
    if (self.user == appDelegate.currentUser)
    {
        [tracker set: kGAIScreenName
               value: @"Own Profile"];
    }
    else
    {
        [tracker set: kGAIScreenName
               value: @"User Profile"];
    }
    
    [tracker send: [[GAIDictionaryBuilder createAppView] build]];
}


#pragma mark - Core Data Callbacks

- (void) handleDataModelChange: (NSNotification *) notification
{
    NSArray *updatedObjects = [notification userInfo][NSUpdatedObjectsKey];
    
    
    [updatedObjects enumerateObjectsUsingBlock: ^(id obj, NSUInteger idx, BOOL *stop)
     {
         if (obj == self.user)
         {
             [self.userProfileController setChannelOwner: (ChannelOwner *) obj];
             
             // Handle new insertions
             
             [self reloadCollectionViews];
             
             return;
         }
     }];
    
}


#pragma mark - Deletion wobble layout delegate

- (BOOL) isDeletionModeActiveForCollectionView: (UICollectionView *) collectionView
                                        layout: (UICollectionViewLayout *) collectionViewLayout
{
    return NO;
}


#pragma mark - Orientation

- (void) willRotateToInterfaceOrientation: (UIInterfaceOrientation) toInterfaceOrientation duration: (NSTimeInterval) duration
{
    //Decide which collection view should be in control of the scroll offset on orientaiton change. The tallest one wins...
    if (self.channelThumbnailCollectionView.collectionViewLayout.collectionViewContentSize.height > self.subscriptionsViewController.channelThumbnailCollectionView.collectionViewLayout.collectionViewContentSize.height)
    {
        self.channelsIndexPath = [self topIndexPathForCollectionView: self.channelThumbnailCollectionView];
        self.orientationDesicionmaker = self.channelThumbnailCollectionView;
    }
    else
    {
        self.subscriptionsIndexPath = [self topIndexPathForCollectionView: self.subscriptionsViewController.channelThumbnailCollectionView];
        self.orientationDesicionmaker = self.subscriptionsViewController.channelThumbnailCollectionView;
    }
}


- (void) didRotateFromInterfaceOrientation: (UIInterfaceOrientation) fromInterfaceOrientation
{
    //Ensure the collection views are scrolled so the topmost cell in the tallest viewcontroller is again at the top.
    if (self.channelsIndexPath)
    {
        [self.channelThumbnailCollectionView scrollToItemAtIndexPath: self.channelsIndexPath
                                                    atScrollPosition: UICollectionViewScrollPositionTop
                                                            animated: NO];
    }
    
    if (self.subscriptionsIndexPath)
    {
        [self.subscriptionsViewController.channelThumbnailCollectionView scrollToItemAtIndexPath: self.subscriptionsIndexPath
                                                                                atScrollPosition: UICollectionViewScrollPositionTop
                                                                                        animated: NO];
    }
    
    self.orientationDesicionmaker = nil;
    
    self.channelsIndexPath = nil;
    self.subscriptionsIndexPath = nil;
    
    //Fade collections in.
    [UIView animateWithDuration: 0.2f
                          delay: 0.0f
                        options: UIViewAnimationCurveEaseInOut
                     animations: ^{
                         self.channelThumbnailCollectionView.alpha = 1.0f;
                         self.subscriptionsViewController.view.alpha = 1.0f;
                     }
     
     
                     completion: nil];
}


- (void) willAnimateRotationToInterfaceOrientation: (UIInterfaceOrientation) toInterfaceOrientation
                                          duration: (NSTimeInterval) duration
{
    //Fade out collections as they don't animate well together.
    self.channelThumbnailCollectionView.alpha = 0.0f;
    self.subscriptionsViewController.view.alpha = 0.0f;
    [self updateLayoutForOrientation: toInterfaceOrientation];
}


- (void) updateLayoutForOrientation: (UIDeviceOrientation) orientation
{
    CGRect newFrame;
    CGFloat viewHeight;
    SYNDeletionWobbleLayout *channelsLayout;
    SYNDeletionWobbleLayout *subscriptionsLayout;
    
    //Setup the headers
    
    if (self.isIPhone)
    {
        newFrame = self.headerChannelsView.frame;
        newFrame.size.width = 160.0f;
        self.headerChannelsView.frame = newFrame;
        
        newFrame = self.headerSubscriptionsView.frame;
        newFrame.origin.x = 160.0f;
        newFrame.size.width = 160.0f;
        self.headerSubscriptionsView.frame = newFrame;
        
        channelsLayout = self.channelsPortraitLayout;
        subscriptionsLayout = self.subscriptionsPortraitLayout;
    }
    else
    {
        if (UIDeviceOrientationIsPortrait(orientation))
        {
            newFrame = self.headerChannelsView.frame;
            newFrame.size.width = 384.0f;
            self.headerChannelsView.frame = newFrame;
            
            newFrame = self.headerSubscriptionsView.frame;
            newFrame.origin.x = 384.0f;
            newFrame.size.width = 385.0f;
            self.headerSubscriptionsView.frame = newFrame;
            
            
            channelsLayout = self.channelsPortraitLayout;
            subscriptionsLayout = self.subscriptionsPortraitLayout;
        }
        else
        {
            newFrame = self.headerChannelsView.frame;
            newFrame.size.width = 612.0f;
            self.headerChannelsView.frame = newFrame;
            
            newFrame = self.headerSubscriptionsView.frame;
            newFrame.origin.x = 612.0f;
            newFrame.size.width = 412.0f;
            self.headerSubscriptionsView.frame = newFrame;
            
            channelsLayout = self.channelsLandscapeLayout;
            subscriptionsLayout = self.subscriptionsLandscapeLayout;
        }
        
        
        
        //Apply correct backgorund images
        [self.headerSubscriptionsView setBackgroundImage: ([SYNDeviceManager.sharedInstance isLandscape] ?
                                                           [UIImage imageNamed: @"HeaderProfileSubscriptionsLandscape"] :
                                                           [UIImage imageNamed: @"HeaderProfilePortraitBoth"])];
        
        [self.headerChannelsView setBackgroundImage: [SYNDeviceManager.sharedInstance isLandscape] ?
                                                        [UIImage imageNamed: @"HeaderProfileChannelsLandscape"]:
                                                        [UIImage imageNamed: @"HeaderProfilePortraitBoth"]];
    }
    
    viewHeight = [[SYNDeviceManager sharedInstance] currentScreenHeightWithStatusBar];
    
    // Setup Channel feed collection view
    newFrame = self.channelThumbnailCollectionView.frame;
    newFrame.size.width = self.isIPhone ? 320.0f : self.headerChannelsView.frame.size.width;
    
    newFrame.size.height = viewHeight - newFrame.origin.y;
    self.channelThumbnailCollectionView.collectionViewLayout = channelsLayout;
    self.channelThumbnailCollectionView.frame = newFrame;
    
    
    //Setup subscription feed collection view
    newFrame = self.subscriptionsViewController.view.frame;
    newFrame.size.width = self.isIPhone ? 320.0f : self.headerSubscriptionsView.frame.size.width;
    newFrame.size.height = viewHeight - newFrame.origin.y;
    newFrame.origin.x = self.isIPhone ? 0.0f : self.headerSubscriptionsView.frame.origin.x;
    self.subscriptionsViewController.channelThumbnailCollectionView.collectionViewLayout = subscriptionsLayout;
    self.subscriptionsViewController.view.frame = newFrame;
    
    
    [subscriptionsLayout invalidateLayout];
    [channelsLayout invalidateLayout];
    
    [self resizeScrollViews];
}


- (void) reloadCollectionViews
{
    NSInteger totalChannels = self.user.channels.count;
    NSString *title = [self getHeaderTitleForChannels];
    
    [self.headerChannelsView setTitle: title
                            andNumber: totalChannels];
    
    [self.subscriptionsViewController reloadCollectionViews];
    [self.channelThumbnailCollectionView reloadData];
    
    [self resizeScrollViews];
}


#pragma mark - Updating

- (NSString *) getHeaderTitleForChannels
{
    if (self.isIPhone)
    {
        if (self.user == appDelegate.currentUser)
        {
            return NSLocalizedString(@"profile_screen_section_owner_created_title", nil);
        }
        else
        {
            return NSLocalizedString(@"profile_screen_section_user_created_title", nil);
        }
    }
    else
    {
        if (self.user == appDelegate.currentUser)
        {
            return NSLocalizedString(@"profile_screen_section_owner_created_title", nil);
        }
        else
        {
            return NSLocalizedString(@"profile_screen_section_user_created_title", nil);
        }
    }
}


#pragma mark - UICollectionView DataSource/Delegate

- (NSInteger) collectionView: (UICollectionView *) view numberOfItemsInSection: (NSInteger) section
{
    return self.user.channels.count + (self.isUserProfile ? 1 : 0); // to account for the extra 'creation' cell at the start of the collection view
}


- (NSInteger) numberOfSectionsInCollectionView: (UICollectionView *) collectionView
{
    return 1;
}


- (UICollectionViewCell *) collectionView: (UICollectionView *) collectionView
                   cellForItemAtIndexPath: (NSIndexPath *) indexPath
{
    UICollectionViewCell *cell = nil;
    
    if (self.isUserProfile && indexPath.row == 0) // first row for a user profile only (create)
    {
        SYNChannelCreateNewCell *createCell = [collectionView dequeueReusableCellWithReuseIdentifier: @"SYNChannelCreateNewCell"
                                                                                        forIndexPath: indexPath];
        
        cell = createCell;
    }
    else
    {
        Channel *channel = (Channel *) self.user.channels[indexPath.row - (self.isUserProfile ? 1 : 0)];
        
        SYNChannelMidCell *channelThumbnailCell = [collectionView dequeueReusableCellWithReuseIdentifier: @"SYNChannelMidCell"
                                                                                            forIndexPath: indexPath];
        
        [channelThumbnailCell.imageView setImageWithURL: [NSURL URLWithString: channel.channelCover.imageLargeUrl]
                                       placeholderImage: [UIImage imageNamed: @"PlaceholderChannelMid.png"]
                                                options: SDWebImageRetryFailed];
        
        // Make sure we can't delete the favourites channel
        if (channel.favouritesValue)
        {
            channelThumbnailCell.deleteButton.enabled = NO;
        }
        else
        {
            channelThumbnailCell.deleteButton.enabled = YES;
        }
        
        [channelThumbnailCell setChannelTitle: channel.title];
        [channelThumbnailCell setViewControllerDelegate: (id<SYNChannelMidCellDelegate>) self];
        
        cell = channelThumbnailCell;
    }
    
    return cell;
}


- (void)	  collectionView: (UICollectionView *) collectionView
          didSelectItemAtIndexPath: (NSIndexPath *) indexPath
{
    Channel *channel;
    
    if (collectionView == self.channelThumbnailCollectionView)
    {
        if (self.isUserProfile && indexPath.row == 0)
        {
            if (IS_IPAD)
            {
                [self createAndDisplayNewChannel];
            }
            else
            {
                //On iPhone we want a different navigation structure. Slide the view in.
                
                SYNChannelDetailViewController *channelCreationVC =
                [[SYNChannelDetailViewController alloc] initWithChannel: appDelegate.videoQueue.currentlyCreatingChannel
                                                              usingMode: kChannelDetailsModeCreate];
                
                CGRect newFrame = channelCreationVC.view.frame;
                newFrame.size.height = self.view.frame.size.height;
                channelCreationVC.view.frame = newFrame;
                CATransition *animation = [CATransition animation];
                
                [animation setType: kCATransitionMoveIn];
                [animation setSubtype: kCATransitionFromRight];
                
                [animation setDuration: 0.30];
                
                [animation setTimingFunction: [CAMediaTimingFunction functionWithName:
                                               kCAMediaTimingFunctionEaseInEaseOut]];
                
                [self.view.window.layer addAnimation: animation
                                              forKey: nil];
                
                [self presentViewController: channelCreationVC
                                   animated: NO
                                 completion: ^{
                                     [self createAndDisplayNewChannel];
                                 }];
            }
            
            return;
        }
        else
        {
            channel = self.user.channels[indexPath.row - (self.isUserProfile ? 1 : 0)];
        }
    }
    else
    {
        channel = self.user.subscriptions[indexPath.row];
    }
    
    [appDelegate.viewStackManager viewChannelDetails: channel];
}



- (void) scrollViewDidScroll: (UIScrollView *) scrollView
{
    if (!self.isIPhone)
    {
        if (self.orientationDesicionmaker && scrollView != self.orientationDesicionmaker)
        {
            scrollView.contentOffset = [self.orientationDesicionmaker contentOffset];
            return;
        }
        
        CGPoint offset;
        
        if ([scrollView isEqual: self.channelThumbnailCollectionView])
        {
            offset = self.channelThumbnailCollectionView.contentOffset;
            offset.y = self.channelThumbnailCollectionView.contentOffset.y;
            [self.subscriptionsViewController.collectionView setContentOffset: offset];
        }
        else if ([scrollView isEqual: self.subscriptionsViewController.collectionView])
        {
            offset = self.subscriptionsViewController.collectionView.contentOffset;
            offset.y = self.subscriptionsViewController.collectionView.contentOffset.y;
            [self.channelThumbnailCollectionView setContentOffset: offset];
        }
    }
}


- (void) resizeScrollViews
{
    if (self.isIPhone)
    {
        return;
    }
    
    self.channelThumbnailCollectionView.contentInset = UIEdgeInsetsZero;
    self.subscriptionsViewController.collectionView.contentInset = UIEdgeInsetsZero;
    CGSize channelViewSize = self.channelThumbnailCollectionView.collectionViewLayout.collectionViewContentSize;
    CGSize subscriptionsViewSize = self.subscriptionsViewController.collectionView.collectionViewLayout.collectionViewContentSize;
    
    if (channelViewSize.height < subscriptionsViewSize.height)
    {
        self.channelThumbnailCollectionView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, subscriptionsViewSize.height - channelViewSize.height, 0.0f);
    }
    else if (channelViewSize.height > subscriptionsViewSize.height)
    {
        self.subscriptionsViewController.collectionView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, channelViewSize.height - subscriptionsViewSize.height, 0.0f);
    }
}


#pragma mark - tab button actions

- (IBAction) channelsTabTapped: (id) sender
{
    self.subscriptionsTabActive = NO;
    [self updateTabStates];
}


- (IBAction) subscriptionsTabTapped: (id) sender
{
    self.subscriptionsTabActive = YES;
    [self updateTabStates];
}


- (void) updateTabStates
{
    self.channelThumbnailCollectionView.scrollsToTop = !self.subscriptionsTabActive;
    
    self.subscriptionsViewController.channelThumbnailCollectionView.scrollsToTop = self.subscriptionsTabActive;
    
    self.channelsTabButton.selected = !self.subscriptionsTabActive;
    self.subscriptionsTabButton.selected = self.subscriptionsTabActive;
    self.channelThumbnailCollectionView.hidden = self.subscriptionsTabActive;
    self.subscriptionsViewController.view.hidden = !self.subscriptionsTabActive;
    
    if (self.subscriptionsTabActive)
    {
        [self.headerChannelsView setColorsForText: [UIColor colorWithRed: 106.0f / 255.0f
                                                                   green: 114.0f / 255.0f
                                                                    blue: 122.0f / 255.0f
                                                                   alpha: 1.0f]
                                      parentheses: [UIColor colorWithRed: 187.0f / 255.0f
                                                                   green: 187.0f / 255.0f
                                                                    blue: 187.0f / 255.0f
                                                                   alpha: 1.0f]
                                           number: [UIColor colorWithRed: 11.0f / 255.0f
                                                                   green: 166.0f / 255.0f
                                                                    blue: 171.0f / 255.0f
                                                                   alpha: 1.0f]];
        
        [self.headerSubscriptionsView setColorsForText: [UIColor colorWithRed: 1.0f
                                                                        green: 1.0f
                                                                         blue: 1.0f
                                                                        alpha: 1.0f]
                                           parentheses: [UIColor colorWithRed: 1.0f
                                                                        green: 1.0f
                                                                         blue: 1.0f
                                                                        alpha: 1.0f]
                                                number: [UIColor colorWithRed: 1.0f
                                                                        green: 1.0f
                                                                         blue: 1.0f
                                                                        alpha: 1.0f]];
    }
    else
    {
        [self.headerSubscriptionsView setColorsForText: [UIColor colorWithRed: 106.0f / 255.0f
                                                                        green: 114.0f / 255.0f
                                                                         blue: 122.0f / 255.0f
                                                                        alpha: 1.0f]
                                           parentheses: [UIColor colorWithRed: 187.0f / 255.0f
                                                                        green: 187.0f / 255.0f
                                                                         blue: 187.0f / 255.0f
                                                                        alpha: 1.0f]
                                                number: [UIColor colorWithRed: 11.0f / 255.0f
                                                                        green: 166.0f / 255.0f
                                                                         blue: 171.0f / 255.0f
                                                                        alpha: 1.0f]];
        
        [self.headerChannelsView setColorsForText: [UIColor colorWithRed: 1.0f
                                                                   green: 1.0f
                                                                    blue: 1.0f
                                                                   alpha: 1.0f]
                                      parentheses: [UIColor colorWithRed: 1.0f
                                                                   green: 1.0f
                                                                    blue: 1.0f
                                                                   alpha: 1.0f]
                                           number: [UIColor colorWithRed: 1.0f
                                                                   green: 1.0f
                                                                    blue: 1.0f
                                                                   alpha: 1.0f]];
    }
}


#pragma mark - Deleting Channels

- (void) channelDeleteButtonTapped: (UIButton *) sender
{
    if (_deleteCellModeOn)
    {
        return;
    }
    
    UIView *v = sender.superview.superview;
    self.indexPathToDelete = [self.channelThumbnailCollectionView indexPathForItemAtPoint: v.center];
    
    Channel *channelToDelete = (Channel *) self.user.channels[self.indexPathToDelete.row - (self.isUserProfile ? 1 : 0)];
    
    if (!channelToDelete)
    {
        return;
    }
    
    NSString *message = [NSString stringWithFormat: NSLocalizedString(@"profile_screen_channel_delete_dialog_description", nil), channelToDelete.title];
    NSString *title = [NSString stringWithFormat: NSLocalizedString(@"profile_screen_channel_delete_dialog_title", nil), channelToDelete.title ];
    
    [[[UIAlertView alloc] initWithTitle: title
                                message: message
                               delegate: self
                      cancelButtonTitle: NSLocalizedString(@"Cancel", nil)
                      otherButtonTitles: NSLocalizedString(@"Delete", nil), nil] show];
}


- (void)	 alertView: (UIAlertView *) alertView
         willDismissWithButtonIndex: (NSInteger) buttonIndex
{
    if (buttonIndex == 1)
    {
        [self deleteChannel];
    }
    else
    {
        // Cancel Clicked, do nothing
    }
}


- (void) deleteChannel
{
    Channel *channelToDelete = (Channel *) self.user.channels[self.indexPathToDelete.row - (self.isUserProfile ? 1 : 0)];
    
    if (!channelToDelete)
    {
        return;
    }
    
    [appDelegate.oAuthNetworkEngine
     deleteChannelForUserId: appDelegate.currentUser.uniqueId
     channelId: channelToDelete.uniqueId
     completionHandler: ^(id response) {
         UICollectionViewCell *cell = [self.channelThumbnailCollectionView cellForItemAtIndexPath: self.indexPathToDelete];
         
         [UIView	 animateWithDuration: 0.2
                           animations: ^{
                               cell.alpha = 0.0;
                           }
                           completion: ^(BOOL finished) {
                               [appDelegate.currentUser.channelsSet
                                removeObject: channelToDelete];
                               
                               [channelToDelete.managedObjectContext
                                deleteObject: channelToDelete];
                               
                               [self.channelThumbnailCollectionView deleteItemsAtIndexPaths: @[self.indexPathToDelete]];
                               
                               [appDelegate saveContext: YES];
                               
                               _deleteCellModeOn = NO;
                           }];
     }
     errorHandler: ^(id error) {
         DebugLog(@"Delete channel NOT succeed");
         
         _deleteCellModeOn = NO;
     }];
}


- (void) headerTapped
{
    // no need to animate the subscriptions part since it observes the channels thumbnails scroll view
    [self.channelThumbnailCollectionView setContentOffset: CGPointZero
                                                 animated: YES];
}


#pragma mark - Accessors

- (void) setUser: (ChannelOwner *) user
{
    if (self.user) // if we have an existing user
    {
        // remove the listener, even if nil is passed
        
        [[NSNotificationCenter defaultCenter] removeObserver: self
                                                        name: NSManagedObjectContextDidSaveNotification
                                                      object: self.user];
    }
    
    if (!appDelegate)
    {
        appDelegate = (SYNAppDelegate *) [[UIApplication sharedApplication] delegate];
    }
    
    if (!user) // if no user has been passed, set to nil and then return
    {
        return;
    }
    
    if (![user isMemberOfClass: [User class]]) // is a User has been passsed dont copy him OR his channels as there can be only one.
    {
        NSFetchRequest *channelOwnerFetchRequest = [[NSFetchRequest alloc] init];
        
        [channelOwnerFetchRequest setEntity: [NSEntityDescription entityForName: @"ChannelOwner"
                                                         inManagedObjectContext: user.managedObjectContext]];
        
        channelOwnerFetchRequest.includesSubentities = NO;
        
        [channelOwnerFetchRequest setPredicate: [NSPredicate predicateWithFormat: @"uniqueId == %@ AND viewId == %@", user.uniqueId, self.viewId]];
        
        NSError *error = nil;
        NSArray *matchingChannelOwnerEntries = [user.managedObjectContext
                                                executeFetchRequest: channelOwnerFetchRequest
                                                error: &error];
        
        if (matchingChannelOwnerEntries.count > 0)
        {
            _user = (ChannelOwner *) matchingChannelOwnerEntries[0];
            _user.markedForDeletionValue = NO;
            
            if (matchingChannelOwnerEntries.count > 1) // housekeeping, there can be only one!
            {
                for (int i = 1; i < matchingChannelOwnerEntries.count; i++)
                {
                    [user.managedObjectContext
                     deleteObject: (matchingChannelOwnerEntries[i])];
                }
            }
        }
        else
        {
            IgnoringObjects flags = kIgnoreChannelOwnerObject | kIgnoreVideoInstanceObjects; // these flags are passed to the Channels
            
            _user = [ChannelOwner instanceFromChannelOwner: user
                                                 andViewId: self.viewId
                                 usingManagedObjectContext: user.managedObjectContext
                                       ignoringObjectTypes: flags];
            
            if (self.user)
            {
                [self.user.managedObjectContext save: &error];
                
                if (error)
                {
                    _user = nil; // further error code
                }
            }
        }
    }
    else
    {
        _user = user; // if User isKindOfClass [User class]
    }
    
    if (self.user) // if a user has been passed or found, monitor
    {
        if ([self.user.uniqueId isEqualToString: appDelegate.currentUser.uniqueId])
        {
            self.isUserProfile = YES;
        }
        else
        {
            self.isUserProfile = NO;
        }
        
        self.subscriptionsViewController.user = self.user;
        
        
        self.userProfileController.channelOwner = self.user;
        
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(handleDataModelChange:)
                                                     name: NSManagedObjectContextDidSaveNotification
                                                   object: self.user.managedObjectContext];
        
        [[NSNotificationCenter defaultCenter] postNotificationName: kChannelOwnerUpdateRequest
                                                            object: self
                                                          userInfo: @{kChannelOwner : self.user}];
    }
}


#pragma mark - indexpath helper method

- (NSIndexPath *) topIndexPathForCollectionView: (UICollectionView *) collectionView
{
    //This method finds a cell that is in the first row of the collection view that is showing at least half the height of its cell.
    NSIndexPath *result = nil;
    NSArray *indexPaths = [[collectionView indexPathsForVisibleItems] sortedArrayUsingDescriptors: self.sortDescriptors];
    
    if ([indexPaths count] > 0)
    {
        result = indexPaths[0];
        UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath: result];
        
        if (cell.center.y < collectionView.contentOffset.y)
        {
            if ([indexPaths count] > 3)
            {
                result = indexPaths[3];
            }
        }
    }
    
    return result;
}


#pragma mark - Arc menu support

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
        Channel *channel = [self channelInstanceForIndexPath: self.arcMenuIndexPath
                                           andComponentIndex: kArcMenuInvalidComponentIndex];
        
        [self requestShareLinkWithObjectType: @"channel"
                                    objectId: channel.uniqueId];
        
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
    
    Channel *channel = (Channel *) self.user.channels[indexPath.row - (self.isUserProfile ? 1 : 0)];
    
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
    
    Channel *channel = (Channel *) self.user.channels[indexPath.row - (self.isUserProfile ? 1 : 0)];
    
    [appDelegate.viewStackManager viewProfileDetails: channel.channelOwner];
}


- (void) channelTapped: (UICollectionViewCell *) cell
{
    SYNChannelThumbnailCell *selectedCell = (SYNChannelThumbnailCell *) cell;
    NSIndexPath *indexPath = [self.channelThumbnailCollectionView indexPathForItemAtPoint: selectedCell.center];
    
    if (self.isDeletionModeActive)
    {
        self.deletionModeActive = NO;
        return;
    }
    
    Channel *channel;
    
    if (self.isUserProfile && indexPath.row == 0)
    {
        [self createAndDisplayNewChannel];
        
        return;
    }
    else
    {
        self.indexPathToDelete = indexPath;
        channel = self.user.channels[indexPath.row - (self.isUserProfile ? 1 : 0)];
    }

    
    [appDelegate.viewStackManager viewChannelDetails: channel];
}


@end
