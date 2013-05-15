//
//  AppContants.h
//  RockPack
//
//  Created by Nick Banks on 13/10/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#ifndef RockPack_AppContants_h
#define RockPack_AppContants_h


//
// API
//

// Returns a list of all the recently added videos associated with a user's subscribed channels (the %@ represents the USERID)
#define kAPIRecentlyAddedVideoInSubscribedChannelsForUser @"ws/%@/subscriptions/recent_videos/"

// Main RestFul API
// Entities

#define kChannel                    @"Channel"
#define kVideo                      @"Video"
#define kVideoInstance              @"VideoInstance"
#define kChannelOwner               @"ChannelOwner"
#define kUser                       @"User"
#define kCoverArt                   @"CoverArt"

// OAuth2

#define kFeedViewId                 @"Home"
#define kChannelsViewId             @"Channels"
#define kProfileViewId              @"You"
#define kSearchViewId               @"Search"
#define kUserChanneslViewId         @"UserChannels"
#define kExistingChannelsViewId     @"ExistingChannels"
#define kChannelDetailsViewId       @"ChannelDetails"
#define kCoverArtViewId             @"CoverArt"
#define kUserCoverArtViewId         @"UserCoverArt"

#define kFeedTitle                  @"Feed"
#define kChannelsTitle              @"Channels"
#define kProfileTitle               @"Profile"
#define kSearchTitle                @"Search"
#define kUserChanneslTitle          @"UserChannels"
#define kChannelDetailsTitle        @"ChannelDetails"

#define kAPIRefreshToken            @"/ws/token"

// Login
#define kAPISecureLogin             @"/ws/login/"
#define kAPISecureExternalLogin     @"/ws/login/external/"
#define kAPISecureRegister          @"/ws/register/"
#define kAPIPasswordReset           @"/ws/reset-password/"                      /* POST */


#define kCoverArtChanged            @"kCoverArtChanged"


// Search according to term, currently a wrapper around YouTube
#define kAPISearchVideos            @"/ws/search/videos/"
#define kAPICompleteVideos          @"/ws/complete/videos/"
#define kAPISearchChannels          @"/ws/search/channels/"
#define kAPICompleteChannels        @"/ws/complete/channels/"

// User details
#define kAPIGetUserDetails          @"/ws/USERID/"                              /* GET */
#define kAPIChangeUserName          @"/ws/USERID/username/"                     /* PUT */
#define kAPIChangeuserPassword      @"/ws/USERID/password/"                     /* PUT */
#define kAPIChangeUserFields        @"/ws/USERID/ATTRIBUTE/"
#define kAPIGetUserNotifications    @"/ws/USERID/notifications/"                /* GET */

// Avatar
#define kAPIUpdateAvatar           @"/ws/USERID/avatar/"                       /* PUT */

// Channel manageent
#define kAPIGetChannelDetails       @"/ws/USERID/channels/CHANNELID/"           /* GET */
#define kAPICreateNewChannel        @"/ws/USERID/channels/"                     /* POST */
#define kAPIUpdateExistingChannel   @"/ws/USERID/channels/CHANNELID/"           /* PUT */
#define kAPIUpdateChannelPrivacy    @"/ws/USERID/channels/CHANNELID/public/"     /* PUT */
#define kAPIDeleteChannel           @"/ws/USERID/channels/CHANNELID/"     /* PUT */

// Videos for channel
#define kAPIGetVideosForChannel     @"/ws/USERID/channels/CHANNELID/videos/"    /* GET */
#define kAPIUpdateVideosForChannel  @"/ws/USERID/channels/CHANNELID/videos/"    /* PUT */

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

// Cover art
#define kAPIGetCoverArt             @"/ws/cover_art/"                           /* GET */

// Something
#define kAPIPopularVideos           @"ws/videos/"
#define kAPIPopularChannels         @"ws/channels/"
#define kAPICategories              @"ws/categories/"

// Share link
#define kAPIShareLink               @"/ws/share/link/"                          /* POST */

// Report concerns

#define kAPIReportConcern           @"/ws/USERID/content_reports"               /* POST */

#define kAccountSettingsPressed     @"kAccountSettingsPressed"
#define kAccountSettingsLogout      @"kAccountSettingsLogout"
#define kUserDataChanged            @"kUserDataChanged"
#define kChannelSubscribeRequest    @"kChannelSubscribeRequest"
#define kChannelUpdateRequest       @"kChannelUpdateRequest"
#define kChannelOwnerUpdateRequest  @"kChannelOwnerUpdateRequest"
#define kChannelDeleteRequest       @"kChannelDeleteRequest"

