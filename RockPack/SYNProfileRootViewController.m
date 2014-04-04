//
//  SYNProfileRootViewController.m
//  rockpack
//
//  Created by Nick Banks on 24/01/2013.
//  Copysubscriptions (c) Rockpack Ltd. All subscriptionss reserved.
//

#import "AppConstants.h"
#import "Channel.h"
#import "SYNAddToChannelCreateNewCell.h"
#import "SYNChannelMidCell.h"
#import "SYNChannelSearchCell.h"
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
#import "SYNTrackingManager.h"


@import QuartzCore;

#define FULL_NAME_LABEL_IPHONE 364.0f // lower is down
#define FULL_NAME_LABEL_IPAD_PORTRAIT 533.0f
#define FULLNAMELABELIPADLANDSCAPE 412.0f
#define SEARCHBAR_Y 430.0f
#define ALPHA_IN_EDIT 0.2f
#define OFFSET_DESCRIPTION_EDIT 130.0f
#define PARALLAX_SCROLL_VALUE 2.0f
#define kHeightChange 94.0f
#define MAXRANGE 1000.0f
#define SEGMENTED_CONTROLLER_ANIMATION 0.35f


@interface SYNProfileRootViewController () <UISearchBarDelegate, UITextViewDelegate, UITextFieldDelegate, SYNImagePickerControllerDelegate, SYNChannelMidCellDelegate,SYNChannelCreateNewCelllDelegate> {
    ProfileType modeType;
}

@property (nonatomic) BOOL isUserProfile;
@property (nonatomic, assign) BOOL collectionsTabActive;

@property (nonatomic, strong) NSArray *filteredSubscriptions;
@property (nonatomic, strong) UIBarButtonItem *barBtnBack; // storage for the navigation back button

@property (nonatomic, strong) NSIndexPath *channelsIndexPath;
@property (nonatomic, strong) NSIndexPath *subscriptionsIndexPath;
//used for the search bar in subscriptions tab
@property (nonatomic, strong) NSString *currentSearchTerm;
@property (nonatomic, assign) BOOL shouldBeginEditing;

@property (nonatomic, strong) IBOutlet UIButton *uploadCoverPhotoButton;

@property (nonatomic, strong) id orientationDesicionmaker;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *topSegmentedConstraint;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *topTextViewConstraint;

@property (nonatomic, strong) SYNImagePickerController* imagePickerControllerAvatar;
@property (nonatomic, strong) SYNImagePickerController* imagePickerControllerCoverphoto;

@property (nonatomic, strong) SYNChannelMidCell *followCell;
@property (nonatomic, strong) IBOutlet UICollectionViewFlowLayout *channelLayoutIPad;
@property (nonatomic, strong) IBOutlet UICollectionViewFlowLayout *subscriptionLayoutIPad;
@property (nonatomic, strong) IBOutlet SYNSocialButton *followAllButton;
@property (nonatomic, strong) IBOutlet UIView *outerViewFullNameLabel;
@property (nonatomic, strong) IBOutlet UICollectionViewFlowLayout *channelLayoutIPhone;
@property (nonatomic, strong) IBOutlet UICollectionViewFlowLayout *subscriptionLayoutIPhone;
@property (nonatomic, strong) NSIndexPath *indexPathToDelete;

@property (nonatomic, strong) SYNProfileExpandedFlowLayout *channelExpandedLayout;
@property (nonatomic, strong) IBOutlet UICollectionView *channelThumbnailCollectionView;
@property (nonatomic, strong) IBOutlet UICollectionView *subscriptionThumbnailCollectionView;
@property (nonatomic, strong) IBOutlet UIImageView *profileImageView;
//@property (strong, nonatomic) IBOutlet UIButton *avatarButton;

@property (nonatomic, strong) IBOutlet UILabel *fullNameLabel;
@property (nonatomic, strong) IBOutlet UILabel *userNameLabel;
@property (nonatomic, strong) IBOutlet UIImageView *coverImage;
@property (nonatomic, strong) IBOutlet UITextView *aboutMeTextView;

@property (nonatomic, strong) IBOutlet UIButton *collectionsTabButton;
@property (nonatomic, strong) IBOutlet UIButton *followingTabButton;
@property (nonatomic, strong) IBOutlet UIView *segmentedControlsView;
@property (nonatomic, strong) IBOutlet UIButton *moreButton;
@property (nonatomic, strong) SYNChannelMidCell *deleteCell;

@property (nonatomic, strong) IBOutlet UIButton *uploadAvatarButton;


@property (nonatomic, assign) BOOL searchMode;
@property (nonatomic, strong) IBOutlet UISearchBar *followingSearchBar;
@property (nonatomic, strong) IBOutlet UIView *containerViewIPad;
@property (nonatomic) ProfileType modeType;
@property (nonatomic, strong) UIBarButtonItem *barBtnCancelEditMode;
@property (nonatomic, strong) UIBarButtonItem *barBtnCancelCreateChannel;
@property (nonatomic, strong) UIBarButtonItem *barBtnSaveEditMode;
@property (nonatomic, strong) UIBarButtonItem *barBtnSaveCreateChannel;

@property (nonatomic, strong) IBOutlet UIView *backgroundView;

@property (nonatomic, strong) UITapGestureRecognizer *tapToHideKeyoboard;
@property (nonatomic, strong) UITapGestureRecognizer *tapToCancelEditMode;


@property (nonatomic, strong) UIAlertView *followAllAlertView;
@property (nonatomic, strong) UIAlertView *deleteChannelAlertView;

@property (nonatomic) CGPoint contentOffset;

@property (weak, nonatomic) SYNChannelCreateNewCell *createChannelCell;
@property (nonatomic, strong) IBOutlet UILabel *followersCountLabel;

@property (nonatomic) BOOL creatingChannel;

@property (nonatomic) NSRange dataRequestRangeChannel;
@property (nonatomic) NSRange dataRequestRangeSubscriptions;
@property (nonatomic, strong) IBOutlet UIButton *uploadAvatar;

@end


@implementation SYNProfileRootViewController
#pragma mark - Object lifecycle
@synthesize modeType;

- (id) initWithViewId:(NSString *)vid {
    if (self = [super initWithNibName:NSStringFromClass([SYNProfileRootViewController class]) bundle:nil]) {
        viewId = vid;
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(handleDataModelChange:)
                                                     name: NSManagedObjectContextObjectsDidChangeNotification
                                                   object: appDelegate.searchManagedObjectContext];
        
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(hideDescriptionCurrentlyShowing) name:kHideAllDesciptions object:nil];
        
    }
    
    return self;
}

- (id) initWithViewId:(NSString*) vid andChannelOwner:(ChannelOwner*)chanOwner {
    self = [self initWithViewId:vid];
    self.channelOwner = chanOwner;
    return self;
}

