//
//  SYNProfileRootViewController.m
//  rockpack
//
//  Created by Nick Banks on 24/01/2013.
//  Copysubscriptions (c) Rockpack Ltd. All subscriptionss reserved.
//

#import "AppConstants.h"
#import "Channel.h"
#import "ChannelCover.h"
#import "GAI.h"
#import "SYNAddToChannelCreateNewCell.h"
#import "SYNChannelMidCell.h"
#import "SYNChannelSearchCell.h"
#import "SYNChannelThumbnailCell.h"
#import "SYNDeletionWobbleLayout.h"
#import "SYNDeviceManager.h"
#import "SYNImagePickerController.h"
#import "SYNIntegralCollectionViewFlowLayout.h"
#import "SYNOAuthNetworkEngine.h"
#import "SYNPassthroughView.h"
#import "SYNProfileRootViewController.h"
#import "SYNYouHeaderView.h"
#import "UIColor+SYNColor.h"
#import "UIFont+SYNFont.h"
#import "UIImageView+WebCache.h"
#import "Video.h"
#import "SYNChannelDetailsViewController.h"

@import QuartzCore;

#define kInterRowMargin 1.0f
#define PULL_THRESHOLD -285.0f
#define PULL_THRESHOLD_IPAD 0.0f
#define ADDEDBOUNDS 200.0f
#define TABBAR_HEIGHT 49.0f
#define FULL_NAME_LABEL_IPHONE 285.0f
#define FULL_NAME_LABEL_IPAD_PORTRAIT 533.0f
#define FULLNAMELABELIPADLANDSCAPE 412.0f
#define SEARCHBAR_Y 390.0f
//delete function in channeldetails deletechannel


@interface SYNProfileRootViewController () <UIGestureRecognizerDelegate, SYNImagePickerControllerDelegate, SYNChannelMidCellDelegate> {
    ProfileType modeType;
    
}

@property (strong, nonatomic) IBOutlet UIView *outerViewFullNameLabel;
@property (nonatomic) BOOL deleteCellModeOn;
@property (nonatomic) BOOL isIPhone;
@property (nonatomic) BOOL isUserProfile;
@property (nonatomic) BOOL trackView;
@property (nonatomic, assign) BOOL collectionsTabActive;
@property (nonatomic, assign, getter = isDeletionModeActive) BOOL deletionModeActive;

@property (strong, nonatomic) IBOutlet UIButton *backButton;
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
@property (nonatomic, strong) SYNChannelMidCell *followCell;
@property (strong, nonatomic) IBOutlet UICollectionViewFlowLayout *channelLayoutIPad;
@property (strong, nonatomic) IBOutlet UICollectionViewFlowLayout *subscriptionLayoutIPad;
@property (strong, nonatomic) IBOutlet UIButton *followAllButton;

@property (strong, nonatomic) IBOutlet UICollectionViewFlowLayout *channelLayoutIPhone;
@property (strong, nonatomic) IBOutlet UICollectionViewFlowLayout *subscriptionLayoutIPhone;
@property (nonatomic, strong) IBOutlet UICollectionView *channelThumbnailCollectionView;
@property (strong, nonatomic) IBOutlet UICollectionView *subscriptionThumbnailCollectionView;
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
@property (strong, nonatomic) UIColor *tabTextColor;

@property (nonatomic, assign) BOOL pulling;
@property (nonatomic, assign) BOOL searchMode;
@property (nonatomic,assign) CGFloat startingPosition;
@property (strong, nonatomic) IBOutlet UISearchBar *followingSearchBar;
@property (strong, nonatomic) IBOutlet UIView *containerViewIPad;
@property (nonatomic) ProfileType modeType;
@property (nonatomic) CGPoint offsetBeforeSearch;

@end


@implementation SYNProfileRootViewController
#pragma mark - Object lifecycle
@synthesize modeType;

- (id) initWithViewId:(NSString *)vid
{
    if (self = [super initWithNibName:NSStringFromClass([SYNProfileRootViewController class]) bundle:nil])
    {
        viewId = vid;
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(handleDataModelChange:)
                                                     name: NSManagedObjectContextObjectsDidChangeNotification
                                                   object: appDelegate.searchManagedObjectContext];
        
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(hideDescriptionCurrentlyShowing) name:kHideAllDesciptions object:nil];

        self.shouldBeginEditing = YES;
    }
    
    return self;
}

