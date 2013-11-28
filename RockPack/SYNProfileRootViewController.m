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
#import "SYNDeviceManager.h"
#import "SYNImagePickerController.h"
#import "SYNIntegralCollectionViewFlowLayout.h"
#import "SYNOAuthNetworkEngine.h"
#import "SYNProfileRootViewController.h"
#import "UIColor+SYNColor.h"
#import "UIFont+SYNFont.h"
#import "SYNOptionsOverlayViewController.h"
#import <UIImageView+WebCache.h>
#import "SYNMasterViewController.h"
#import "Video.h"
#import "SYNChannelDetailsViewController.h"
#import "UIImage+blur.h"
#import "SYNProfileFlowLayout.h"
#import "SYNChannelCreateNewCell.h"
#import "SYNProfileExpandedFlowLayout.h"

@import QuartzCore;

#define FULL_NAME_LABEL_IPHONE 276.0f // lower is down
#define FULL_NAME_LABEL_IPAD_PORTRAIT 533.0f
#define FULLNAMELABELIPADLANDSCAPE 412.0f
#define SEARCHBAR_Y 415.0f
#define ALPHA_IN_EDIT 0.2f
#define OFFSET_DESCRIPTION_EDIT 130.0f
#define PARALLAX_SCROLL_VALUE 2.0f
#define kHeightChange 94.0f


//delete function in channeldetails deletechannel


@interface SYNProfileRootViewController () <UIGestureRecognizerDelegate, SYNImagePickerControllerDelegate, SYNChannelMidCellDelegate,SYNChannelCreateNewCelllDelegate> {
    ProfileType modeType;
}

@property (strong, nonatomic) IBOutlet UIView *outerViewFullNameLabel;
@property (nonatomic) BOOL isIPhone;
@property (nonatomic) BOOL isUserProfile;
@property (nonatomic) BOOL trackView;
@property (nonatomic, assign) BOOL collectionsTabActive;
@property (nonatomic, assign, getter = isDeletionModeActive) BOOL deletionModeActive;
@property (strong, nonatomic) IBOutlet UIButton *followersCountButton;

@property (nonatomic, strong) NSArray* arrDisplayFollowing;
@property (nonatomic, strong) NSArray* arrFollowing;
@property (strong, nonatomic) UIBarButtonItem *barBtnBack; // storage for the navigation back button

@property (nonatomic, strong) NSIndexPath *channelsIndexPath;
@property (nonatomic, strong) NSIndexPath *indexPathToDelete;
@property (nonatomic, strong) NSIndexPath *subscriptionsIndexPath;

@property (strong, nonatomic) IBOutlet UIButton *uploadCoverPhotoButton;
@property (nonatomic, strong) NSString *currentSearchTerm;
@property (nonatomic, assign) BOOL shouldBeginEditing;

@property (nonatomic, strong) id orientationDesicionmaker;

@property (nonatomic, weak) IBOutlet UIButton *subscriptionsTabButton;

@property (nonatomic, strong) SYNImagePickerController* imagePickerController;

@property (nonatomic, strong) SYNChannelMidCell *followCell;
@property (strong, nonatomic) IBOutlet UICollectionViewFlowLayout *channelLayoutIPad;
@property (strong, nonatomic) IBOutlet UICollectionViewFlowLayout *subscriptionLayoutIPad;
@property (strong, nonatomic) IBOutlet UIButton *followAllButton;

@property (strong, nonatomic) IBOutlet UICollectionViewFlowLayout *channelLayoutIPhone;
@property (strong, nonatomic) IBOutlet UICollectionViewFlowLayout *subscriptionLayoutIPhone;
@property (strong, nonatomic) SYNProfileExpandedFlowLayout *channelExpandedLayout;

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
@property (strong, nonatomic) IBOutlet UIButton *uploadAvatarButton;

@property (strong, nonatomic) UIColor *greyColor;
@property (strong, nonatomic) UIColor *tabTextColor;

@property (nonatomic, assign) BOOL searchMode;
@property (nonatomic,assign) CGFloat startingPosition;
@property (strong, nonatomic) IBOutlet UISearchBar *followingSearchBar;
@property (strong, nonatomic) IBOutlet UIView *containerViewIPad;
@property (nonatomic) ProfileType modeType;
@property (nonatomic) CGPoint offsetBeforeSearch;
@property (strong, nonatomic) UIBarButtonItem *barBtnCancelEditMode;
@property (strong, nonatomic) UIBarButtonItem *barBtnCancelCreateChannel;
@property (strong, nonatomic) UIBarButtonItem *barBtnSaveEditMode;
@property (strong, nonatomic) UIBarButtonItem *barBtnSaveCreateChannel;

@property (strong, nonatomic) IBOutlet UIView *backgroundView;

@property (strong, nonatomic) UITapGestureRecognizer *tapToHideKeyoboard;
@property (strong, nonatomic) UIAlertView *unfollowAlertView;
@property (strong, nonatomic) UIAlertView *followAllAlertView;

@property (strong, nonatomic) SYNProfileFlowLayout *testLayoutIPhone;


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
        
    }
    
    return self;
}

