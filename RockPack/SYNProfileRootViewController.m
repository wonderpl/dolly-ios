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
#import "SYNYouHeaderView.h"
#import "UIFont+SYNFont.h"
#import "UIImageView+WebCache.h"
#import "Video.h"
#import <QuartzCore/QuartzCore.h>

#define kInterRowMargin 8.0f

@interface SYNProfileRootViewController () <
UIGestureRecognizerDelegate,
SYNImagePickerControllerDelegate>

@property (nonatomic) BOOL deleteCellModeOn;
@property (nonatomic) BOOL isIPhone;
@property (nonatomic) BOOL isUserProfile;
@property (nonatomic) BOOL trackView;
@property (nonatomic, assign) BOOL subscriptionsTabActive;
@property (nonatomic, assign, getter = isDeletionModeActive) BOOL deletionModeActive;

@property (nonatomic, strong) NSArray *sortDescriptors;
@property (nonatomic, strong) NSIndexPath *channelsIndexPath;
@property (nonatomic, strong) NSIndexPath *indexPathToDelete;
@property (nonatomic, strong) NSIndexPath *subscriptionsIndexPath;

@property (nonatomic, strong) id orientationDesicionmaker;

@property (nonatomic, weak) IBOutlet UIButton *channelsTabButton;
@property (nonatomic, weak) IBOutlet UIButton *subscriptionsTabButton;

@property (nonatomic, strong) SYNImagePickerController* imagePickerController;

@property (nonatomic, strong) IBOutlet SYNYouHeaderView *headerChannelsView;
@property (nonatomic, strong) IBOutlet SYNYouHeaderView *headerSubscriptionsView;
@property (strong, nonatomic) IBOutlet UICollectionViewFlowLayout *channelLayoutIPad;
@property (strong, nonatomic) IBOutlet UICollectionViewFlowLayout *subscriptionLayoutIPad;

@property (strong, nonatomic) IBOutlet UICollectionViewFlowLayout *channelLayoutIPhone;
@property (strong, nonatomic) IBOutlet UICollectionViewFlowLayout *subscriptionLayoutIPhone;
@property (nonatomic, strong) IBOutlet UICollectionView *channelThumbnailCollectionView;
@property (strong, nonatomic) IBOutlet UICollectionView *subscriptionThumbnailCollectionView;
@property (strong, nonatomic) IBOutlet UIScrollView *mainScrollView;
@property (strong, nonatomic) IBOutlet UIView *userProfileView;

@property (strong, nonatomic) IBOutlet UIImageView *profileImageView;
@property (strong, nonatomic) IBOutlet UIButton *avatarButton;

@property (strong, nonatomic) IBOutlet UILabel *fullNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *userNameLabel;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatiorView;


@end




@implementation SYNProfileRootViewController

#pragma mark - Object lifecycle

- (id) initWithViewId:(NSString *)vid
{
    if (self = [super initWithNibName:NSStringFromClass([SYNProfileRootViewController class]) bundle:nil])
    {
        viewId = vid;
        
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(handleDataModelChange:)
                                                     name: NSManagedObjectContextObjectsDidChangeNotification
                                                   object: appDelegate.searchManagedObjectContext];
        
        
    }
    
    return self;
}

- (void) dealloc
{
    self.channelOwner = nil;
    self.subscriptionThumbnailCollectionView.delegate =nil;
    self.subscriptionThumbnailCollectionView.dataSource =nil;
    // Defensive programming
    self.channelThumbnailCollectionView.delegate = nil;
    self.channelThumbnailCollectionView.dataSource = nil;
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
    
    [self.subscriptionThumbnailCollectionView registerNib: thumbnailCellNib
                               forCellWithReuseIdentifier: @"SYNChannelMidCell"];
    self.isIPhone = IS_IPHONE;
    
    // Main Collection View
    
    if (!self.isIPhone)
    {
        self.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey: @"section"
                                                               ascending: YES], [NSSortDescriptor sortDescriptorWithKey: @"row" ascending: YES]];
    }
    
    if (IS_IPHONE)
    {
        self.subscriptionThumbnailCollectionView.collectionViewLayout = self.subscriptionLayoutIPhone;
        self.channelThumbnailCollectionView.collectionViewLayout = self.channelLayoutIPhone;
        
    }else{
        self.channelThumbnailCollectionView.collectionViewLayout = self.channelLayoutIPad;
        self.subscriptionThumbnailCollectionView.collectionViewLayout = self.subscriptionLayoutIPad;
    }
    [self setUpUserProfile];
    
    [self setUpHeader];
    
    if (self.isIPhone)
    {
        [self updateTabStates];
    }
    
    
    
    
    self.subscriptionThumbnailCollectionView.scrollsToTop = NO;
    self.channelThumbnailCollectionView.scrollsToTop = NO;
    
}

