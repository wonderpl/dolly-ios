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
#import "SYNChannelSearchCell.h"
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
#import "AppConstants.h"

#define kInterRowMargin 1.0f
#define PULL_THRESHOLD -285.0f
#define PULL_THRESHOLD_IPAD 0.0f
#define ADDEDBOUNDS 200.0f
#define TABBAR_HEIGHT 49.0f
#define FULLNAMELABEL 293.0f


@interface SYNProfileRootViewController () <
UIGestureRecognizerDelegate,
SYNImagePickerControllerDelegate>

@property (nonatomic) BOOL deleteCellModeOn;
@property (nonatomic) BOOL isIPhone;
@property (nonatomic) BOOL isUserProfile;
@property (nonatomic) BOOL trackView;
@property (nonatomic, assign) BOOL collectionsTabActive;
@property (nonatomic, assign, getter = isDeletionModeActive) BOOL deletionModeActive;

@property (nonatomic, strong) NSArray *sortDescriptors;
@property (nonatomic, strong) NSArray* arrDisplayFollowing;
@property (nonatomic, strong) NSArray* arrFollowing;

@property (nonatomic, strong) NSIndexPath *channelsIndexPath;
@property (nonatomic, strong) NSIndexPath *indexPathToDelete;
@property (nonatomic, strong) NSIndexPath *subscriptionsIndexPath;

@property (nonatomic, strong) NSString *currentSearchTerm;
@property (nonatomic, assign) BOOL shouldBeginEditing;

@property (nonatomic, strong) id orientationDesicionmaker;

@property (nonatomic, weak) IBOutlet UIButton *subscriptionsTabButton;

@property (nonatomic, strong) SYNImagePickerController* imagePickerController;

@property (nonatomic, strong) IBOutlet SYNYouHeaderView *headerChannelsView;
@property (nonatomic, strong) IBOutlet SYNYouHeaderView *headerSubscriptionsView;
@property (strong, nonatomic) IBOutlet UICollectionViewFlowLayout *channelLayoutIPad;
@property (strong, nonatomic) IBOutlet UICollectionViewFlowLayout *subscriptionLayoutIPad;
@property (strong, nonatomic) IBOutlet UIButton *followAllButton;

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
@property (strong, nonatomic) IBOutlet UIImageView *coverImage;
@property (strong, nonatomic) IBOutlet UITextView *aboutMeTextView;

