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


#define kAPIInitialBatchSize 48

//
// API
//

// Entities

#define kGenre                      @"Genre"
#define kSubGenre                   @"SubGenre"
#define kComment                    @"Comment"
#define kFeedItem                   @"FeedItem"
#define kChannel                    @"Channel"
#define kRecommendation             @"Recomendation"
#define kVideo                      @"Video"
#define kVideoInstance              @"VideoInstance"
#define kChannelOwner               @"ChannelOwner"
#define kUser                       @"User"

// viewId
#define kFeedViewId                 @"FEED"
#define kChannelsViewId             @"PACKS"
#define kCommentsViewId             @"COMMENTS"
#define kProfileViewId              @"ME"
#define kSearchViewId               @"SEARCH"
#define kDiscoverViewId             @"DISCOVER"
#define kExistingChannelsViewId     @"EXISTING CHANNELS"
#define kChannelDetailsViewId       @"CHANNEL DETAILS"
#define kSideNavigationViewId       @"SIDE NAVIGATION"
#define kSubscribersListViewId      @"SUBSCRIBERS"
#define kFriendsViewId              @"My Friends"
#define kActivityViewId             @"ACTIVITY"
#define kMoodViewId                 @"MOOD-MINDER"

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
#define kAPIGetUserChannel        @"/ws/USERID/channels/"                       /* GET */
#define kAPICreateNewChannel        @"/ws/USERID/channels/"                     /* POST */
#define kAPIUpdateExistingChannel   @"/ws/USERID/channels/CHANNELID/"           /* PUT */
#define kAPIUpdateChannelPrivacy    @"/ws/USERID/channels/CHANNELID/public/"    /* PUT */
#define kAPIDeleteChannel           @"/ws/USERID/channels/CHANNELID/"           /* PUT */

#define STANDARD_REQUEST_LENGTH 48
#define MAXIMUM_REQUEST_LENGTH 1000

#define kURLTermsAndConditions @"http://rockpack.com/tos"
#define kURLPrivacy @"http://rockpack.com/privacy"

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
#define kAPIVideos                  @"/ws/videos/"                              /* GET */
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


// Moods
#define kGetMoods                   @"/ws/moods/"                               /* GET */


// HTML player source
#define kHTMLVideoPlayerSource      @"/ws/videos/players/"                      /* GET */

// Apple push notifications
#define kRegisterExternalAccount    @"/ws/USERID/external_accounts/"            /* POST */
#define kGetExternalAccounts        @"/ws/USERID/external_accounts/"             /* GET */
#define kGetExternalAccountId       @"/ws/USERID/external_accounts/ACCOUNTID/"  /* GET */

#define kGetUserRecommendations     @"/ws/USERID/user_recommendations/"         /* GET */


#define kAPIComments                @"/ws/USERID/channels/CHANNELID/videos/VIDEOINSTANCEID/comments/"    /* GET */

#define kGetVideoRecommendations    @"/ws/USERID/video_recommendations/"         /* GET */
#define kGetChannelRecommendations  @"/ws/USERID/channel_recommendations/"       /* GET */

#define kFeedbackUrl                @"/ws/feedback/"                            /* GET */

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
#define kChannelOwnerSubscribeToUserRequest @"kChannelOwnerSubscribeToUserRequest"



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
#define kScrollMovement @"kScrollMovement"
#define kHideAllDesciptions @"kHideAllDesciptions"


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

//
// Colours
//

// Highlighted RockIt number text colour
#define kHighlightedStarTextColour [UIColor colorWithRed: 0.894f green: 0.945f blue: 0.965f alpha: 1.0f]

//
// Animations
//

// Text cross-fade
#define kTextCrossfadeDuration 0.3f

// Edit mode
#define kChannelEditModeAnimationDuration 0.4f

#define kClearedLocationBoundData           @"kClearedLocationBoundData"

#define kVideoInAnimationDuration 0.3f

//
// Dimensions
//

#define kLoadMoreFooterViewHeight   50.0f

#define kVideoQueueAdd              @"kVideoQueueAdd"
#define kVideoQueueRemove           @"kVideoQueueRemove"
#define kVideoQueueClear            @"kVideoQueueClear"

static NSString* kPopularGenreName = @"POPULAR";
static NSString* kPopularGenreUniqueId = @"1979";





// UserDefaults
#define kUserDefaultsNotFirstInstall @"UD_Not_First_Install"
#define kUserDefaultsSubscribe @"UD_OnBoaring_Subscribe"
#define kUserDefaultsAddVideo @"UD_OnBoaring_AddVideo"
#define kUserDefaultsFriendsTab @"UD_OnBoaring_FriendsTab"
#define kUserDefaultsChannels @"UD_OnBoaring_Channels"
#define kUserDefaultsFeed @"UD_OnBoaring_Feed"
#define kUserDefaultsSeenOnBoarding @"UD_Seen_On_Boarding"

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
    ScrollingDirectionUp,
    ScrollingDirectionDown,
} ScrollingDirection;

typedef enum : NSInteger {
    PointingDirectionNone = 0,
    PointingDirectionUp,
    PointingDirectionDown,
    PointingDirectionLeft,
    PointingDirectionRight
} PointingDirection;

typedef enum : NSInteger
{
    kChannelDetailsModeDisplay = 0,
    kChannelDetailsModeEdit = 1,
    kChannelDetailsModeCreate = 2,
    kChannelDetailsModeDisplayUser = 3,
    kChannelDetailsFavourites = 4
} kChannelDetailsMode;

typedef enum {
    
    CreateNewChannelCellStateHidden = 0,
    CreateNewChannelCellStateEditing = 1,
    CreateNewChannelCellStateFinilizing = 2
    
} CreateNewChannelCellState;


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
//
// Video Overlay
//

// Maximum number of times the player time remains the same before restart attempted
#define kMaxStallCount                  20

// Number of seconds we wait before reporting a video problem
#define kVideoStallThresholdTime        20

// Time between shuttle bar updates
#define kShuttleBarUpdateTimerInterval  0.1f

#define kVideoBackgroundColour          [UIColor blackColor]

#define kShuttleBarHeight               44.0f
#define kShuttleBarTimeLabelWidth       40.0f
#define kShuttleBarButtonWidthiPad      77.0f
#define kShuttleBarButtonWidthiPhone    77.0f
#define kShuttleBarButtonOffsetiPhone   67.0f
#define kShuttleBarSliderOffset         5.0f

// Notifications

#define kNoteVideoAddedToExistingChannel         @"kNoteAddedToChannel"

#define kNoteChannelSaved           @"kNoteChannelSaved"
#define kNoteHideAllCautions          @"kNoteHideAllCautions"

#define kNoteHideNetworkMessages    @"kNoteHideNetworkMessages"
#define kNoteShowNetworkMessages    @"kNoteShowNetworkMessages"

//
// Tracking
//

// TestFlight support
#define  kTestFlightAppToken @"350faab3-e77f-4954-aa44-b85dba25d029"

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

#endif

//User token refresh error

#define kUserIdInconsistencyError @"UserIdInconsistency"
#define kStoredRefreshTokenNilError @"StoredRefreshTokenNil"
