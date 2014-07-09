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

#define APP_ID @"824769819"

//
// API
//

// Entities

#define kFeedItem                   @"FeedItem"
#define kChannel                    @"Channel"
#define kVideo                      @"Video"
#define kVideoInstance              @"VideoInstance"
#define kChannelOwner               @"ChannelOwner"

// viewId
#define kFeedViewId                 @"MY FEED"
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

#define kShareLinkForObjectObtained @"kShareLinkForObjectObtained"

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
#define kAPIUsers                   @"/ws/users/"

// User details
#define kAPIGetUserDetails          @"/ws/USERID/"                              /* GET */
#define kAPIChangeUserName          @"/ws/USERID/username/"                     /* PUT */
#define kAPIChangeuserPassword      @"/ws/USERID/password/"                     /* PUT */
#define kAPIChangeUserFields        @"/ws/USERID/ATTRIBUTE/"
#define kAPIGetUserNotifications    @"/ws/USERID/notifications/"                /* GET */
#define kAPIGetUserVideos        	@"/ws/USERID/videos/"						/* GET */

// Avatar
#define kAPIUpdateAvatar           @"/ws/USERID/avatar/"                        /* PUT */

#define kAPIUpdateProfileCover     @"ws/USERID/profile_cover/"                  /* PUT */

// Channel manageent
#define kAPIGetChannelDetails       @"/ws/USERID/channels/CHANNELID/"           /* GET */
#define kAPIGetUserChannel        @"/ws/USERID/"								/* GET */
#define kAPICreateNewChannel        @"/ws/USERID/channels/"                     /* POST */
#define kAPIUpdateExistingChannel   @"/ws/USERID/channels/CHANNELID/"           /* PUT */
#define kAPIUpdateChannelPrivacy    @"/ws/USERID/channels/CHANNELID/public/"    /* PUT */
#define kAPIDeleteChannel           @"/ws/USERID/channels/CHANNELID/"           /* PUT */

#define STANDARD_REQUEST_LENGTH 40
#define MAXIMUM_REQUEST_LENGTH 1000

#define kURLTermsAndConditions @"http://wonderpl.com/tos"
#define kURLPrivacy @"http://wonderpl.com/privacy"

// Videos for channel
#define kAPIGetVideosForChannel     @"/ws/USERID/channels/CHANNELID/videos/"    /* GET */
#define kAPIUpdateVideosForChannel  @"/ws/USERID/channels/CHANNELID/videos/"    /* PUT */ /* POST */
#define kAPIGetVideoDetails         @"/ws/USERID/channels/CHANNELID/videos/INSTANCEID/"  /* GET */

#define kAPISubscribersForChannel   @"/ws/USERID/channels/CHANNELID/subscribers/" /* GET */

// User activity
#define kAPIRecordUserActivity      @"/ws/USERID/activity/"                     /* POST */
#define kAPIGetUserActivity         @"/ws/USERID/activity/"                     /* GET */

// User subscriptions
#define kAPIGetUserSubscriptions    @"/ws/USERID/subscriptions/users/"			/* GET */
#define kAPICreateUserSubscription  @"/ws/USERID/subscriptions/"                /* POST */
#define kAPIDeleteUserSubscription  @"/ws/USERID/subscriptions/SUBSCRIPTION/"   /* DELETE */

// Subscription updates

#define kAPIUserSubscriptionUpdates @"/ws/USERID/subscriptions/recent_videos/"  /* GET */
#define kAPIContentFeedUpdates      @"/ws/USERID/content_feed/"

// Something
#define kAPIVideos                  @"/ws/videos/"                              /* GET */
#define kAPIRecommendedChannels     @"/ws/USERID/channel_recommendations/"
#define kAPICategories              @"ws/categories/"

// Video info
#define kAPIVideoLikes				@"/ws/videos/VIDEOID/starring_users/"		/* GET */
#define kAPIVideoChannels			@"/ws/videos/VIDEOID/channels/"				/* GET */

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
#define kAccountSettingsLogout      @"kAccountSettingsLogout"
#define kUserDataChanged            @"kUserDataChanged"
#define kChannelUpdateRequest       @"kChannelUpdateRequest"
#define kChannelOwnerUpdateRequest  @"kChannelOwnerUpdateRequest"


#define kUpdateFailed               @"kUpdateFailed"

#define kImageSizeStringReplace     @"thumbnail_medium"

#define kMaxSuportedImageSize       3264