-(void)viewWillAppear:(BOOL)animated{
   // [self resizeScrollViews];
}

- (void) viewDidAppear: (BOOL) animated
{
 //   self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    
    
    [super viewDidAppear: animated];
    
    if (self.channelOwner == appDelegate.currentUser)
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
            self.subscriptionThumbnailCollectionView.scrollsToTop = self.subscriptionsTabActive;
        }
        else
        {
            self.channelThumbnailCollectionView.scrollsToTop = YES;
            self.subscriptionThumbnailCollectionView.scrollsToTop = NO;
        }
        
        // Google analytics support
        id tracker = [[GAI sharedInstance] defaultTracker];
        
        [tracker set: kGAIScreenName
               value: @"User Profile"];
        
        [tracker send: [[GAIDictionaryBuilder createAppView] build]];
    }
    
    self.deletionModeActive = NO;
    
    self.channelThumbnailCollectionView.delegate=self;
    self.subscriptionThumbnailCollectionView.delegate=self;
    
    [self updateLayoutForOrientation: [SYNDeviceManager.sharedInstance orientation]];
    
    [self.channelThumbnailCollectionView reloadData];
    [self.subscriptionThumbnailCollectionView reloadData];
   // [self updateMainScrollView];
    
}


- (void) viewWillDisappear: (BOOL) animated
{
   // self.navigationController.navigationBar.hidden = NO;

    self.channelThumbnailCollectionView.delegate = nil;
    self.subscriptionThumbnailCollectionView.delegate = nil;
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
        
        self.subscriptionThumbnailCollectionView.scrollsToTop = self.subscriptionsTabActive;
    }
    else
    {
        self.channelThumbnailCollectionView.scrollsToTop = YES;
        
        self.subscriptionThumbnailCollectionView.scrollsToTop = YES;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName: kChannelOwnerUpdateRequest
                                                        object: self
                                                      userInfo: @{kChannelOwner: self.channelOwner}];
}

- (void) viewDidScrollToBack
{
    self.channelThumbnailCollectionView.scrollsToTop = NO;
    self.subscriptionThumbnailCollectionView.scrollsToTop = NO;
}

- (void) updateAnalytics
{
    // Google analytics support
    id tracker = [[GAI sharedInstance] defaultTracker];
    
    // Google analytics support
    if (self.channelOwner == appDelegate.currentUser)
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


#pragma mark - User Profile

//config for user profile views

-(void) setUpUserProfile
{
    
    self.fullNameLabel.font = [UIFont boldSystemFontOfSize:30];
    self.userNameLabel.font = [UIFont lightCustomFontOfSize:12.0];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(userDataChanged:)
                                                 name: kUserDataChanged
                                               object: nil];
    
    self.userNameLabel.text = self.channelOwner.username;
    self.fullNameLabel.text = self.channelOwner.displayName;
    
    UIImage* placeholderImage = [UIImage imageNamed: @"PlaceholderAvatarProfile"];
    
    if (![self.channelOwner.thumbnailURL isEqualToString:@""]){ // there is a url string
        
        dispatch_queue_t downloadQueue = dispatch_queue_create("com.rockpack.avatarloadingqueue", NULL);
        dispatch_async(downloadQueue, ^{
            
            NSData * imageData = [NSData dataWithContentsOfURL: [NSURL URLWithString: self.channelOwner.thumbnailURL ]];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.self.profileImageView.image = [UIImage imageWithData: imageData];
            });
        });
        
    }else{
        self.profileImageView.image = placeholderImage;
    }
}