- (id) initWithViewId:(NSString*) vid andChannelOwner:(ChannelOwner*)chanOwner
{
    self = [self initWithViewId:vid];
    self.channelOwner = chanOwner;
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
    
    
    self.shouldBeginEditing = YES;
    self.collectionsTabActive = YES;
    
    // == Masking Images into a circle
    self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.width/2;
    self.profileImageView.layer.masksToBounds = YES;
    self.uploadAvatarButton.layer.cornerRadius = self.uploadAvatarButton.frame.size.width/2;
    self.uploadAvatarButton.layer.masksToBounds = YES;
    self.uploadCoverPhotoButton.layer.cornerRadius = self.uploadCoverPhotoButton.frame.size.width/2;
    self.uploadCoverPhotoButton.layer.masksToBounds = YES;
    
    self.greyColor = [UIColor dollyTabColorSelectedBackground];
    self.tabTextColor = [UIColor dollyTabColorSelectedText];
    
    
    // == Registering nibs
    
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
    
    
    self.channelExpandedLayout = [[SYNProfileExpandedFlowLayout alloc]init];
    
    
    
    // == Main Collection View
    if (IS_IPHONE)
    {
        self.subscriptionThumbnailCollectionView.collectionViewLayout = self.subscriptionLayoutIPhone;
        
        self.testLayoutIPhone = [[SYNProfileFlowLayout alloc]init];
        
        self.channelThumbnailCollectionView.collectionViewLayout = self.channelLayoutIPhone;
        [self.channelThumbnailCollectionView.collectionViewLayout invalidateLayout];
        [self.subscriptionThumbnailCollectionView.collectionViewLayout invalidateLayout];
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
    
    self.channelThumbnailCollectionView.hidden = YES;
    //updates the staus bar appearance
    
    [self updateLayoutForOrientation:[SYNDeviceManager.sharedInstance orientation]];
    
    UITextField *txfSearchField = [self.followingSearchBar valueForKey:@"_searchField"];
    if(txfSearchField)
        txfSearchField.backgroundColor = [UIColor colorWithRed: (255.0f / 255.0f)
                                                         green: (255.0f / 255.0f)
                                                          blue: (255.0f / 255.0f)
                                                         alpha: 1.0f];
    
    
    
    [self setProfleType:self.modeType];
    
    //    NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
    ////    [attributes setValue:[UIColor colorWithWhite:0.30 alpha:1.0] forKey:NSForegroundColorAttributeName];
    ////    [attributes setValue:[UIColor whiteColor] forKey:NSShadowAttributeName];
    //
    //    NSShadow *tmpShadow = [[NSShadow alloc]init];
    //    tmpShadow.shadowColor = [UIColor colorWithWhite:0.0f alpha:0.4f];
    //    [tmpShadow setShadowOffset: CGSizeMake(0.0f, 1.0f)];
    //
    //    [attributes setValue:tmpShadow forKey:NSShadowAttributeName];
    //    [[UIBarButtonItem appearance] setTitleTextAttributes:attributes forState:UIControlStateNormal];
    //
    //    NSShadow *shadow = [NSShadow new];
    //    [shadow setShadowColor: [UIColor colorWithWhite:0.0f alpha:0.750f]];
    //    [shadow setShadowOffset: CGSizeMake(0.0f, 1.0f)];
    
    
    
    self.barBtnCancelEditMode = [[UIBarButtonItem alloc]initWithTitle:@"cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelEditModeTapped)];
    self.barBtnCancelEditMode.tintColor = [UIColor colorWithRed: (210.0f / 255.0f)
                                                          green: (66.0f / 255.0f)
                                                           blue: (42.0f / 255.0f)
                                                          alpha: 1.0f];
    
    self.barBtnCancelCreateChannel = [[UIBarButtonItem alloc]initWithTitle:@"cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelCreateChannel)];
    self.barBtnCancelCreateChannel.tintColor = [UIColor colorWithRed: (210.0f / 255.0f)
                                                               green: (66.0f / 255.0f)
                                                                blue: (42.0f / 255.0f)
                                                               alpha: 1.0f];
    
    
    self.barBtnSaveEditMode= [[UIBarButtonItem alloc]initWithTitle:@"save" style:UIBarButtonItemStyleBordered target:self action:@selector(saveEditModeTapped)];
    
    self.barBtnSaveEditMode.tintColor = [UIColor colorWithRed: (78.0f / 255.0f)
                                                        green: (210.0f / 255.0f)
                                                         blue: (42.0f / 255.0f)
                                                        alpha: 1.0f];
    
    self.barBtnSaveCreateChannel = [[UIBarButtonItem alloc]initWithTitle:@"save" style:UIBarButtonItemStyleBordered target:self action:@selector(saveCreateChannelTapped)];
    
    self.barBtnSaveCreateChannel.tintColor = [UIColor colorWithRed: (78.0f / 255.0f)
                                                             green: (210.0f / 255.0f)
                                                              blue: (42.0f / 255.0f)
                                                             alpha: 1.0f];
    
    self.tapToHideKeyoboard = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    
    if (IS_IPAD)
    {
        self.aboutMeTextView.translatesAutoresizingMaskIntoConstraints = YES;
    }
    
    [self.navigationController.navigationItem.leftBarButtonItem setTitle:@""];
    
    self.unfollowAlertView = [[UIAlertView alloc]initWithTitle:@"Unfollow?" message:nil delegate:self cancelButtonTitle:[self noButtonTitle] otherButtonTitles:[self yesButtonTitle], nil];
    
    self.followAllAlertView = [[UIAlertView alloc]initWithTitle:@"Follow All?" message:nil delegate:self cancelButtonTitle:[self noButtonTitle] otherButtonTitles:[self yesButtonTitle], nil];
    
    
}

-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
    //    self.navigationController.navigationBar.hidden = YES;
    
    [self updateTabStates];
    [self setUpUserProfile];
    [self setUpSegmentedControl];
    [self setNeedsStatusBarAppearanceUpdate];
    
    
    
    [self.channelThumbnailCollectionView reloadData];
    [self.subscriptionThumbnailCollectionView reloadData];
    [self updateLayoutForOrientation: [SYNDeviceManager.sharedInstance orientation]];
    
    //self.channelThumbnailCollectionView.contentOffset = CGPointZero;
    //self.subscriptionThumbnailCollectionView.contentOffset = CGPointZero;
    // Setting navigation bar settings
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.view.backgroundColor = [UIColor clearColor];
    //    [self.navigationController setTitle:@""];
    self.navigationItem.title = @"";
    
    
    //This should not be needed
    self.navigationController.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                                                  style:UIBarButtonItemStyleBordered
                                                                                                 target:nil
                                                                                                 action:nil];
    
    //    [self.navigationController.navigationBar.backItem setTitle:@""];
    
    
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
    
    //    self.tempBackString = self.navigationController.navigationBar.backItem.title.copy;
    //    [self.navigationController.navigationBar.backItem setTitle:@""];
    
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}


-(void)viewWillDisappear:(BOOL)animated
{
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.view.backgroundColor = [UIColor colorWithHue:0.6 saturation:0.33 brightness:0.69 alpha:0];
    
    //This should not be needed
    self.navigationController.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:nil action:nil];
    
    //    [self.navigationController.navigationBar.backItem setTitle: self.tempBackString];
    //    NSLog(@"back title %@", self.tempBackString);
    
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
    
    self.aboutMeTextView.text = self.channelOwner.channelOwnerDescription;
    
    [[self.aboutMeTextView layer] setBorderColor:[[UIColor colorWithRed:172.0/255.0f green:172.0/255.0f blue:172.0/255.0f alpha:1.0f] CGColor]];
    
    
    //  NSLog(@"chan des%@", self.channelOwner.channelOwnerDescription);
    
}