- (void) dealloc {
    // Defensive programming
    
    self.channelOwner = nil;
    self.subscriptionThumbnailCollectionView.delegate =nil;
    self.subscriptionThumbnailCollectionView.dataSource =nil;
    self.channelThumbnailCollectionView.delegate = nil;
    self.channelThumbnailCollectionView.dataSource = nil;
	
	self.followingSearchBar.delegate = nil;
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - View Lifecycle

- (void) viewDidLoad {
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
    
    //Bool to check if the user is "Creating a new channel"
    self.creatingChannel = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(userDataChanged:)
                                                 name: kUserDataChanged
                                               object: nil];
    
    
    self.channelExpandedLayout = [[SYNProfileExpandedFlowLayout alloc]init];
    
    // == Main Collection View
    if (IS_IPHONE) {
        self.subscriptionThumbnailCollectionView.collectionViewLayout = self.subscriptionLayoutIPhone;
        self.channelThumbnailCollectionView.collectionViewLayout = self.channelLayoutIPhone;
        
        [self.channelThumbnailCollectionView.collectionViewLayout invalidateLayout];
        [self.subscriptionThumbnailCollectionView.collectionViewLayout invalidateLayout];
        // == BG Colour of the search bar that is only found in iphone for channals that are being followed
        UITextField *txfSearchField = [self.followingSearchBar valueForKey:@"_searchField"];
        if(txfSearchField)
            txfSearchField.backgroundColor = [UIColor dollySearchBarColor];
        
        // == Layout for the expanded create new channel cell
        self.channelExpandedLayout.minimumInteritemSpacing = 0;
        self.channelExpandedLayout.minimumLineSpacing = 0;
        self.channelExpandedLayout.itemSize = CGSizeMake(320, 71);
        self.channelExpandedLayout.sectionInset = UIEdgeInsetsMake(494, 0, 70, 0);
        
    }
    else {
        // == IPad collectionview layouts
        self.channelThumbnailCollectionView.collectionViewLayout = self.channelLayoutIPad;
        self.subscriptionThumbnailCollectionView.collectionViewLayout = self.subscriptionLayoutIPad;
    }
    
    self.searchMode = NO;
    
    //hide the channel collectionview
    if (IS_IPAD) {
        self.channelThumbnailCollectionView.hidden = YES;
    }
    
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
    
    self.barBtnCancelEditMode = [[UIBarButtonItem alloc]initWithTitle:@"cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelEditModeTapped)];
    self.barBtnCancelEditMode.tintColor = [UIColor colorWithRed: (100 / 255.0f)
                                                          green: (99 / 255.0f)
                                                           blue: (112 / 255.0f)
                                                          alpha: 1.0f];
    
    self.barBtnCancelCreateChannel = [[UIBarButtonItem alloc]initWithTitle:@"cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelCreateChannel)];
    self.barBtnCancelCreateChannel.tintColor = [UIColor colorWithRed: (100 / 255.0f)
                                                               green: (99 / 255.0f)
                                                                blue: (112 / 255.0f)
                                                               alpha: 1.0f];
    
    
    self.barBtnSaveEditMode= [[UIBarButtonItem alloc]initWithTitle:@"save" style:UIBarButtonItemStyleBordered target:self action:@selector(saveDescription)];
    
    self.barBtnSaveEditMode.tintColor = [UIColor colorWithRed: (100 / 255.0f)
                                                        green: (99 / 255.0f)
                                                         blue: (112 / 255.0f)
                                                        alpha: 1.0f];
    
    self.barBtnSaveCreateChannel = [[UIBarButtonItem alloc]initWithTitle:@"save" style:UIBarButtonItemStyleBordered target:self action:@selector(saveCreateChannelTapped)];
    
    self.barBtnSaveCreateChannel.tintColor = [UIColor colorWithRed: (100 / 255.0f)
                                                             green: (99 / 255.0f)
                                                              blue: (112 / 255.0f)
                                                             alpha: 1.0f];
    
    // == Tap gesture do dismiss the keyboard
    self.tapToHideKeyoboard = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    
    self.tapToCancelEditMode = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelEditModeTapped)];
    
    // == The back button title is always set to ""
    [self.navigationController.navigationItem.leftBarButtonItem setTitle:@""];
    
    
    
    // == Init alert views, Follow and Unfollow
    self.followAllAlertView = [[UIAlertView alloc]initWithTitle:@"Follow All?" message:nil delegate:self cancelButtonTitle:[self noButtonTitle] otherButtonTitles:[self yesButtonTitle], nil];
    
    
    self.deleteChannelAlertView = [[UIAlertView alloc] initWithTitle:@"" message:@"" delegate:self cancelButtonTitle:[self noButtonTitle] otherButtonTitles:[self yesButtonTitle] , nil];
    
    
    [self setFollowersCountLabel];
    
    
    // == adjust for 3.5 inch screens
    if (!IS_IPHONE_5) {
        UIEdgeInsets tmpInsets = self.subscriptionThumbnailCollectionView.contentInset;
        tmpInsets.bottom += 88;
        [self.subscriptionThumbnailCollectionView setContentInset: tmpInsets];
        
        tmpInsets = self.channelThumbnailCollectionView.contentInset;
        tmpInsets.bottom += 88;
        
        [self.channelThumbnailCollectionView setContentInset: tmpInsets];
        
    }
    
    
    // == Right transform for the segmented control animations
    
    if (IS_IPHONE) {
        CGAffineTransform translateRight = CGAffineTransformMakeTranslation(self.view.frame.size.width, 0);
        
        self.subscriptionThumbnailCollectionView.transform = translateRight;
        
        self.followingSearchBar.transform = CGAffineTransformTranslate(self.followingSearchBar.transform, self.view.frame.size.width, 0);
        
        CGRect tmp = self.followingSearchBar.frame;
        tmp.origin.x+=320;
        self.followingSearchBar.frame = tmp;
    }
    
    // == set up views

    if (self.modeType == kModeMyOwnProfile) {
        [self setUpUserProfile];
        [self setUpImages];

    }
    // == set up the segmented controller
    [self setUpSegmentedControl];
    
    // == updates the segmented controllers functionality
    if (IS_IPHONE)
    {
        [self updateTabStatesWithServerCalls:NO];
    }
    
    
    if (IS_IPAD) {
        self.followingSearchBar.layer.borderWidth = 1.0f;
        self.followingSearchBar.layer.borderColor = [[UIColor dollyMediumGray] CGColor];
    }

    
    [self setUpViews];
    
}
-(void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
    
	[SYNActivityManager.sharedInstance updateActivityForCurrentUserWithReset:NO];
    [self updateTabStatesWithServerCalls:YES];
    [self setNeedsStatusBarAppearanceUpdate];
    [self updateLayoutForOrientation: [SYNDeviceManager.sharedInstance orientation]];
    
    // == Transparent navigation bar
	[self.navigationController.navigationBar setBackgroundTransparent:YES];
	
    self.navigationController.view.backgroundColor = [UIColor clearColor];
    
    self.navigationItem.title = @"";
    
        [self.followAllButton setSelected:self.channelOwner.subscribedByUserValue];
    
    self.filteredSubscriptions = [self.channelOwner.subscriptions array];
    
    [self.subscriptionThumbnailCollectionView reloadData];
    [self.channelThumbnailCollectionView reloadData];
    
    self.channelThumbnailCollectionView.contentOffset = CGPointZero;
    self.subscriptionThumbnailCollectionView.contentOffset = CGPointZero;
    
    if (IS_IPHONE) {
        if (self.collectionsTabActive) {
            self.subscriptionThumbnailCollectionView.contentOffset = self.contentOffset;
            self.channelThumbnailCollectionView.contentOffset = self.contentOffset;
        } else {
            self.channelThumbnailCollectionView.contentOffset = self.contentOffset;
            [self.subscriptionThumbnailCollectionView setContentOffset:self.contentOffset animated:NO];
        }
    }
    
    //View gets hidden in view will dissapear because the ios 7 swipe gesture to go back, the collection covered the last screen
    if (IS_IPHONE) {
        self.channelThumbnailCollectionView.hidden=NO;
        self.subscriptionThumbnailCollectionView.hidden=NO;
    }
}


- (void) viewDidAppear: (BOOL) animated {
    [super viewDidAppear: animated];
    
    self.navigationController.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                                                  style:UIBarButtonItemStyleBordered
                                                                                                 target:nil
                                                                                                 action:nil];
    self.navigationItem.backBarButtonItem.title = @"";
    [self.navigationItem.backBarButtonItem setTitle:@""];
    
    
    if (self.channelOwner == appDelegate.currentUser) {
		[[SYNTrackingManager sharedManager] trackOwnProfileScreenView];
    } else {
        if (IS_IPHONE) {
            self.channelThumbnailCollectionView.scrollsToTop = !self.collectionsTabActive;
            self.subscriptionThumbnailCollectionView.scrollsToTop = self.collectionsTabActive;
        } else {
            self.channelThumbnailCollectionView.scrollsToTop = YES;
            self.subscriptionThumbnailCollectionView.scrollsToTop = NO;
        }
		
		[[SYNTrackingManager sharedManager] trackOtherUserProfileScreenView];
	}
    
    if (IS_IPAD) {
        [self updateLayoutForOrientation: [SYNDeviceManager.sharedInstance orientation]];
    }
        double delayInSeconds = 0.9;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self showInboardingAnimationDescription];
        });
    
    
}

-(void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
    if (IS_IPHONE) {
        [self.navigationController.navigationBar setBackgroundTransparent:NO];
    }

    if (self.creatingChannel) {
        [self cancelCreateChannel];
    }
    
    if (IS_IPHONE) {
        self.contentOffset = self.collectionsTabActive ? self.channelThumbnailCollectionView.contentOffset : self.subscriptionThumbnailCollectionView.contentOffset;
    }
    if (IS_IPHONE && !self.collectionsTabActive) {
        self.channelThumbnailCollectionView.hidden=YES;
    }
}

-(void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	
    if (IS_IPHONE) {
        self.channelThumbnailCollectionView.hidden=NO;
    }
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}


#pragma mark - User Profile

//Initial set up for user profile uiviews

- (void) setUpViews {
    [self.userNameLabel setFont:[UIFont regularCustomFontOfSize:12.0]];
    self.userNameLabel.textColor = [UIColor colorWithWhite:120/255.0 alpha:1.0];
    self.fullNameLabel.font = [UIFont regularCustomFontOfSize:20];
    [self.collectionsTabButton.titleLabel setFont:[UIFont regularCustomFontOfSize:15]];
    [self.followingTabButton.titleLabel setFont:[UIFont regularCustomFontOfSize:15]];
	self.aboutMeTextView.textAlignment = NSTextAlignmentCenter;
	self.aboutMeTextView.textColor = [UIColor colorWithWhite:120/255.0 alpha:1.0];
    self.aboutMeTextView.textContainer.maximumNumberOfLines = 2;
    [[self.aboutMeTextView layer] setBorderColor:[[UIColor colorWithRed:172.0/255.0f green:172.0/255.0f blue:172.0/255.0f alpha:1.0f] CGColor]];
    self.aboutMeTextView.font = [UIFont lightCustomFontOfSize:11.0];

}


