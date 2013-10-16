//
//  AppContants.h
//  RockPack
//
//  Created by Nick Banks on 13/10/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#ifndef RockPack_AppContants_h
#define RockPack_AppContants_h

// User ratings mechanism

#define ENABLE_USER_RATINGS


// Use this to remove arc menus for cells
#define ENABLE_ARC_MENU

#define kAPIInitialBatchSize 48

//
// API
//

// Entities

#define kFeedItem                   @"FeedItem"
#define kChannel                    @"Channel"
#define kVideo                      @"Video"
#define kVideoInstance              @"VideoInstance"
#define kChannelOwner               @"ChannelOwner"
#define kUser                       @"User"
#define kCoverArt                   @"CoverArt"
#define kCoverImageReference        @"CoverImageReference"
#define kCoverArtImage              @"CoverArtImage"

#define kForceRefreshValue          @"kForceRefreshValue"
#define kAutoPlayVideoId            @"kAutoPlayVideoId"

#define kDataRequestRange           @"DataRequestRange"


// viewId
#define kFeedViewId                 NSLocalizedString(@"core_nav_section_feed", nil)
#define kChannelsViewId             NSLocalizedString(@"core_nav_section_channels", nil)
#define kProfileViewId              NSLocalizedString(@"core_nav_section_profile", nil)
#define kSearchViewId               @"Search"
#define kExistingChannelsViewId     @"ExistingChannels"
#define kChannelDetailsViewId       @"ChannelDetails"
#define kSideNavigationViewId       @"kSideNavigationViewId"
#define kSubscribersListViewId      @"kSubscribersListViewId"


#define kShareLinkForObjectObtained @"kShareLinkForObjectObtained"

// Feed

typedef enum : NSInteger {
    
    FeedItemTypeLeaf = 0,
    FeedItemTypeAggregate = 1
    
} FeedItemType;

typedef enum : NSInteger {
    
    FeedItemResourceTypeVideo = 0,
    FeedItemResourceTypeChannel = 1
    
} FeedItemResourceType;

// OAuth2
#define kAPIRefreshToken            @"/ws/token/"

// Login
#define kAPISecureLogin             @"/ws/login/"
#define kAPISecureExternalLogin     @"/ws/login/external/"
#define kAPISecureRegister          @"/ws/register/"
#define kAPIPasswordReset           @"/ws/reset-password/"                      /* POST */
#define kAPIUsernameAvailability    @"/ws/register/availability/"


#define kCoverArtChanged            @"kCoverArtChanged"
#define kCoverSetNoCover            @"kCoverSetNoCover"

#define kCaution                    @"kCaution"

// == Main WS API == //

// Search according to term, currently a wrapper around YouTube

#define kAPICompleteAll             @"/ws/complete/videos/"
#define kAPICompleteVideos          @"/ws/complete/videos/"
#define kAPICompleteChannels        @"/ws/complete/channels/"
#define kAPICompleteUsers           @"/ws/complete/channels/"

#define kAPISearchVideos            @"/ws/search/videos/"
#define kAPISearchChannels          @"/ws/search/channels/"
#define kAPISearchUsers             @"/ws/search/users/"

// User details
#define kAPIGetUserDetails          @"/ws/USERID/"                              /* GET */
#define kAPIChangeUserName          @"/ws/USERID/username/"                     /* PUT */
#define kAPIChangeuserPassword      @"/ws/USERID/password/"                     /* PUT */
#define kAPIChangeUserFields        @"/ws/USERID/ATTRIBUTE/"
#define kAPIGetUserNotifications    @"/ws/USERID/notifications/"                /* GET */

// Avatar
#define kAPIUpdateAvatar           @"/ws/USERID/avatar/"                        /* PUT */

// Channel manageent
#define kAPIGetChannelDetails       @"/ws/USERID/channels/CHANNELID/"           /* GET */
#define kAPICreateNewChannel        @"/ws/USERID/channels/"                     /* POST */
#define kAPIUpdateExistingChannel   @"/ws/USERID/channels/CHANNELID/"           /* PUT */
#define kAPIUpdateChannelPrivacy    @"/ws/USERID/channels/CHANNELID/public/"    /* PUT */
#define kAPIDeleteChannel           @"/ws/USERID/channels/CHANNELID/"           /* PUT */