- (id) initWithViewId:(NSString*) vid WithMode: (ProfileType) mode
{
    self.modeType = mode;
    self = [self initWithViewId:vid];
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
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextObjectsDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kHideAllDesciptions object:nil];
}


#pragma mark - View Lifecycle

- (void) viewDidLoad
{
    [super viewDidLoad];
    self.collectionsTabActive = YES;
    self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.width/2;
    self.profileImageView.layer.masksToBounds = YES;
    self.greyColor = [UIColor dollyTabColorSelectedBackground];
    self.tabTextColor = [UIColor dollyTabColorSelectedText];

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
    if (IS_IPHONE)
    {
        self.subscriptionThumbnailCollectionView.collectionViewLayout = self.subscriptionLayoutIPhone;
        self.channelThumbnailCollectionView.collectionViewLayout = self.channelLayoutIPhone;
        
        // change the BG color of the text field inside the searcBar
        UITextField *txfSearchField = [self.followingSearchBar valueForKey:@"_searchField"];
        if(txfSearchField)
            txfSearchField.backgroundColor = [UIColor colorWithRed: (224.0f / 255.0f)
                                                             green: (224.0f / 255.0f)
                                                              blue: (224.0f / 255.0f)
                                                             alpha: 1.0f];
        
    }
    else
    {
        self.channelThumbnailCollectionView.collectionViewLayout = self.channelLayoutIPad;
        self.subscriptionThumbnailCollectionView.collectionViewLayout = self.subscriptionLayoutIPad;
    }
    
    [self setUpUserProfile];
    [self setUpSegmentedControl];
    
    if (self.isIPhone)
    {
        [self updateTabStates];
    }
    
    self.searchMode = NO;
    //  self.subscriptionThumbnailCollectionView.scrollsToTop = NO;
    //  self.channelThumbnailCollectionView.scrollsToTop = NO;
    /*
     self.channelThumbnailCollectionView.frame = CGRectMake(self.channelThumbnailCollectionView.frame.origin.x, self.channelThumbnailCollectionView.frame.origin.y, self.channelThumbnailCollectionView.frame.size.width, self.channelThumbnailCollectionView.frame.size.height);
     
     self.subscriptionThumbnailCollectionView.frame = CGRectMake(self.subscriptionThumbnailCollectionView.frame.origin.x, self.subscriptionThumbnai
     lCollectionView.frame.origin.y, self.subscriptionThumbnailCollectionView.frame.size.width, self.subscriptionThumbnailCollectionView.frame.size.height);
     */
    
    self.channelThumbnailCollectionView.hidden = YES;
    //updates the staus bar appearance
    
    //[self updateMainScrollView];
    [self updateLayoutForOrientation:[SYNDeviceManager.sharedInstance orientation]];
    
    self.pulling = NO;
    
    //   self.mainScrollView.contentSize = CGSizeMake(self.mainScrollView.frame.size.width, self.mainScrollView.frame.size.height + self.channelThumbnailCollectionView.frame.size.height - TABBAR_HEIGHT);
    
    //  self.channelThumbnailCollectionView.contentSize = CGSizeMake(self.channelThumbnailCollectionView.contentSize.width, self.channelThumbnailCollectionView.contentSize.height);
    
    //  NSLog(@"View Did Load %f",selfs.mainScrollView.contentSize.height);
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
    
    UITextField *txfSearchField = [self.followingSearchBar valueForKey:@"_searchField"];
    if(txfSearchField)
        txfSearchField.backgroundColor = [UIColor colorWithRed: (255.0f / 255.0f)
                                                         green: (255.0f / 255.0f)
                                                          blue: (255.0f / 255.0f)
                                                         alpha: 1.0f];
    
    [self setProfleType:self.modeType];



}

-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
    self.navigationController.navigationBar.hidden = YES;
    [self updateTabStates];
    
    [self setUpUserProfile];
    [self setUpSegmentedControl];
    [self setNeedsStatusBarAppearanceUpdate];
    
    
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
    
    
    [self.channelThumbnailCollectionView reloadData];
    [self.subscriptionThumbnailCollectionView reloadData];
    [self updateLayoutForOrientation: [SYNDeviceManager.sharedInstance orientation]];
    
    //self.channelThumbnailCollectionView.contentOffset = CGPointZero;
    //self.subscriptionThumbnailCollectionView.contentOffset = CGPointZero;
    
}


