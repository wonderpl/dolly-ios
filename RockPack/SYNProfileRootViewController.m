//
//  SYNProfileRootViewController.m
//  rockpack
//
//  Created by Nick Banks on 24/01/2013.
//  Copysubscriptions (c) Rockpack Ltd. All subscriptionss reserved.
//
//Alertview to 2 channels create with the same name


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
#import "SYNActivityManager.h"
#import "UINavigationBar+Appearance.h"
#import "SYNGenreColorManager.h"


@import QuartzCore;

#define FULL_NAME_LABEL_IPHONE 276.0f // lower is down
#define FULL_NAME_LABEL_IPAD_PORTRAIT 533.0f
#define FULLNAMELABELIPADLANDSCAPE 412.0f
#define SEARCHBAR_Y 415.0f
#define ALPHA_IN_EDIT 0.2f
#define OFFSET_DESCRIPTION_EDIT 130.0f
#define PARALLAX_SCROLL_VALUE 2.0f
#define kHeightChange 94.0f
#define MAXRANGE 1000.0f


//alertview for channels with same name
//alertview for channels with no name

@interface SYNProfileRootViewController () <UIGestureRecognizerDelegate, SYNImagePickerControllerDelegate, SYNChannelMidCellDelegate,SYNChannelCreateNewCelllDelegate> {
    ProfileType modeType;
}

@property (nonatomic) BOOL isIPhone;
@property (nonatomic) BOOL isUserProfile;
@property (nonatomic) BOOL trackView;
@property (nonatomic, assign) BOOL collectionsTabActive;

@property (nonatomic, strong) NSArray* arrDisplayFollowing;
@property (strong, nonatomic) UIBarButtonItem *barBtnBack; // storage for the navigation back button

@property (nonatomic, strong) NSIndexPath *channelsIndexPath;
@property (nonatomic, strong) NSIndexPath *subscriptionsIndexPath;
//used for the search bar in subscriptions tab
@property (nonatomic, strong) NSString *currentSearchTerm;
@property (nonatomic, assign) BOOL shouldBeginEditing;

@property (strong, nonatomic) IBOutlet UIButton *uploadCoverPhotoButton;

@property (nonatomic, strong) id orientationDesicionmaker;

@property (nonatomic, strong) SYNImagePickerController* imagePickerControllerAvatar;
@property (nonatomic, strong) SYNImagePickerController* imagePickerControllerCoverphoto;

@property (nonatomic, strong) SYNChannelMidCell *followCell;
@property (strong, nonatomic) IBOutlet UICollectionViewFlowLayout *channelLayoutIPad;
@property (strong, nonatomic) IBOutlet UICollectionViewFlowLayout *subscriptionLayoutIPad;
@property (strong, nonatomic) IBOutlet UIButton *followAllButton;
@property (strong, nonatomic) IBOutlet UIButton *followersCountButton;
@property (strong, nonatomic) IBOutlet UIView *outerViewFullNameLabel;
@property (strong, nonatomic) IBOutlet UICollectionViewFlowLayout *channelLayoutIPhone;
@property (strong, nonatomic) IBOutlet UICollectionViewFlowLayout *subscriptionLayoutIPhone;

@property (strong, nonatomic) SYNProfileExpandedFlowLayout *channelExpandedLayout;
@property (nonatomic, strong) IBOutlet UICollectionView *channelThumbnailCollectionView;
@property (strong, nonatomic) IBOutlet UICollectionView *subscriptionThumbnailCollectionView;
@property (strong, nonatomic) IBOutlet UIImageView *profileImageView;
@property (strong, nonatomic) IBOutlet UIButton *avatarButton;

@property (strong, nonatomic) IBOutlet UILabel *fullNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *userNameLabel;
@property (strong, nonatomic) IBOutlet UIImageView *coverImage;
@property (strong, nonatomic) IBOutlet UITextView *aboutMeTextView;

@property (strong, nonatomic) IBOutlet UIButton *editButton;
@property (strong, nonatomic) IBOutlet UIButton *collectionsTabButton;
@property (strong, nonatomic) IBOutlet UIButton *followingTabButton;
@property (strong, nonatomic) IBOutlet UIView *segmentedControlsView;
@property (strong, nonatomic) IBOutlet UIButton *moreButton;
@property (nonatomic, strong) SYNChannelMidCell *deleteCell;

@property (strong, nonatomic) IBOutlet UIButton *uploadAvatarButton;


@property (nonatomic, assign) BOOL searchMode;
@property (strong, nonatomic) IBOutlet UISearchBar *followingSearchBar;
@property (strong, nonatomic) IBOutlet UIView *containerViewIPad;
@property (nonatomic) ProfileType modeType;
@property (strong, nonatomic) UIBarButtonItem *barBtnCancelEditMode;
@property (strong, nonatomic) UIBarButtonItem *barBtnCancelCreateChannel;
@property (strong, nonatomic) UIBarButtonItem *barBtnSaveEditMode;
@property (strong, nonatomic) UIBarButtonItem *barBtnSaveCreateChannel;

@property (strong, nonatomic) IBOutlet UIView *backgroundView;

@property (strong, nonatomic) UITapGestureRecognizer *tapToHideKeyoboard;

@property (strong, nonatomic) UIAlertView *unfollowAlertView;
@property (strong, nonatomic) UIAlertView *followAllAlertView;
@property (strong, nonatomic) UIAlertView *sameChannelNameAlertView;
@property (nonatomic, strong) UIAlertView *deleteChannelAlertView;


@property (weak, nonatomic) SYNChannelCreateNewCell *createChannelCell;

@property  (nonatomic) BOOL creatingChannel;

@property (nonatomic) NSRange dataRequestRangeChannel;
@property (nonatomic) NSRange dataRequestRangeSubscriptions;

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
    // Defensive programming
    
    self.channelOwner = nil;
    self.subscriptionThumbnailCollectionView.delegate =nil;
    self.subscriptionThumbnailCollectionView.dataSource =nil;
    self.channelThumbnailCollectionView.delegate = nil;
    self.channelThumbnailCollectionView.dataSource = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextObjectsDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kHideAllDesciptions object:nil];
}