-(void) setUpSegmentedControl{
    
    self.segmentedControlsView.layer.cornerRadius = 4;
    self.segmentedControlsView.layer.borderWidth = .5f;
    self.segmentedControlsView.layer.borderColor = [[UIColor grayColor] CGColor];
    self.segmentedControlsView.layer.masksToBounds = YES;
    
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
    if (profileType == modeMyOwnProfile)
    {
        self.editButton.hidden = NO;
        self.followAllButton.hidden = YES;
        
        self.moreButton.hidden = NO;
        
    }
    if (profileType == modeOtherUsersProfile)
    {
        self.editButton.hidden = YES;
        self.followAllButton.hidden = NO;
        self.moreButton.hidden = YES;
        
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
    
    //    self.navigationController.navigationBarHidden = YES;
    
    if (!self.isIPhone)
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
            self.channelLayoutIPad.headerReferenceSize = CGSizeMake(671, 752);
            self.subscriptionLayoutIPad.minimumLineSpacing = 14.0f;
            self.subscriptionLayoutIPad.sectionInset = UIEdgeInsetsMake(0.0, 47.0, 0.0, 47.0);
            self.subscriptionLayoutIPad.headerReferenceSize = CGSizeMake(671, 752);
            
            self.channelExpandedLayout.minimumLineSpacing = 14.0f;
            self.channelExpandedLayout.sectionInset = UIEdgeInsetsMake(0.0, 47.0, 0.0, 47.0);
            self.channelExpandedLayout.headerReferenceSize = CGSizeMake(671, 752);
            
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
            self.channelLayoutIPad.minimumLineSpacing = 14.0f;
            self.channelLayoutIPad.headerReferenceSize = CGSizeMake(1004, 630);
            self.subscriptionLayoutIPad.minimumLineSpacing = 14.0f;
            self.subscriptionLayoutIPad.headerReferenceSize = CGSizeMake(1004, 630);
            self.subscriptionLayoutIPad.sectionInset =  UIEdgeInsetsMake(0.0, 21.0, 0.0, 21.0);
            
            self.channelExpandedLayout.sectionInset = UIEdgeInsetsMake(0.0, 21.0, 0.0, 21.0);
            self.channelExpandedLayout.minimumLineSpacing = 14.0f;
            self.channelExpandedLayout.headerReferenceSize = CGSizeMake(1004, 630);
            
            
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
        SYNChannelCreateNewCell *createCell = [collectionView dequeueReusableCellWithReuseIdentifier: @"SYNChannelCreateNewCell"
                                                                                        forIndexPath: indexPath];
        cell = createCell;
        ((SYNChannelCreateNewCell*)cell).viewControllerDelegate = self;
        
    }
    else
    {
        SYNChannelMidCell *channelThumbnailCell = [collectionView dequeueReusableCellWithReuseIdentifier: @"SYNChannelMidCell" forIndexPath: indexPath];
        
        Channel *channel;
        
        [channelThumbnailCell setBorder];
        
        // == Add Special Attributes == //
        // == Add Common Attributes == //
        
        if(self.modeType == modeOtherUsersProfile)
            
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
        
        
        if(collectionView == self.channelThumbnailCollectionView)
        {
            channel = (Channel *) self.channelOwner.channels[indexPath.item - (self.isUserProfile ? 1 : 0)];
            
            [channelThumbnailCell setHiddenForFollowButton:(self.modeType == modeMyOwnProfile)];
            
            NSString* subscribersString = [NSString stringWithFormat: @"%lld %@",channel.subscribersCountValue, NSLocalizedString(@"Subscribers", nil)];
            [channelThumbnailCell.followerCountLabel setText:subscribersString];
            
            channelThumbnailCell.channel = channel;
            
            NSMutableString* videoCountString = [NSMutableString new];
            if (IS_IPHONE)
            {
                [videoCountString appendString:@"- "];
            }
            
            [videoCountString appendFormat:@"%d %@",channel.totalVideosValue, NSLocalizedString(@"Videos", nil)];
            // NSLog(@"totalvideos value in pro%ld", (long)channel.totalVideosValue);
            
            channelThumbnailCell.videoCountLabel.text = [NSString stringWithString:videoCountString];
            
        }
        else // (collectionView == self.subscribersThumbnailCollectionView)
        {
            if (indexPath.row < self.arrDisplayFollowing.count)
            {
                channel = _arrDisplayFollowing[indexPath.item];
                
                if (self.modeType == modeMyOwnProfile)
                {
                    [channelThumbnailCell setFollowButtonLabel:NSLocalizedString(@"Unfollow", nil)];
                }
                
                NSString* subscribersString = [NSString stringWithFormat: @"%lld %@",channel.subscribersCountValue, NSLocalizedString(@"Subscribers", nil)];
                [channelThumbnailCell.followerCountLabel setText:subscribersString];
                
                channelThumbnailCell.channel = channel;
                
                NSMutableString* videoCountString = [NSMutableString new];
                if (IS_IPHONE)
                {
                    [videoCountString appendString:@"- "];
                }
                
                
                [videoCountString appendFormat:@"%ld %@",(long)channel.videoInstances.count, NSLocalizedString(@"Videos", nil)];
                
                
                channelThumbnailCell.videoCountLabel.text = [NSString stringWithString:videoCountString];
                
            }
        }
        
        
        
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
            
            //            SYNChannelDetailsViewController *channelVC;
            //
            //            channelVC = [[SYNChannelDetailsViewController alloc] initWithChannel:channel usingMode:kChannelDetailsModeEdit];
            //
            //            [self.navigationController pushViewController:channelVC animated:YES];
            
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
    
    
    if (self.isUserProfile  && indexPath.row == 0 && self.channelThumbnailCollectionView.collectionViewLayout == self.channelLayoutIPhone && IS_IPHONE)
    {
        return CGSizeMake(320, 60);
    }
    
    
    if (collectionView == self.channelThumbnailCollectionView)
    {
        if (IS_IPHONE)
        {
            return self.channelLayoutIPhone.itemSize;
        }
        else
        {
            return self.channelLayoutIPad.itemSize;
        }
    }
    
    if (collectionView == self.subscriptionThumbnailCollectionView)
    {
        if (IS_IPHONE)
        {
            return self.subscriptionLayoutIPhone.itemSize;
        }
        else{
            
            
            return self.subscriptionLayoutIPad.itemSize;
        }
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
    
    if (self.modeType == modeMyOwnProfile) {
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
        [self moveNameLabelWithOffset:scrollView.contentOffset.y];
    }
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [self moveNameLabelWithOffset:scrollView.contentOffset.y];
}


- (void) scrollViewDidScroll: (UIScrollView *) scrollView
{
    [super scrollViewDidScroll:scrollView];
    CGFloat offset = scrollView.contentOffset.y;
    
    //   NSLog(@"%f", offset);
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
            self.followersCountButton.transform = move;
            self.uploadAvatarButton.transform = move;
            self.uploadCoverPhotoButton.transform = move;
            
            
            if (offset<0)
            {
                //Scale the cover phote in iphone
                CGAffineTransform scale = CGAffineTransformMakeScale(1+ fabsf(offset)/250,1+ fabsf(offset)/250);
                self.coverImage.transform = scale;
                
                CGRect tmpFrame = self.coverImage.frame;
                tmpFrame.origin.y = 0;
                self.coverImage.frame = tmpFrame;
                
                //                self.coverImage.transform = CGAffineTransformConcat(scale, move);
                
                //NSLog(@"%f", offset);
                //Way too slow
                //[self.coverImage setImage:[self.coverImage.image blur:self.coverImage.image withBlurValue:fabsf(offset)]];
                
                
                self.backgroundView.transform = move;
                
            }
            else
            {
                CGAffineTransform moveCoverImage = CGAffineTransformMakeTranslation(0, -offset/PARALLAX_SCROLL_VALUE);
                
                self.coverImage.transform = moveCoverImage;
                self.backgroundView.transform = move;
                
            }
            
            [self moveNameLabelWithOffset:offset];
        }
        else
        {
            CGAffineTransform move = CGAffineTransformMakeTranslation(0, -offset);
            self.coverImage.transform = move;
            self.moreButton.transform = move;
            self.containerViewIPad.transform = move;
            self.uploadAvatarButton.transform = move;
            self.uploadCoverPhotoButton.transform = move;
            
            //scaling
            if (offset<0)
            {
                //Scale the cover phote in iphone
                CGAffineTransform scale;
                
                if (UIDeviceOrientationIsPortrait([SYNDeviceManager.sharedInstance orientation]))
                {
                    
                    scale = CGAffineTransformMakeScale(1+ fabsf(offset)/530,1+ fabsf(offset)/530);
                    
                }else
                {
                    scale = CGAffineTransformMakeScale(1+ fabsf(offset)/400,1+ fabsf(offset)/400);
                }
                
                self.coverImage.transform = scale;
                self.backgroundView.transform = move;
                
                //recentre the image, root of problem is in autolayout
                CGRect tmpRect = self.coverImage.frame;
                CGAffineTransform move = CGAffineTransformMakeTranslation(self.view.center.x - tmpRect.size.width/2, 0);
                
                self.coverImage.transform = CGAffineTransformConcat(scale, move);
                
            }
            else
            {
                //parallaxing
                CGAffineTransform moveCoverImage = CGAffineTransformMakeTranslation(0, -offset/PARALLAX_SCROLL_VALUE);
                self.coverImage.transform = moveCoverImage;
                self.backgroundView.transform = move;
                
            }
            
            [self moveNameLabelWithOffset:offset];
        }
    }
    
    if (!self.isIPhone)
    {
        if (self.orientationDesicionmaker && scrollView != self.orientationDesicionmaker)
        {
            scrollView.contentOffset = [self.orientationDesicionmaker contentOffset];
            return;
        }
        
    }
}