#define kScrollingDirection         @"kScrollingDirection"

// Timeout for API calls

#define kAPIDefaultTimout 30

// Savecontext

#define kSaveSynchronously TRUE
#define kSaveAsynchronously FALSE

// Placeholders

#define kNewChannelPlaceholderId @"NewChannelPlaceholderId"

// Notifications

#define kScrollMovement @"kScrollMovement"
#define kHideAllDesciptions @"kHideAllDesciptions"
#define kReloadFeed @"kReloadFeed"

#define kLoginOnBoardingMessagesNum 5

// Observers
#define kTextViewContentSizeKey @"contentSize"

// OAuth Username and Password

#define kOAuth2ClientId @"c8fe5f6rock873dpack19Q"


typedef enum : NSInteger {
    
    GenderMale = 0,
    GenderFemale = 1,
    GenderUndecided = 2 // how post-modern
    
} Gender;

//
// Animations
//

// Text cross-fade
#define kTextCrossfadeDuration 0.3f

// Edit mode
#define kChannelEditModeAnimationDuration 0.4f

#define kClearedLocationBoundData           @"kClearedLocationBoundData"

//
// Dimensions
//

#define kLoadMoreFooterViewHeight   50.0f

#define kVideoQueueAdd              @"kVideoQueueAdd"
#define kVideoQueueRemove           @"kVideoQueueRemove"
#define kVideoQueueClear            @"kVideoQueueClear"

static NSString* kPopularGenreName = @"ALL";
static NSString* kPopularGenreUniqueId = @"1979";





// UserDefaults
#define kUserDefaultsNotFirstInstall @"UD_Not_First_Install"
#define kUserDefaultsDiscoverVideoFirstTime @"UD_Discover_Video_First_Time"
#define kUserDefaultsDiscoverUserFirstTime @"UD_Discover_User_First_Time"
#define kUserDefaultsDiscoverSearchFirstTime @"UD_Discover_Search_First_Time"
#define kUserDefaultsYourProfileFirstTime @"UD_Your_Profile_First_Time"
#define kUserDefaultsCreateChannelFirstTime @"UD_Create_Channel_First_Time"
#define kUserDefaultsOtherPersonsProfile @"UD_Other_Persons_Profile"
#define kUserDefaultsSharingAlert @"UD_Sharing_Alert_Count"
#define kUserDefaultsRecentlyViewed @"UD_Recently_Viewed"
#define kUserDefaultsFeedCount @"UD_Feed_Count"
#define kUserDefaultsShareFirstTime @"UD_Share_First_Time"
#define kUserDefaultsAddToCollectionFirstTime @"UD_Add_To_Collection_First_Time"
#define kUserDefaultsShopMotionFirstTime @"UD_Shop_Motion_First_Time"
#define kUserDefaultsDiagnosticLogging @"UD_Diagnostic_Logging"
#define kUserDefaultsVideoPlayerFirstTime @"UD_Video_Player_First_Time"


//Login Origin

#define kOriginFacebook @"Facebook"
#define kOriginWonderPL @"WonderPL"
#define kOriginTwitter @"Twitter"

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
    LoginOriginFacebook = 1,
    LoginOriginTwitter = 2

} LoginOrigin;

#define kLoginCompleted @"kLoginCompleted"
#define kOnboardingCompleted @"kOnboardingCompleted"

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

typedef enum : NSInteger {
    kModeMyOwnProfile = 0,
    kModeOtherUsersProfile,
    kModeEditProfile,
} ProfileType;

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

#define CategoriesReloadedNotification @"CategoriesReloadedNotification"

#define kNoteChannelSaved           @"kNoteChannelSaved"
#define kNoteHideAllCautions          @"kNoteHideAllCautions"

#define kNoteHideNetworkMessages    @"kNoteHideNetworkMessages"
#define kNoteShowNetworkMessages    @"kNoteShowNetworkMessages"

//
// Tracking
//

// TestFlight support
#define  kTestFlightAppToken @"c051d2e5-ef68-4bda-b71c-86393cba33f2"

// Google Analytics
#ifdef DEBUG
// Id to use for debug
#define kGoogleAnalyticsId @"UA-46534300-1"
#else
// Id to use for production
#define kGoogleAnalyticsId @"UA-46520786-1"
#endif

// Sharing messages

#endif

//User token refresh error

#define kUserIdInconsistencyError @"UserIdInconsistency"
#define kStoredRefreshTokenNilError @"StoredRefreshTokenNil"