#pragma mark - View Lifecycle

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    [SYNActivityManager.sharedInstance updateActivityForCurrentUser];

    self.shouldBeginEditing = YES;
    self.collectionsTabActive = YES;
    
    // == Masking Images into a circle
    self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.width/2;
    self.profileImageView.layer.masksToBounds = YES;
    self.uploadAvatarButton.layer.cornerRadius = self.uploadAvatarButton.frame.size.width/2;
    self.uploadAvatarButton.layer.masksToBounds = YES;
    self.uploadCoverPhotoButton.layer.cornerRadius = self.uploadCoverPhotoButton.frame.size.width/2;
    self.uploadCoverPhotoButton.layer.masksToBounds = YES;
    
    // == Registering nibs
    
    UINib *searchCellNib = [UINib nibWithNibName: @"SYNChannelSearchCell"
                                          bundle: nil];
    
    [self.subscriptionThumbnailCollectionView registerNib:searchCellNib forCellWithReuseIdentifier:@"SYNChannelSearchCell"];
    
    
    UINib *createCellNib = [UINib nibWithNibName: @"SYNChannelCreateNewCell"
                                          bundle: nil];
    
    [self.channelThumbnailCollectionView registerNib: createCellNib
                          forCellWithReuseIdentifier: @"SYNChannelCreateNewCell"];
    
    UINib *thumbnailCellNib = [UINib nibWithNibName: @"SYNChannelMidCell"
                                             bundle: nil];
    
    [self.channelThumbnailCollectionView registerNib: thumbnailCellNib
                          forCellWithReuseIdentifier: @"SYNChannelMidCell"];
    
    [self.subscriptionThumbnailCollectionView registerNib: thumbnailCellNib
                               forCellWithReuseIdentifier: @"SYNChannelMidCell"];
    
    self.isIPhone = IS_IPHONE;
    
    self.creatingChannel = NO;
    
    
    self.channelExpandedLayout = [[SYNProfileExpandedFlowLayout alloc]init];
    
    // == Main Collection View
    if (IS_IPHONE)
    {
        self.subscriptionThumbnailCollectionView.collectionViewLayout = self.subscriptionLayoutIPhone;
        self.channelThumbnailCollectionView.collectionViewLayout = self.channelLayoutIPhone;
        [self.channelThumbnailCollectionView.collectionViewLayout invalidateLayout];
        [self.subscriptionThumbnailCollectionView.collectionViewLayout invalidateLayout];
        // == BG Colour of the search bar that is only found in iphone for channals that are being followed
        UITextField *txfSearchField = [self.followingSearchBar valueForKey:@"_searchField"];
        if(txfSearchField)
            txfSearchField.backgroundColor = [UIColor colorWithRed: (255.0f / 255.0f)
                                                             green: (255.0f / 255.0f)
                                                              blue: (255.0f / 255.0f)
                                                             alpha: 1.0f];
        
        // == Layout for the expanded create new channel cell
        self.channelExpandedLayout.minimumInteritemSpacing = 0;
        self.channelExpandedLayout.minimumLineSpacing = 0;
        self.channelExpandedLayout.itemSize = CGSizeMake(320, 71);
        self.channelExpandedLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
        self.channelExpandedLayout.headerReferenceSize = CGSizeMake(320, 472);
        
    }
    else
    {
        // == IPad collectionview layouts
        self.channelThumbnailCollectionView.collectionViewLayout = self.channelLayoutIPad;
        self.subscriptionThumbnailCollectionView.collectionViewLayout = self.subscriptionLayoutIPad;
        
    }
    
    // == set up views
    [self setUpUserProfile];
    // == set up the segmented controller
    [self setUpSegmentedControl];
    
    // == updates the segmented controllers functionality
    if (self.isIPhone)
    {
        [self updateTabStates];
    }
    
    self.searchMode = NO;
    
    //hide the channel collectionview
    self.channelThumbnailCollectionView.hidden = YES;
    
    [self updateLayoutForOrientation:[SYNDeviceManager.sharedInstance orientation]];
    
    // == sets up the profile views according to the mode type
    [self setProfleType:self.modeType];
    
    // == Gives the navigation buttons a shadow colour, Leave here
    // there may be problems with having a transparent cover and the button titles
    //not having a shadow
    
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
    
    
    
    // == Initialising the navigation bar items
    // TODO: get rid of 2 of the bar buttons and refactor into 2 methods
    
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
    
    
    // == Tap gesture do dismiss the keyboard
    self.tapToHideKeyoboard = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    
    // == Required because of autolay, it was not functioning properly when the views were changing
    
    if (IS_IPAD)
    {
        self.aboutMeTextView.translatesAutoresizingMaskIntoConstraints = YES;
    }
    
    // == The back button title is always set to ""
    [self.navigationController.navigationItem.leftBarButtonItem setTitle:@""];
    
    
    [self.followAllButton.titleLabel setFont:[UIFont lightCustomFontOfSize:14.0f]];
    
    // == Init alert views, Follow and Unfollow
    self.unfollowAlertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Unfollow?", @"Unfollow a channel in profile") message:nil delegate:self cancelButtonTitle:[self noButtonTitle] otherButtonTitles:[self yesButtonTitle], nil];
    
    self.followAllAlertView = [[UIAlertView alloc]initWithTitle:@"Follow All?" message:nil delegate:self cancelButtonTitle:[self noButtonTitle] otherButtonTitles:[self yesButtonTitle], nil];
    
    self.sameChannelNameAlertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"New channels can not have the same titles", @"Unfollow a channel in profile") message:nil delegate:self cancelButtonTitle:[self noButtonTitle] otherButtonTitles:nil];

    self.deleteChannelAlertView = [[UIAlertView alloc] initWithTitle:@"" message:@"" delegate:self cancelButtonTitle:[self noButtonTitle] otherButtonTitles:[self yesButtonTitle] , nil];
    
    
    [self setFollowersCountButton];
    
    
    
}
-(void) setFollowersCountButton
{
    NSString *tmpString;
    if (self.channelOwner.subscribersCountValue == 1) {
        tmpString = [[NSString alloc] initWithFormat:@"%lld %@", self.channelOwner.subscribersCountValue, NSLocalizedString(@"follower", "follower count in profile")];
    }
    else
    {
        tmpString = [[NSString alloc] initWithFormat:@"%lld %@", self.channelOwner.subscribersCountValue, NSLocalizedString(@"followers", "followers count in profile")];
    }
    
    
    [self.followersCountButton setTitle:tmpString forState:UIControlStateNormal];
    
    [self.followersCountButton.titleLabel setFont:[UIFont  regularCustomFontOfSize:self.followersCountButton.titleLabel.font.pointSize]];
    
}

-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
    
    [self updateTabStates];
    //  [self setUpUserProfile];
    [self setUpSegmentedControl];
    [self setNeedsStatusBarAppearanceUpdate];
    [self updateLayoutForOrientation: [SYNDeviceManager.sharedInstance orientation]];
    
    // == Transparent navigation bar
	[self.navigationController.navigationBar setBackgroundTransparent:YES];
	
    self.navigationController.view.backgroundColor = [UIColor clearColor];

    self.navigationItem.title = @"";
    
    if (self.channelOwner.subscribedByUserValue)
    {
        [self.followAllButton setTitle:@"unfollow all" forState:UIControlStateNormal];
    }
    else
    {
        [self.followAllButton setTitle:@"follow all" forState:UIControlStateNormal];
    }
}


- (void) viewDidAppear: (BOOL) animated
{
    [super viewDidAppear: animated];

    self.navigationController.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                                                  style:UIBarButtonItemStyleBordered
                                                                                                 target:nil
                                                                                                 action:nil];
    self.navigationItem.backBarButtonItem.title = @"";
    [self.navigationItem.backBarButtonItem setTitle:@""];
    
    self.arrDisplayFollowing = [self.channelOwner.subscriptions array];
    [self.subscriptionThumbnailCollectionView reloadData];
    [self.channelThumbnailCollectionView reloadData];
    
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
    
    [self updateLayoutForOrientation: [SYNDeviceManager.sharedInstance orientation]];
}

-(void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	
	[self.navigationController.navigationBar setBackgroundTransparent:NO];
    
    if (self.creatingChannel) {
        [self updateCollectionLayout];
        self.creatingChannel = NO;
    }
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


-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}


#pragma mark - User Profile

//Initial set up for user profile uiviews

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
    
    
    [self setProfileImage:self.channelOwner.thumbnailURL];
    [self setCoverphotoImage:self.channelOwner.coverPhotoURL];
    
    self.aboutMeTextView.text = self.channelOwner.channelOwnerDescription;
    
    [[self.aboutMeTextView layer] setBorderColor:[[UIColor colorWithRed:172.0/255.0f green:172.0/255.0f blue:172.0/255.0f alpha:1.0f] CGColor]];
    
    [self.editButton.titleLabel setFont:[UIFont regularCustomFontOfSize:self.editButton.titleLabel.font.pointSize]];
    
    [self.editButton setTitle:NSLocalizedString(@"edit", nil) forState:UIControlStateNormal];
    
    [self.followAllButton.titleLabel setFont:[UIFont regularCustomFontOfSize:self.editButton.titleLabel.font.pointSize]];
}

//Setting up the layout for the custom segmented controller
//TODO: Abstract segmented controller out, used in multiple places in the app
-(void) setUpSegmentedControl{
    
    self.segmentedControlsView.layer.cornerRadius = 4;
    self.segmentedControlsView.layer.borderWidth = .5f;
    self.segmentedControlsView.layer.borderColor = [[UIColor grayColor] CGColor];
    self.segmentedControlsView.layer.masksToBounds = YES;
    
    [self.collectionsTabButton.titleLabel setFont:[UIFont regularCustomFontOfSize:self.editButton.titleLabel.font.pointSize]];
    [self.followingTabButton .titleLabel setFont:[UIFont regularCustomFontOfSize:self.editButton.titleLabel.font.pointSize]];
}

-(void) setProfileImage : (NSString*) thumbnailURL
{
    UIImage* placeholderImage = [UIImage imageNamed: @"PlaceholderAvatarProfile"];
    self.profileImageView.image = placeholderImage;
    
    if (![self.channelOwner.thumbnailURL isEqualToString:@""]){ // there is a url string
        
        dispatch_queue_t downloadQueue = dispatch_queue_create("com.rockpack.avatarloadingqueue", NULL);
        dispatch_async(downloadQueue, ^{
            
            NSData * imageData = [NSData dataWithContentsOfURL: [NSURL URLWithString: self.channelOwner.thumbnailLargeUrl ]];
            
            UIImage *tmpImage = [UIImage imageWithData: imageData];
            
            //if statement for now as the db has urls for avatars that have not been uploaded
            //should be able to get rid of it later
            if (tmpImage.size.height != 0 && tmpImage.size.height != 0) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    self.profileImageView.image = tmpImage;
                });
            }
            
        });
    }else{
        self.profileImageView.image = placeholderImage;
    }
}