-(void) moveNameLabelWithOffset :(CGFloat) offset
{
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
    
    BOOL channelOwnerIsUser = (BOOL)[user.uniqueId isEqualToString: appDelegate.currentUser.uniqueId];
    
    
    if (!channelOwnerIsUser) // is a User has been passsed dont copy him OR his channels as there can be only one.
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
    else // The ChannelOwner is the User!
    {
        _channelOwner = user;
    }
    
    // if a user has been passed or found, monitor
    if (self.channelOwner)
    {
        // isUserProfile set to YES for the current User
        self.isUserProfile = channelOwnerIsUser;
        
        
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(handleDataModelChange:)
                                                     name: NSManagedObjectContextDidSaveNotification
                                                   object: self.channelOwner.managedObjectContext];
        
        [[NSNotificationCenter defaultCenter] postNotificationName: kChannelOwnerUpdateRequest
                                                            object: self
                                                          userInfo: @{kChannelOwner : self.channelOwner}];
    }
    
    if(channelOwnerIsUser && self.modeType != modeEditProfile)
    {
        self.modeType = modeMyOwnProfile;
    }
    else
    {
        self.modeType = modeOtherUsersProfile;
    }
    
    [self.subscriptionThumbnailCollectionView reloadData];
    [self.channelThumbnailCollectionView reloadData];
    
    
}