-(void) setUpHeader {
    
    SYNYouHeaderView *tmpHeaderChannelsView;
    SYNYouHeaderView *tmpHeaderSubscriptionsView;
    
    if (!self.isIPhone)
    {
        CGFloat correctWidth = [SYNDeviceManager.sharedInstance isLandscape] ? 600.0 : 400.0;
        
        self.headerChannelsView.frame = CGRectMake(self.headerChannelsView.frame.origin.x, self.headerChannelsView.frame.origin.y, correctWidth, self.headerChannelsView.frame.size.height);
        
        tmpHeaderChannelsView = [[SYNYouHeaderView alloc]initWithFrame:self.headerChannelsView.frame];
        self.headerSubscriptionsView.frame = CGRectMake(self.headerSubscriptionsView.frame.origin.x, self.headerSubscriptionsView.frame.origin.y, correctWidth, self.headerSubscriptionsView.frame.size.height);
        tmpHeaderSubscriptionsView = [[SYNYouHeaderView alloc]initWithFrame:self.headerSubscriptionsView.frame];
        
        self.headerChannelsView = tmpHeaderChannelsView;
        self.headerSubscriptionsView = tmpHeaderSubscriptionsView;
        [tmpHeaderChannelsView setTitle: [self getHeaderTitleForChannels] andNumber: self.channelOwner.channels.count];
        [tmpHeaderSubscriptionsView setTitle: NSLocalizedString(@"profile_screen_section_owner_subscription_title", nil) andNumber: self.channelOwner.subscriptions.count];
        
        
        [self.view addSubview:tmpHeaderChannelsView];
        [self.view addSubview:tmpHeaderSubscriptionsView];
        
    }
    
    if (self.isIPhone)
    {
        
        tmpHeaderChannelsView = [[SYNYouHeaderView alloc]initWithFrame:self.channelsTabButton.frame];
        tmpHeaderSubscriptionsView = [[SYNYouHeaderView alloc]initWithFrame:self.subscriptionsTabButton.frame];
        
        self.headerChannelsView = tmpHeaderChannelsView;
        self.headerSubscriptionsView = tmpHeaderSubscriptionsView;
        
        [tmpHeaderChannelsView setFontSize: 12.0f];
        [tmpHeaderSubscriptionsView setFontSize: 12.0f];
        [tmpHeaderChannelsView setTitle: [self getHeaderTitleForChannels] andNumber: self.channelOwner.channels.count];
        [tmpHeaderSubscriptionsView setTitle: NSLocalizedString(@"profile_screen_section_owner_subscription_title", nil) andNumber: self.channelOwner.subscriptions.count];
        
        tmpHeaderChannelsView.userInteractionEnabled = NO;
        tmpHeaderSubscriptionsView.userInteractionEnabled = NO;
        
        [self.channelsTabButton addSubview:tmpHeaderChannelsView];
        [self.channelsTabButton addSubview:tmpHeaderSubscriptionsView];
        
    }
}

- (void) updateMainScrollView {
    NSLog(@"Before, %f", self.mainScrollView.frame.size.height);
    NSLog(@"%f", self.mainScrollView.contentSize.height);

    CGRect newFrame = self.mainScrollView.frame;
    newFrame.size.height = 400;
    newFrame.size.height += self.channelThumbnailCollectionView.contentSize.height;
    
    self.mainScrollView.contentSize = newFrame.size;

    NSLog(@"After, %f", self.mainScrollView.frame.size.height);
    NSLog(@"%f", self.mainScrollView.contentSize.height);

}


- (void) userDataChanged: (NSNotification*) notification
{
    User* currentUser = (User*)[notification userInfo][@"user"];
    if(!currentUser)
        return;
    
    if ([self.channelOwner.uniqueId isEqualToString: currentUser.uniqueId])
    {
        [self setChannelOwner: currentUser];
    }
}



- (IBAction) userTouchedAvatarButton: (UIButton *) avatarButton
{
    self.imagePickerController = [[SYNImagePickerController alloc] initWithHostViewController: self];
    self.imagePickerController.delegate = self;
    
    [self.imagePickerController presentImagePickerAsPopupFromView: avatarButton
                                                   arrowDirection: UIPopoverArrowDirectionUp];
}

#pragma mark - Core Data Callbacks