#define STANDARD_REQUEST_LENGTH 48
#define MAXIMUM_REQUEST_LENGTH 1000

// Videos for channel
#define kAPIGetVideosForChannel     @"/ws/USERID/channels/CHANNELID/videos/"    /* GET */
#define kAPIUpdateVideosForChannel  @"/ws/USERID/channels/CHANNELID/videos/"    /* PUT */ /* POST */
#define kAPIGetVideoDetails         @"/ws/USERID/channels/CHANNELID/videos/INSTANCEID/"  /* GET */

#define kAPISubscribersForChannel   @"/ws/USERID/channels/CHANNELID/subscribers/" /* GET */

// User activity
#define kAPIRecordUserActivity      @"/ws/USERID/activity/"                     /* POST */
#define kAPIGetUserActivity         @"/ws/USERID/activity/"                     /* GET */

// Cover art
#define kAPIGetUserCoverArt         @"/ws/USERID/cover_art/"                    /* GET */
#define kAPIUploadUserCoverArt      @"/ws/USERID/cover_art/"                    /* POST */
#define kAPIDeleteUserCoverArt      @"/ws/USERID/cover_art/COVERID"             /* DELETE */

// User subscriptions
#define kAPIGetUserSubscriptions    @"/ws/USERID/subscriptions/"                /* GET */ 
#define kAPICreateUserSubscription  @"/ws/USERID/subscriptions/"                /* POST */
#define kAPIDeleteUserSubscription  @"/ws/USERID/subscriptions/SUBSCRIPTION/"   /* DELETE */  

// Subscription updates

#define kAPIUserSubscriptionUpdates @"/ws/USERID/subscriptions/recent_videos/"  /* GET */
#define kAPIContentFeedUpdates      @"/ws/USERID/content_feed/"
// Cover art
#define kAPIGetCoverArt             @"/ws/cover_art/"                           /* GET */

// Something
#define kAPIPopularVideos           @"ws/videos/"
#define kAPIPopularChannels         @"ws/channels/"
#define kAPIRecommendedChannels     @"/ws/USERID/channel_recommendations/"
#define kAPICategories              @"ws/categories/"

#define kLocationService            @"/ws/location/"                            /* GET */

// Share link
#define kAPIShareLink               @"/ws/share/link/"                          /* POST */
#define kAPIShareEmail              @"/ws/share/email/"                          /* POST */

// Report concerns

#define kAPIReportConcern           @"/ws/USERID/content_reports/"               /* POST */

// Player error
#define kAPIReportPlayerError       @"/ws/videos/player_error/"                 /* POST */



#define kAPIReportSession           @"/ws/session/"                             /* GET */


// HTML player source
#define kHTMLVideoPlayerSource      @"/ws/videos/players/"                      /* GET */

// Apple push notifications
#define kRegisterExternalAccount    @"/ws/USERID/external_accounts/"                      /* POST */
#define kGetExternalAccounts       @"/ws/USERID/external_accounts/"             /* GET */
#define kGetExternalAccountId       @"/ws/USERID/external_accounts/ACCOUNTID/"  /* GET */

// Set/Get Flags
#define kFlagsGetAll                @"/ws/USERID/flags/"                      /* GET */
#define kFlagsSet                   @"/ws/USERID/flags/FLAG/"                 /* PUT */ /* DELETE */

#define kAPIFriends                 @"/ws/USERID/friends/"  /* GET */

// Push notification
#define kAccountSettingsPressed     @"kAccountSettingsPressed"
#define kAccountSettingsLogout      @"kAccountSettingsLogout"
#define kUserDataChanged            @"kUserDataChanged"
#define kChannelSubscribeRequest    @"kChannelSubscribeRequest"
#define kChannelUpdateRequest       @"kChannelUpdateRequest"
#define kChannelOwnerUpdateRequest  @"kChannelOwnerUpdateRequest"
#define kChannelDeleteRequest       @"kChannelDeleteRequest"

#define kRefreshComplete            @"kRefreshComplete"

#define kUpdateFailed               @"kUpdateFailed"

#define kShowUserChannels           @"kShowUserChannels"

#define kImageSizeStringReplace     @"thumbnail_medium"