#pragma mark - Arc menu support

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
        SYNChannelDetailsViewController *channelVC;
        
        Channel *channel;
        
        if (self.isUserProfile && indexPath.row == 0)
        {
            //never gets called, first cell gets called and created in didSelectItem
            return;
        }
        else if( self.isUserProfile && indexPath.row == 1)
        {
            channel = self.channelOwner.channels[indexPath.row - (self.isUserProfile ? 1 : 0)];
            
            channelVC = [[SYNChannelDetailsViewController alloc] initWithChannel:channel usingMode:kChannelDetailsFavourites];
            
            [self.navigationController pushViewController:channelVC animated:YES];
            
            return;
        }
        
        else
        {
            //  self.indexPathToDelete = indexPath;
            channel = self.channelOwner.channels[indexPath.row - (self.isUserProfile ? 1 : 0)];
        }
        
        if (modeType == modeMyOwnProfile) {
            channelVC = [[SYNChannelDetailsViewController alloc] initWithChannel:channel usingMode:kChannelDetailsModeDisplayUser];
            
        }
        
        if (modeType == modeOtherUsersProfile) {
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
        //        self.navigationController.navigationBarHidden = NO;
        
        
        SYNChannelDetailsViewController *channelVC = [[SYNChannelDetailsViewController alloc] initWithChannel:channel usingMode:kChannelDetailsModeDisplay];
        
        [self.navigationController pushViewController:channelVC animated:YES];
    }
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

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [self.view addGestureRecognizer:self.tapToHideKeyoboard];
    
    NSLog(@"Started editing a textfield");
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.view removeGestureRecognizer:self.tapToHideKeyoboard];
    
    [textField resignFirstResponder];
    return YES;
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    
    NSLog(@"text field end editing");
    [textField resignFirstResponder];
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

#pragma mark - Displayed Search

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
    
    [self.unfollowAlertView setMessage:message];
    
    self.followCell = ((SYNChannelMidCell*)cell);
    
    if (modeType == modeMyOwnProfile) {
        [self.unfollowAlertView show];
    }
    else if(modeType == modeOtherUsersProfile)
    {
        
        [[NSNotificationCenter defaultCenter] postNotificationName: kChannelSubscribeRequest
                                                            object: self
                                                          userInfo: @{kChannel : self.followCell.channel}];
        
        //Need to refresh the cell
        if (self.followCell.channel.subscribedByUserValue == YES)
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
    return NSLocalizedString(@"Yes", @"Yes to deleting a video instance");
}
- (NSString *) noButtonTitle{
    return NSLocalizedString(@"Cancel", @"cancel to deleting a video instance");
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *buttonTitle = [alertView buttonTitleAtIndex:buttonIndex];
    
    
    if (alertView == self.unfollowAlertView && [buttonTitle isEqualToString:[self yesButtonTitle]])
    {
        
        if (self.followCell.channel != nil)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName: kChannelSubscribeRequest
                                                                object: self
                                                              userInfo: @{kChannel : self.followCell.channel}];
        }
    }
    
    if (alertView == self.followAllAlertView && [buttonTitle isEqualToString:[self yesButtonTitle]])
    {
        
        
        //        NSLog(@"alertView clickedButtonAtIndex FOLLOW ALL");
        [[NSNotificationCenter defaultCenter] postNotificationName: kChannelOwnerSubscribeToUserRequest
                                                            object: self
                                                          userInfo: @{kChannelOwner : self.channelOwner}];
        
    }
    
    
}

#pragma mark - IBActions

- (IBAction)backButtonTapped:(id)sender {
    //    self.navigationController.navigationBarHidden = NO;
    
    [self.navigationController popViewControllerAnimated:YES];
    
}
- (IBAction)followersCountTapped:(id)sender {
    
    //To be implemented
}


-(void) followButtonTapped:(UICollectionViewCell *) cell
{
    [self showAlertView: cell];
    
}

- (IBAction)moreButtonTapped:(id)sender
{
    
    SYNOptionsOverlayViewController* optionsVC = [[SYNOptionsOverlayViewController alloc] init];
    
    // Set frame to full screen
    CGRect vFrame = optionsVC.view.frame;
    vFrame.size = [[SYNDeviceManager sharedInstance] currentScreenSize];
    optionsVC.view.frame = vFrame;
    optionsVC.view.alpha = 0.0f;
    
    
    [appDelegate.masterViewController addChildViewController:optionsVC];
    [appDelegate.masterViewController.view addSubview:optionsVC.view];
    
    [UIView animateWithDuration:0.3 animations:^{
        optionsVC.view.alpha = 1.0f;
    }];
    
}