- (void) handleDataModelChange: (NSNotification *) notification
{
    NSArray *updatedObjects = [notification userInfo][NSUpdatedObjectsKey];
    
    
    [updatedObjects enumerateObjectsUsingBlock: ^(id obj, NSUInteger idx, BOOL *stop)
     {
         if (obj == self.channelOwner)
         {
             
             [self reloadCollectionViews];
             
             return;
         }
     }];
    
}

//Doesnt work as expected, check it out.
- (BOOL)prefersStatusBarHidden
{
    return YES;
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
    if (self.channelThumbnailCollectionView.collectionViewLayout.collectionViewContentSize.height > self.subscriptionThumbnailCollectionView.collectionViewLayout.collectionViewContentSize.height)
    {
        self.channelsIndexPath = [self topIndexPathForCollectionView: self.channelThumbnailCollectionView];
        self.orientationDesicionmaker = self.channelThumbnailCollectionView;
    }
    else
    {
        self.subscriptionsIndexPath = [self topIndexPathForCollectionView: self.subscriptionThumbnailCollectionView];
        self.orientationDesicionmaker = self.subscriptionThumbnailCollectionView;
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
        [self.subscriptionThumbnailCollectionView scrollToItemAtIndexPath: self.subscriptionsIndexPath
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
                         self.subscriptionThumbnailCollectionView.alpha = 1.0f;
                     }
     
     
                     completion: nil];
}


- (void) willAnimateRotationToInterfaceOrientation: (UIInterfaceOrientation) toInterfaceOrientation
                                          duration: (NSTimeInterval) duration
{
    //Fade out collections as they don't animate well together.
    self.channelThumbnailCollectionView.alpha = 0.0f;
    self.subscriptionThumbnailCollectionView.alpha = 0.0f;
    [self updateLayoutForOrientation: toInterfaceOrientation];
}


- (void) updateLayoutForOrientation: (UIDeviceOrientation) orientation
{
    CGRect newFrame;
    CGFloat viewHeight;
    UICollectionViewFlowLayout *channelsLayout;
    UICollectionViewFlowLayout *subscriptionsLayout;
    
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
        channelsLayout = self.channelLayoutIPhone;
        subscriptionsLayout = self.subscriptionLayoutIPhone;
        
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
            
            self.channelLayoutIPad.minimumLineSpacing = 0.0f;
            self.channelLayoutIPad.sectionInset = UIEdgeInsetsMake(kInterRowMargin, 0.0, kInterRowMargin, 0.0);
            self.subscriptionLayoutIPad.minimumLineSpacing = 0.0f;
            self.subscriptionLayoutIPad.sectionInset = UIEdgeInsetsMake(kInterRowMargin, 0.0, kInterRowMargin, 0.0);
            
            channelsLayout = self.channelLayoutIPad;
            subscriptionsLayout = self.subscriptionLayoutIPad;
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
            
            self.channelLayoutIPad.sectionInset = UIEdgeInsetsMake(kInterRowMargin - 8.0, 12.0, kInterRowMargin, 11.0);
            
            self.subscriptionLayoutIPad.sectionInset = UIEdgeInsetsMake(kInterRowMargin - 8.0, 12.0, kInterRowMargin, 11.0);
            
            self.channelLayoutIPad.minimumLineSpacing = 5.0f;
            
            self.subscriptionLayoutIPad.minimumLineSpacing = 5.0f;
            channelsLayout = self.channelLayoutIPad;
            subscriptionsLayout = self.subscriptionLayoutIPad;
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
    newFrame = self.subscriptionThumbnailCollectionView.frame;
    newFrame.size.width = self.isIPhone ? 320.0f : self.headerSubscriptionsView.frame.size.width;
    newFrame.size.height = viewHeight - newFrame.origin.y;
    newFrame.origin.x = self.isIPhone ? 0.0f : self.headerSubscriptionsView.frame.origin.x;
    self.self.self.subscriptionThumbnailCollectionView.collectionViewLayout = subscriptionsLayout;
    self.self.self.subscriptionThumbnailCollectionView.frame = newFrame;
    
    
    [subscriptionsLayout invalidateLayout];
    [channelsLayout invalidateLayout];
    
    [self resizeScrollViews];
}