#define kMaxSuportedImageSize       3264

// Timeout for API calls

#define kAPIDefaultTimout 30

// API default batch size (we may need different ones for each API at some stage)
#define kDefaultBatchSize 20

// Savecontext

#define kSaveSynchronously TRUE
#define kSaveAsynchronously FALSE

// Placeholders

#define kNewChannelPlaceholderId @"NewChannelPlaceholderId"

// Notifications

#define kMainControlsChangeEnter @"kMainControlsChangeEnter"
#define kMainControlsChangeLeave @"kMainControlsChangeLeave"


// One the APIs imported some new data - we will need to be more specific at some stage.
#define kCategoriesUpdated @"kCategoriesUpdated"

#define kLoginOnBoardingMessagesNum 5
#define kInstruction1OnBoardingState @"kInstruction1OnBoardingState"
#define kInstruction2OnBoardingState @"kInstruction2OnBoardingState"

// Observers
#define kCollectionViewContentOffsetKey @"contentOffset"
#define kTextViewContentSizeKey @"contentSize"
#define kChannelUpdatedKey @"eCommerceURL"
#define kSubscribedByUserKey @"subscribedByUser"

// Settings

#define kDownloadedVideoContentBool @"kDownloadedVideoContentBool"

// Major functionality switches

// OAuth Username and Password

#define kOAuth2ClientId @"c8fe5f6rock873dpack19Q"

// Enable full screen thumbnail view 
#define FULL_SCREEN_THUMBNAILS__


typedef enum : NSInteger {
    
    GenderMale = 0,
    GenderFemale = 1,
    GenderUndecided = 2 // how post-modern
    
} Gender;

typedef enum : NSInteger {
    
    NavigationButtonsAppearanceBlack = 0,
    NavigationButtonsAppearanceWhite = 1,
    
} NavigationButtonsAppearance;


typedef enum : NSInteger {
    kArcMenuInvalidComponentIndex = 999999
} kArcMenuComponentIndex;

//
// Colours
//

// Highlighted RockIt number text colour
#define kHighlightedStarTextColour [UIColor colorWithRed: 0.894f green: 0.945f blue: 0.965f alpha: 1.0f]

// Default
#define kDefaultStarTextColour

//
// Animations
//

#define kArcMenuStartButtonTag 456

// Text cross-fade
#define kTextCrossfadeDuration 0.3f

// Switch label
#define kSwitchLabelAnimation 0.25f

// Splash screen
#define kSplashViewDuration 2.0f
#define kSplashAnimationDuration  0.75f

// Edit mode
#define kChannelEditModeAnimationDuration 0.4f

// Tabs
#define kTabAnimationDuration 0.3f


#define kChangedAccountSettingsValue        @"kChangedAccountSettingsValue"
#define kClearedLocationBoundData           @"kClearedLocationBoundData"

// Rockie-talkie
#define kRockieTalkieAnimationDuration 0.3f

// Image well
#define kVideoQueueAnimationDuration 0.3f
#define kVideoQueueOnScreenDuration 10.0f
//#define kVideoQueueOnScreenDuration 10000.0f

// Large Video panel
#define kLargeVideoPanelAnimationDuration 0.3f

// Camera preview animation
#define kCameraPreviewAnimationDuration 0.3f

// Large Video panel
#define kCreateChannelPanelAnimationDuration 0.3f

#define kVideoInAnimationDuration 0.3f
#define kVideoOutAnimationDuration 0.3f
#define kAddToChannelAnimationDuration 0.3f

//
// Dimensions
//

#define kiOS7PlusHeaderYOffset 10.0f

#define kRotateThresholdX 100
#define kRotateThresholdY 180
#define kRotateBorderX 25
#define kRotateBorderY 25

#define kLoadMoreFooterViewHeight   50.0f

#define kMinorDimension 768.0f
#define kMajorDimension 1024.0f
#define kStatusBarHeight 20.0f

#define kFullScreenHeightPortrait kMajorDimension
#define kFullScreenHeightPortraitMinusStatusBar (kFullScreenHeightPortrait - kStatusBarHeight)
#define kFullScreenWidthPortrait kMinorDimension