-(void) setCoverphotoImage: (NSString*) thumbnailURL
{
    
   UIImage* placeholderImage = [UIImage imageNamed: @"coverImageTest"];
    
    if (![thumbnailURL isEqualToString:@""]){ // there is a url string
        
        NSArray *thumbnailURLItems = [thumbnailURL componentsSeparatedByString: @"/"];
        
        if (thumbnailURLItems.count >= 6)
        {
            NSString *thumbnailSizeString = thumbnailURLItems[5];
            NSString *thumbnailUrlString;
            if (IS_IPAD)
            {
                thumbnailUrlString = [thumbnailURL stringByReplacingOccurrencesOfString: thumbnailSizeString                                                                                               withString: @"ipad"];
            }
            else
            {
                thumbnailUrlString = [thumbnailURL stringByReplacingOccurrencesOfString: thumbnailSizeString                                                                                               withString: @"thumbnail_medium"];
            }
            
            [self.coverImage setImageWithURL: [NSURL URLWithString: thumbnailUrlString]
                            placeholderImage: placeholderImage
                                     options: SDWebImageRetryFailed];
        }
        
    }else{
        
        self.coverImage.image = placeholderImage;
    }
    
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


-(void) setProfleType: (ProfileType) profileType
{
    if (profileType == kModeMyOwnProfile)
    {
        self.editButton.hidden = NO;
        self.followAllButton.hidden = YES;
        
        self.moreButton.hidden = NO;
        
    }
    if (profileType == kModeOtherUsersProfile)
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
             //TODO:Get total number of channels or sub number?
             [self reloadCollectionViews];
             [self setFollowersCountButton];

             return;
         }
     }];
}

//Doesnt work as expected, check it out.
- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark - Orientation


//#warning is this needed check ipad
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
    
    //self.navigationController.navigationBarHidden = YES;
    
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
        
        [subscriptionsLayout invalidateLayout];
        [channelsLayout invalidateLayout];
    }
    
    if (self.creatingChannel)
    {
        [self setCreateOffset];
    }
    
    if (!self.creatingChannel)
    {
        [self reloadCollectionViews];
    }
    // [self resizeScrollViews];
}

-(void) updateChannelOwner
{
    [[NSNotificationCenter defaultCenter] postNotificationName: kChannelOwnerUpdateRequest
                                                        object: self
                                                      userInfo: @{kChannelOwner : self.channelOwner}];
}

- (void) reloadCollectionViews
{
    [self.subscriptionThumbnailCollectionView reloadData];
    [self.channelThumbnailCollectionView reloadData];
}

#pragma mark - UICollectionView DataSource/Delegate