-(void) rotateForBugFix
{
    
    if (self.channelThumbnailCollectionView.collectionViewLayout.collectionViewContentSize.height > self.subscriptionThumbnailCollectionView.collectionViewLayout.collectionViewContentSize.height)
    {
        self.channelsIndexPath = [self topIndexPathForCollectionView: self.channelThumbnailCollectionView];
        self.orientationDesicionmaker = self.channelThumbnailCollectionView;
    }
    else
    {
        self.subscriptionsIndexPath = [self topIndexPathForCollectionView: self.subscriptionThumbnailCollectionView];
        self.orientationDesicionmaker = self.subscriptionThumbnailCollectionView;
    }
    
    if (self.channelsIndexPath)
    {
        [self.channelThumbnailCollectionView scrollToItemAtIndexPath: self.channelsIndexPath
                                                    atScrollPosition: UICollectionViewScrollPositionTop
                                                            animated: NO];
    }
    
    if (self.subscriptionsIndexPath)
    {
        [self.subscriptionThumbnailCollectionView scrollToItemAtIndexPath: self.subscriptionsIndexPath
                                                         atScrollPosition: UICollectionViewScrollPositionTop
                                                                 animated: NO];
    }
    
    self.orientationDesicionmaker = nil;
    
    self.channelsIndexPath = nil;
    self.subscriptionsIndexPath = nil;
    
    [self updateLayoutForOrientation: [SYNDeviceManager.sharedInstance orientation]];
}



- (void) reloadCollectionViews
{
    
    [self.headerChannelsView setTitle: [self getHeaderTitleForChannels] andNumber: self.channelOwner.channels.count];
    [self.headerSubscriptionsView setTitle: [self getHeaderTitleForChannels] andNumber: self.channelOwner.subscriptions.count];
    
    [self.subscriptionThumbnailCollectionView reloadData];
    [self.channelThumbnailCollectionView reloadData];
  //  [self resizeScrollViews];

}


#pragma mark - Updating

- (NSString *) getHeaderTitleForChannels
{
    if (self.isIPhone)
    {
        if (self.channelOwner == appDelegate.currentUser)
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
        if (self.channelOwner == appDelegate.currentUser)
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
    
    if ([view isEqual:self.subscriptionThumbnailCollectionView]) {
        
        return self.channelOwner.subscriptions.count;
    }
    
    return self.channelOwner.channels.count + (self.isUserProfile ? 1 : 0); // to account for the extra 'creation' cell at the start of the collection view
}


- (NSInteger) numberOfSectionsInCollectionView: (UICollectionView *) collectionView
{
    
    if ([collectionView isEqual:self.subscriptionThumbnailCollectionView]) {
        return 1;
    }
    return 1;
}


- (UICollectionViewCell *) collectionView: (UICollectionView *) collectionView
                   cellForItemAtIndexPath: (NSIndexPath *) indexPath
{
    
    UICollectionViewCell *cell = nil;
    
    
    SYNChannelMidCell *channelThumbnailCell = [collectionView dequeueReusableCellWithReuseIdentifier: @"SYNChannelMidCell" forIndexPath: indexPath];
    
    if (self.isUserProfile && indexPath.row == 0 && [collectionView isEqual:self.channelThumbnailCollectionView]) // first row for a user profile only (create)
    {
        SYNChannelCreateNewCell *createCell = [collectionView dequeueReusableCellWithReuseIdentifier: @"SYNChannelCreateNewCell" forIndexPath: indexPath];
        cell = createCell;
    }
    else if([collectionView isEqual:self.channelThumbnailCollectionView])
    {
        Channel *channel = (Channel *) self.channelOwner.channels[indexPath.row - (self.isUserProfile ? 1 : 0)];
        
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
    }else if ([collectionView isEqual:self.subscriptionThumbnailCollectionView]){
        
        
        Channel *channel = self.channelOwner.subscriptions[indexPath.item];
        
        [channelThumbnailCell.imageView setImageWithURL: [NSURL URLWithString: channel.channelCover.imageLargeUrl]
                                       placeholderImage: [UIImage imageNamed: @"PlaceholderChannelMid.png"]
                                                options: SDWebImageRetryFailed];
        
        if (channel.favouritesValue)
        {
            if ([appDelegate.currentUser.uniqueId isEqualToString:channel.channelOwner.uniqueId])
            {
                [channelThumbnailCell setChannelTitle: [NSString stringWithFormat:@"MY %@", NSLocalizedString(@"FAVORITES", nil)] ];
            }
            else
            {
                [channelThumbnailCell setChannelTitle:
                 [NSString stringWithFormat:@"%@'S %@", [channel.channelOwner.displayName uppercaseString], NSLocalizedString(@"FAVORITES", nil)]];
            }
        }
        else
        {
            [channelThumbnailCell setChannelTitle: channel.title];
        }
        
        [channelThumbnailCell setViewControllerDelegate: (id<SYNChannelMidCellDelegate>) self];
        cell = channelThumbnailCell;
    }
    
    
    return cell;
}


- (void) collectionView: (UICollectionView *) collectionView
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
                
                
                //presented twice
               /* [self presentViewController: channelCreationVC
                                   animated: NO
                                 completion: ^{
                                     
                                     */
                                     [self createAndDisplayNewChannel];
                               //  }];
            }
            
            return;
        }
        else
        {
            channel = self.channelOwner.channels[indexPath.row - (self.isUserProfile ? 1 : 0)];
        }
    }
    else
    {
        channel = self.channelOwner.subscriptions[indexPath.row];
    }
    
    
    
  //  [self.navigationController pushViewController:channel animated:nil];

    
    [appDelegate.viewStackManager viewChannelDetails: channel];

}