- (IBAction)editButtonTapped:(id)sender
{
    
    self.modeType = modeEditProfile;
    self.uploadCoverPhotoButton.hidden = NO;
    self.uploadAvatarButton.hidden = NO;
    self.uploadCoverPhotoButton.alpha = 0.0f;
    self.uploadAvatarButton.alpha = 0.0f;
    
    CGRect tmpRect = self.aboutMeTextView.frame;
    tmpRect.origin.y += 10;
    tmpRect.size.height += 18;
    
    
    self.subscriptionThumbnailCollectionView.scrollEnabled = NO;
    self.channelThumbnailCollectionView.scrollEnabled = NO;
    self.aboutMeTextView.editable = YES;
    
    [UIView animateWithDuration:0.5f animations:^{
        
        self.coverImage.alpha = ALPHA_IN_EDIT;
        self.segmentedControlsView.alpha = ALPHA_IN_EDIT;
        self.channelThumbnailCollectionView.alpha = ALPHA_IN_EDIT;
        self.subscriptionThumbnailCollectionView.alpha = ALPHA_IN_EDIT;
        
        self.editButton.alpha = 0.0f;
        self.moreButton.alpha = 0.0f;
        self.followersCountButton.alpha = 0.0f;
        self.profileImageView.alpha = 0.0f;
        self.followersCountButton.alpha = 0.0f;
        
        self.barBtnBack = self.navigationItem.leftBarButtonItem;
        self.navigationItem.leftBarButtonItem = self.barBtnCancelEditMode;
        self.navigationItem.rightBarButtonItem = self.barBtnSaveEditMode;
        
        self.aboutMeTextView.backgroundColor = [UIColor colorWithRed:224.0/255.0f green:224.0/255.0f blue:224.0/255.0f alpha:1.0];
        self.uploadCoverPhotoButton.alpha = 1.0f;
        self.uploadAvatarButton.alpha = 1.0f;
        
        self.aboutMeTextView.frame = tmpRect;
        [[self.aboutMeTextView layer] setBorderColor:[[UIColor colorWithRed:172.0/255.0f green:172.0/255.0f blue:172.0/255.0f alpha:1.0f] CGColor]];
        if (IS_RETINA)
        {
            [[self.aboutMeTextView layer] setBorderWidth:0.5];
        }
        else
        {
            [[self.aboutMeTextView layer] setBorderWidth:1.0];
        }
        [[self.aboutMeTextView layer] setCornerRadius:0];
        
        self.subscriptionThumbnailCollectionView.contentOffset = CGPointMake(0, 0);
        self.channelThumbnailCollectionView.contentOffset = CGPointMake(0, 0);
        
    }];
}
#pragma mark - Navigation item methods

//Navigation bar item cancel
-(void) cancelEditModeTapped
{
    
    self.modeType = modeMyOwnProfile;
    CGRect tmpRect = self.aboutMeTextView.frame;
    tmpRect.origin.y -= 10;
    tmpRect.size.height -= 18;
    
    self.aboutMeTextView.editable = NO;
    
    self.aboutMeTextView.text = self.channelOwner.channelOwnerDescription;
    [UIView animateWithDuration:0.5f animations:^{
        
        self.coverImage.alpha = 1.0f;
        self.segmentedControlsView.alpha = 1.0f;
        self.editButton.alpha = 1.0f;
        self.moreButton.alpha = 1.0f;
        self.followersCountButton.alpha = 1.0f;
        self.channelThumbnailCollectionView.alpha = 1.0f;
        self.subscriptionThumbnailCollectionView.alpha = 1.0f;
        
        self.navigationItem.leftBarButtonItem = self.barBtnBack;
        self.navigationItem.rightBarButtonItem = nil;
        self.aboutMeTextView.backgroundColor = [UIColor whiteColor];
        self.profileImageView.alpha = 1.0f;
        
        self.uploadAvatarButton.alpha = 0.0f;
        self.uploadCoverPhotoButton.alpha = 0.0f;
        
        [[self.aboutMeTextView layer] setBorderWidth:0.0];
        
        self.aboutMeTextView.frame = tmpRect;
        
    } completion:^(BOOL finished) {
        self.uploadCoverPhotoButton.hidden = YES;
        self.uploadAvatarButton.hidden = YES;
        
        
    }];
    self.subscriptionThumbnailCollectionView.scrollEnabled = YES;
    self.channelThumbnailCollectionView.scrollEnabled = YES;
    
    //    [self resetOffsetWithAnimation];
    
}



-(void) saveCreateChannelTapped
{
    NSLog(@"saveCreateChannelTapped");
}

-(void) saveEditModeTapped
{
    
    [self updateField:@"description" forValue:self.aboutMeTextView.text withCompletionHandler:^{
        appDelegate.currentUser.channelOwnerDescription = self.aboutMeTextView.text;
        [appDelegate saveContext: YES];
        [self cancelEditModeTapped];
        
    }];
    //
    //
    //
    
    
}

- (void) updateField: (NSString *) field
            forValue: (id) newValue
withCompletionHandler: (MKNKBasicSuccessBlock) successBlock
{
    
    [appDelegate.oAuthNetworkEngine changeUserField: field
                                            forUser: appDelegate.currentUser
                                       withNewValue: newValue
                                  completionHandler: ^(NSDictionary * dictionary){
                                      
                                      
                                      //                                           [self.spinner stopAnimating];
                                      //                                           self.saveButton.hidden = NO;
                                      //                                           self.saveButton.enabled = YES;
                                      
                                      successBlock();
                                      
                                      [[NSNotificationCenter defaultCenter]  postNotificationName: kUserDataChanged
                                                                                           object: self
                                                                                         userInfo: @{@"user": appDelegate.currentUser}];
                                      
                                      //                                           [self.spinner stopAnimating];
                                      
                                  } errorHandler: ^(id errorInfo) {
                                      
                                      //                                           [self.spinner stopAnimating];
                                      //
                                      //                                           self.saveButton.hidden = NO;
                                      //                                           self.saveButton.enabled = YES;
                                      
                                      if (!errorInfo || ![errorInfo isKindOfClass: [NSDictionary class]])
                                      {
                                          return;
                                      }
                                      
                                      NSString *message = errorInfo[@"message"];
                                      
                                      if (message)
                                      {
                                          if ([message isKindOfClass: [NSArray class]])
                                          {
                                              //                                                   self.errorLabel.text = (NSString *) ((NSArray *) message)[0];
                                              
                                              NSLog(@"Error %@", message);
                                          }
                                          else if ([message isKindOfClass: [NSString class]])
                                          {
                                              //                                                   self.errorLabel.text = message;
                                              NSLog(@"Error %@", message);
                                          }
                                      }
                                  }];
}