#define kFullScreenHeightLandscape kMinorDimension
#define kFullScreenHeightLandscapeMinusStatusBar (kFullScreenHeightLandscape - kStatusBarHeight)
#define kFullScreenWidthLandscape kMajorDimension

#define kStandardCollectionViewOffsetY 90.0f
#define kStandardCollectionViewOffsetYiPhone 60.0f
#define kYouCollectionViewOffsetY 160.0f
#define kChannelDetailsCollectionViewOffsetY 500.0f
#define kChannelDetailsFadeSpan 250.0f
#define kChannelDetailsFadeSpaniPhone 135.0f

#define kImageUploadWidth 1024
#define kImageUploadHeight 768

// Effective height (exlcuding shadow) of the image well
//#define kVideoQueueEffectiveHeight 99

#define kVideoQueueWidth 490
//#define kVideoQueueWidth 475
#define kVideoQueueOffsetX 10

#define kVideoQueueAdd              @"kVideoQueueAdd"
#define kVideoQueueRemove           @"kVideoQueueRemove"
#define kVideoQueueClear            @"kVideoQueueClear"


#define kScrollerPageChanged        @"kScrollerPageChanged"

#define kNavigateToPage       @"kNavigateToPage"

#define kNoteCreateButtonRequested       @"kNoteCreateButtonRequested"

#define kSearchTyped      @"kSearchTyped"
#define kSearchTerm      @"kSearchTerm"

#define kCurrentPage        @"kCurrentPage"

// UserDefaults
#define kUserDefaultsNotFirstInstall @"UD_Not_First_Install"
#define kUserDefaultsSubscribe @"UD_OnBoaring_Subscribe"
#define kUserDefaultsAddVideo @"UD_OnBoaring_AddVideo"
#define kUserDefaultsFriendsTab @"UD_OnBoaring_FriendsTab"
#define kUserDefaultsChannels @"UD_OnBoaring_Channels"
#define kUserDefaultsFeed @"UD_OnBoaring_Feed"

//Login Origin

#define kOriginFacebook @"Facebook"
#define kOriginRockpack @"Rockpack"

// Accounts

#define kFacebook @"facebook"
#define kEmail @"email"
#define kRockpack @"rockpack"
#define kTwitter @"twitter"
#define kGooglePlus @"google"
#define kAPNS   @"apns"
#define kAddressBook @"AddressBook"

typedef enum : NSInteger {
    LoginOriginRockpack = 0,
    LoginOriginFacebook = 1
    
} LoginOrigin;

#define kLoginCompleted @"kLoginCompleted"

typedef enum : NSInteger {
    EntityTypeAny = 0,
    EntityTypeChannel,
    EntityTypeVideo,
    EntityTypeVideoInstance,
    EntityTypeUser,
    EntityTypeCategory
    
} EntityType;

typedef enum : NSInteger {
    ScrollingDirectionNone = 0,
    ScrollingDirectionLeft,
    ScrollingDirectionRight,
} ScrollingDirection;

typedef enum : NSInteger {
    PointingDirectionNone = 0,
    PointingDirectionUp,
    PointingDirectionDown,
    PointingDirectionLeft,
    PointingDirectionRight
} PointingDirection;




// Height of the bottom tab bar in pixels
#define kBottomTabBarHeight 62

// Height of the header bar
#define kHeaderBarHeight 44

// Height of the top tab bar
#define kTopTabBarHeight 45

// Offset from the bottom of the status bar to the bottom of the top tab bar
#define kTabTopContentOffset (kHeaderBarHeight + kTopTabBarHeight)

// Amount of overspill for top tab bar
#define kTopTabOverspill 7

#define kCategorySecondRowHeight 35.0f

//
// Tabs
//

// Used to work out what button is pressed on the bottom tab
#define kBottomTabIndexOffset 100

#define kTopTabCount 10

#define kSearchBarItemWidth 100.0
//
// Video Overlay
//

// Maximum number of times the player time remains the same before restart attempted
#define kMaxStallCount                  20

// Number of seconds we wait before reporting a video problem
#define kVideoStallThresholdTime        20

// Time between shuttle bar updates
#define kShuttleBarUpdateTimerInterval  0.1f

// How long for the placeholder animations to cycle
#define kMiddlePlaceholderCycleTime     2.0f
#define kBottomPlaceholderCycleTime     4.0f
#define kMiddlePlaceholderIdentifier    @"MiddlePlaceholder"