- (void) resizeScrollViews
{
    if (self.isIPhone)
    {
        return;
    }
    
    self.channelThumbnailCollectionView.contentInset = UIEdgeInsetsZero;
    self.subscriptionThumbnailCollectionView.contentInset = UIEdgeInsetsZero;
    
    
    CGSize channelViewSize = self.channelThumbnailCollectionView.collectionViewLayout.collectionViewContentSize;
    CGSize subscriptionsViewSize = self.subscriptionThumbnailCollectionView.collectionViewLayout.collectionViewContentSize;
    
    
    if (channelViewSize.height < subscriptionsViewSize.height)
    {
        NSLog(@"A WINS");
        NSLog(@"%f, %f", channelViewSize.height, subscriptionsViewSize.height);

        self.channelThumbnailCollectionView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, subscriptionsViewSize.height - channelViewSize.height, 0.0f);
    }
    else if (channelViewSize.height > subscriptionsViewSize.height)
    {
                NSLog(@"B WINS");
        NSLog(@"%f, %f", channelViewSize.height, subscriptionsViewSize.height);

        self.subscriptionThumbnailCollectionView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, channelViewSize.height - subscriptionsViewSize.height, 0.0f);
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
    self.subscriptionThumbnailCollectionView.scrollsToTop = self.subscriptionsTabActive;
    
    self.channelsTabButton.selected = !self.subscriptionsTabActive;
    self.subscriptionsTabButton.selected = self.subscriptionsTabActive;
    self.channelThumbnailCollectionView.hidden = self.subscriptionsTabActive;
    self.subscriptionThumbnailCollectionView.hidden = !self.subscriptionsTabActive;
    
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
    
    Channel *channelToDelete = (Channel *) self.channelOwner.channels[self.indexPathToDelete.row - (self.isUserProfile ? 1 : 0)];
    
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
    Channel *channelToDelete = (Channel *) self.channelOwner.channels[self.indexPathToDelete.row - (self.isUserProfile ? 1 : 0)];
    
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
    [self.channelThumbnailCollectionView setContentOffset: CGPointZero animated: YES];
}


#pragma mark - scroll view delegates


-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [super scrollViewWillBeginDragging:scrollView];
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    [super scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
}

- (void) scrollViewDidScroll: (UIScrollView *) scrollView
{
    
    [super scrollViewDidScroll:scrollView];
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
            [self.subscriptionThumbnailCollectionView setContentOffset: offset];
        }
        else if ([scrollView isEqual: self.subscriptionThumbnailCollectionView])
        {
            offset = self.subscriptionThumbnailCollectionView.contentOffset;
            offset.y = self.subscriptionThumbnailCollectionView.contentOffset.y;
            [self.channelThumbnailCollectionView setContentOffset: offset];
        }
    }
    
    if([self.moveTabDelegate respondsToSelector:@selector(moveTab:)])
    {
        [self.moveTabDelegate moveTab:scrollView];
    }
}