#define kRefreshComplete           @"kRefreshComplete"

#define kClearAllAddedCells         @"kClearAllAddedCells"



#define kShowUserChannels           @"kShowUserChannels"

// Timeout for API calls

#define kAPIDefaultTimout 30

// API default batch size (we may need different ones for each API at some stage)
#define kDefaultBatchSize 20

// Savecontext

#define kSaveSynchronously TRUE
#define kSaveAsynchronously FALSE

// Placeholders

#define kNewChannelPlaceholderId @"NewChannelPlaceholder"

// Notifications


// One the APIs imported some new data - we will need to be more specific at some stage.
#define kCategoriesUpdated @"kCategoriesUpdated"

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
#define kOAuth2Service @"com.rockpack.rockpack"
#define kOAuth2ClientSecret @"7d6a1956c0207ed9d0bbc22ddf9d95"

// Enable full screen thumbnail view 
#define FULL_SCREEN_THUMBNAILS__


typedef enum _Gender {
    
    GenderMale = 0,
    GenderFemale = 1,
    GenderUndecided = 2 // how post-modern
    
} Gender;

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

// Switch label
#define kSwitchLabelAnimation 0.25f

// Splash screen
#define kSplashViewDuration 2.0f
#define kSplashAnimationDuration  0.75f

// Edit mode
#define kChannelEditModeAnimationDuration 0.3f

// Tabs
#define kTabAnimationDuration 0.3f

#define kChangedAccountSettingsValue @"kChangedAccountSettingsValue"

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

//
// Dimensions
//

#define kMinorDimension 768.0f
#define kMajorDimension 1024.0f
#define kStatusBarHeight 20.0f

#define kFullScreenHeightPortrait kMajorDimension
#define kFullScreenHeightPortraitMinusStatusBar (kFullScreenHeightPortrait - kStatusBarHeight)
#define kFullScreenWidthPortrait kMinorDimension

#define kFullScreenHeightLandscape kMinorDimension
#define kFullScreenHeightLandscapeMinusStatusBar (kFullScreenHeightLandscape - kStatusBarHeight)
#define kFullScreenWidthLandscape kMajorDimension

#define kStandardCollectionViewOffsetY 80.0f
#define kStandardCollectionViewOffsetYiPhone 60.0f
#define kYouCollectionViewOffsetY 160.0f
#define kChannelDetailsCollectionViewOffsetY 580.0f
#define kChannelDetailsFadeSpan 15.0f

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


#define kLoginCompleted @"kLoginCompleted"

typedef enum {
    EntityTypeChannel = 0,
    EntityTypeVideo,
    EntityTypeVideoInstance,
    EntityTypeCategory
    
} EntityType;

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

#define kVideoBackgroundColour          [UIColor blackColor]
#define kBufferMonitoringTimerInterval  1.0f
#define kShuttleBarUpdateTimerInterval  0.5f
#define kMiddlePlaceholderCycleTime     2.0f
#define kMiddlePlaceholderIdentifier    @"MiddlePlaceholder"
#define kBottomPlaceholderCycleTime     4.0f
#define kBottomPlaceholderIdentifier    @"BottomPlaceholder"
#define kShuttleBarHeight               44.0f
#define kShuttleBarTimeLabelWidth       40.0f
#define kShuttleBarTimeLabelOffset      100.0f
#define kShuttleBarButtonWidth          77.0f
#define kShuttleBarSliderOffset         10.0f

// Channel creation

#define kChannelCreationCollectionViewOffsetY           580.0f
#define kChannelCreationCategoryTabOffsetY              444.0f
#define kChannelCreationCategoryAdditionalOffsetY       51.0f

// Notifications

#define kNoteBackButtonShow         @"kNoteBackButtonShow"
#define kNoteBackButtonHide         @"kNoteBackButtonHide"
#define kNoteStarButtonPressed      @"kNoteStarButtonPressed"
#define kNoteAddToChannelRequest    @"kNoteAddToChannelRequest"

#define kNoteAddedToChannel         @"kNoteAddedToChannel"
#define kNoteCreateNewChannel       @"kNoteCreateNewChannel"

#define kNotificationMarkedRead     @"kNoteAddedToChannel"

#define kProfileRequested           @"kProfileRequested"
#define kChannelDetailsRequested    @"kChannelDetailsRequested"
#define kVideoOverlayRequested      @"kVideoOverlayRequested"
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

#endif