- (void) setUpImages {
    [self setCoverphotoImage:self.channelOwner.coverPhotoURL];
    [self setProfileImage:self.channelOwner.thumbnailURL];
}

- (void) setUpUserProfile {
    self.userNameLabel.text = [NSString stringWithFormat:@"@%@", self.channelOwner.username];
    
    
    //other user cover photos are set in set channel owner succcess block as
    //places such as the cover photo set yet
    
    self.fullNameLabel.text = self.channelOwner.displayName;
    
    [self.collectionsTabButton setTitle:[NSString stringWithFormat:@"%@ (%lld)", NSLocalizedString(@"Collections", nil), self.channelOwner.totalVideosValueChannelValue ]forState:UIControlStateNormal];
    
    
    [self.followingTabButton setTitle:[NSString stringWithFormat:@"%@ (%lld)", NSLocalizedString(@"Following", nil), self.channelOwner.subscriptionCountValue]forState:UIControlStateNormal];

    
    [self.aboutMeTextView setText:self.channelOwner.channelOwnerDescription];
    [self setUpViews];
}

-(void) setUpSegmentedControl{
    
    self.segmentedControlsView.layer.cornerRadius = 4;
    self.segmentedControlsView.layer.borderWidth = .5f;
    self.segmentedControlsView.layer.borderColor = [[UIColor grayColor] CGColor];
    self.segmentedControlsView.layer.masksToBounds = YES;
    
}

-(void) setProfileImage : (NSString*) thumbnailURL
{
    __weak SYNProfileRootViewController *weakSelf = self;
    
    
    
    [self.profileImageView setImageWithURL:[NSURL URLWithString: self.channelOwner.thumbnailLargeUrl]
                                 completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                                     
                                     weakSelf.profileImageView.layer.borderColor = [[UIColor colorWithWhite:219/255.0 alpha:1.0] CGColor];
                                     weakSelf.profileImageView.layer.borderWidth = (IS_RETINA ? 0.5 : 1.0);

                                     if (image && cacheType == SDImageCacheTypeNone)
                                     {
                                         weakSelf.profileImageView.alpha = 0.0;
                                         [UIView animateWithDuration:1.0 animations:^{
                                             weakSelf.profileImageView.alpha = 1.0;
                                         }];
                                     }
                                     if (!image) {
                                         weakSelf.profileImageView.alpha = 0.0;
                                         [weakSelf.profileImageView setImage:[UIImage imageNamed:@"PlaceholderAvatarProfile"]];

                                         [UIView animateWithDuration:1.0 animations:^{
                                             weakSelf.profileImageView.alpha = 1.0;
                                         }];

                                     }
                                 }];

}

-(void) setCoverphotoImage: (NSString*) thumbnailURL
{
    
    
    
//    if (self.coverImage.image) {
//        return;
//    }

    NSString *thumbnailUrlString;
    if (IS_IPAD)
    {
        thumbnailUrlString = [thumbnailURL stringByReplacingOccurrencesOfString: @"thumbnail_medium"                                                                                               withString: @"ipad"];
    }
    else
    {
        thumbnailUrlString = [thumbnailURL stringByReplacingOccurrencesOfString: @"thumbnail_medium"                                                                                               withString: @"thumbnail_medium"];
    }
    
    __weak SYNProfileRootViewController *weakSelf = self;

    [self.coverImage setImageWithURL:[NSURL URLWithString: thumbnailUrlString]
                    placeholderImage:[UIImage imageNamed: @"placeholderwhite"]
                           completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                               if (image && cacheType == SDImageCacheTypeNone)
                               {
                                   weakSelf.coverImage.alpha = 0.0;
                                   [UIView animateWithDuration:1.0 animations:^{
                                       weakSelf.coverImage.alpha = 1.0;
                                   }];
                               }
                           }];
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


-(void) setFollowersCountLabel {
    NSString *tmpString;
    if (self.channelOwner.subscribersCountValue == 1) {
        tmpString = [[NSString alloc] initWithFormat:@"%lld %@", self.channelOwner.subscribersCountValue, NSLocalizedString(@"follower", "follower count in profile")];
    }
    else {
        tmpString = [[NSString alloc] initWithFormat:@"%lld %@", self.channelOwner.subscribersCountValue, NSLocalizedString(@"followers", "followers count in profile")];
    }
    
    
    [self.followersCountLabel setText:tmpString];
    
    [self.followersCountLabel setFont:[UIFont  regularCustomFontOfSize:self.followersCountLabel.font.pointSize]];
}