#pragma mark - Accessors

- (void) setChannelOwner: (ChannelOwner *) user
{
    if (self.channelOwner) // if we have an existing user
    {
        // remove the listener, even if nil is passed
        
        [[NSNotificationCenter defaultCenter] removeObserver: self
                                                        name: NSManagedObjectContextDidSaveNotification
                                                      object: self.channelOwner];
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
            _channelOwner = (ChannelOwner *) matchingChannelOwnerEntries[0];
            _channelOwner.markedForDeletionValue = NO;
            
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
            
            _channelOwner = [ChannelOwner instanceFromChannelOwner: user
                                                         andViewId: self.viewId
                                         usingManagedObjectContext: user.managedObjectContext
                                               ignoringObjectTypes: flags];
            
            if (self.channelOwner)
            {
                [self.channelOwner.managedObjectContext save: &error];
                
                if (error)
                {
                    _channelOwner = nil; // further error code
                }
            }
        }
    }
    else
    {
        _channelOwner = user; // if User isKindOfClass [User class]
    }
    
    if (self.channelOwner) // if a user has been passed or found, monitor
    {
        if ([self.channelOwner.uniqueId isEqualToString: appDelegate.currentUser.uniqueId])
        {
            self.isUserProfile = YES;
        }
        else
        {
            self.isUserProfile = NO;
        }
        
        
        
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(handleDataModelChange:)
                                                     name: NSManagedObjectContextDidSaveNotification
                                                   object: self.channelOwner.managedObjectContext];
        
        [[NSNotificationCenter defaultCenter] postNotificationName: kChannelOwnerUpdateRequest
                                                            object: self
                                                          userInfo: @{kChannelOwner : self.channelOwner}];
    }
    
    [self.subscriptionThumbnailCollectionView reloadData];
    [self.channelThumbnailCollectionView reloadData];
    
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



- (Channel *) channelInstanceForIndexPath: (NSIndexPath *) indexPath
                        andComponentIndex: (NSInteger) componentIndex
{
    
    
    
    Channel *channel = (Channel *) self.channelOwner.channels[indexPath.row - (self.isUserProfile ? 1 : 0)];
    
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
    
    Channel *channel = (Channel *) self.channelOwner.channels[indexPath.row - (self.isUserProfile ? 1 : 0)];
    
    [appDelegate.viewStackManager viewProfileDetails: channel.channelOwner];
}


- (void) channelTapped: (UICollectionViewCell *) cell
{
    SYNChannelThumbnailCell *selectedCell = (SYNChannelThumbnailCell *) cell;
    NSIndexPath *indexPath = [self.channelThumbnailCollectionView indexPathForItemAtPoint: selectedCell.center];
    
    
    if([cell.superview isEqual:self.channelThumbnailCollectionView])
    {
        
        Channel *channel;
        
        if (self.isUserProfile && indexPath.row == 0)
        {
        //never gets called, first cell gets called and created in didSelectItem
           // [self createAndDisplayNewChannel];
            
            return;
        }
        else
        {
            
          //  self.indexPathToDelete = indexPath;
            channel = self.channelOwner.channels[indexPath.row - (self.isUserProfile ? 1 : 0)];
        }
        
        [appDelegate.viewStackManager viewChannelDetails:channel withNavigationController:self.navigationController];
        
    }
    
    if([cell.superview isEqual:self.subscriptionThumbnailCollectionView])
    {
        
        SYNChannelMidCell *selectedCell = (SYNChannelMidCell *) cell;
        NSIndexPath *indexPath = [self.subscriptionThumbnailCollectionView indexPathForItemAtPoint: selectedCell.center];
        
        Channel *channel = self.channelOwner.subscriptions[indexPath.item];
        
        [appDelegate.viewStackManager viewChannelDetails:channel withNavigationController:self.navigationController];
        
    }
    
}



#pragma mark - move tab delegate

-(void) moveTab{
    
    
}




@end