#define kBottomPlaceholderIdentifier    @"BottomPlaceholder"

#define kVideoBackgroundColour          [UIColor blackColor]

#define kShuttleBarHeight               44.0f
#define kShuttleBarTimeLabelWidth       40.0f
#define kShuttleBarButtonWidthiPad      77.0f
#define kShuttleBarButtonWidthiPhone    77.0f
#define kShuttleBarButtonOffsetiPhone   67.0f
#define kShuttleBarSliderOffset         5.0f

#define kSYNBundleFullVersion           @"FullVersion"
#define kSYNBundleBuildTarget           @"BuildTarget"

// Channel creation

#define kChannelCreationCollectionViewOffsetY           500.0f
#define kChannelCreationCategoryTabOffsetY              444.0f
#define kChannelCreationCategoryAdditionalOffsetY       51.0f

// Notifications

#define kNotePushingController      @"kNotePushingController"

#define kNoteBackButtonShow         @"kNoteBackButtonShow"
#define kNoteBackButtonHide         @"kNoteBackButtonHide"

#define kNoteTopRightControlsShow   @"kNoteTopRightControlsShow"
#define kNoteTopRightControlsHide   @"kNoteTopRightControlsHide"

#define kNoteAllNavControlsShow     @"kNoteAllNavControlsShow"
#define kNoteAllNavControlsHide     @"kNoteAllNavControlsHide"
#define kNoteHideTitleAndDots       @"kNoteAllHideTitleAndDots"

#define kChannelsNavControlsHide    @"kChannelsNavControlsHide"

#define kNoteStarButtonPressed      @"kNoteStarButtonPressed"
#define kNoteAddToChannelRequest    @"kNoteAddToChannelRequest"


#define kNoteVideoAddedToExistingChannel         @"kNoteAddedToChannel"
#define kNoteCreateNewChannel                    @"kNoteCreateNewChannel"

#define kNotificationMarkedRead     @"kNotificationMarkedRead"

#define kProfileRequested           @"kProfileRequested"
#define kVideoOverlayRequested      @"kVideoOverlayRequested"
#define kHideSideNavigationView     @"kHideSideNavigationView"

#define kNoteChannelSaved           @"kNoteChannelSaved"
#define kNoteSavingCaution          @"kNoteSavingCaution"
#define kNoteHideAllCautions          @"kNoteHideAllCautions"

#define kNoteHideNetworkMessages    @"kNoteHideNetworkMessages"
#define kNoteShowNetworkMessages    @"kNoteShowNetworkMessages"
#define kNotePopCurrentViewController  @"kNotePopCurrentViewController"

//
// Tracking
//

// TestFlight support
#define  kTestFlightAppToken @"350faab3-e77f-4954-aa44-b85dba25d029"


// Block Definitions
typedef void (^JSONResponseBlock)(id jsonObject);

// Video view threshold
#define kPercentageThresholdForView 0.1f

// Google Analytics
#ifdef DEBUG
// Id to use for debug
#define kGoogleAnalyticsId @"UA-39188851-3"
#else
// Id to use for production
#define kGoogleAnalyticsId @"UA-38220268-4"
#endif

// Custom GA Dimensions

#define kGADimensionAge         1
#define kGADimensionCategory    2
#define kGADimensionGender      3
#define kGADimensionLocale      4

// Sharing messages

#define kChannelShareMessage NSLocalizedString (@"Take a look at this great channel I found on Rockpack", nil)
#define kVideoShareMessage NSLocalizedString (@"Take a look at this great video I found on Rockpack", nil)

// Gestures

#define ALLOWS_PINCH_GESTURES__

// UICollectionView reload strategy

#define SMART_RELOAD__

// Do we display the video provider branding

#define SHOW_BRANDING 

#endif

//User token refresh error

#define kUserIdInconsistencyError @"UserIdInconsistency"
#define kStoredRefreshTokenNilError @"StoredRefreshTokenNil"

#define kActionNone @""
#define kActionShareVideo @"ActionShareVideo"
#define kActionShareChannel @"ActionShareChannel"
#define kActionLike @"ActionLike"
#define kActionAdd @"ActionAdd"