- (void) viewDidAppear: (BOOL) animated
{
    self.arrDisplayFollowing = [self.channelOwner.subscriptions array];
    [self.subscriptionThumbnailCollectionView reloadData];
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
    [self updateLayoutForOrientation: [SYNDeviceManager.sharedInstance orientation]];
    
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
    self.aboutMeTextView.font = [UIFont regularCustomFontOfSize:13.0];
    
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
        self.editButton.hidden = NO;
        self.followAllButton.hidden = YES;
        self.backButton.hidden = YES;
        
        

    }
    if (profileType == OtherUsersProfile)
    {
        self.editButton.hidden = YES;
        self.followAllButton.hidden = NO;
        self.backButton.hidden = NO;
        
        
        self.followingSearchBar.hidden = YES;
        CGSize tmp = self.subscriptionLayoutIPhone.headerReferenceSize;
        
        tmp.height -= 43;
        self.subscriptionLayoutIPhone.headerReferenceSize = tmp;

//
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
    
    self.navigationController.navigationBarHidden = YES;
    
    if (self.isIPhone)
    {
        self.subscriptionThumbnailCollectionView.collectionViewLayout = self.subscriptionLayoutIPhone;
        self.channelThumbnailCollectionView.collectionViewLayout = self.channelLayoutIPhone;
    }
    else
    {
        self.channelThumbnailCollectionView.contentOffset = CGPointZero;
        self.subscriptionThumbnailCollectionView.contentOffset = CGPointZero;
        self.channelThumbnailCollectionView.contentInset = UIEdgeInsetsZero;
        self.subscriptionThumbnailCollectionView.contentInset = UIEdgeInsetsZero;
        //        self.coverImage.transform = CGAffineTransformIdentity;
        //        self.moreButton.transform = CGAffineTransformIdentity;
        //        self.coverImage.transform = CGAffineTransformIdentity;
        if (UIDeviceOrientationIsPortrait(orientation))
        {
            self.channelLayoutIPad.minimumLineSpacing = 14.0f;
            self.channelLayoutIPad.sectionInset = UIEdgeInsetsMake(0.0, 47.0, 0.0, 47.0);
            self.subscriptionLayoutIPad.minimumLineSpacing = 14.0f;
            self.subscriptionLayoutIPad.sectionInset = UIEdgeInsetsMake(0.0, 47.0, 0.0, 47.0);
            self.channelLayoutIPad.headerReferenceSize = CGSizeMake(671, 722);
            self.subscriptionLayoutIPad.headerReferenceSize = CGSizeMake(671, 722);
            
            //NEED DYNAMIC WAY
            // self.channelThumbnailCollectionView.frame = CGRectMake(37.0f, 747.0f, 592.0f, 260.0f);
            //  self.subscriptionThumbnailCollectionView.frame = CGRectMake(37.0f, 747.0f, 592.0f, 260.0f);
            
            //            self.coverImage.frame = CGRectMake(0.0f, 0.0f, 670.0f, 512.0f);
            //            self.moreButton.frame = CGRectMake(614, 512, 56, 56);
            //            channelsLayout = self.channelLayoutIPad;
            subscriptionsLayout = self.subscriptionLayoutIPad;
            
            //   self.containerViewIPad.frame = CGRectMake(179, 449, 314, 237);
            
        }
        else
        {
            self.channelLayoutIPad.sectionInset = UIEdgeInsetsMake(0.0, 21.0, 0.0, 21.0);
            self.subscriptionLayoutIPad.sectionInset =  UIEdgeInsetsMake(0.0, 21.0, 0.0, 21.0);
            self.channelLayoutIPad.minimumLineSpacing = 14.0f;
            self.subscriptionLayoutIPad.minimumLineSpacing = 14.0f;
            self.channelLayoutIPad.headerReferenceSize = CGSizeMake(1004, 600);
            self.subscriptionLayoutIPad.headerReferenceSize = CGSizeMake(1004, 600);
            
            // self.containerViewIPad.frame = CGRectMake(179, 449, 314, 237);
            
            //self.channelThumbnailCollectionView.contentSize = CGSizeMake(800, self.channelThumbnailCollectionView.contentSize.height);
            //self.channelThumbnailCollectionView.frame = CGRectMake(27.0f, 580.0f, 870.0f, 260.0f);
            //self.subscriptionThumbnailCollectionView.frame = CGRectMake(27.0f, 580.0f, 870.0f, 260.0f);
            //self.moreButton.frame = CGRectMake(384, 871, 56, 56);
            channelsLayout = self.channelLayoutIPad;
            subscriptionsLayout = self.subscriptionLayoutIPad;
            //  self.coverImage.frame = CGRectMake(0.0f, 0.0f, 927.0f, 384.0f);
        }
        
        //  self.channelThumbnailCollectionView.collectionViewLayout = channelsLayout;
        // self.subscriptionThumbnailCollectionView.collectionViewLayout = subscriptionsLayout;
        
    }
    
    [subscriptionsLayout invalidateLayout];
    [channelsLayout invalidateLayout];
    
    [self reloadCollectionViews];
   // [self resizeScrollViews];
}