@property (strong, nonatomic) IBOutlet UIButton *editButton;
@property (strong, nonatomic) IBOutlet UIButton *collectionsTabButton;
@property (strong, nonatomic) IBOutlet UIButton *followingTabButton;
@property (strong, nonatomic) IBOutlet UIView *segmentedControlsView;
@property (strong, nonatomic) IBOutlet UIButton *moreButton;
@property (strong, nonatomic) UIColor *greyColor;
@property (nonatomic, assign) BOOL pulling;
@property (nonatomic,assign) CGFloat startingPosition;
@property (strong, nonatomic) IBOutlet UISearchBar *followingSearchBar;
@property (nonatomic) ProfileType tmpProfile;
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
        self.shouldBeginEditing = YES;
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
    self.collectionsTabActive = YES;
    self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.width/2;
    self.profileImageView.layer.masksToBounds = YES;
    self.greyColor = [UIColor colorWithRed:120.0f/255.0f green:120.0f/255.0f blue:120.0f/255.0f alpha:1];
    
    UINib *searchCellNib = [UINib nibWithNibName: @"SYNChannelSearchCell"
                                          bundle: nil];
    
    [self.subscriptionThumbnailCollectionView registerNib:searchCellNib forCellWithReuseIdentifier:@"SYNChannelSearchCell"];
    
    
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
    [self setUpSegmentedControl];
    
    if (self.isIPhone)
    {
        [self updateTabStates];
    }
    
    
    //  self.subscriptionThumbnailCollectionView.scrollsToTop = NO;
    //  self.channelThumbnailCollectionView.scrollsToTop = NO;
    /*
     self.channelThumbnailCollectionView.frame = CGRectMake(self.channelThumbnailCollectionView.frame.origin.x, self.channelThumbnailCollectionView.frame.origin.y, self.channelThumbnailCollectionView.frame.size.width, self.channelThumbnailCollectionView.frame.size.height);
     
     self.subscriptionThumbnailCollectionView.frame = CGRectMake(self.subscriptionThumbnailCollectionView.frame.origin.x, self.subscriptionThumbnai
     lCollectionView.frame.origin.y, self.subscriptionThumbnailCollectionView.frame.size.width, self.subscriptionThumbnailCollectionView.frame.size.height);
     */
    
    self.channelThumbnailCollectionView.hidden = YES;
    //updates the staus bar appearance
    [self setNeedsStatusBarAppearanceUpdate];
    
    //[self updateMainScrollView];
    [self updateLayoutForOrientation:[SYNDeviceManager.sharedInstance orientation]];
    
    self.pulling = NO;
    
    self.mainScrollView.contentSize = CGSizeMake(self.mainScrollView.frame.size.width, self.mainScrollView.frame.size.height + self.channelThumbnailCollectionView.frame.size.height - TABBAR_HEIGHT);
    
    //  self.channelThumbnailCollectionView.contentSize = CGSizeMake(self.channelThumbnailCollectionView.contentSize.width, self.channelThumbnailCollectionView.contentSize.height);
    
    //  NSLog(@"View Did Load %f",self.mainScrollView.contentSize.height);
    /*
     CGRect tmpRect = self.channelThumbnailCollectionView.bounds;
     tmpRect.size.height += ADDEDBOUNDS;
     tmpRect.origin.y -= ADDEDBOUNDS;
     self.channelThumbnailCollectionView.bounds = tmpRect;
     
     self.channelThumbnailCollectionView.contentInset = UIEdgeInsetsMake(100, 0, 0, 0);
     
     tmpRect = self.subscriptionThumbnailCollectionView.bounds;
     tmpRect.size.height += ADDEDBOUNDS;
     tmpRect.origin.y -= ADDEDBOUNDS;
     self.subscriptionThumbnailCollectionView.bounds = tmpRect;
     
     self.subscriptionThumbnailCollectionView.contentInset = UIEdgeInsetsMake(100, 0, 0, 0);
     */
    
    self.tmpProfile = MyOwnProfile;
    
    [self setProfleType:self.tmpProfile];
}

-(void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBar.hidden = YES;
    [self.channelThumbnailCollectionView reloadData];
    [self.subscriptionThumbnailCollectionView reloadData];
    
    [self updateLayoutForOrientation: [SYNDeviceManager.sharedInstance orientation]];
    [self updateTabStates];
    
    if (IS_IPHONE)
    {
        /*
         CGRect tmpRect = self.channelThumbnailCollectionView.frame;
         tmpRect.size.height = self.channelThumbnailCollectionView.contentSize.height;
         self.channelThumbnailCollectionView.frame = tmpRect;
         
         tmpRect.origin.y -= ADDEDBOUNDS;
         tmpRect.size.height += ADDEDBOUNDS;
         
         self.channelThumbnailCollectionView.bounds = tmpRect;
         
         NSLog(@"BOUNDS %f, %f, %f, %f", tmpRect.origin.x, tmpRect.origin.y, tmpRect.size.width, tmpRect.size.height);
         tmpRect = self.channelThumbnailCollectionView.frame;
         
         NSLog(@"FRAME %f, %f, %f, %f", tmpRect.origin.x, tmpRect.origin.y, tmpRect.size.width, tmpRect.size.height);
         
         self.channelThumbnailCollectionView.scrollEnabled = YES;
         
         if (self.channelThumbnailCollectionView.contentSize.height < self.channelThumbnailCollectionView.bounds.size.height)
         {
         NSLog(@"error, content > bounds");
         }
         
         self.channelThumbnailCollectionView.contentInset = UIEdgeInsetsMake(-PULL_THRESHOLD, 0, 0, 0);
         
         
         NSLog(@"%f",[self.channelThumbnailCollectionView.collectionViewLayout collectionViewContentSize].height);
         */
        //self.channelThumbnailCollectionView.contentOffset = CGPointMake(0, 100);
        //self.channelThumbnailCollectionView.userInteractionEnabled = NO;
        //self.subscriptionThumbnailCollectionView.userInteractionEnabled = NO;
        
    }
    else
    {
        
        /*   CGRect tmpRect = self.channelThumbnailCollectionView.frame;
         tmpRect.size.height = self.channelThumbnailCollectionView.contentSize.height;
         self.channelThumbnailCollectionView.frame = tmpRect;
         
         tmpRect.origin.y -= 200;
         tmpRect.size.height += 200;
         
         self.channelThumbnailCollectionView.bounds = tmpRect;
         tmpRect = self.channelThumbnailCollectionView.frame;
         self.channelThumbnailCollectionView.scrollEnabled = YES;
         if (self.channelThumbnailCollectionView.contentSize.height < self.channelThumbnailCollectionView.bounds.size.height)
         {
         NSLog(@"error, content > bounds");
         }
         //self.channelThumbnailCollectionView.contentOffset = CGPointMake(0, 100);
         //self.channelThumbnailCollectionView.userInteractionEnabled = NO;
         //self.subscriptionThumbnailCollectionView.userInteractionEnabled = NO;
         */
    }
    
    self.arrDisplayFollowing = [self.channelOwner.subscriptions array];
}