- (NSInteger) collectionView: (UICollectionView *) view numberOfItemsInSection: (NSInteger) section
{
    
    if ([view isEqual:self.subscriptionThumbnailCollectionView])
    {
        //1 for search bar
        
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
        self.createChannelCell = createCell;
        cell = self.createChannelCell;
        
        ((SYNChannelCreateNewCell*)cell).viewControllerDelegate = self;
        if (self.creatingChannel)
        {
            ((SYNChannelCreateNewCell*)cell).descriptionTextView.hidden = NO;
            
            CGRect tmpBoarder = ((SYNChannelCreateNewCell*)cell).frame;
            tmpBoarder.size.height+= kHeightChange;
            
            //iphone cell height is different by 11
            if (IS_IPHONE) {
                tmpBoarder.size.height+= 18;
            }
            ((SYNChannelCreateNewCell*)cell).frame = tmpBoarder;
            
            ((SYNChannelCreateNewCell*)cell).state = CreateNewChannelCellStateEditing;
        }
        else
        {
            ((SYNChannelCreateNewCell*)cell).state = CreateNewChannelCellStateHidden;
                        CGRect tmpBoarder = ((SYNChannelCreateNewCell*)cell).frame;
            
            //Sizes of the create cell is different from ipad and iphone
            if (IS_IPAD) {
                tmpBoarder.size.height= 80;
            }else{
                tmpBoarder.size.height= 74;
            }
                        //iphone cell height is different by 11
                        if (IS_IPHONE)
                        {
                            tmpBoarder.size.height-= 14;
                        }
            ((SYNChannelCreateNewCell*)cell).frame = tmpBoarder;
        }
    }
    else
    {
        SYNChannelMidCell *channelThumbnailCell = [collectionView dequeueReusableCellWithReuseIdentifier: @"SYNChannelMidCell" forIndexPath: indexPath];
        
        Channel *channel;
        
        [channelThumbnailCell setBorder];

        channelThumbnailCell.showsDescriptionOnSwipe = YES;

        if(collectionView == self.channelThumbnailCollectionView)
        {
            channel = (Channel *) self.channelOwner.channels[indexPath.item - (self.isUserProfile ? 1 : 0)];
            
			channelThumbnailCell.followButton.hidden = (self.modeType == kModeMyOwnProfile);
            
            [channelThumbnailCell.descriptionLabel setText:channel.channelDescription];
            
            channelThumbnailCell.channel = channel;
			
			// indexPath.row == Favourites cell, which is a special case
            if(self.modeType == kModeMyOwnProfile && indexPath.row != 1)
            {
                channelThumbnailCell.deletableCell = YES;
            }
            
            
           [channelThumbnailCell setCategoryColor: [[SYNGenreColorManager sharedInstance] colorFromID:channel.categoryId]];
        
        }
        else // (collectionView == self.subscribersThumbnailCollectionView)
        {
            if (indexPath.row < self.arrDisplayFollowing.count)
            {
                channel = _arrDisplayFollowing[indexPath.item];
                
                if (self.modeType == kModeMyOwnProfile)
                {
                    [channelThumbnailCell setFollowButtonLabel:NSLocalizedString(@"Unfollow", nil)];
                }
				//text is set in the channelmidcell setChannel method
                channelThumbnailCell.channel = channel;
                
                [channelThumbnailCell setCategoryColor: [[SYNGenreColorManager sharedInstance] colorFromID:channel.categoryId]];
                }
        }
        if(self.modeType == kModeOtherUsersProfile)
        {
            if ([SYNActivityManager.sharedInstance isSubscribedToChannelId:channel.uniqueId])
            {
                [channelThumbnailCell setFollowButtonLabel:NSLocalizedString(@"Unfollow", @"unfollow")];
            }
            else
            {
                [channelThumbnailCell setFollowButtonLabel:NSLocalizedString(@"Follow", @"follow")];
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
    
    if (self.creatingChannel) {
        [self cancelCreateChannel];
    }
    
    SYNChannelMidCell* cell = (SYNChannelMidCell*)[collectionView cellForItemAtIndexPath:indexPath];
    
    SYNChannelMidCell *selectedCell = cell;
    
    if (selectedCell.state != ChannelMidCellStateDefault) {
        [selectedCell setState: ChannelMidCellStateDefault withAnimation:YES];
        return;
    }
    
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
            channel = self.channelOwner.channels[indexPath.row - (self.isUserProfile ? 1 : 0)];
        }
        if (modeType == kModeMyOwnProfile)
        {
            channelVC = [[SYNChannelDetailsViewController alloc] initWithChannel:channel usingMode:kChannelDetailsModeDisplayUser];
        }
        if (modeType == kModeOtherUsersProfile)
        {
            channelVC = [[SYNChannelDetailsViewController alloc] initWithChannel:channel usingMode:kChannelDetailsModeDisplay];
        }
        
        [self.navigationController pushViewController:channelVC animated:YES];
        return;
    }
    if([cell.superview isEqual:self.subscriptionThumbnailCollectionView])
    {
        NSIndexPath *indexPath = [self.subscriptionThumbnailCollectionView indexPathForItemAtPoint: selectedCell.center];
        
        if (indexPath.row < self.arrDisplayFollowing.count) {
            Channel *channel = self.arrDisplayFollowing[indexPath.item];
            //        self.navigationController.navigationBarHidden = NO;
            
            SYNChannelDetailsViewController *channelVC = [[SYNChannelDetailsViewController alloc] initWithChannel:channel usingMode:kChannelDetailsModeDisplay];
            
            [self.navigationController pushViewController:channelVC animated:YES];
        }
    }
    return;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    /*
     if (self.isUserProfile  && indexPath.row == 0 && [collectionView isEqual:self.subscriptionThumbnailCollectionView])
     {
     return CGSizeMake(320, 44);
     }*/
    
    
    if (self.isUserProfile  && indexPath.row == 0 && collectionViewLayout == self.channelLayoutIPhone && IS_IPHONE)
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
        else
        {
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
    
    self.channelThumbnailCollectionView.hidden = !self.collectionsTabActive;
    self.subscriptionThumbnailCollectionView.hidden = self.collectionsTabActive;
    
    if (self.modeType == kModeMyOwnProfile)
    {
        self.followingSearchBar.hidden = self.collectionsTabActive;
    }
    
    if (self.collectionsTabActive)
    {
        [self.followingTabButton.titleLabel setTextColor:[UIColor dollyTabColorSelectedText]];
        self.followingTabButton.backgroundColor = [UIColor whiteColor];
        
        self.collectionsTabButton.backgroundColor = [UIColor dollyTabColorSelectedBackground];
        [self.collectionsTabButton.titleLabel setTextColor:[UIColor whiteColor]];
        
        
    }
    else
    {
        [self.followingTabButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.followingTabButton.backgroundColor = [UIColor dollyTabColorSelectedBackground];
        
        [self.collectionsTabButton.titleLabel setTextColor:[UIColor dollyTabColorSelectedText]];
        self.collectionsTabButton.backgroundColor = [UIColor whiteColor];
        __weak typeof(self) weakSelf = self;
        
        MKNKUserSuccessBlock successBlock = ^(NSDictionary *dictionary) {
            weakSelf.loadingMoreContent = NO;
            NSError *error = nil;
            
            [weakSelf.channelOwner setSubscriptionsDictionary: dictionary];
//#warning cache all the channels to activity manager?
            // is there a better way?
            // can use the range object, this should be poosible
            if (self.channelOwner.uniqueId == appDelegate.currentUser.uniqueId) {
                for (Channel *tmpChannel in self.channelOwner.subscriptions) {
                    [SYNActivityManager.sharedInstance addChannelSubscriptionsObject:tmpChannel];
                }
            }
            
            [self.channelOwner.managedObjectContext save: &error];

        };
    
        // define success block //
        MKNKUserErrorBlock errorBlock = ^(NSDictionary *errorDictionary) {
            weakSelf.loadingMoreContent = NO;
            DebugLog(@"Update action failed");
        };
        //    Working load more videos for user channels
    
        NSRange range = NSMakeRange(0, 100);
    
        [appDelegate.oAuthNetworkEngine subscriptionsForUserId: self.channelOwner.uniqueId
                                                       inRange: range
                                             completionHandler: successBlock
                                                  errorHandler: errorBlock];
    
//
//
//
//        NSManagedObjectID *channelOwnerObjectId = self.channelOwner.objectID;
//        NSManagedObjectContext *channelOwnerObjectMOC = self.channelOwner.managedObjectContext;
//
//        MKNKUserErrorBlock errorBlock = ^(id error) {
//            
//        };
//
//        
//
//        [appDelegate.oAuthNetworkEngine userSubscriptionsForUser: ((User *) self.channelOwner)
//                                                    onCompletion: ^(id dictionary) {
//                                                        NSError *error = nil;
//
//                                                        // Transform the object ID into the object again, as it it likely to have disappeared again
//                                                        NSError *error2 = nil;
//                                                        ChannelOwner * channelOwnerFromId2 = (ChannelOwner *)[channelOwnerObjectMOC existingObjectWithID: channelOwnerObjectId
//                                                                                                                                                   error: &error2];
//                                                        if (channelOwnerFromId2)
//                                                        {
//                                                            // this will remove the old subscriptions
//                                                            [channelOwnerFromId2 setSubscriptionsDictionary: dictionary];
//                                                            
//                                                            [channelOwnerFromId2.managedObjectContext save: &error2];
//                                                            
//                                                            if (error)
//                                                            {
//                                                                NSString *errorString = [NSString stringWithFormat: @"%@ %@", [error localizedDescription], [error userInfo]];
//                                                                DebugLog(@"%@", errorString);
//                                                                errorBlock(@{@"saving_error": errorString});
//                                                            }
//                                                        }
//                                                        else
//                                                        {
//                                                            DebugLog (@"Channel disappeared from underneath us");
//                                                        }
//                                                    }  onError: errorBlock];
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
    
    if (self.channelThumbnailCollectionView == scrollView) {
        if (scrollView.contentSize.height > 0 && (scrollView.contentOffset.y >= scrollView.contentSize.height - scrollView.bounds.size.height - kLoadMoreFooterViewHeight) && self.isLoadingMoreContent == NO && !self.collectionsTabButton.selected)
        {
            [self loadMoreChannels];
        }
    }
    
    if (self.subscriptionThumbnailCollectionView == scrollView) {
        if (scrollView.contentSize.height > 0 && (scrollView.contentOffset.y >= scrollView.contentSize.height - scrollView.bounds.size.height - kLoadMoreFooterViewHeight) && self.isLoadingMoreContent == NO && self.collectionsTabButton.selected)
        {
            [self loadMoreSubscriptions];
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
    
    [self moveViewsWithScroller:scrollView withOffset:offset];
    
}

- (void)killScroll {
    
    CGPoint offset = self.subscriptionThumbnailCollectionView.contentOffset;
    offset.x -= 1.0;
    offset.y -= 1.0;
    [self.subscriptionThumbnailCollectionView setContentOffset:offset animated:NO];
    offset.x += 1.0;
    offset.y += 1.0;
    [self.subscriptionThumbnailCollectionView setContentOffset:offset animated:NO];

}


- (void) loadMoreChannels
{
    
    self.loadingMoreContent = YES;
    //copy our value into the abstract
    self.dataRequestRange = self.dataRequestRangeChannel;
    self.dataItemsAvailable = self.channelOwner.totalVideosValueChannelValue;
    
    if(!self.moreItemsToLoad)
        return;
    
    
    [self incrementRangeForNextRequest];
    
    //update the value in profile
    self.dataRequestRangeChannel = self.dataRequestRange;
    
    __weak typeof(self) weakSelf = self;
    
    MKNKUserSuccessBlock successBlock = ^(NSDictionary *dictionary) {
        
        weakSelf.loadingMoreContent = NO;
        [weakSelf.channelOwner addChannelsFromDictionary: dictionary];
        [self.channelThumbnailCollectionView reloadData];
    };
    
    // define error block //
    MKNKUserErrorBlock errorBlock = ^(NSDictionary *errorDictionary) {
        weakSelf.loadingMoreContent = NO;
        DebugLog(@"Update action failed");
    };
    
    //My own profile web service call
    if (self.modeType == kModeMyOwnProfile) {
        [appDelegate.oAuthNetworkEngine channelsForUserId: self.channelOwner.uniqueId
                                                  inRange: self.dataRequestRange
                                        completionHandler: successBlock
                                             errorHandler: errorBlock];
        
    }
    //Other users web service call
    else if(self.modeType == kModeOtherUsersProfile)
    {
        [appDelegate.networkEngine channelsForUserId: self.channelOwner.uniqueId
                                             inRange: self.dataRequestRange
                                   completionHandler: successBlock
                                        errorHandler: errorBlock];
    }
    
}

- (void) loadMoreSubscriptions
{
    self.loadingMoreContent = YES;
    
    self.dataRequestRange = self.dataRequestRangeSubscriptions;
    self.dataItemsAvailable = self.channelOwner.totalVideosValueSubscriptionsValue;

    if(!self.moreItemsToLoad)
        return;
    
    [self incrementRangeForNextRequest];
    self.dataRequestRangeSubscriptions = self.dataRequestRange;
    
    
    __weak typeof(self) weakSelf = self;
    
    MKNKUserSuccessBlock successBlock = ^(NSDictionary *dictionary) {
        
        weakSelf.loadingMoreContent = NO;
        [weakSelf.channelOwner addSubscriptionsFromDictionary: dictionary];
        [self.subscriptionThumbnailCollectionView reloadData];
    };
    
    // define success block //
    MKNKUserErrorBlock errorBlock = ^(NSDictionary *errorDictionary) {
        weakSelf.loadingMoreContent = NO;
        DebugLog(@"Update action failed");
    };
    //    Working load more videos for user channels
    
    [appDelegate.oAuthNetworkEngine subscriptionsForUserId: self.channelOwner.uniqueId
                                                   inRange: self.dataRequestRange
                                         completionHandler: successBlock
                                              errorHandler: errorBlock];
    
}


-(void) moveViewsWithScroller :(UIScrollView*)scrollView withOffset:(CGFloat) offset
{
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
                self.backgroundView.transform = move;
                
            }
            else
            {
                CGAffineTransform moveCoverImage = CGAffineTransformMakeTranslation(0, (-offset/PARALLAX_SCROLL_VALUE)-1);
                self.coverImage.transform = moveCoverImage;
                self.backgroundView.transform = move;
            }
            [self moveNameLabelWithOffset:offset];
        }
        else
        {
            CGAffineTransform move = CGAffineTransformMakeTranslation(0, -offset-1);
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
    
    if(channelOwnerIsUser && self.modeType != kModeEditProfile)
    {
        self.modeType = kModeMyOwnProfile;
    }
    else
    {
        self.modeType = kModeOtherUsersProfile;
    }
    
    self.dataRequestRangeChannel = NSMakeRange(0, STANDARD_REQUEST_LENGTH);
    self.dataRequestRangeSubscriptions = NSMakeRange(0, STANDARD_REQUEST_LENGTH);
    
    
    self.aboutMeTextView.text = self.channelOwner.channelOwnerDescription;
    
    
    self.channelOwner.subscribedByUserValue = [SYNActivityManager.sharedInstance isSubscribedToUserId:self.channelOwner.uniqueId];
    
    
    if (self.channelOwner.subscribedByUserValue) {
        [self.followAllButton setTitle:@"unfollow all" forState:UIControlStateNormal];
    }
    else
    {
        [self.followAllButton setTitle:@"follow all" forState:UIControlStateNormal];
    }
    
//    [self.subscriptionThumbnailCollectionView reloadData];
//    [self.channelThumbnailCollectionView reloadData];

}

#pragma mark - Arc menu support

- (void) displayNameButtonPressed: (UIButton *) button
{
    SYNChannelMidCell *parent = (SYNChannelMidCell *) [[button superview] superview];
    
    NSIndexPath *indexPath = [self.channelThumbnailCollectionView indexPathForCell: parent];
    
    Channel *channel = (Channel *) self.channelOwner.channels[indexPath.row - (self.isUserProfile ? 1 : 0)];
    
    [self viewProfileDetails:channel.channelOwner];
}

// Channels are the cell in the collection view
- (void) channelTapped: (UICollectionViewCell *) cell
{
    
    //is currently creating a channel, cancel and put it back into noncreating state
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
    
    if (self.creatingChannel) {
        [self setCreateOffset];
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.view removeGestureRecognizer:self.tapToHideKeyoboard];
    if (textField == self.createChannelCell.createTextField) {
        [self.createChannelCell.descriptionTextView becomeFirstResponder];
    }
    else
    {
        [textField resignFirstResponder];
    }
    return YES;
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    [textField resignFirstResponder];
    if (textField == self.createChannelCell.createTextField) {
    }
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)bar
{
    // boolean to check if the keyboard should show
    BOOL boolToReturn = self.shouldBeginEditing;
    self.searchMode = YES;
    
    [self killScroll];
    
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
        if ([cell isKindOfClass:[SYNChannelMidCell class]]) {
            
            [((SYNChannelMidCell*)cell) setState:ChannelMidCellStateDefault withAnimation:YES];
        }
    }
    
    for (UICollectionViewCell *cell in [self.channelThumbnailCollectionView visibleCells])
    {
        if ([cell isKindOfClass:[SYNChannelMidCell class]]) {
            [((SYNChannelMidCell*)cell) setState:ChannelMidCellStateDefault withAnimation:YES];
        }
    }
    
}





-(void) showAlertView: (UICollectionViewCell *) cell{
    
    
    NSString *message = @"Are you sure you want to unfollow";
    message =  [message stringByAppendingString:@" "];
    message =  [message stringByAppendingString:((SYNChannelMidCell*)cell).channel.title];
    
    [self.unfollowAlertView setMessage:message];
    
    self.followCell = ((SYNChannelMidCell*)cell);
    
    if (modeType == kModeMyOwnProfile) {
        [self.unfollowAlertView show];
    }
    else if(modeType == kModeOtherUsersProfile)
    {
//#warning change to make the call to servers
        

            // To prevent crashes that would occur when faulting object that have disappeared
        NSManagedObjectID *channelObjectId = self.followCell.channel.objectID;
        NSManagedObjectContext *channelObjectMOC = self.followCell.channel.managedObjectContext;

        
        self.followCell.channel.subscribedByUserValue = [SYNActivityManager.sharedInstance isSubscribedToChannelId:self.followCell.channel.uniqueId];
        
        if (!self.followCell.channel.subscribedByUserValue) {
            
        [SYNActivityManager.sharedInstance subscribeToChannel:self.followCell.channel
                                            completionHandler: ^(NSDictionary *responseDictionary) {
                                                    id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
                                                    
                                                    NSError *error = nil;
                                                    Channel *channelFromId = (Channel *)[channelObjectMOC existingObjectWithID: channelObjectId
                                                                                                                         error: &error];
                                                    
                                                    if (channelFromId)
                                                    {
                                                        [tracker send: [[GAIDictionaryBuilder createEventWithCategory: @"goal"
                                                                                                               action: @"userSubscription"
                                                                                                                label: nil
                                                                                                                value: nil] build]];
                                                        
                                                        // This notifies the ChannelDetails through KVO
//                                                        channelFromId.hasChangedSubscribeValue = YES;
//                                                        channelFromId.subscribedByUserValue = YES;
//                                                        channelFromId.subscribersCountValue += 1;
                                                        
                                                        // the channel that got updated was a copy inside the ChannelDetails, so we must copy it to user@
                                                        IgnoringObjects copyFlags = kIgnoreVideoInstanceObjects;
                                                        
                                                        Channel *subscription = [Channel instanceFromChannel: channelFromId
                                                                                                   andViewId: kProfileViewId
                                                                                   usingManagedObjectContext: appDelegate.currentUser.managedObjectContext
                                                                                         ignoringObjectTypes: copyFlags];

                                                        [appDelegate.currentUser addSubscriptionsObject: subscription];
                                                        
                                                        // might be in search context
                                                        [channelFromId.managedObjectContext save: &error];
                                                        
                                                            [self.followCell setFollowButtonLabel:NSLocalizedString(@"Unfollow", @"unfollow")];
                                                        
                                                        if (error)
                                                        {
                                                            [[NSNotificationCenter defaultCenter] postNotificationName: kUpdateFailed
                                                                                                                object: self];
                                                        }
                                                        else
                                                        {
                                                            [appDelegate saveContext: YES];
                                                        }
                                                    }
                                                    else
                                                    {
                                                        DebugLog (@"Channel disappeared from underneath us");
                                                    }
                                                    
                                                } errorHandler: ^(NSDictionary *errorDictionary) {
                                                    [[NSNotificationCenter defaultCenter] postNotificationName: kUpdateFailed
                                                                                                        object: self];
                                                }];
    }
        else
        {
            
            NSManagedObjectID *channelOwnerObjectId = self.followCell.channel.objectID;
            NSManagedObjectContext *channelOwnerObjectMOC = self.followCell.channel.managedObjectContext;
            
            
            [SYNActivityManager.sharedInstance unsubscribeToChannel:self.followCell.channel
                                                      completionHandler: ^(NSDictionary *responseDictionary) {
                                                          // Find our object from it's ID
                                                          NSError *error = nil;
                                                          Channel *channelFromId = (Channel *)[channelOwnerObjectMOC existingObjectWithID: channelOwnerObjectId
                                                                                                                                    error: &error];
                                                          if (channelFromId)
                                                          {
                                                              // This notifies the ChannelDetails through KVO
//                                                              channelFromId.hasChangedSubscribeValue = YES;
//                                                              channelFromId.subscribedByUserValue = NO;
//                                                              channelFromId.subscribersCountValue -= 1;
                                                              
                                                              // the channel that got updated was a copy inside the ChannelDetails, so we must find the original and update it.
                                                              for (Channel * subscription in appDelegate.currentUser.subscriptions)
                                                              {
                                                                  if ([subscription.uniqueId isEqualToString: channelFromId.uniqueId])
                                                                  {
                                                                      [appDelegate.currentUser removeSubscriptionsObject: subscription];
                                                                      
                                                                      break;
                                                                  }
                                                              }
                                                              
                                                              [channelFromId.managedObjectContext save: &error];
                                                              
                                                              [self.followCell setFollowButtonLabel:NSLocalizedString(@"follow", @"follow")];

                                                              if (error)
                                                              {
                                                                  [[NSNotificationCenter defaultCenter] postNotificationName: kUpdateFailed
                                                                                                                      object: self];
                                                              }
                                                              else
                                                              {
                                                                  [appDelegate saveContext: YES];
                                                              }
                                                          }
                                                          else
                                                          {
                                                              DebugLog (@"Channel disappeared from underneath us");
                                                          }
                                                      } errorHandler: ^(NSDictionary *errorDictionary) {
                                                          [[NSNotificationCenter defaultCenter]  postNotificationName: kUpdateFailed
                                                                                                               object: self];
                                                      }];

            
            
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
        
        // Sub to channel
        if (self.followCell.channel != nil)
        {
            NSManagedObjectID *channelOwnerObjectId = self.followCell.channel.objectID;
            NSManagedObjectContext *channelOwnerObjectMOC = self.followCell.channel.managedObjectContext;
            //Unfollow only as in ownchannel mode!
            [SYNActivityManager.sharedInstance unsubscribeToChannel:self.followCell.channel                                       completionHandler: ^(NSDictionary *responseDictionary) {
                                                          // Find our object from it's ID
                                                          NSError *error = nil;
                                                          Channel *channelFromId = (Channel *)[channelOwnerObjectMOC existingObjectWithID: channelOwnerObjectId
                                                                                                                                    error: &error];
                                                          if (channelFromId)
                                                          {
                                                              // This notifies the ChannelDetails through KVO
//                                                              channelFromId.hasChangedSubscribeValue = YES;
//                                                              channelFromId.subscribersCountValue -= 1;
                                                              
                                                              // the channel that got updated was a copy inside the ChannelDetails, so we must find the original and update it.
                                                              for (Channel * subscription in appDelegate.currentUser.subscriptions)
                                                              {
                                                                  if ([subscription.uniqueId isEqualToString: channelFromId.uniqueId])
                                                                  {
                                                                      [appDelegate.currentUser removeSubscriptionsObject: subscription];
                                                                      
                                                                      break;
                                                                  }
                                                              }
                                                              
                                                              channelFromId.subscribedByUserValue = [SYNActivityManager.sharedInstance isSubscribedToChannelId:channelFromId.uniqueId];
                                                              
                                                              [channelFromId.managedObjectContext save: &error];
                                                              [self.channelThumbnailCollectionView reloadData];
                                                              
                                                              if (self.followCell.channel.subscribedByUserValue) {
                                                                  [self.followCell setFollowButtonLabel:NSLocalizedString(@"unfollow all", @"unfollow")];
                                                              }
                                                              else
                                                              {
                                                                  [self.followCell setFollowButtonLabel:NSLocalizedString(@"follow all", @"follow")];
                                                              }
                                                              
                                                              if (error)
                                                              {
                                                                  [[NSNotificationCenter defaultCenter] postNotificationName: kUpdateFailed
                                                                                                                      object: self];
                                                              }
                                                              else
                                                              {
                                                                  [appDelegate saveContext: YES];
                                                                  [self reloadCollectionViews];
                                                                  
//#warning change to have success block and reload cells on success
                                                                  [SYNActivityManager.sharedInstance updateActivityForCurrentUser];

                                                              }
                                                          }
                                                          else
                                                          {
                                                              DebugLog (@"Channel disappeared from underneath us");
                                                          }
                                                      } errorHandler: ^(NSDictionary *errorDictionary) {
                                                          [[NSNotificationCenter defaultCenter]  postNotificationName: kUpdateFailed
                                                                                                               object: self];
                                                      }];
            
            

            
        }
    }
//#warning change to server call
    if (alertView == self.followAllAlertView && [buttonTitle isEqualToString:[self yesButtonTitle]])
    {
        
        
        self.channelOwner.subscribedByUserValue = [SYNActivityManager.sharedInstance isSubscribedToUserId:self.channelOwner.uniqueId];
        
        
        if(self.channelOwner.subscribedByUserValue)
        {
            
            [SYNActivityManager.sharedInstance unsubscribeToUser:self.channelOwner
                                               completionHandler:^(id responce) {
                                                   
                                                   self.channelOwner.subscribedByUser = [NSNumber numberWithBool:NO];
                                                   [self.followAllButton setTitle:@"follow" forState:UIControlStateNormal];
                                                   [appDelegate saveContext: YES];
                                                   
                                                   
                                               } errorHandler:^(id error) {
                                                   
                                                   NSLog(@"%@",error);
                                               }];
        }
        else
        {
            
            [SYNActivityManager.sharedInstance subscribeToUser:self.channelOwner
                                             completionHandler: ^(id responce) {
                                                 
                                                 [self.followAllButton setTitle:@"unfollow" forState:UIControlStateNormal];
                                                 
                                                 [appDelegate saveContext: YES];
                                                 
                                             } errorHandler: ^(id error) {
                                                 
                                                 
                                             }];

            
        }

    }
    
    if (alertView == self.deleteChannelAlertView && [buttonTitle isEqualToString:[self yesButtonTitle]])
    {
        
        [self deleteChannel:self.deleteCell];
        
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
    
    [self killScroll];
    [self.createChannelCell.descriptionTextView resignFirstResponder];
    [self.createChannelCell.createTextField resignFirstResponder];
    
    
    self.modeType = kModeEditProfile;
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
        self.profileImageView.alpha = ALPHA_IN_EDIT;
        
        self.editButton.alpha = 0.0f;
        self.moreButton.alpha = 0.0f;
        self.followersCountButton.alpha = 0.0f;
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
    
    self.modeType = kModeMyOwnProfile;
    CGRect tmpRect = self.aboutMeTextView.frame;
    tmpRect.origin.y -= 10;
    tmpRect.size.height -= 18;
    
    self.aboutMeTextView.editable = NO;
    
    self.aboutMeTextView.text = self.channelOwner.channelOwnerDescription;
    [UIView animateWithDuration:0.5f animations:^{
        
        self.coverImage.alpha = 1.0f;
        self.profileImageView.alpha = 1.0f;
        self.segmentedControlsView.alpha = 1.0f;
        self.editButton.alpha = 1.0f;
        self.moreButton.alpha = 1.0f;
        self.followersCountButton.alpha = 1.0f;
        self.channelThumbnailCollectionView.alpha = 1.0f;
        self.subscriptionThumbnailCollectionView.alpha = 1.0f;
        
        self.navigationItem.leftBarButtonItem = self.barBtnBack;
        self.navigationItem.rightBarButtonItem = nil;
        self.aboutMeTextView.backgroundColor = [UIColor whiteColor];
        
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
    //    self.channel.title = self.channelTitleTextView.text;
    //
    //    self.channel.channelDescription = self.channel.channelDescription ? self.channel.channelDescription : @"";
    //
    //    NSString *category = [self categoryIdStringForServiceCall];
    //
    //    NSString *cover = self.selectedCoverId;
    //
    //    if ([cover length] == 0 || [cover isEqualToString: kCoverSetNoCover])
    //    {
    //        cover = @"";
    //    }
    
    
    
    [appDelegate.oAuthNetworkEngine createChannelForUserId: appDelegate.currentOAuth2Credentials.userId
                                                     title: self.createChannelCell.createTextField.text
                                               description: self.createChannelCell.descriptionTextView.text
                                                  category: @""
                                                     cover: @""
                                                  isPublic: YES
                                         completionHandler: ^(NSDictionary *resourceCreated) {
                                             
                                             // shows the message label from the MasterViewController
                                             //                                             id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
                                             
                                             //                                             [tracker send: [[GAIDictionaryBuilder createEventWithCategory: @"goal"
                                             //                                                                                                    action: @"channelCreated"
                                             //                                                                                                     label: @""
                                             //                                                                                                     value: nil] build]];
                                             
                                             //                                             NSString *channelId = resourceCreated[@"id"];
                                             
                                             [self cancelCreateChannel];
                                             
                                             [self performSelector:@selector(updateChannelOwner) withObject:self afterDelay:0.6f];

                                             
                                         } errorHandler: ^(id error) {
                                             
                                             
                                             DebugLog(@"Error @ createChannelPressed:");
                                             
                                             NSString *errorTitle = NSLocalizedString(@"channel_creation_screen_error_unknown_title", nil);
                                             NSString *errorMessage = NSLocalizedString(@"channel_creation_screen_error_unknown_create_description", nil);
                                             
                                             NSArray *errorTitleArray = error[@"form_errors"][@"title"];
                                             
                                             if ([errorTitleArray count] > 0)
                                             {
                                                 NSString *errorType = errorTitleArray[0];
                                                 
                                                 if ([errorType isEqualToString: @"Duplicate title."])
                                                 {
                                                     errorTitle = NSLocalizedString(@"channel_creation_screen_error_existing_dialog_title", nil);
                                                     errorMessage = NSLocalizedString(@"channel_creation_screen_error_existing_dialog_description", nil);
                                                     [self.sameChannelNameAlertView show];
                                                     [self.createChannelCell.createTextField becomeFirstResponder];
                                                 }
                                                 else if ([errorType isEqualToString: @"Mind your language!"])
                                                 {
                                                     errorTitle = NSLocalizedString(@"channel_creation_screen_error_inappropriate_dialog_title", nil);
                                                     errorMessage = NSLocalizedString(@"channel_creation_screen_error_inappropriate_dialog_description", nil);
                                                 }
                                             }
                                             
                                             
                                             //                                             [self	 showError: errorMessage
                                             //                                               showErrorTitle: errorTitle];
                                         }];
    
    
    
    
    
}

-(void) saveEditModeTapped
{
    [self updateField:@"description" forValue:self.aboutMeTextView.text withCompletionHandler:^{
        appDelegate.currentUser.channelOwnerDescription = self.aboutMeTextView.text;
        [appDelegate saveContext: YES];
        [self cancelEditModeTapped];
    }];
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
                                              //self.errorLabel.text = (NSString *) ((NSArray *) message)[0];
                                              
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
    if (self.modeType == kModeEditProfile) {
        
        
        [self performSelector:@selector(resetOffsetWithAnimation) withObject:nil afterDelay:0.3f];
    }
    //[self resetOffsetWithAnimation];
    
    if (self.creatingChannel && self.createChannelCell.descriptionTextView == textView && [textView.text isEqualToString:@""])
    {
        self.createChannelCell.descriptionPlaceholderLabel.hidden = NO;
    }
    
    [textView resignFirstResponder];
}

-(void) textViewDidBeginEditing:(UITextView *)textView
{
    [self.view addGestureRecognizer:self.tapToHideKeyoboard];
    
    //Using a placeholder label to mimic placeholder text in textview
    
    if (self.creatingChannel && self.createChannelCell.descriptionTextView == textView )
    {
        self.createChannelCell.descriptionPlaceholderLabel.hidden = YES;
        self.createChannelCell.descriptionTextView.text = @"";
        [self.createChannelCell.descriptionTextView performSelector:@selector(setText:) withObject:@"" afterDelay:0.1f];

    }

    
    if (self.modeType == kModeEditProfile) {
        
        [UIView animateWithDuration:0.3f animations:^{
            self.subscriptionThumbnailCollectionView.contentOffset = CGPointMake(0, OFFSET_DESCRIPTION_EDIT);
            self.channelThumbnailCollectionView.contentOffset = CGPointMake(0, OFFSET_DESCRIPTION_EDIT);
            
        }];
    }
    else
    {
        if (IS_IPAD) {
            
            [self setCreateOffset];
            
        }
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        
        [textView resignFirstResponder];
        
        if (textView == self.createChannelCell.descriptionTextView) {
            [self saveCreateChannelTapped];
        }
        // Return FALSE so that the final '\n' character doesn't get added
        return NO;
    }
    
    NSUInteger newLength = [textView.text length] + [text length] - range.length;
    return (newLength > 50) ? NO : YES;
}

-(void)dismissKeyboard
{
    [self.aboutMeTextView resignFirstResponder];
    [self.createChannelCell.descriptionTextView resignFirstResponder];
    [self.createChannelCell.createTextField resignFirstResponder];
    [self.view removeGestureRecognizer:self.tapToHideKeyoboard];
    
    if (self.modeType == kModeEditProfile) {
        [self resetOffsetWithAnimation];
        
    }
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
//#warning cover photo
    //302,167 is the values for the cropping, the cover photo dimensions is 907 x 502
    self.imagePickerControllerCoverphoto = [[SYNImagePickerController alloc] initWithHostViewController:self withCropSize:CGSizeMake(302,167)];
    self.imagePickerControllerCoverphoto.delegate = self;
    [self.imagePickerControllerCoverphoto presentImagePickerAsPopupFromView:sender arrowDirection:UIPopoverArrowDirectionRight];

}
- (IBAction)changeAvatarButtonTapped:(id)sender
{
    self.imagePickerControllerAvatar = [[SYNImagePickerController alloc] initWithHostViewController:self withCropSize:CGSizeMake(280, 280)];
    
    self.imagePickerControllerAvatar.delegate = self;
    [self.imagePickerControllerAvatar presentImagePickerAsPopupFromView:sender arrowDirection:UIPopoverArrowDirectionRight];

}


- (IBAction)followAllTapped:(id)sender
{
    NSString *message = @"Are you sure you want to follow all channels of this user";
    message =  [message stringByAppendingString:@" "];
    message =  [message stringByAppendingString:self.channelOwner.username];
    
    [self.followAllAlertView setMessage:message];
    
    if(modeType == kModeOtherUsersProfile)
    {
        [self.followAllAlertView show];
        
      
    }
}

- (void) picker: (SYNImagePickerController *) picker
finishedWithImage: (UIImage *) image
{
    //DebugLog(@"Orign image width: %f, height%f", image.size.width, image.size.height);
    self.avatarButton.enabled = NO;
    //  [self.activityIndicator startAnimating];
    
    if (picker == self.imagePickerControllerAvatar) {

        [appDelegate.oAuthNetworkEngine updateAvatarForUserId: appDelegate.currentOAuth2Credentials.userId
                                                    image: image
                                        completionHandler: ^(NSDictionary* result)
     {

         [self setProfileImage:result[@"thumbnail_url"]];
         //[self.activityIndicator stopAnimating];
         self.avatarButton.enabled = YES;
         
     }
                                             errorHandler: ^(id error)
     {
//         [self.profileImageView setImageWithURL: [NSURL URLWithString: appDelegate.currentUser.thumbnailURL]
//                               placeholderImage: [UIImage imageNamed: @"PlaceholderSidebarAvatar"]
//                                        options: SDWebImageRetryFailed];
//         
//         //     [self.activityIndicator stopAnimating];
//         self.avatarButton.enabled = YES;
//         
//         UIAlertView* alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"register_screen_form_avatar_upload_title",nil)
//                                                         message: NSLocalizedString(@"register_screen_form_avatar_upload_description",nil)
//                                                        delegate: nil
//                                               cancelButtonTitle: nil
//                                               otherButtonTitles: NSLocalizedString(@"OK",nil), nil];
//         [alert show];
     }];
    
    self.imagePickerControllerAvatar = nil;
    
            }
    else
    {
        [appDelegate.oAuthNetworkEngine updateProfileCoverForUserId: appDelegate.currentOAuth2Credentials.userId
                                                        image: image
                                            completionHandler: ^(NSDictionary* result)
         {
             [self setCoverphotoImage:result[@"Location"]];


//             [self.activityIndicator stopAnimating];
//             self.avatarButton.enabled = YES;
         }
                                                 errorHandler: ^(id error)
         {
//             [self.coverImage setImageWithURL: [NSURL URLWithString: appDelegate.currentUser.coverartUrl]
//                                   placeholderImage: [UIImage imageNamed: @"PlaceholderSidebarAvatar"]
//                                            options: SDWebImageRetryFailed];
//             
//             //     [self.activityIndicator stopAnimating];
////             self.avatarButton.enabled = YES;
//             
//             UIAlertView* alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"register_screen_form_avatar_upload_title",nil)
//                                                             message: NSLocalizedString(@"register_screen_form_avatar_upload_description",nil)
//                                                            delegate: nil
//                                                   cancelButtonTitle: nil
//                                                   otherButtonTitles: NSLocalizedString(@"OK",nil), nil];
//             [alert show];
         }];
        
        self.imagePickerControllerCoverphoto = nil;
    }
}

-(void)createNewButtonPressed
{
    
    self.creatingChannel = YES;
    for (SYNChannelMidCell* cell in self.channelThumbnailCollectionView.visibleCells)
    {
        NSIndexPath* indexPathForCell = [self.channelThumbnailCollectionView indexPathForCell:cell];
        
        
        __block int index = indexPathForCell.row;
        
        if (index == 0)
        {
            ((SYNChannelCreateNewCell*)cell).descriptionTextView.hidden = NO;
            
            CGRect tmpBoarder = ((SYNChannelCreateNewCell*)cell).frame;
            tmpBoarder.size.height+= kHeightChange;
            
            //iphone cell height is different by 11
            if (IS_IPHONE)
            {
                tmpBoarder.size.height+= 19;
            }
            ((SYNChannelCreateNewCell*)cell).frame = tmpBoarder;
            ((SYNChannelCreateNewCell*)cell).state = CreateNewChannelCellStateEditing;
            
            if ([((SYNChannelCreateNewCell*)cell).descriptionTextView.text isEqualToString:@""]) {
                ((SYNChannelCreateNewCell*)cell).descriptionPlaceholderLabel.hidden = NO;
            }
            else
            {
                ((SYNChannelCreateNewCell*)cell).descriptionPlaceholderLabel.hidden = YES;

            }
        }
            void (^animateEditMode)(void) = ^{
                
                CGRect frame = cell.frame;
                
                if (index == 0)
                {
                    
                    ((SYNChannelCreateNewCell*)cell).createCellButton.alpha = 0.0;
                    ((SYNChannelCreateNewCell*)cell).descriptionTextView .alpha = 1.0;
                    
                    CGRect tmpBoarder = ((SYNChannelCreateNewCell*)cell).frame;

                    tmpBoarder.size.height+= kHeightChange;
                    ((SYNChannelCreateNewCell*)cell).frame = tmpBoarder;
                    [((SYNChannelCreateNewCell*)cell).createTextField becomeFirstResponder];
                    
                    tmpBoarder = ((SYNChannelCreateNewCell*)cell).boarderView.frame;
                    tmpBoarder.size.height = 172;
                    ((SYNChannelCreateNewCell*)cell).boarderView.frame = tmpBoarder;

                }
                else
                {
                    if (IS_IPHONE)
                    {
                        frame.origin.y += kHeightChange+18;
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
            
            [UIView animateKeyframesWithDuration:0.2 delay:0.4 options:UIViewAnimationCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState animations:^{
                [self setCreateOffset];
                self.navigationItem.leftBarButtonItem = self.barBtnCancelCreateChannel;
                self.navigationItem.rightBarButtonItem = self.barBtnSaveCreateChannel;
                
            } completion:Nil];
    }
    
    [self performSelector:@selector(updateCollectionLayout) withObject:self afterDelay:0.6f];
}

-(void) cancelCreateChannel
{
    self.creatingChannel = NO;
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.rightBarButtonItem = nil;
    
    
    for (SYNChannelMidCell* cell in self.channelThumbnailCollectionView.visibleCells)
    {
        NSIndexPath* indexPathForCell = [self.channelThumbnailCollectionView indexPathForCell:cell];
        
        __block int index = indexPathForCell.row;
        
        if (index == 0)
        {
            [((SYNChannelCreateNewCell*)cell).createTextField resignFirstResponder];
            [((SYNChannelCreateNewCell*)cell).descriptionTextView resignFirstResponder];
            ((SYNChannelCreateNewCell*)cell).descriptionPlaceholderLabel.hidden = YES;
            ((SYNChannelCreateNewCell*)cell).state = CreateNewChannelCellStateHidden;
        }
        void (^animateProfileMode)(void) = ^{
            CGRect frame = cell.frame;
            
            if (index == 0)
            {
                ((SYNChannelCreateNewCell*)cell).createCellButton.alpha = 1.0f;
                ((SYNChannelCreateNewCell*)cell).descriptionTextView .alpha = 0.0f;
                ((SYNChannelCreateNewCell*)cell).state = CreateNewChannelCellStateHidden;
                CGRect tmpBoarder = ((SYNChannelCreateNewCell*)cell).boarderView.frame;
                if (IS_IPHONE) {
                    tmpBoarder.size.height = 61;
                }
                else
                {
                    tmpBoarder.size.height = 80;
                }
                ((SYNChannelCreateNewCell*)cell).boarderView.frame = tmpBoarder;
                
            }
            else
            {
                if (IS_IPHONE)
                {
                    frame.origin.y -= kHeightChange+18;
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
            //            [self.channelThumbnailCollectionView setContentOffset: CGPointMake(0, 414)];
            
        } completion:Nil];
        
    }
    
    [self performSelector:@selector(updateCollectionLayout) withObject:self afterDelay:0.6f];
    
}

-(void) setCreateOffset
{
    if (UIDeviceOrientationIsPortrait([SYNDeviceManager.sharedInstance orientation]))
    {
        if (self.channelThumbnailCollectionView.contentOffset.y < 120) {
            [self.channelThumbnailCollectionView setContentOffset: CGPointMake(0, 414) animated:YES];
            
        }
    }
    else
    {
        if (self.channelThumbnailCollectionView.contentOffset.y < 370) {
            [self.channelThumbnailCollectionView setContentOffset: CGPointMake(0, 414) animated:YES];
            
        }
    }
    
    if (IS_IPHONE) {
        [self.channelThumbnailCollectionView setContentOffset: CGPointMake(0, 414) animated:YES];
    }
}


-(void) updateCollectionLayout
{
    //  self.channelThumbnailCollectionView.collectionViewLayout = self.channelExpandedLayout;
    CGPoint tmpPoint = self.channelThumbnailCollectionView.contentOffset;
    
    if (IS_IPHONE){
        if (self.channelThumbnailCollectionView.collectionViewLayout == self.channelLayoutIPhone) {
            [self.channelThumbnailCollectionView setCollectionViewLayout:self.channelExpandedLayout];
        }
        else
        {
            [self.channelThumbnailCollectionView setCollectionViewLayout:self.channelLayoutIPhone];
        }
    }
    else
    {
        if (self.channelThumbnailCollectionView.collectionViewLayout == self.channelLayoutIPad) {
            [self.channelThumbnailCollectionView setCollectionViewLayout:self.channelExpandedLayout];
        }
        else
        {
            [self.channelThumbnailCollectionView setCollectionViewLayout:self.channelLayoutIPad];
        }
    }
    
    self.channelThumbnailCollectionView.contentOffset = tmpPoint;
    [self.channelThumbnailCollectionView.collectionViewLayout invalidateLayout];
    
    
}


-(void)deleteChannelTapped: (SYNChannelMidCell*) cell{
    
    
//
//    [self.channelThumbnailCollectionView performBatchUpdates:^{
//        
//        NSIndexPath *indexPath = [self.channelThumbnailCollectionView indexPathForItemAtPoint: cell.center];
//        
//        // Delete the items from the data source.
//        [appDelegate.currentUser.channelsSet removeObject: cell.channel];
////        [cell.channel.managedObjectContext deleteObject: cell.channel];
//        
//        // Now delete the items from the collection view.
//        [self.channelThumbnailCollectionView deleteItemsAtIndexPaths:@[indexPath]];
//        
//    } completion:^(BOOL finished) {
//        NSLog(@"COMPLETED!");
//    }];

    self.deleteCell = cell;
    NSString *tmpString = [NSString stringWithFormat:@"%@ %@?",NSLocalizedString(@"Delete channel", "Alerview confirm to delete a Channel"), cell.channel.title];
    
    [self.deleteChannelAlertView setMessage:tmpString];
    [self.deleteChannelAlertView show];
    
}



-(void) deleteChannel:(SYNChannelMidCell *)cell
{
    ((SYNChannelMidCell*)cell).state = ChannelMidCellStateDefault;

//    [self.channelThumbnailCollectionView performBatchUpdates:^{
//        
//
//        NSArray* itemPaths = [self.channelThumbnailCollectionView indexPathsForSelectedItems];
//        
//        
//        for (int i = 0; i<itemPaths.count; i++) {
//            
//            NSLog(@"**Index : %@", [itemPaths objectAtIndex:i]);
//            
//        }
//        
//        // Delete the items from the data source.
//        [appDelegate.currentUser.channelsSet removeObject: cell.channel];
//        
//        // Now delete the items from the collection view.
//        [self.channelThumbnailCollectionView deleteItemsAtIndexPaths:itemPaths];
//    } completion:nil];
    
    [appDelegate.oAuthNetworkEngine deleteChannelForUserId: appDelegate.currentUser.uniqueId
                                                 channelId: cell.channel.uniqueId
                                         completionHandler: ^(id response) {

//                                             CGRect tmp = ((SYNChannelMidCell*)cell).boarderView.frame;
//                                             tmp.size.height = 0;
//                                             
//                                             [UIView animateWithDuration:0.4 animations:^{
//                                                 
//                                                 cell.boarderView.frame = tmp;
//                                             } completion:^(BOOL finished) {
//                                                 CGRect tmp = ((SYNChannelMidCell*)cell).boarderView.frame;
//                                                 if (IS_IPHONE) {
//                                                     tmp.size.height = 71;
//
//                                                 }
//                                                 else
//                                                 {
//                                                 tmp.size.height = 80;
//
//                                                 }
//                                                 cell.boarderView.frame = tmp;
//                                                 [[NSNotificationCenter defaultCenter] postNotificationName: kChannelOwnerUpdateRequest
//                                                                                                     object: self
//                                                                                                   userInfo: @{kChannelOwner : self.channelOwner}];
//
//                                             }];
                                             
                                             [cell.channel.managedObjectContext deleteObject: cell.channel];
                                             [self.channelThumbnailCollectionView reloadData];
                                             
                                         } errorHandler: ^(id error) {
                                             DebugLog(@"Delete channel failed");
                                         }];
}


@end