- (void) reloadCollectionViews
{
    [self.subscriptionThumbnailCollectionView reloadData];
    [self.channelThumbnailCollectionView reloadData];
    
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
        //return self.arrDisplayFollowing.count;
        return self.channelOwner.subscriptions.count;
    }
    
    return self.channelOwner.channels.count + (self.isUserProfile ? 1 : 0); // to account for the extra 'creation' cell at the start of the collection view
}

- (NSInteger) numberOfSectionsInCollectionView: (UICollectionView *) collectionView
{
    
    return 1;
}


- (UICollectionViewCell *) collectionView: (UICollectionView *) collectionView
                   cellForItemAtIndexPath: (NSIndexPath *) indexPath
{
    
    UICollectionViewCell *cell = nil;
    
    
    
    if (self.isUserProfile && indexPath.row == 0 && [collectionView isEqual:self.channelThumbnailCollectionView]) // first row for a user profile only (create)
    {
        SYNAddToChannelCreateNewCell *createCell = [collectionView dequeueReusableCellWithReuseIdentifier: @"SYNChannelCreateNewCell"
                                                                                             forIndexPath: indexPath];
        cell = createCell;
    }
    else
    {
        SYNChannelMidCell *channelThumbnailCell = [collectionView dequeueReusableCellWithReuseIdentifier: @"SYNChannelMidCell"
                                                                                            forIndexPath: indexPath];
        
        Channel *channel;
        
        // == Add Special Attributes == //
        
        if(collectionView == self.channelThumbnailCollectionView)
        {
            channel = (Channel *) self.channelOwner.channels[indexPath.item - (self.isUserProfile ? 1 : 0)];
            
            [channelThumbnailCell setHiddenForFollowButton:(self.modeType == MyOwnProfile)];
           
        }
        else // (collectionView == self.subscribersThumbnailCollectionView)
        {
            if (indexPath.row < self.arrDisplayFollowing.count)
            {
                channel = _arrDisplayFollowing[indexPath.item];
                
                if (self.modeType == MyOwnProfile)
                {
                    [channelThumbnailCell setFollowButtonLabel:NSLocalizedString(@"Unfollow", nil)];
                }
                
            }
        }
        

        // == Add Common Attributes == //
        
        if(self.modeType == OtherUsersProfile)

        {
            if (channel.subscribedByUserValue)
            {
                [channelThumbnailCell setFollowButtonLabel:NSLocalizedString(@"Unfollow", @"unfollow")];
            }
            else
            {
                [channelThumbnailCell setFollowButtonLabel:NSLocalizedString(@"Follow", @"follow")];
            }

        }
        
        NSString* subscribersString = [NSString stringWithFormat: @"%lld %@",channel.subscribersCountValue, NSLocalizedString(@"SUBSCRIBERS", nil)];
        [channelThumbnailCell.followerCountLabel setText:subscribersString];
        
        channelThumbnailCell.channel = channel;
        
        NSMutableString* videoCountString = [NSMutableString new];
        if (IS_IPHONE)
        {
            [videoCountString appendString:@"- "];
        }
        
        
        [videoCountString appendFormat:@"%ld %@",(long)channel.videoInstances.count, NSLocalizedString(@"VIDEOS", nil)];
        
        
        channelThumbnailCell.videoCountLabel.text = [NSString stringWithString:videoCountString];
        channelThumbnailCell.viewControllerDelegate = self;
        
        cell = channelThumbnailCell;
        
    }
    
    // precaution
    if(!cell)
    {
        AssertOrLog(@"No Cell Created");
    }
    
    return cell;
}