-(void) setProfleType: (ProfileType) profileType
{
    if (profileType == kModeMyOwnProfile)
    {
        self.followAllButton.hidden = YES;
        self.uploadAvatar.hidden = NO;
        self.moreButton.hidden = NO;
        self.followingSearchBar.hidden = NO;
        self.userNameLabel.hidden = YES;
        
    }
    if (profileType == kModeOtherUsersProfile)
    {
        self.followAllButton.hidden = NO;
        self.moreButton.hidden = YES;
        self.uploadAvatar.hidden = YES;
        if (IS_IPHONE) {
            CGRect tmpFrame = self.aboutMeTextView.frame;
            tmpFrame.origin.y += 26;
            self.aboutMeTextView.frame = tmpFrame;
            
            tmpFrame = self.segmentedControlsView.frame;
            tmpFrame.origin.y +=22;
            self.segmentedControlsView.frame = tmpFrame;
            
            self.followingSearchBar.hidden = YES;
            UIEdgeInsets tmpEdgeInset = self.subscriptionLayoutIPhone.sectionInset;
            tmpEdgeInset.top -= 42;
            self.subscriptionLayoutIPhone.sectionInset = tmpEdgeInset;
            self.uploadAvatar.hidden=YES;
            
            
            UICollectionViewFlowLayout *tmpLayout = ((UICollectionViewFlowLayout*)self.channelThumbnailCollectionView.collectionViewLayout);
            UIEdgeInsets tmpInset = tmpLayout.sectionInset;
            tmpInset.top +=22;
            
            tmpLayout.sectionInset = tmpInset;
            self.channelThumbnailCollectionView.collectionViewLayout = tmpLayout;
            
            tmpLayout = ((UICollectionViewFlowLayout*)self.subscriptionThumbnailCollectionView.collectionViewLayout);
            tmpInset = tmpLayout.sectionInset;
            tmpInset.top +=22;
            tmpLayout.sectionInset = tmpInset;
            self.subscriptionThumbnailCollectionView.collectionViewLayout = tmpLayout;
        }
        
        if (IS_IPAD) {
            
            [self.topTextViewConstraint setConstant:self.topTextViewConstraint.constant+10];
            [self.containerViewIPad layoutIfNeeded];
        }
    }
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


#pragma mark - Core Data Callbacks
- (void) handleDataModelChange: (NSNotification *) notification
{
    NSArray *updatedObjects = [notification userInfo][NSUpdatedObjectsKey];
    
    [updatedObjects enumerateObjectsUsingBlock: ^(id obj, NSUInteger idx, BOOL *stop)
     {
         if (obj == self.channelOwner)
         {
             [self.collectionsTabButton setTitle:[NSString stringWithFormat:@"%@ (%lld)", NSLocalizedString(@"Collections", nil), self.channelOwner.totalVideosValueChannelValue ]forState:UIControlStateNormal];
             [self.followingTabButton setTitle:[NSString stringWithFormat:@"%@ (%lld)", NSLocalizedString(@"Following", nil), self.channelOwner.subscriptionCountValue]forState:UIControlStateNormal];
             
             [self reloadCollectionViews];
             [self setFollowersCountLabel];
             
             return;
         }
     }];
}


#pragma mark - Orientation


- (void) didRotateFromInterfaceOrientation: (UIInterfaceOrientation) fromInterfaceOrientation
{
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
    
    if (IS_IPAD)
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
            
            
            float sectionHeader = 702.0f;
            
            self.channelLayoutIPad.minimumLineSpacing = 14.0f;
            self.channelLayoutIPad.sectionInset = UIEdgeInsetsMake(sectionHeader, 47.0, 70.0, 47.0);
            self.subscriptionLayoutIPad.minimumLineSpacing = 14.0f;
            self.subscriptionLayoutIPad.sectionInset = UIEdgeInsetsMake(sectionHeader, 47.0, 70.0, 47.0);
            
            self.channelExpandedLayout.minimumLineSpacing = 14.0f;
            self.channelExpandedLayout.sectionInset = UIEdgeInsetsMake(sectionHeader, 47.0, 70.0, 47.0);
            
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
            float sectionHeader = 574.0f;

            self.channelLayoutIPad.sectionInset = UIEdgeInsetsMake(sectionHeader, 21.0, 70.0, 21.0);
            self.channelLayoutIPad.minimumLineSpacing = 14.0f;
            self.subscriptionLayoutIPad.minimumLineSpacing = 14.0f;
            self.subscriptionLayoutIPad.sectionInset =  UIEdgeInsetsMake(sectionHeader, 21.0, 70.0, 21.0);
            
            self.channelExpandedLayout.sectionInset = UIEdgeInsetsMake(sectionHeader, 21.0, 70.0, 21.0);
            self.channelExpandedLayout.minimumLineSpacing = 14.0f;
            
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
}


#pragma mark - UICollectionView DataSource/Delegate

- (NSInteger) collectionView: (UICollectionView *) view numberOfItemsInSection: (NSInteger) section
{
    
    if ([view isEqual:self.subscriptionThumbnailCollectionView])
    {
        return self.channelOwner.subscriptionsSet.count;
    }
    
    return self.channelOwner.channelsSet.count + (self.isUserProfile ? 1 : 0); // to account for the extra 'creation' cell at the start of the collection view
}

- (NSInteger) numberOfSectionsInCollectionView: (UICollectionView *) collectionView
{
    return 1;
}


- (UICollectionViewCell *) collectionView: (UICollectionView *) collectionView
                   cellForItemAtIndexPath: (NSIndexPath *) indexPath
{
    
    UICollectionViewCell *cell = nil;
    
    if (self.isUserProfile && indexPath.row == 0 && [collectionView isEqual:self.channelThumbnailCollectionView])
        // first row for a user profile only (create)
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
        
        channelThumbnailCell.showsDescriptionOnSwipe = YES;
        
        if(collectionView == self.channelThumbnailCollectionView)
        {
            channel = (Channel *) self.channelOwner.channelsSet[indexPath.item - (self.isUserProfile ? 1 : 0)];
            
			channelThumbnailCell.followButton.hidden = (self.modeType == kModeMyOwnProfile);
            
            [channelThumbnailCell.descriptionLabel setText:channel.channelDescription];
            
            channelThumbnailCell.channel = channel;
			
			// indexPath.row == Favourites cell, which is a special case
            if(!channel.favouritesValue && self.modeType == kModeMyOwnProfile) {
                channelThumbnailCell.deletableCell = YES;
            } else {
                channelThumbnailCell.deletableCell = NO;
            }
        }
        else
        {
            if (indexPath.row < [self.filteredSubscriptions count])
            {
                channel = self.filteredSubscriptions[indexPath.item];
                
                if (self.modeType == kModeMyOwnProfile)
                {
                    [channelThumbnailCell setFollowButtonLabel:NSLocalizedString(@"Unfollow", nil)];
                }
				//text is set in the channelmidcell setChannel method
                channelThumbnailCell.channel = channel;
            } else {
				channelThumbnailCell.channel = nil;
			}
        }
        channelThumbnailCell.viewControllerDelegate = self;
        
        cell = channelThumbnailCell;
        
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
        else if(self.isUserProfile)
        {
            
            channel = self.channelOwner.channels[indexPath.row - (self.isUserProfile ? 1 : 0)];

            if (channel.favouritesValue) {
                channelVC = [[SYNChannelDetailsViewController alloc] initWithChannel:channel usingMode:kChannelDetailsFavourites];
                [self.navigationController pushViewController:channelVC animated:YES];
                return;
            }
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
        
        if (indexPath.row < [self.filteredSubscriptions count]) {
            Channel *channel = self.filteredSubscriptions[indexPath.item];
            
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

#pragma mark - tab button actions
- (IBAction)collectionsTabTapped:(id)sender {
    self.collectionsTabActive = YES;
    if (IS_IPHONE) {
        
        CGAffineTransform translateLeftChannel = CGAffineTransformTranslate(self.channelThumbnailCollectionView.transform,self.view.frame.size.width, 0);
        
        CGAffineTransform translateLeftSubscription = CGAffineTransformTranslate(self.subscriptionThumbnailCollectionView.transform,self.view.frame.size.width, 0);
        
        CGRect tmp = self.followingSearchBar.frame;
        tmp.origin.x+=320;
        
        
        // == using the position of the search bar to determine if the the animation should animate or not
        if (self.followingSearchBar.frame.origin.x == 0) {
            
            
            [UIView animateWithDuration:SEGMENTED_CONTROLLER_ANIMATION animations:^{
                self.channelThumbnailCollectionView.transform = translateLeftChannel;
                self.subscriptionThumbnailCollectionView.transform = translateLeftSubscription;
                
                self.followingSearchBar.frame = tmp;
                
            }];
            
        }
    }
    
    [self updateTabStatesWithServerCalls:YES];
    
}
- (IBAction)followingsTabTapped:(id)sender {
    self.collectionsTabActive = NO;
	
	if ([self.channelOwner.uniqueId isEqualToString:appDelegate.currentUser.uniqueId]) {
		[[SYNTrackingManager sharedManager] trackOwnProfileFollowingScreenView];
	} else {
		[[SYNTrackingManager sharedManager] trackOtherUserCollectionFollowingScreenView];
	}
	
    //
    if (IS_IPHONE) {
        CGAffineTransform translateLeftChannel = CGAffineTransformTranslate(self.channelThumbnailCollectionView.transform,-self.view.frame.size.width, 0);
        
        CGAffineTransform translateLeftSubscription = CGAffineTransformTranslate(self.subscriptionThumbnailCollectionView.transform,-self.view.frame.size.width, 0);
        
        CGRect tmp = self.followingSearchBar.frame;
        tmp.origin.x-=320;
        
        if (self.followingSearchBar.frame.origin.x == 320) {
            
            [UIView animateWithDuration:SEGMENTED_CONTROLLER_ANIMATION animations:^{
                self.channelThumbnailCollectionView.transform = translateLeftChannel;
                self.subscriptionThumbnailCollectionView.transform = translateLeftSubscription;
                
                self.followingSearchBar.frame = tmp;
                
            }];
        }
    }
    
    [self updateTabStatesWithServerCalls:YES];
    
}

- (void) updateTabStatesWithServerCalls:(BOOL) calls
{
    
    [self stopCollectionScrollViews];
    
    self.collectionsTabButton.selected = !self.collectionsTabActive;
    
    if (IS_IPAD) {
        self.channelThumbnailCollectionView.hidden = !self.collectionsTabActive;
        self.subscriptionThumbnailCollectionView.hidden = self.collectionsTabActive;
    }
    
    if (self.modeType == kModeMyOwnProfile)
    {
        self.followingSearchBar.hidden = NO;
    }
    
    if (self.collectionsTabActive)
    {
        [self.followingTabButton setTitleColor:[UIColor dollyTabColorSelectedText] forState:UIControlStateNormal];
        [self.followingTabButton setTitleColor:[UIColor dollyTabColorSelectedText] forState:UIControlStateHighlighted];

        
        [self.followingTabButton setBackgroundColor: [UIColor whiteColor]];
        
        [self.collectionsTabButton setBackgroundColor: [UIColor dollyTabColorSelectedBackground]];
        
        [self.collectionsTabButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.collectionsTabButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        
        //    Working load more videos for user channels
        
        NSManagedObjectID *channelOwnerObjectId = self.channelOwner.objectID;
        NSManagedObjectContext *channelOwnerObjectMOC = self.channelOwner.managedObjectContext;

        if (calls) {
            [appDelegate.oAuthNetworkEngine userDataForUser: ((User *) self.channelOwner)
                                               onCompletion: ^(id dictionary) {
                                                   NSError *error = nil;
                                                   ChannelOwner * channelOwnerFromId = (ChannelOwner *)[channelOwnerObjectMOC existingObjectWithID: channelOwnerObjectId error: &error];
                                                   
                                                   if (channelOwnerFromId)
                                                   {
                                                       [channelOwnerFromId setAttributesFromDictionary: dictionary
                                                                                   ignoringObjectTypes: kIgnoreNothing];
                                                       
                                                       
                                                       [self setUpUserProfile];
                                                       [self reloadCollectionViews];
                                                   }
                                                   
                                                   
                                               } onError: nil];

        }
        
    }
    else
    {
        if (self.creatingChannel) {
            [self cancelCreateChannel];
        }

        [self.followingTabButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.followingTabButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];

        [self.followingTabButton setBackgroundColor: [UIColor dollyTabColorSelectedBackground]];
        
        [self.collectionsTabButton setTitleColor:[UIColor dollyTabColorSelectedText] forState:UIControlStateNormal];
        [self.collectionsTabButton setTitleColor:[UIColor dollyTabColorSelectedText] forState:UIControlStateHighlighted];

        [self.collectionsTabButton setBackgroundColor: [UIColor whiteColor]];
        
        
        __weak typeof(self) weakSelf = self;
        
        MKNKUserSuccessBlock successBlock = ^(NSDictionary *dictionary) {
            weakSelf.loadingMoreContent = NO;
            NSError *error = nil;
            
            [weakSelf.channelOwner setSubscriptionsDictionary: dictionary];
            [weakSelf.subscriptionThumbnailCollectionView reloadData];
            [weakSelf.channelOwner.managedObjectContext save: &error];
            [self.followingTabButton setTitle:[NSString stringWithFormat:@"%@ (%@)", NSLocalizedString(@"Following", nil), dictionary[@"channels"][@"total"]]forState:UIControlStateNormal];
            
        };
        
        // define success block //
        MKNKUserErrorBlock errorBlock = ^(NSDictionary *errorDictionary) {
            weakSelf.loadingMoreContent = NO;
            DebugLog(@"Update action failed");
        };
        //    Working load more videos for user channels
        
        NSRange range = NSMakeRange(0, 100);
        
        if (calls) {
            
            [appDelegate.oAuthNetworkEngine subscriptionsForUserId: weakSelf.channelOwner.uniqueId
                                                           inRange: range
                                                 completionHandler: successBlock
                                                      errorHandler: errorBlock];
        }
        
    }
}

#pragma mark - scroll view delegates

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
    //TODO:FIX AMOUNT NEEDED TO SCROLL
    //    if (decelerate)
    //    {
    //        [self moveNameLabelWithOffset:scrollView.contentOffset.y];
    //    }
    //
    //    if (self.channelThumbnailCollectionView == scrollView)
    //    {
    //        [self.subscriptionThumbnailCollectionView setContentOffset:scrollView.contentOffset];
    //    }
    //    if (self.subscriptionThumbnailCollectionView == scrollView)
    //    {
    //        [self.channelThumbnailCollectionView setContentOffset:scrollView.contentOffset];
    //    }
    
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [self moveNameLabelWithOffset:scrollView.contentOffset.y];
    
    
    //    if (self.channelThumbnailCollectionView == scrollView)
    //    {
    //        [self.subscriptionThumbnailCollectionView setContentOffset:scrollView.contentOffset];
    //    }
    //    if (self.subscriptionThumbnailCollectionView == scrollView)
    //    {
    //        [self.channelThumbnailCollectionView setContentOffset:scrollView.contentOffset];
    //    }
    
}


- (void) scrollViewDidScroll: (UIScrollView *) scrollView
{
    [super scrollViewDidScroll:scrollView];
    
    
    if (IS_IPAD) {
        if (self.channelThumbnailCollectionView == scrollView)
        {
            self.subscriptionThumbnailCollectionView.contentOffset = self.channelThumbnailCollectionView.contentOffset;
        }
        if (self.subscriptionThumbnailCollectionView == scrollView)
        {
            self.channelThumbnailCollectionView.contentOffset = self.subscriptionThumbnailCollectionView.contentOffset;
        }
    }
    else {
        // == setting the content off caused problems with the hiding and showing of tab bar, so set bounds instead.
        
        if (self.channelThumbnailCollectionView == scrollView)
        {
            self.subscriptionThumbnailCollectionView.bounds = self.channelThumbnailCollectionView.bounds;
        }
        if (self.subscriptionThumbnailCollectionView == scrollView)
        {
            self.channelThumbnailCollectionView.bounds = self.subscriptionThumbnailCollectionView.bounds;
        }
    }
    
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
    
    if (!IS_IPHONE)
    {
        if (self.orientationDesicionmaker && scrollView != self.orientationDesicionmaker)
        {
            scrollView.contentOffset = [self.orientationDesicionmaker contentOffset];
            return;
        }
    }
    
    [self moveViewsWithScroller:scrollView withOffset:offset];
    
}

- (void)stopCollectionScrollViews {
    
    [self stopScrollView:self.channelThumbnailCollectionView];
    [self stopScrollView:self.subscriptionThumbnailCollectionView];
}

-(void) stopScrollView: (UIScrollView*) scrollview {
    CGPoint offset = scrollview.contentOffset;
    offset.x -= 1.0;
    offset.y -= 1.0;
    [scrollview setContentOffset:offset animated:NO];
    offset.x += 1.0;
    offset.y += 1.0;
    [scrollview setContentOffset:offset animated:NO];
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
        
        if (IS_IPHONE) {
            
            CGAffineTransform move = CGAffineTransformMakeTranslation(0, -offset);
            self.profileImageView.transform = move;
            self.aboutMeTextView.transform = move;
            self.segmentedControlsView.transform = move;
            self.followAllButton.transform = move;
            self.moreButton.transform = move;
            self.followingSearchBar.transform = move;
            self.followersCountLabel.transform = move;
            self.uploadAvatarButton.transform = move;
            self.uploadCoverPhotoButton.transform = move;
            self.userNameLabel.transform = move;
            self.uploadAvatar.transform = move;

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
            self.uploadAvatar.transform = move;
            self.followersCountLabel.transform = move;
            self.followAllButton.transform = move;

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
    
    if (user) {
        _channelOwner = user;
        [self setUpUserProfile];
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
    
     // is a User has been passsed dont copy him OR his channels as there can be only one.
    if (!channelOwnerIsUser && user.uniqueId)
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
			
            if (_channelOwner)
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
    if (_channelOwner)
    {
        // isUserProfile set to YES for the current User
        self.isUserProfile = channelOwnerIsUser;
        
        
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(handleDataModelChange:)
                                                     name: NSManagedObjectContextDidSaveNotification
                                                   object: self.channelOwner.managedObjectContext];
        
        NSManagedObjectID *channelOwnerObjectId = self.channelOwner.objectID;
        NSManagedObjectContext *channelOwnerObjectMOC = self.channelOwner.managedObjectContext;
        
        __weak SYNProfileRootViewController *weakSelf = self;
        
        [appDelegate.oAuthNetworkEngine userDataForUser: ((User *) self.channelOwner)
                                           onCompletion: ^(id dictionary) {
                                               
                                               NSError *error = nil;
                                               ChannelOwner * channelOwnerFromId = (ChannelOwner *)[channelOwnerObjectMOC existingObjectWithID: channelOwnerObjectId
                                                                                                                                         error: &error];
                                               if (channelOwnerFromId)
                                               {
                                                   [channelOwnerFromId setAttributesFromDictionary: dictionary
                                                                               ignoringObjectTypes: kIgnoreVideoInstanceObjects | kIgnoreChannelOwnerObject];
                                                   
                                                   [weakSelf setUpUserProfile];
                                                   [weakSelf setUpImages];
                                                   [weakSelf reloadCollectionViews];
                                               }
                                               else
                                               {
                                                   DebugLog (@"Channel disappeared from underneath us");
                                               }
                                               
                                               
                                           } onError: nil];
        
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
    self.channelOwner.subscribedByUserValue = [SYNActivityManager.sharedInstance isSubscribedToUserId:self.channelOwner.uniqueId];
    self.userNameLabel.text = self.channelOwner.username;
    self.fullNameLabel.text = self.channelOwner.displayName;
    [self.aboutMeTextView setText:self.channelOwner.channelOwnerDescription];

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
	
	self.filteredSubscriptions = [self filteredSubscriptionsForSearchTerm:searchBar.text];
	
    [self.subscriptionThumbnailCollectionView reloadData];
}

- (NSArray *)filteredSubscriptionsForSearchTerm:(NSString *)searchTerm {
	if ([searchTerm length]) {
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"title BEGINSWITH[cd] %@", searchTerm];
		return [[self.channelOwner.subscriptions array] filteredArrayUsingPredicate:predicate];
	}
	return [self.channelOwner.subscriptions array];
}


- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)bar
{
    // boolean to check if the keyboard should show
    BOOL boolToReturn = self.shouldBeginEditing;
    self.searchMode = YES;
    
    [self stopCollectionScrollViews];
    
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

#pragma mark - textfield delegates

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


#pragma mark - Displayed Search

-(void) hideDescriptionCurrentlyShowing
{
    [self hideDescriptionForCollectioView:self.subscriptionThumbnailCollectionView];
    [self hideDescriptionForCollectioView:self.channelThumbnailCollectionView];
}

- (void) hideDescriptionForCollectioView:(UICollectionView*) cv {
    for (UICollectionViewCell *cell in [cv visibleCells]) {
        if ([cell isKindOfClass:[SYNChannelMidCell class]]) {
            if (((SYNChannelMidCell*)cell).state != ChannelMidCellStateAnimating) {
                [((SYNChannelMidCell*)cell) setState:ChannelMidCellStateDefault withAnimation:YES];
            }
        }
    }
}

- (NSString *) yesButtonTitle{
    return NSLocalizedString(@"Yes", @"Yes to alert view");
}
- (NSString *) noButtonTitle{
    return NSLocalizedString(@"No", @"No to alert view");
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *buttonTitle = [alertView buttonTitleAtIndex:buttonIndex];
	
	[[SYNTrackingManager sharedManager] trackUserCollectionsFollowFromScreenName:[self trackingScreenName]];
    
    //#warning change to server call
    if (alertView == self.followAllAlertView && [buttonTitle isEqualToString:[self yesButtonTitle]])
    {
        self.channelOwner.subscribedByUserValue = [SYNActivityManager.sharedInstance isSubscribedToUserId:self.channelOwner.uniqueId];
        self.followAllButton.dataItemLinked = self.channelOwner;
        [self followControlPressed:self.followAllButton];
    }
    
    if (alertView == self.deleteChannelAlertView && [buttonTitle isEqualToString:[self yesButtonTitle]])
    {
        [self deleteChannel:self.deleteCell];
    }
}



#pragma mark - IBActions

- (IBAction)changeCoverImageButtonTapped:(id)sender
{
	[[SYNTrackingManager sharedManager] trackCoverPhotoUpload];
    
    //302,167 is the values for the cropping, the cover photo dimensions is 907 x 502
    self.imagePickerControllerCoverphoto = [[SYNImagePickerController alloc] initWithHostViewController:self withCropSize:CGSizeMake(302,167)];
    self.imagePickerControllerCoverphoto.delegate = self;
    
    if (UIDeviceOrientationIsLandscape([[SYNDeviceManager sharedInstance] isLandscape])) {
        [self.imagePickerControllerCoverphoto presentImagePickerAsPopupFromView:sender arrowDirection:UIPopoverArrowDirectionAny];
    }
    else {
        
        [self.imagePickerControllerCoverphoto presentImagePickerAsPopupFromView:sender arrowDirection:UIPopoverArrowDirectionRight];
        
    }
    
}

- (IBAction)changeAvatarButtonTapped:(id)sender
{
	[[SYNTrackingManager sharedManager] trackAvatarUploadFromScreen:[self trackingScreenName]];
	
    self.imagePickerControllerAvatar = [[SYNImagePickerController alloc] initWithHostViewController:self withCropSize:CGSizeMake(280, 280)];
    
    self.imagePickerControllerAvatar.delegate = self;
    [self.imagePickerControllerAvatar presentImagePickerAsPopupFromView:sender arrowDirection:UIPopoverArrowDirectionRight];
    
}


- (IBAction)followAllTapped:(id)sender
{
    NSString *message;
    
    
    if (self.channelOwner.subscribedByUserValue) {
        self.followAllAlertView.title = @"Unfollow All?";
        message = @"Are you sure you want to unfollow all";
        message =  [message stringByAppendingString:@" "];
        message =  [message stringByAppendingString:self.channelOwner.displayName];
        message =  [message stringByAppendingString:@"'s collections"];
    } else {
        self.followAllAlertView.title = @"Follow All?";
        message = @"Are you sure you want to follow all";
        message =  [message stringByAppendingString:@" "];
        message =  [message stringByAppendingString:self.channelOwner.displayName];
        message =  [message stringByAppendingString:@"'s collections"];
        
    }
    
    
    [self.followAllAlertView setMessage:message];
    
    if(modeType == kModeOtherUsersProfile) {
        [self.followAllAlertView show];
    }
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

- (IBAction)editButtonTapped:(id)sender {
    
    [self.view addGestureRecognizer:self.tapToCancelEditMode];
    [[SYNTrackingManager sharedManager] trackEditProfileScreenView];
    
    [self stopCollectionScrollViews];
    self.channelThumbnailCollectionView.userInteractionEnabled = NO;
    [self.createChannelCell.descriptionTextView resignFirstResponder];
    [self.createChannelCell.createTextField resignFirstResponder];
	
	self.aboutMeTextView.userInteractionEnabled = YES;
    self.aboutMeTextView.editable = YES;
    self.modeType = kModeEditProfile;
    self.uploadAvatar.hidden =YES;
    self.uploadCoverPhotoButton.hidden = NO;
    self.uploadAvatarButton.hidden = NO;
    self.uploadCoverPhotoButton.alpha = 0.0f;
    self.uploadAvatarButton.alpha = 0.0f;
    
    CGRect tmpRect = self.aboutMeTextView.frame;
    if (IS_IPHONE) {
//        tmpRect.origin.y += 10;
//        tmpRect.size.height += 18;
    }
    

    self.subscriptionThumbnailCollectionView.scrollEnabled = NO;
    self.channelThumbnailCollectionView.scrollEnabled = NO;
    self.aboutMeTextView.editable = YES;
	
    self.barBtnBack = self.navigationItem.leftBarButtonItem;
    self.navigationItem.leftBarButtonItem = self.barBtnCancelEditMode;
    self.navigationItem.rightBarButtonItem = self.barBtnSaveEditMode;
    
    self.createChannelCell.createCellButton.userInteractionEnabled = NO;
    
    
    [UIView animateWithDuration:0.5f animations:^{
        
        self.coverImage.alpha = ALPHA_IN_EDIT;
        self.segmentedControlsView.alpha = ALPHA_IN_EDIT;
        self.channelThumbnailCollectionView.alpha = ALPHA_IN_EDIT;
        self.subscriptionThumbnailCollectionView.alpha = ALPHA_IN_EDIT;
        self.profileImageView.alpha = ALPHA_IN_EDIT;
        
        self.moreButton.alpha = 0.0f;
        self.followersCountLabel.alpha = 0.0f;
        
        
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
        
        if (IS_IPHONE) {
            if (!IS_IPHONE_5) {
                self.subscriptionThumbnailCollectionView.contentOffset = CGPointMake(0, 100);
                self.channelThumbnailCollectionView.contentOffset = CGPointMake(0, 100);
            } else {
                self.subscriptionThumbnailCollectionView.contentOffset = CGPointMake(0, 0);
                self.channelThumbnailCollectionView.contentOffset = CGPointMake(0, 0);

            }
        } else {
            self.subscriptionThumbnailCollectionView.contentOffset = CGPointMake(0, 0);
            self.channelThumbnailCollectionView.contentOffset = CGPointMake(0, 0);
        }
        
    }];
}
#pragma mark - Navigation item methods

//Navigation bar item cancel
-(void) cancelEditModeTapped
{
    
    self.uploadAvatar.hidden = NO;
    self.modeType = kModeMyOwnProfile;
    CGRect tmpRect = self.aboutMeTextView.frame;
    
    if (IS_IPHONE) {
//        tmpRect.origin.y -= 10;
//        tmpRect.size.height -= 18;
        
    }
    
    [self.view removeGestureRecognizer:self.tapToCancelEditMode];
    self.aboutMeTextView.editable = NO;
	self.aboutMeTextView.userInteractionEnabled = NO;
    
    self.channelThumbnailCollectionView.userInteractionEnabled = YES;

    self.createChannelCell.createCellButton.userInteractionEnabled = YES;

    
    self.aboutMeTextView.text = self.channelOwner.channelOwnerDescription;
    self.navigationItem.leftBarButtonItem = self.barBtnBack;
    self.navigationItem.rightBarButtonItem = nil;

    [UIView animateWithDuration:0.5f animations:^{
        
        self.coverImage.alpha = 1.0f;
        self.profileImageView.alpha = 1.0f;
        self.segmentedControlsView.alpha = 1.0f;
        self.moreButton.alpha = 1.0f;
        self.followersCountLabel.alpha = 1.0f;
        self.channelThumbnailCollectionView.alpha = 1.0f;
        self.subscriptionThumbnailCollectionView.alpha = 1.0f;
        
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
    
    [appDelegate.oAuthNetworkEngine createChannelForUserId: appDelegate.currentOAuth2Credentials.userId
                                                     title: self.createChannelCell.createTextField.text
                                               description: self.createChannelCell.descriptionTextView.text
                                                  category: @""
                                                     cover: @""
                                                  isPublic: YES
                                         completionHandler: ^(NSDictionary *resourceCreated) {
											 
											 NSString *name = [self.createChannelCell.createTextField.text uppercaseString];
											 [[SYNTrackingManager sharedManager] trackCollectionCreatedWithName:name];
                                             
                                             [self cancelCreateChannel];
                                             //takes 0.6f for the cancel animation to end
                                             
                                             //                                             if (IS_IPHONE) {
                                             [self performSelector:@selector(createNewCollection) withObject:nil afterDelay:0.6f];
                                             
                                             //                                             } else {
                                             //                                                 [self performSelector:@selector(updateChannelOwner) withObject:self afterDelay:0.6f];
                                             //                                             }
                                             
                                             
                                             if (IS_IPAD) {
                                                 [self performSelector:@selector(showInboardingAnimationAfterCreate) withObject:nil afterDelay:1.5f];
                                             }
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
                                                     [self.createChannelCell.createTextField becomeFirstResponder];
                                                 }
                                                 else if ([errorType isEqualToString: @"Mind your language!"])
                                                 {
                                                     errorTitle = NSLocalizedString(@"channel_creation_screen_error_inappropriate_dialog_title", nil);
                                                     errorMessage = NSLocalizedString(@"channel_creation_screen_error_inappropriate_dialog_description", nil);
                                                 }
                                             }
                                             
                                             
                                             [self	 showError: errorMessage
                                                                                showErrorTitle: errorTitle];
                                         }];
    
    
    
    
    
}

- (void) showError: (NSString *) errorMessage showErrorTitle: (NSString *) errorTitle
{
    
    [[[UIAlertView alloc] initWithTitle: errorTitle
                                message: errorMessage
                               delegate: nil
                      cancelButtonTitle: NSLocalizedString(@"OK", nil)
                      otherButtonTitles: nil] show];
}


- (void) createNewCollection {
    
    
    NSManagedObjectID *channelOwnerObjectId = self.channelOwner.objectID;
    NSManagedObjectContext *channelOwnerObjectMOC = self.channelOwner.managedObjectContext;
    MKNKUserErrorBlock errorBlock = ^(id error) {
        
    };

    __block float oldCount = self.channelOwner.channelsSet.count+1;
    

    
    [appDelegate.oAuthNetworkEngine userDataForUser: ((User *) self.channelOwner)
                                       onCompletion: ^(id dictionary) {
                                           NSError *error = nil;
                                           ChannelOwner * channelOwnerFromId = (ChannelOwner *)[channelOwnerObjectMOC existingObjectWithID: channelOwnerObjectId
                                                                                                                                     error: &error];
                                           
                                           
                                    
                                           if (channelOwnerFromId)
                                           {
                                               [channelOwnerFromId setAttributesFromDictionary: dictionary
                                                                           ignoringObjectTypes: kIgnoreVideoInstanceObjects | kIgnoreChannelOwnerObject];
                                               if (self.channelOwner.channelsSet.count+1 > oldCount) {
                                                   
                                                   
                                                   if (IS_IPAD) {
                                                       self.channelThumbnailCollectionView.contentSize = CGSizeMake(self.channelThumbnailCollectionView.contentSize.width, self.channelThumbnailCollectionView.contentSize.height*2);
                                                   }
                                                   
                                                   
                                                   
                                                   [self.channelThumbnailCollectionView performBatchUpdates:^{
                                                       
                                                       [self.channelThumbnailCollectionView insertItemsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForItem:2 inSection:0]]];
                                                   } completion:^(BOOL finished) {
                                                       CGPoint tmp = self.channelThumbnailCollectionView.contentOffset;
                                                       tmp.y+=1;
                                                       [self.channelThumbnailCollectionView setContentOffset:tmp animated:YES];
                                                       [self.channelThumbnailCollectionView sizeToFit];
                                                       
                                                   }];
                                                   
                                               }
                                           }
                                           else
                                           {
                                               DebugLog (@"Channel disappeared from underneath us");
                                           }
                                       } onError: errorBlock];
    
}

-(void) saveDescription
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
                                      
                                      successBlock();
                                      
                                      [[NSNotificationCenter defaultCenter]  postNotificationName: kUserDataChanged
                                                                                           object: self
                                                                                         userInfo: @{@"user": appDelegate.currentUser}];
                                      
                                  } errorHandler: ^(id errorInfo) {
                                      
                                      if (!errorInfo || ![errorInfo isKindOfClass: [NSDictionary class]])
                                      {
                                          return;
                                      }
                                      
                                      NSString *message = errorInfo[@"message"];
                                      
                                      if (message)
                                      {
                                          if ([message isKindOfClass: [NSArray class]])
                                          {
                                              NSLog(@"Error %@", message);
                                          }
                                          else if ([message isKindOfClass: [NSString class]])
                                          {
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
            
            int offset = OFFSET_DESCRIPTION_EDIT;
            
            if (!IS_IPHONE_5) {
                offset += 70;
            }
            
            self.subscriptionThumbnailCollectionView.contentOffset = CGPointMake(0, offset);
            self.channelThumbnailCollectionView.contentOffset = CGPointMake(0, offset);
            
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
    return (newLength > 100) ? NO : YES;
}

#pragma mark - dismiss keyboard

-(void)dismissKeyboard {
    [self.aboutMeTextView resignFirstResponder];
    [self.createChannelCell.descriptionTextView resignFirstResponder];
    [self.createChannelCell.createTextField resignFirstResponder];
    [self.view removeGestureRecognizer:self.tapToHideKeyoboard];
    
    if (self.modeType == kModeEditProfile) {
        [self resetOffsetWithAnimation];
    }
}

-(void) resetOffsetWithAnimation {
    [UIView animateWithDuration:0.3f animations:^{
        
        if (IS_IPHONE) {
            if (!IS_IPHONE_5) {
                self.subscriptionThumbnailCollectionView.contentOffset = CGPointMake(0, 100);
                self.channelThumbnailCollectionView.contentOffset = CGPointMake(0, 100);
            } else {
                self.subscriptionThumbnailCollectionView.contentOffset = CGPointMake(0, 0);
                self.channelThumbnailCollectionView.contentOffset = CGPointMake(0, 0);
            }
        } else {
            self.subscriptionThumbnailCollectionView.contentOffset = CGPointMake(0, 0);
            self.channelThumbnailCollectionView.contentOffset = CGPointMake(0, 0);
        }
    }];
    
}


- (void) picker: (SYNImagePickerController *) picker finishedWithImage: (UIImage *) image {
    
    if (picker == self.imagePickerControllerAvatar) {
        [appDelegate.oAuthNetworkEngine updateAvatarForUserId: appDelegate.currentOAuth2Credentials.userId
                                                        image: image
                                            completionHandler: ^(NSDictionary* result) {
			 [[SYNTrackingManager sharedManager] trackAvatarPhotoUploadCompleted];
             
             [self setProfileImage:result[@"thumbnail_url"]];
             [self cancelEditModeTapped];
             
         } errorHandler: ^(id error) {
             NSLog(@"updateProfileForUserId error: %@", error);
         }];
        self.imagePickerControllerAvatar = nil;
    } else {
        [appDelegate.oAuthNetworkEngine updateProfileCoverForUserId: appDelegate.currentOAuth2Credentials.userId
                                                              image: image
                                                  completionHandler: ^(NSDictionary* result)
         {
			 [[SYNTrackingManager sharedManager] trackCoverPhotoUploadCompleted];
             [self setCoverphotoImage:result[@"Location"]];
             [self cancelEditModeTapped];
         } errorHandler: ^(id error) {
             NSLog(@"updateProfileForUserId error: %@", error);
         }];
        
        self.imagePickerControllerCoverphoto = nil;
    }
}

-(void)createNewButtonPressed {
	[[SYNTrackingManager sharedManager] trackCreateChannelScreenView];

    self.creatingChannel = YES;
    
    
    //    if (!IS_IPHONE_5) {
    self.channelThumbnailCollectionView.scrollEnabled = NO;
    //    }

    for (SYNChannelMidCell* cell in self.channelThumbnailCollectionView.visibleCells) {
        NSIndexPath* indexPathForCell = [self.channelThumbnailCollectionView indexPathForCell:cell];
        
        
        __block int index = indexPathForCell.row;
        
        if (index == 0) {
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
            else {
                ((SYNChannelCreateNewCell*)cell).descriptionPlaceholderLabel.hidden = YES;
            }
        }
        void (^animateEditMode)(void) = ^{
            
            CGRect frame = cell.frame;
            
            if (index == 0) {
                
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
            else {
                if (IS_IPHONE) {
                    frame.origin.y += kHeightChange+18;
                }
                
                if (IS_IPAD) {
                    
                    if (UIDeviceOrientationIsPortrait([SYNDeviceManager.sharedInstance orientation])) {
                        if (index%2 == 0) {
                            frame.origin.y +=kHeightChange;
                        }
                    }
                    else {
                        if (index%3 == 0) {
                            frame.origin.y +=kHeightChange;
                        }
                    }
                }
            }
            
            cell.frame = frame;
            
            self.coverImage.alpha = ALPHA_IN_EDIT;

        };
        
        [UIView transitionWithView:cell
                          duration:0.4f
                           options: UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState
                        animations:animateEditMode
                        completion:^(BOOL finished) {
                            
                            
                        }];
        
        self.navigationItem.leftBarButtonItem = self.barBtnCancelCreateChannel;
        self.navigationItem.rightBarButtonItem = self.barBtnSaveCreateChannel;

        [UIView animateKeyframesWithDuration:0.2 delay:0.4 options:UIViewAnimationCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState animations:^{
            [self setCreateOffset];
            
        } completion:nil];
    }
    
    [self performSelector:@selector(updateCollectionLayout) withObject:self afterDelay:0.6f];
}

-(void) cancelCreateChannel {
    
    [self stopCollectionScrollViews];
    self.creatingChannel = NO;
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.rightBarButtonItem = nil;
    
//    if (IS_IPHONE_5) {
        self.channelThumbnailCollectionView.scrollEnabled = YES;
//    }
    
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
            
            if (index == 0) {
                ((SYNChannelCreateNewCell*)cell).createCellButton.alpha = 1.0f;
                ((SYNChannelCreateNewCell*)cell).descriptionTextView .alpha = 0.0f;
                ((SYNChannelCreateNewCell*)cell).state = CreateNewChannelCellStateHidden;
                CGRect tmpBoarder = ((SYNChannelCreateNewCell*)cell).boarderView.frame;
                if (IS_IPHONE) {
                    tmpBoarder.size.height = 61;
                } else {
                    tmpBoarder.size.height = 80;
                }
                ((SYNChannelCreateNewCell*)cell).boarderView.frame = tmpBoarder;
            } else {
                if (IS_IPHONE) {
                    frame.origin.y -= kHeightChange+18;
                }
                
                if (IS_IPAD) {
                    if (UIDeviceOrientationIsPortrait([SYNDeviceManager.sharedInstance orientation])) {
                        if (index%2 == 0) {
                            frame.origin.y -=kHeightChange;
                        }
                    }
                    else {
                        if (index%3 == 0) {
                            frame.origin.y -=kHeightChange;
                        }
                    }
                }
            }
            
            cell.frame = frame;
            self.coverImage.alpha = 1.0f;

        };
        
        __weak SYNProfileRootViewController* wself = self;

        [UIView transitionWithView:cell
                          duration:0.4f
                           options: UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState
                        animations:animateProfileMode
                        completion:^(BOOL finished) {
                            float time = 0.4;
                            
                            if (![[NSUserDefaults standardUserDefaults] boolForKey:kUserDefaultsCreateChannelFirstTime]) {
                                time= 6.8f;
                            }
                            if (IS_IPHONE) {
                                [wself performSelector:@selector(showInboardingAnimationAfterCreate) withObject:self afterDelay:1.4f];
                            }
                                [wself performSelector:@selector(scrollUpWithTime) withObject:self afterDelay:time];
                        }];
    }
    [self performSelector:@selector(updateCollectionLayout) withObject:self afterDelay:0.6f];
}

-(void) scrollUpWithTime{
    if (self.channelOwner.channelsSet.count<=3 && IS_IPHONE) {
        [UIView animateWithDuration:0.4 animations:^{
            [self.channelThumbnailCollectionView setContentOffset:CGPointMake(0, 0) animated:YES];
        }];
    }
}

-(void) setCreateOffset {
    if (UIDeviceOrientationIsPortrait([SYNDeviceManager.sharedInstance orientation])) {
        if (self.channelThumbnailCollectionView.contentOffset.y < 120) {
            [self.channelThumbnailCollectionView setContentOffset: CGPointMake(0, 414) animated:YES];
        }
    } else {
        if (self.channelThumbnailCollectionView.contentOffset.y < 370) {
            [self.channelThumbnailCollectionView setContentOffset: CGPointMake(0, 414) animated:YES];
        }
    }
    
    if (IS_IPHONE) {
        [self.channelThumbnailCollectionView setContentOffset: CGPointMake(0, 434) animated:YES];
    }
}


-(void) updateCollectionLayout {
    CGPoint tmpPoint = self.channelThumbnailCollectionView.contentOffset;
    
    if (IS_IPHONE) {
        if (self.channelThumbnailCollectionView.collectionViewLayout == self.channelLayoutIPhone) {
            [self.channelThumbnailCollectionView setCollectionViewLayout:self.channelExpandedLayout];
        } else {
            [self.channelThumbnailCollectionView setCollectionViewLayout:self.channelLayoutIPhone];
        }
    } else {
        if (self.channelThumbnailCollectionView.collectionViewLayout == self.channelLayoutIPad) {
            [self.channelThumbnailCollectionView setCollectionViewLayout:self.channelExpandedLayout];
        } else {
            [self.channelThumbnailCollectionView setCollectionViewLayout:self.channelLayoutIPad];
        }
    }
    
    self.channelThumbnailCollectionView.contentOffset = tmpPoint;
    [self.channelThumbnailCollectionView.collectionViewLayout invalidateLayout];
}

#pragma mark - Delete channel

-(void)deleteChannelTapped: (SYNChannelMidCell*) cell {
    
    self.deleteCell = cell;
    NSString *tmpString = [NSString stringWithFormat:@"%@ %@?",NSLocalizedString(@"Delete Collection", "Alerview confirm to delete a Channel"), cell.channel.title];
    
    [self.deleteChannelAlertView setTitle:tmpString];
    [self.deleteChannelAlertView show];
    
}

-(void) deleteChannel:(SYNChannelMidCell *)cell {
    ((SYNChannelMidCell*)cell).state = ChannelMidCellStateDefault;
    
    [appDelegate.oAuthNetworkEngine deleteChannelForUserId: appDelegate.currentUser.uniqueId
                                                 channelId: cell.channel.uniqueId
                                         completionHandler: ^(id response) {
                                             
                                             [self.channelThumbnailCollectionView performBatchUpdates:^{
                                                 [self.channelOwner.channelsSet removeObject:cell.channel];
                                                 
                                                 UIView *v = cell;
                                                 
                                                 self.indexPathToDelete = [self.channelThumbnailCollectionView indexPathForItemAtPoint: v.center];
                                                 
                                                 [self.channelThumbnailCollectionView deleteItemsAtIndexPaths:[NSArray arrayWithObject: self.indexPathToDelete]];
                                                 
                                                 [self updateChannelOwner];
                                             } completion:^(BOOL finished) {
                                                 [cell.channel.managedObjectContext deleteObject:cell.channel];
                                                 
                                                 CGPoint tmp = self.channelThumbnailCollectionView.contentOffset;
                                                 tmp.y+=1;
                                                 [self.channelThumbnailCollectionView setContentOffset:tmp animated:YES];
                                             }];
                                         } errorHandler: ^(id error) {
                                             DebugLog(@"Delete channel failed");
                                         }];
}

#pragma mark popover controller
- (void)popoverController:(UIPopoverController *)popoverController willRepositionPopoverToRect:(inout CGRect *)rect inView:(inout UIView **)view {
    
    if (popoverController == self.imagePickerControllerCoverphoto.cameraPopoverController) {
        CGRect tmpRect =self.uploadCoverPhotoButton.frame;
        *rect = tmpRect;
    }
    
    if (popoverController == self.imagePickerControllerAvatar.cameraPopoverController) {
        CGRect tmpRect =self.uploadAvatarButton.frame;
        *rect = tmpRect;
    }
}

- (NSString *)trackingScreenName {
	return @"Profile";
}


- (void) showInboardingAnimationAfterCreate {
    SYNChannelMidCell *cell;
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:kUserDefaultsCreateChannelFirstTime]) {
        
        if (modeType == kModeMyOwnProfile) {
            cell = ((SYNChannelMidCell*)[self.channelThumbnailCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:2 inSection:0]]);
            if (cell) {
                [cell descriptionAndDeleteAnimation];
            }
        } else {
            return;
        }
        
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kUserDefaultsCreateChannelFirstTime];
    }
}