#pragma mark - Text View Delegates

-(void)textViewDidEndEditing:(UITextView *)textView
{
    if (self.modeType == modeEditProfile) {
        
        [self performSelector:@selector(resetOffsetWithAnimation) withObject:nil afterDelay:0.3f];
    }
    //[self resetOffsetWithAnimation];
    NSLog(@"text view end editing");
    
    [textView resignFirstResponder];
}

-(void) textViewDidBeginEditing:(UITextView *)textView
{
    
    [self.view addGestureRecognizer:self.tapToHideKeyoboard];
    
    if (self.modeType == modeEditProfile) {
        [UIView animateWithDuration:0.3f animations:^{
            self.subscriptionThumbnailCollectionView.contentOffset = CGPointMake(0, OFFSET_DESCRIPTION_EDIT);
            self.channelThumbnailCollectionView.contentOffset = CGPointMake(0, OFFSET_DESCRIPTION_EDIT);
            
        }];
    }
    
    
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        
        [textView resignFirstResponder];
        // Return FALSE so that the final '\n' character doesn't get added
        return NO;
    }
    
    NSUInteger newLength = [textView.text length] + [text length] - range.length;
    return (newLength > 50) ? NO : YES;
}

-(void)dismissKeyboard
{
    NSLog(@"dismiss %f", self.aboutMeTextView.frame.size.height);
    [self.aboutMeTextView resignFirstResponder];
    [self.view removeGestureRecognizer:self.tapToHideKeyoboard];
    [self resetOffsetWithAnimation];
}

-(void) resetOffsetWithAnimation
{
    [UIView animateWithDuration:0.3f animations:^{
        self.subscriptionThumbnailCollectionView.contentOffset = CGPointMake(0, 0);
        self.channelThumbnailCollectionView.contentOffset = CGPointMake(0, 0);
    }];
    
}
- (IBAction)changeCoverImageButtonTapped:(id)sender
{
    
    
}
- (IBAction)changeAvatarButtonTapped:(id)sender
{
    self.imagePickerController = [[SYNImagePickerController alloc] initWithHostViewController:self];
    self.imagePickerController.delegate = self;
    
    
    [self.imagePickerController presentImagePickerAsPopupFromView:sender arrowDirection:UIPopoverArrowDirectionRight];
}


- (IBAction)followAllTapped:(id)sender
{
    NSLog(@"Follow all");
    NSString *message = @"Are you sure you want to follow all channels of this user";
    message =  [message stringByAppendingString:@" "];
    message =  [message stringByAppendingString:self.channelOwner.username];
    
    [self.followAllAlertView setMessage:message];
    
    if(modeType == modeOtherUsersProfile)
    {
        [self.followAllAlertView show];
        
        //Need to refresh the cell
        //        if (self.followCell.channel.channelOwner.subscribedByUserValue == NO)
        //        {
        //            [self.followCell setFollowButtonLabel:NSLocalizedString(@"Follow All", @"unfollow")];
        //        }
        //        else
        //        {
        //            [self.followCell setFollowButtonLabel:NSLocalizedString(@"UnFollow All", @"follow")];
        //        }
    }
}

- (void) picker: (SYNImagePickerController *) picker
finishedWithImage: (UIImage *) image
{
    //DebugLog(@"Orign image width: %f, height%f", image.size.width, image.size.height);
    self.avatarButton.enabled = NO;
    self.profileImageView.image = image;
    //  [self.activityIndicator startAnimating];
    [appDelegate.oAuthNetworkEngine updateAvatarForUserId: appDelegate.currentOAuth2Credentials.userId
                                                    image: image
                                        completionHandler: ^(NSDictionary* result)
     {
         //         self.profilePictureImageView.image = image;
         //      [self.activityIndicator stopAnimating];
         self.avatarButton.enabled = YES;
     }
                                             errorHandler: ^(id error)
     {
         [self.profileImageView setImageWithURL: [NSURL URLWithString: appDelegate.currentUser.thumbnailURL]
                               placeholderImage: [UIImage imageNamed: @"PlaceholderSidebarAvatar"]
                                        options: SDWebImageRetryFailed];
         
         //     [self.activityIndicator stopAnimating];
         self.avatarButton.enabled = YES;
         
         UIAlertView* alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"register_screen_form_avatar_upload_title",nil)
                                                         message: NSLocalizedString(@"register_screen_form_avatar_upload_description",nil)
                                                        delegate: nil
                                               cancelButtonTitle: nil
                                               otherButtonTitles: NSLocalizedString(@"OK",nil), nil];
         [alert show];
     }];
    
    self.imagePickerController = nil;
    
}