- (void) collectionView: (UICollectionView *) collectionView didSelectItemAtIndexPath: (NSIndexPath *) indexPath
{
    Channel *channel;
    
    if (collectionView == self.channelThumbnailCollectionView)
    {
        // The first cell is a 'create_new' cell on a user profile
        if (self.isUserProfile && indexPath.row == 0)
        {
			[self viewChannelDetails:appDelegate.videoQueue.currentlyCreatingChannel];
			
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
	
    [self viewChannelDetails:channel];
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    /*
     if (self.isUserProfile  && indexPath.row == 0 && [collectionView isEqual:self.subscriptionThumbnailCollectionView])
     {
     return CGSizeMake(320, 44);
     }*/
    
    
    if (self.isUserProfile  && indexPath.row == 0 && [collectionView isEqual:self.channelThumbnailCollectionView] && IS_IPHONE)
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
    
    self.channelThumbnailCollectionView.contentOffset = CGPointZero;
    self.subscriptionThumbnailCollectionView.contentOffset = CGPointZero;
    
    //self.channelThumbnailCollectionView.contentInset = UIEdgeInsetsZero;
    //  self.subscriptionThumbnailCollectionView.contentInset = UIEdgeInsetsZero;
    
    
    CGSize channelViewSize = self.channelThumbnailCollectionView.collectionViewLayout.collectionViewContentSize;
    CGSize subscriptionsViewSize = self.subscriptionThumbnailCollectionView.collectionViewLayout.collectionViewContentSize;
    
    if (channelViewSize.height <= subscriptionsViewSize.height)
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
    
    if (self.modeType == MyOwnProfile) {
        self.followingSearchBar.hidden = self.collectionsTabActive;
        
    }
    
    
    if (self.collectionsTabActive)
    {
        [self.followingTabButton.titleLabel setTextColor:self.tabTextColor];
        self.followingTabButton.backgroundColor = [UIColor whiteColor];
        
        self.collectionsTabButton.backgroundColor = self.greyColor;
        [self.collectionsTabButton.titleLabel setTextColor:[UIColor whiteColor]];
        
        
    }
    else
    {
        [self.followingTabButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.followingTabButton.backgroundColor = self.greyColor;
        
        [self.collectionsTabButton.titleLabel setTextColor:self.tabTextColor];
        self.collectionsTabButton.backgroundColor = [UIColor whiteColor];
    }
}


- (void) headerTapped
{
    // no need to animate the subscriptions part since it observes the channels thumbnails scroll view
    // [self.channelThumbnailCollectionView setContentOffset: CGPointZero animated: YES];
}

#pragma mark - scroll view delegates

-(void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
      [super scrollViewWillBeginDragging:scrollView];
    if (self.searchMode) {
        [self.followingSearchBar resignFirstResponder];
        self.searchMode = NO;
    }
    
    [self hideDescriptionCurrentlyShowing];
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [super scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    if (decelerate)
    {
        [self scrollingEnded];
        [self moveNameLabelWithOffset:scrollView.contentOffset.y];
    }
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [self scrollingEnded];
    [self moveNameLabelWithOffset:scrollView.contentOffset.y];
}


- (void) scrollViewDidScroll: (UIScrollView *) scrollView
{
    [super scrollViewDidScroll:scrollView];
    CGFloat offset = scrollView.contentOffset.y;
    
    
    if (scrollView == self.channelThumbnailCollectionView||scrollView == self.subscriptionThumbnailCollectionView)
    {
        
        if (self.channelThumbnailCollectionView == scrollView)
        {
            [self.subscriptionThumbnailCollectionView setContentOffset:scrollView.contentOffset];
        }
        if (self.subscriptionThumbnailCollectionView == scrollView)
        {
            [self.channelThumbnailCollectionView setContentOffset:scrollView.contentOffset];
            
        }
        
        if (IS_IPHONE) {
            
            CGAffineTransform move = CGAffineTransformMakeTranslation(0, -offset);
            self.profileImageView.transform = move;
            self.aboutMeTextView.transform = move;
            self.segmentedControlsView.transform = move;
            self.followAllButton.transform = move;
            //self.outerViewLabel.transform = move;
            self.moreButton.transform = move;
            self.editButton.transform = move;
            self.followingSearchBar.transform = move;
            self.backButton.transform = move;

            if (offset<0)
            {
                //change to make like what they wanted
                CGAffineTransform scale = CGAffineTransformMakeScale(1+ fabsf(offset)/100,1+ fabsf(offset)/100);
                self.coverImage.transform = scale;
            }
            else
            {
                self.coverImage.transform = move;
                
            }
            [self moveNameLabelWithOffset:offset];
        }
        else
        {
            
            CGAffineTransform move = CGAffineTransformMakeTranslation(0, -offset);
            self.coverImage.transform = move;
            self.moreButton.transform = move;
            self.containerViewIPad.transform = move;
            self.backButton.transform = move;

            [self moveNameLabelWithOffset:offset];
        
            /*
             self.profileImageView.transform = move;
             self.aboutMeTextView.transform = move;
             self.segmentedControlsView.transform = move;
             self.followAllButton.transform = move;
             self.editButton.transform = move;
             self.followingSearchBar.transform = move;
             self.fullNameLabel.transform = move;
             */
            
            
        }
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
                
            }
            
        }
        
    }
}


-(void) moveNameLabelWithOffset :(CGFloat) offset  {
    if (IS_IPHONE)
    {
        
        if (offset < FULL_NAME_LABEL_IPHONE)
        {
            CGAffineTransform move = CGAffineTransformMakeTranslation(0, -offset);
            //CGAffineTransform scale =  CGAffineTransformMakeScale(0.7, 1.5);
            //self.fullNameLabel.transform = CGAffineTransformConcat(move, scale);
            CGRect tmpFrame = self.outerViewFullNameLabel.frame;
            tmpFrame.size.height = 43;
            self.outerViewFullNameLabel.frame = tmpFrame;
            self.outerViewFullNameLabel.transform = move;
        }
        
        if (offset > FULL_NAME_LABEL_IPHONE)
        {
            CGAffineTransform move = CGAffineTransformMakeTranslation(0,-FULL_NAME_LABEL_IPHONE);
            CGAffineTransform scale =  CGAffineTransformMakeScale(1.0, 1.0);
            CGRect tmpFrame = self.outerViewFullNameLabel.frame;
            tmpFrame.size.height = 64;
            self.outerViewFullNameLabel.frame = tmpFrame;
            self.outerViewFullNameLabel.transform = CGAffineTransformConcat(move, scale);
        }
    }
    
    if (IS_IPAD)
    {
        if (UIDeviceOrientationIsPortrait([SYNDeviceManager.sharedInstance orientation]) ) {
            if (offset > FULL_NAME_LABEL_IPAD_PORTRAIT)
            {
                CGAffineTransform move = CGAffineTransformMakeTranslation(0,-FULL_NAME_LABEL_IPAD_PORTRAIT);
                CGAffineTransform moveOverView = CGAffineTransformMakeTranslation(0,-FULL_NAME_LABEL_IPAD_PORTRAIT-3);

                self.fullNameLabel.alpha = 0.9;
                self.fullNameLabel.transform = move;
                self.outerViewFullNameLabel.transform = moveOverView;
                self.outerViewFullNameLabel.hidden = NO;
            }
            if (offset<FULL_NAME_LABEL_IPAD_PORTRAIT)
            {
                
                CGAffineTransform move = CGAffineTransformMakeTranslation(0,-offset);

                self.fullNameLabel.transform = move;
                self.outerViewFullNameLabel.transform = move;
                self.fullNameLabel.alpha = 1.0;
                self.outerViewFullNameLabel.hidden = YES;

            }
        }
        else if (UIDeviceOrientationIsLandscape([SYNDeviceManager.sharedInstance orientation]))
        {
            
            if (offset > FULLNAMELABELIPADLANDSCAPE)
            {
                CGAffineTransform move = CGAffineTransformMakeTranslation(0,-FULLNAMELABELIPADLANDSCAPE);
                self.fullNameLabel.transform = move;
                self.fullNameLabel.alpha = 0.9;
                self.outerViewFullNameLabel.transform = move;
                self.outerViewFullNameLabel.hidden = NO;

            }
            
            if (offset<FULLNAMELABELIPADLANDSCAPE)
            {
                CGAffineTransform move = CGAffineTransformMakeTranslation(0,-offset);

                self.fullNameLabel.transform = move;
                self.fullNameLabel.alpha = 1.0;
                self.outerViewFullNameLabel.transform = move;

                self.outerViewFullNameLabel.hidden = YES;


            }
        }
    }
}

-(void) scrollingEnded{
    
    
    
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
    
    [self viewProfileDetails:channel.channelOwner];
}

// Channels are the cell in the collection view
- (void) channelTapped: (UICollectionViewCell *) cell
{
    SYNChannelThumbnailCell *selectedCell = (SYNChannelThumbnailCell *) cell;
    if([cell.superview isEqual:self.channelThumbnailCollectionView])
    {
        
        NSIndexPath *indexPath = [self.channelThumbnailCollectionView indexPathForItemAtPoint: selectedCell.center];
        
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

        SYNChannelDetailsViewController *channelVC;
        if (modeType == MyOwnProfile) {
            channelVC = [[SYNChannelDetailsViewController alloc] initWithChannel:channel usingMode:kChannelDetailsModeDisplayUser];

        }

        if (modeType == OtherUsersProfile) {
            channelVC = [[SYNChannelDetailsViewController alloc] initWithChannel:channel usingMode:kChannelDetailsModeDisplay];

        }
        
        [self.navigationController pushViewController:channelVC animated:YES];
        
        
    }
    if([cell.superview isEqual:self.subscriptionThumbnailCollectionView])
    {
        
        NSIndexPath *indexPath = [self.subscriptionThumbnailCollectionView indexPathForItemAtPoint: selectedCell.center];
        
        if (indexPath.row < self.arrDisplayFollowing.count) {
            
        }
        Channel *channel = self.arrDisplayFollowing[indexPath.item];
        self.navigationController.navigationBarHidden = NO;

        
           SYNChannelDetailsViewController *channelVC = [[SYNChannelDetailsViewController alloc] initWithChannel:channel usingMode:kChannelDetailsModeDisplay];
        
        [self.navigationController pushViewController:channelVC animated:YES];
    }
}

-(void) followButtonTapped:(UICollectionViewCell *) cell
{
    [self showAlertView: cell];

}

- (IBAction)editButtonTapped:(id)sender
{
    
}
- (IBAction)moreButtonTapped:(id)sender
{
    
}

#pragma mark - Searchbar delegates
-(void)searchBarBookmarkButtonClicked:(UISearchBar *)searchBar
{
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    self.searchMode = NO;
    //[self calculateOffsetForSearch];
    
    [UIView animateWithDuration:0.5 animations:^{
        self.subscriptionThumbnailCollectionView.contentOffset = CGPointMake(0, 0);
    }];
    
    [self.followingSearchBar setShowsCancelButton:NO animated:YES];
    
    [searchBar resignFirstResponder];
    
}



-(void)searchBarResultsListButtonClicked:(UISearchBar *)searchBar
{
    
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    
    self.channelThumbnailCollectionView.contentOffset = CGPointMake(0, 0);
    
    self.currentSearchTerm = searchBar.text;
    self.currentSearchTerm = [self.currentSearchTerm uppercaseString];
    [self.subscriptionThumbnailCollectionView reloadData];
    
    self.searchMode = NO;
    
    [self.followingSearchBar resignFirstResponder];
    if (self.currentSearchTerm.length == 0) {
        [self.followingSearchBar setShowsCancelButton:NO animated:YES];
    }
    else
    {
        [self enableCancelButton: searchBar];
        
    }
    self.subscriptionThumbnailCollectionView.contentOffset = CGPointMake(0, SEARCHBAR_Y);
    
}

- (void)searchBar:(UISearchBar *)searchBar activate:(BOOL) active
{
}


- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    //To not get the keyboard to show when the x button is clicked
    if(![self.followingSearchBar isFirstResponder]) {
        self.shouldBeginEditing = NO;
    }
    
    self.currentSearchTerm = searchBar.text;
    self.currentSearchTerm = [self.currentSearchTerm uppercaseString];
    
    [self.subscriptionThumbnailCollectionView reloadData];

}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    
    [self.followingSearchBar resignFirstResponder];
    [self.followingSearchBar setShowsCancelButton:NO animated:YES];
    
    return YES;
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)bar
{
    // boolean to check if the keyboard should show
    BOOL boolToReturn = self.shouldBeginEditing;
    self.searchMode = YES;
    
    
    if (self.shouldBeginEditing)
    {
        
        [UIView animateWithDuration:0.2 animations:^{
            self.channelThumbnailCollectionView.contentOffset = CGPointMake(0, SEARCHBAR_Y);
            
        }];
        [self.followingSearchBar setShowsCancelButton:YES animated:YES];
        
    }
    
    self.shouldBeginEditing = YES;
    
    return boolToReturn;
}