- (void) showInboardingAnimationDescription{
    SYNChannelMidCell *cell;
    
    if (self.modeType == kModeOtherUsersProfile) {
        cell = ((SYNChannelMidCell*)[self.channelThumbnailCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]]);
        
        NSInteger value = [[NSUserDefaults standardUserDefaults] integerForKey: kUserDefaultsOtherPersonsProfile];
        if (value<2)
        {
            if (cell) {
            if (IS_IPHONE) {
                if (!IS_IPHONE_5) {
                    [self.channelThumbnailCollectionView setContentOffset:CGPointMake(0, 250) animated:YES];
                } else {
                    [self.channelThumbnailCollectionView setContentOffset:CGPointMake(0, 150) animated:YES];
                }
            }
            value+=1;
            [[NSUserDefaults standardUserDefaults] setInteger:value forKey:kUserDefaultsOtherPersonsProfile];

                [cell descriptionAnimation];
            }
        }
    }
    else if (self.modeType == kModeMyOwnProfile) {
        if (![[NSUserDefaults standardUserDefaults] boolForKey: kUserDefaultsYourProfileFirstTime]) {
            cell = ((SYNChannelMidCell*)[self.channelThumbnailCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:0]]);
            
            if (cell) {
                if (IS_IPHONE) {
                    if (!IS_IPHONE_5) {
                        [self.channelThumbnailCollectionView setContentOffset:CGPointMake(0, 250) animated:YES];
                    } else {
                        [self.channelThumbnailCollectionView setContentOffset:CGPointMake(0, 150) animated:YES];
                    }
                } 
                [cell descriptionAnimation];
            } else {
                NSLog(@"cell is nil");
            }
            
            [[NSUserDefaults standardUserDefaults] setBool: YES
                                                    forKey: kUserDefaultsYourProfileFirstTime];
        }
    }
}



@end