-(void)createNewButtonPressed
{
    
    NSLog(@"create cell");
    for (SYNChannelMidCell* cell in self.channelThumbnailCollectionView.visibleCells)
    {
        NSIndexPath* indexPathForCell = [self.channelThumbnailCollectionView indexPathForCell:cell];
        
        
        __block int index = indexPathForCell.row;
        void (^animateEditMode)(void) = ^{
            
            CGRect frame = cell.frame;
            
            if (index == 0)
            {
                NSLog(@"index 0");
                ((SYNChannelCreateNewCell*)cell).createCellButton.alpha = 0.0;
                ((SYNChannelCreateNewCell*)cell).descriptionTextView .alpha = 1.0;
                
                CGRect tmpBoarder = ((SYNChannelCreateNewCell*)cell).boarderView.frame;
                tmpBoarder.size.height+= kHeightChange;
                ((SYNChannelCreateNewCell*)cell).boarderView.frame = tmpBoarder;
                [((SYNChannelCreateNewCell*)cell).createTextField becomeFirstResponder];
                
            }
            else
            {
                if (IS_IPHONE)
                {
                    frame.origin.y += kHeightChange;
                }
                
                if (IS_IPAD)
                {
                    
                    if (UIDeviceOrientationIsPortrait([SYNDeviceManager.sharedInstance orientation])) {
                        if (index%2 == 0) {
                            frame.origin.y +=kHeightChange;
                        }
                    }
                    else
                    {
                        if (index%3 == 0) {
                            frame.origin.y +=kHeightChange;
                        }
                        
                    }
                }
            }
            
            cell.frame = frame;
        };
        
        [UIView transitionWithView:cell
                          duration:0.4f
                           options: UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState
                        animations:animateEditMode
                        completion:^(BOOL finished) {
                            
                            
                        }];
        
        [UIView animateKeyframesWithDuration:0.2 delay:0.4 options:UIViewAnimationCurveEaseInOut animations:^{
            [self.channelThumbnailCollectionView setContentOffset: CGPointMake(0, 414)];
            self.navigationItem.leftBarButtonItem = self.barBtnCancelCreateChannel;
            self.navigationItem.rightBarButtonItem = self.barBtnSaveCreateChannel;
            
        } completion:Nil];
        
    }
    
    [self performSelector:@selector(updateCollectionLayout) withObject:self afterDelay:0.6f];
}


-(void) cancelCreateChannel
{
    NSLog(@"cancelCancelChannel");
    
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.rightBarButtonItem = nil;
    [self resignFirstResponder];
    
    NSLog(@"create cell");
    for (__block SYNChannelMidCell* cell in self.channelThumbnailCollectionView.visibleCells)
    {
        NSIndexPath* indexPathForCell = [self.channelThumbnailCollectionView indexPathForCell:cell];
        
        
        __block int index = indexPathForCell.row;
        void (^animateProfileMode)(void) = ^{
            
            CGRect frame = cell.frame;
            
            if (index == 0)
            {
                NSLog(@"index 0");
                ((SYNChannelCreateNewCell*)cell).createCellButton.alpha = 1.0f;
                ((SYNChannelCreateNewCell*)cell).descriptionTextView .alpha = 0.0f;
                
                CGRect tmpBoarder = ((SYNChannelCreateNewCell*)cell).boarderView.frame;
                tmpBoarder.size.height-= kHeightChange;
                ((SYNChannelCreateNewCell*)cell).boarderView.frame = tmpBoarder;
            }
            else
            {
                if (IS_IPHONE)
                {
                    frame.origin.y -= kHeightChange;
                }
                
                if (IS_IPAD)
                {
                    
                    if (UIDeviceOrientationIsPortrait([SYNDeviceManager.sharedInstance orientation]))
                    {
                        if (index%2 == 0)
                        {
                            frame.origin.y -=kHeightChange;
                        }
                    }
                    else
                    {
                        if (index%3 == 0)
                        {
                            frame.origin.y -=kHeightChange;
                        }
                        
                    }
                }
            }
            
            cell.frame = frame;
        };
        
        [UIView transitionWithView:cell
                          duration:0.4f
                           options: UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState
                        animations:animateProfileMode
                        completion:^(BOOL finished) {
                            
                            
                        }];
        
        [UIView animateKeyframesWithDuration:0.2 delay:0.4 options:UIViewAnimationCurveEaseInOut animations:^{
            [self.channelThumbnailCollectionView setContentOffset: CGPointMake(0, 414)];
            
        } completion:Nil];
        
    }
    
    [self performSelector:@selector(updateCollectionLayout) withObject:self afterDelay:0.6f];
    
}

-(void) updateCollectionLayout
{
    //  self.channelThumbnailCollectionView.collectionViewLayout = self.channelExpandedLayout;
    CGPoint tmpPoint = self.channelThumbnailCollectionView.contentOffset;
    
    if (IS_IPHONE){
        if (self.channelThumbnailCollectionView.collectionViewLayout == self.channelLayoutIPhone) {
            [self.channelThumbnailCollectionView setCollectionViewLayout:self.channelExpandedLayout];
            self.channelThumbnailCollectionView.contentOffset = tmpPoint;
            [self.channelThumbnailCollectionView.collectionViewLayout invalidateLayout];
        }
        else
        {
            [self.channelThumbnailCollectionView setCollectionViewLayout:self.channelLayoutIPhone];
            self.channelThumbnailCollectionView.contentOffset = tmpPoint;
            [self.channelThumbnailCollectionView.collectionViewLayout invalidateLayout];
        }
    }
    else
    {
        if (self.channelThumbnailCollectionView.collectionViewLayout == self.channelLayoutIPad) {
            [self.channelThumbnailCollectionView setCollectionViewLayout:self.channelExpandedLayout];
            self.channelThumbnailCollectionView.contentOffset = tmpPoint;
            [self.channelThumbnailCollectionView.collectionViewLayout invalidateLayout];
        }
        else
        {
            [self.channelThumbnailCollectionView setCollectionViewLayout:self.channelLayoutIPad];
            
            
            self.channelThumbnailCollectionView.contentOffset = tmpPoint;
            [self.channelThumbnailCollectionView.collectionViewLayout invalidateLayout];
        }
        
    }
}



@end