-(void) calculateOffsetForSearch
{
    if (self.searchMode)
    {
        self.subscriptionThumbnailCollectionView.contentOffset = CGPointMake(0, SEARCHBAR_Y);
    }
    else
    {
        self.subscriptionThumbnailCollectionView.contentOffset = CGPointMake(0, 0);
        
    }
    
}

- (void)enableCancelButton:(UISearchBar *)searchBar
{
    for (UIView *view in searchBar.subviews)
    {
        for (id subview in view.subviews)
        {
            if ( [subview isKindOfClass:[UIButton class]] )
            {
                [subview setEnabled:YES];
                return;
            }
        }
    }
}


-(NSArray*)arrDisplayFollowing
{
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


-(void) hideDescriptionCurrentlyShowing
{
    
    for (UICollectionViewCell *cell in [self.subscriptionThumbnailCollectionView visibleCells])
    {
        if ([cell respondsToSelector:@selector(moveToCentre)]) {
            [((SYNChannelMidCell*)cell) moveToCentre];
        }
    }
    
    for (UICollectionViewCell *cell in [self.channelThumbnailCollectionView visibleCells])
    {
        if ([cell respondsToSelector:@selector(moveToCentre)]) {
            [((SYNChannelMidCell*)cell) moveToCentre];
        }
    }
    
}



-(void) showAlertView: (UICollectionViewCell *) cell{
    NSString *message = @"Are you sure you want to unfollow";
    message =  [message stringByAppendingString:@" "];
    
    message =  [message stringByAppendingString:((SYNChannelMidCell*)cell).channel.title];
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Unfollow?" message:message delegate:self cancelButtonTitle:[self noButtonTitle] otherButtonTitles:[self yesButtonTitle], nil];
    self.followCell = ((SYNChannelMidCell*)cell);
    
    if (modeType == MyOwnProfile) {
        [alertView show];
    }
    else if(modeType == OtherUsersProfile)
    {
        
        //Need to refresh the cell
        if (self.followCell.channel.subscribedByUserValue)
        {
            [self.followCell setFollowButtonLabel:NSLocalizedString(@"Unfollow", @"unfollow")];
        }
        else
        {
            [self.followCell setFollowButtonLabel:NSLocalizedString(@"Follow", @"follow")];
        }

        [[NSNotificationCenter defaultCenter] postNotificationName: kChannelSubscribeRequest
                                                            object: self
                                                          userInfo: @{kChannel : self.followCell.channel}];
        
        //Need to refresh the cell
        if (self.followCell.channel.subscribedByUserValue)
        {
            [self.followCell setFollowButtonLabel:NSLocalizedString(@"Unfollow", @"unfollow")];
        }
        else
        {
            [self.followCell setFollowButtonLabel:NSLocalizedString(@"Follow", @"follow")];
        }
    }
}

- (NSString *) yesButtonTitle{
    return @"Yes";
}
- (NSString *) noButtonTitle{
    return @"Cancel";
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *buttonTitle = [alertView buttonTitleAtIndex:buttonIndex];
    if ([buttonTitle isEqualToString:[self yesButtonTitle]])
    {
        if (self.followCell.channel != nil)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName: kChannelSubscribeRequest
                                                                object: self
                                                              userInfo: @{kChannel : self.followCell.channel}];
        }
    }
}
- (IBAction)backButtonTapped:(id)sender {
    self.navigationController.navigationBarHidden = NO;

    [self.navigationController popViewControllerAnimated:YES];
    
}


@end