- (void) viewDidAppear: (BOOL) animated
{
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
            self.channelThumbnailCollectionView.scrollsToTop = !self.collectionsTabActive;
            self.subscriptionThumbnailCollectionView.scrollsToTop = self.collectionsTabActive;
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
}


- (void) viewWillDisappear: (BOOL) animated
{
    self.navigationController.navigationBar.hidden = NO;
    
    self.channelThumbnailCollectionView.delegate = nil;
    self.subscriptionThumbnailCollectionView.delegate = nil;
    self.deletionModeActive = NO;
    
    [super viewWillDisappear: animated];
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}


#pragma mark - Container Scroll Delegates
- (void) viewDidScrollToFront
{
    [self updateAnalytics];
    
    if (self.isIPhone)
    {
        self.channelThumbnailCollectionView.scrollsToTop = !self.collectionsTabActive;
        
        self.subscriptionThumbnailCollectionView.scrollsToTop = self.collectionsTabActive;
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
    self.fullNameLabel.font = [UIFont regularCustomFontOfSize:20];
    self.aboutMeTextView.font = [UIFont lightCustomFontOfSize:13.0];
    
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


-(void) setUpSegmentedControl{
    
    self.segmentedControlsView.layer.cornerRadius = 4;
    self.segmentedControlsView.layer.borderWidth = .5f;
    self.segmentedControlsView.layer.borderColor = [[UIColor grayColor] CGColor];
    self.segmentedControlsView.layer.masksToBounds = YES;
    
}

- (void) updateMainScrollView
{
    CGRect tmpFrame;
    tmpFrame = self.channelThumbnailCollectionView.frame;
    
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


-(void) setProfleType: (ProfileType) profileType
{
    if (profileType == MyOwnProfile)
    {
        NSLog(@"my own profile");
        self.editButton.hidden = NO;
        self.followAllButton.hidden = YES;
    }
    if (profileType == OtherUsersProfile)
    {
        NSLog(@"other user profile");
        self.editButton.hidden = YES;
        self.followAllButton.hidden = NO;
    }
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
    
    UICollectionViewFlowLayout *channelsLayout;
    UICollectionViewFlowLayout *subscriptionsLayout;
    
    //Setup the headers
    
    if (self.isIPhone)
    {
        
    }
    else
    {
        if (UIDeviceOrientationIsPortrait(orientation))
        {
            self.channelLayoutIPad.minimumLineSpacing = 14.0f;
            self.channelLayoutIPad.sectionInset = UIEdgeInsetsMake(0.0, 17.0, 0.0, 17.0);
            self.subscriptionLayoutIPad.minimumLineSpacing = 14.0f;
            self.subscriptionLayoutIPad.sectionInset = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
            
            //NEED TO USE MORE DYNAMIC VALUES?
            // self.channelThumbnailCollectionView.frame = CGRectMake(37.0f, 747.0f, 592.0f, 260.0f);
            //  self.subscriptionThumbnailCollectionView.frame = CGRectMake(37.0f, 747.0f, 592.0f, 260.0f);
            
            //  self.coverImage.frame = CGRectMake(0.0f, 0.0f, 670.0f, 512.0f);
            //  self.moreButton.frame = CGRectMake(614, 512, 56, 56);
            channelsLayout = self.channelLayoutIPad;
            subscriptionsLayout = self.subscriptionLayoutIPad;
            
        }
        else
        {
            
            self.channelLayoutIPad.sectionInset = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
            self.subscriptionLayoutIPad.sectionInset =  UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
            self.channelLayoutIPad.minimumLineSpacing = 14.0f;
            self.subscriptionLayoutIPad.minimumLineSpacing = 14.0f;
            //self.channelThumbnailCollectionView.contentSize = CGSizeMake(800, self.channelThumbnailCollectionView.contentSize.height);
            //self.channelThumbnailCollectionView.frame = CGRectMake(27.0f, 580.0f, 870.0f, 260.0f);
            //self.subscriptionThumbnailCollectionView.frame = CGRectMake(27.0f, 580.0f, 870.0f, 260.0f);
            //self.moreButton.frame = CGRectMake(384, 871, 56, 56);
            channelsLayout = self.channelLayoutIPad;
            subscriptionsLayout = self.subscriptionLayoutIPad;
            // self.coverImage.frame = CGRectMake(0.0f, 0.0f, 927.0f, 384.0f);
            
        }
        
        //  self.channelThumbnailCollectionView.collectionViewLayout = channelsLayout;
        // self.subscriptionThumbnailCollectionView.collectionViewLayout = subscriptionsLayout;
        
    }
    
    [subscriptionsLayout invalidateLayout];
    [channelsLayout invalidateLayout];
    
    // [self resizeScrollViews];
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
    
    if ([view isEqual:self.subscriptionThumbnailCollectionView])
    {
        //1 for search bar
        
        return self.arrDisplayFollowing.count;
    }
    
    return self.channelOwner.channels.count + (self.isUserProfile ? 1 : 0); // to account for the extra 'creation' cell at the start of the collection view
}

- (NSInteger) numberOfSectionsInCollectionView: (UICollectionView *) collectionView
{
    
    if ([collectionView isEqual:self.subscriptionThumbnailCollectionView])
    {
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
    /*
     else if (self.isUserProfile  && indexPath.row == 0 && [collectionView isEqual:self.subscriptionThumbnailCollectionView]) {
     
     SYNChannelCreateNewCell *searchCell = [collectionView dequeueReusableCellWithReuseIdentifier: @"SYNChannelSearchCell" forIndexPath: indexPath];
     cell = searchCell;
     }*/
    
    else if([collectionView isEqual:self.channelThumbnailCollectionView])
    {
        Channel *channel = (Channel *) self.channelOwner.channels[indexPath.row - (self.isUserProfile ? 1 : 0)];
        /*
         [channelThumbnailCell.imageView setImageWithURL: [NSURL URLWithString: channel.channelCover.imageLargeUrl]
         placeholderImage: [UIImage imageNamed: @"PlaceholderChannelMid.png"]
         options: SDWebImageRetryFailed];
         */
        [channelThumbnailCell setChannel:channel];
        [channelThumbnailCell setTitle: channel.title];
        [channelThumbnailCell setHiddenForFollowButton:YES];
        cell = channelThumbnailCell;
        
    }else if ([collectionView isEqual:self.subscriptionThumbnailCollectionView]){
        Channel *channel = _arrDisplayFollowing[indexPath.item];
        [channelThumbnailCell setChannel:channel];
        [channelThumbnailCell setTitle: channel.title];
        [channelThumbnailCell setFollowButtonLabel:self.tmpProfile];
        
        
        /*
         [channelThumbnailCell.imageView setImageWithURL: [NSURL URLWithString: channel.channelCover.imageLargeUrl]
         placeholderImage: [UIImage imageNamed: @"PlaceholderChannelMid.png"]
         options: SDWebImageRetryFailed];
         */
        
        [channelThumbnailCell setTitle:channel.title];
        if (channel.favouritesValue)
        {
            if ([appDelegate.currentUser.uniqueId isEqualToString:channel.channelOwner.uniqueId])
            {
                /*
                 [channelThumbnailCell setChannelTitle: [NSString stringWithFormat:@"MY %@", NSLocalizedString(@"FAVORITES", nil)] ];*/
            }
            else
            {/*
              [channelThumbnailCell setChannelTitle:
              [NSString stringWithFormat:@"%@'S %@", [channel.channelOwner.displayName uppercaseString], NSLocalizedString(@"FAVORITES", nil)]];*/
            }
        }
        else
        {
            //[channelThumbnailCell setChannelTitle: channel.title];
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


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    /*
     if (self.isUserProfile  && indexPath.row == 0 && [collectionView isEqual:self.subscriptionThumbnailCollectionView])
     {
     return CGSizeMake(320, 44);
     }*/
    
    if (self.isUserProfile  && indexPath.row == 0 && [collectionView isEqual:self.channelThumbnailCollectionView])
    {
        return CGSizeMake(320, 60);
    }
    
    
    if (collectionView == self.channelThumbnailCollectionView)
    {
        if (IS_IPHONE)
            return self.channelLayoutIPhone.itemSize;
        else
            return self.channelLayoutIPad.itemSize;
    }
    
    if (collectionView == self.subscriptionThumbnailCollectionView)
    {
        if (IS_IPHONE)
            return self.subscriptionLayoutIPhone.itemSize;
        else
            return self.subscriptionLayoutIPad.itemSize;
    }
    
    return CGSizeZero;
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
        self.channelThumbnailCollectionView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, subscriptionsViewSize.height - channelViewSize.height, 0.0f);
    }
    else if (channelViewSize.height > subscriptionsViewSize.height)
    {
        
        self.subscriptionThumbnailCollectionView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, channelViewSize.height - subscriptionsViewSize.height, 0.0f);
    }
}

#pragma mark - tab button actions
- (IBAction)collectionsTabTapped:(id)sender {
    self.collectionsTabActive = YES;
    [self updateTabStates];
    
}
- (IBAction)followingsTabTapped:(id)sender {
    self.collectionsTabActive = NO;
    [self updateTabStates];
    
}

- (void) updateTabStates
{
    
    self.collectionsTabButton.selected = !self.collectionsTabActive;
    self.subscriptionsTabButton.selected = self.collectionsTabActive;
    self.channelThumbnailCollectionView.hidden = !self.collectionsTabActive;
    self.subscriptionThumbnailCollectionView.hidden = self.collectionsTabActive;
    
    
    if (self.collectionsTabActive)
    {
        [self.followingTabButton.titleLabel setTextColor:self.greyColor];
        self.followingTabButton.backgroundColor = [UIColor whiteColor];
        
        self.collectionsTabButton.backgroundColor = self.greyColor;
        [self.collectionsTabButton.titleLabel setTextColor:[UIColor whiteColor]];
        
        
    }
    else
    {
        [self.followingTabButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.followingTabButton.backgroundColor = self.greyColor;
        
        [self.collectionsTabButton.titleLabel setTextColor:self.greyColor];
        self.collectionsTabButton.backgroundColor = [UIColor whiteColor];
    }
}


- (void) headerTapped
{
    // no need to animate the subscriptions part since it observes the channels thumbnails scroll view
    // [self.channelThumbnailCollectionView setContentOffset: CGPointZero animated: YES];
}

#pragma mark - scroll view delegates

-(void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset{
    
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.followingSearchBar resignFirstResponder];
    
    
    [super scrollViewWillBeginDragging:scrollView];
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [super scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    if (decelerate)
    {
        [self scrollingEnded];
        
        [self moveNameLabelWithOffset:scrollView.contentOffset];
    }
    
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [self scrollingEnded];
    [self moveNameLabelWithOffset:scrollView.contentOffset];
}


- (void) scrollViewDidScroll: (UIScrollView *) scrollView
{
    [super scrollViewDidScroll:scrollView];
    /*
    NSLog(@"main %f", self.mainScrollView.contentOffset.y);
    NSLog(@"sub %f", self.subscriptionThumbnailCollectionView.contentOffset.y);
    NSLog(@"chan %f", self.channelThumbnailCollectionView.contentOffset.y);
    */
    if(self.mainScrollView.contentOffset.y >= self.channelThumbnailCollectionView.frame.origin.y-(self.mainScrollView.frame.size.height -self.channelThumbnailCollectionView.frame.origin.y) )
    {
        self.mainScrollView.bounces = NO;
        [self.channelThumbnailCollectionView setScrollEnabled:YES];
        [self.subscriptionThumbnailCollectionView setScrollEnabled:YES];
        // [self.mainScrollView setScrollEnabled:NO];
        
    }
    else
    {
        self.mainScrollView.bounces = YES;
        self.channelThumbnailCollectionView.bounces = NO;
        self.subscriptionThumbnailCollectionView.bounces = NO;
        [self.channelThumbnailCollectionView setScrollEnabled:NO];
        [self.subscriptionThumbnailCollectionView setScrollEnabled:NO];
        // [self.mainScrollView setScrollEnabled:YES];
        
    }
    
    if (!self.isIPhone)
    {
        if (self.orientationDesicionmaker && scrollView != self.orientationDesicionmaker)
        {
            scrollView.contentOffset = [self.orientationDesicionmaker contentOffset];
            return;
        }
        
        /*
         CGFloat offset;
         
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
         // [self.mainScrollView setScrollEnabled:NO];
         }*/
        /*
         
         offset = scrollView.contentOffset.y;
         
         if (scrollView == self.channelThumbnailCollectionView || scrollView == self.subscriptionThumbnailCollectionView)
         {
         
         
         if (offset  > PULL_THRESHOLD_IPAD && !_pulling)
         {
         [self didBeginPulling];
         //Get the starting position of the main scroll as the
         //child scroll starts scrolling
         _startingPosition = self.mainScrollView.contentOffset.y;
         
         _pulling = YES;
         }
         if (_pulling)
         {
         //Get the off set for to set the main scroll view too
         CGFloat pullOffSet = (offset - PULL_THRESHOLD_IPAD + _startingPosition);
         
         [self didChangePullOffSet:pullOffSet];
         
         //adjusts the child scroll view back to the right position
         scrollView.transform = CGAffineTransformMakeTranslation(0, pullOffSet - _startingPosition);
         //moves the fullname label with the scroll view
         self.userNameLabel.transform = CGAffineTransformMakeTranslation(0, pullOffSet - _startingPosition);
         }
         }*/
    }
    else
    {
        CGFloat offset = scrollView.contentOffset.y;
        
        if (scrollView == self.channelThumbnailCollectionView || scrollView == self.subscriptionThumbnailCollectionView)
        {
            /*
             if (offset  > PULL_THRESHOLD && !_pulling)
             {
             //Get the starting position of the main scroll as the
             //child scroll starts scrolling
             [self didBeginPulling];
             _startingPosition = self.mainScrollView.contentOffset.y;
             _pulling = YES;
             
             
             }
             if (_pulling)
             {
             //Get the off set for to set the main scroll view too
             CGFloat pullOffSet = (offset - PULL_THRESHOLD + _startingPosition);
             
             if (_mainScrollView.contentOffset.y < 475) {
             [self didChangePullOffSet:pullOffSet];
             //    scrollView.transform = CGAffineTransformMakeTranslation(0, pullOffSet - _startingPosition);
             }
             
             NSLog(@" Offset%f",_mainScrollView.contentOffset.y);
             
             NSLog(@" collections y%f",self.channelThumbnailCollectionView.frame.origin.y);
             
             //adjusts the child scroll view back to the right position
             
             //moves the fullname label with the scroll view
             self.userNameLabel.transform = CGAffineTransformMakeTranslation(0, pullOffSet - _startingPosition);
             }*/
            
            if (scrollView == self.channelThumbnailCollectionView || scrollView == self.subscriptionThumbnailCollectionView)
            {
                {
                    
                }
            }
            
        }
        if (scrollView == self.mainScrollView)
        {
            
            [self moveNameLabelWithOffset:scrollView.contentOffset];
            
            //scale the image here
            if (scrollView.contentOffset.y < 0)
            {
            }
        }
        
    }
}


-(void) moveNameLabelWithOffset :(CGPoint) offset  {
    
    if (offset.y >FULLNAMELABEL) {
        CGAffineTransform move = CGAffineTransformMakeTranslation(0, offset.y-FULLNAMELABEL);
        
   //     CGAffineTransform scale =  CGAffineTransformMakeScale(0.7, 1.5);
        
        //self.fullNameLabel.transform = CGAffineTransformConcat(move, scale);
        
        self.fullNameLabel.transform = move;
    }
    
    if (offset.y < FULLNAMELABEL) {
    
        CGAffineTransform move = CGAffineTransformMakeTranslation(0,0);
        
        CGAffineTransform scale =  CGAffineTransformMakeScale(1.0, 1.0);
        
        self.fullNameLabel.transform = CGAffineTransformConcat(move, scale);

    }
    
    
}

-(void) scrollingEnded{
    [self didEndPulling];
    _pulling = NO;
    
    //self.channelThumbnailCollectionView.contentOffset = CGPointZero;
    // self.subscriptionThumbnailCollectionView.contentOffset = CGPointZero;
    
    //self.channelThumbnailCollectionView.transform = CGAffineTransformIdentity;
    
    
}


-(void) didBeginPulling{
    
    [_mainScrollView setScrollEnabled:NO];
}

-(void) didChangePullOffSet:(CGFloat) offset{
    [_mainScrollView setContentOffset:CGPointMake(0, offset)];
    
}

-(void) didEndPulling{
    [_mainScrollView setScrollEnabled:YES];
    
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

//Channels are the cell in the collection view
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

- (IBAction)editButtonTapped:(id)sender
{
    
}
- (IBAction)moreButtonTapped:(id)sender
{
    
}

#pragma mark - Searchbar delegates
-(void)searchBarBookmarkButtonClicked:(UISearchBar *)searchBar{
    NSLog(@"searchBarBookmarkButtonClicked");
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    
    NSLog(@" searchBarCancelButtonClicked");
    
    [searchBar resignFirstResponder];
}



-(void)searchBarResultsListButtonClicked:(UISearchBar *)searchBar{
    NSLog(@" searchBarResultsListButtonClicked ");
    
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    
    self.currentSearchTerm = searchBar.text;
    self.currentSearchTerm = [self.currentSearchTerm uppercaseString];
    
    NSLog(@"%@", self.currentSearchTerm);
    
    [self.subscriptionThumbnailCollectionView reloadData];
    
    /*
     
     for (int i=0; i<self.channelOwner.subscriptions.count; i++) {
     NSLog(@"%@",((Channel*)[self.channelOwner.subscriptions objectAtIndex:i]).title);
     }
     
     */
    [self.followingSearchBar resignFirstResponder];
    
}

- (void)searchBar:(UISearchBar *)searchBar activate:(BOOL) active{
    NSLog(@"searchBar activate");
}


- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if(![self.followingSearchBar isFirstResponder]) {
        self.shouldBeginEditing = NO;
    }
    
    self.currentSearchTerm = searchBar.text;
    self.currentSearchTerm = [self.currentSearchTerm uppercaseString];
    
    NSLog(@"%@", self.currentSearchTerm);
    
    [self.subscriptionThumbnailCollectionView reloadData];
    
    
    
}

- (BOOL)textFieldShouldClear:(UITextField *)textField{
    
    
    
    [self performSelector:@selector(searchBarCancelButtonClicked:) withObject:self.followingSearchBar afterDelay: 0.1];
    
    return YES;
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)bar {
    // reset the shouldBeginEditing BOOL ivar to YES, but first take its value and use it to return it from the method call
    BOOL boolToReturn = self.shouldBeginEditing;
    self.shouldBeginEditing = YES;
    return boolToReturn;
}




-(NSArray*)arrDisplayFollowing{
    
    _arrDisplayFollowing =[self.channelOwner.subscriptions array];
    
    if(self.currentSearchTerm.length > 0)
    {
        
        NSPredicate* searchPredicate = [NSPredicate predicateWithBlock:^BOOL(Channel* channel, NSDictionary *bindings) {
            
            NSString* nameToCompare = [channel.title uppercaseString];
            
            BOOL result = [nameToCompare hasPrefix:self.currentSearchTerm];
            
            return result;
        }];
        
        _arrDisplayFollowing = [_arrDisplayFollowing filteredArrayUsingPredicate:searchPredicate];
        
    }
    
    
    return _arrDisplayFollowing;
}




@end
