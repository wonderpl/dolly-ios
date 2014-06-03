//
//  SYNTrackingManager.m
//  dolly
//
//  Created by Sherman Lo on 18/02/14.
//  Copyright (c) 2014 Rockpack Ltd. All rights reserved.
//

#import "SYNTrackingManager.h"
#import "NSString+Utils.h"
#import "SYNNotification.h"
#import <GAI.h>
#import <GAIFields.h>
#import <GAIDictionaryBuilder.h>
#import <FacebookSDK/FacebookSDK.h>
#import <Reachability.h>
@import CoreTelephony;

static NSString *const UIActionCategory = @"uiAction";
static NSString *const GoalCategory = @"goal";
static NSString *const NetworkCategory = @"network";

static const NSInteger TrackingDimensionAge = 1;
static const NSInteger TrackingDimensionCategory = 2;
static const NSInteger TrackingDimensionGender = 3;
static const NSInteger TrackingDimensionLocale = 4;
static const NSInteger TrackingDimensionChannelRelation = 5;
static const NSInteger TrackingDimensionConnection = 6;

@interface SYNTrackingManager ()

@property (nonatomic, strong) Reachability *reachability;
@property (nonatomic, strong) CTTelephonyNetworkInfo *networkInfo;

@end

@implementation SYNTrackingManager

#pragma mark - Singleton

+ (instancetype)sharedManager {
	static SYNTrackingManager *manager;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		manager = [[SYNTrackingManager alloc] init];
	});
	return manager;
}

#pragma mark - Init / Dealloc

- (instancetype)init {
	if (self = [super init]) {
		NSString *hostname = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"APIHostName"];
		self.reachability = [Reachability reachabilityWithHostname:hostname];
		[self.reachability startNotifier];
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(reachabilityChanged:)
													 name:kReachabilityChangedNotification
												   object:self.reachability];
		
		self.networkInfo = [[CTTelephonyNetworkInfo alloc] init];
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(radioAccessTechnologyChanged:)
													 name:CTRadioAccessTechnologyDidChangeNotification
												   object:self.networkInfo];
	}
	return self;
}

#pragma mark - Public

- (void)setup {
	GAI *gai = [GAI sharedInstance];
	
    [gai trackerWithTrackingId:kGoogleAnalyticsId];
	
	gai.trackUncaughtExceptions = YES;
    gai.dispatchInterval = 30;
	
	[self setConnectionDimension:[self currentConnectionString]];
}

- (void)trackClickToMoreWithTitle:(NSString *)title URL:(NSString *)URL {
	NSString *label = [NSString stringWithFormat:@"%@ - %@", title, URL];
	[self trackEventWithCategory:UIActionCategory action:@"videoClickToMoreClick" label:label value:nil];
    [FBAppEvents logEvent:FBAppEventNameInitiatedCheckout
               parameters:@{FBAppEventParameterNameContentType: @"more",
                            FBAppEventParameterNameContentID: label}];
}

- (void)trackVideoAddFromScreenName:(NSString *)screenName {
	[self trackEventWithCategory:UIActionCategory action:@"videoPlusButtonClick" label:screenName value:nil];
}

- (void)trackVideoLikeFromScreenName:(NSString *)screenName {
	[self trackEventWithCategory:UIActionCategory action:@"videoLoveButtonClick" label:screenName value:nil];
}

- (void)trackFacebookLogin {
	[self trackEventWithCategory:UIActionCategory action:@"facebookLogin"];
}

- (void)trackDiscoverScreenView {
	[self trackScreenViewWithName:@"Discover"];
}

- (void)trackShareFriendSearch {
	[self trackEventWithCategory:UIActionCategory action:@"searchFriendtoShare"];
}

- (void)trackShareFriendSearchSelect:(NSString *)origin {
	[self trackEventWithCategory:UIActionCategory action:@"selectFriendtoShare" label:origin value:nil];
}

- (void)trackVideoSwipeToVideo:(BOOL)isPrevious {
	NSString *label = (isPrevious ? @"prev" : @"next");
	[self trackEventWithCategory:UIActionCategory action:@"videoSwipe" label:label value:nil];
}

- (void)trackUserLoginFromOrigin:(NSString *)origin {
	[self trackEventWithCategory:GoalCategory action:@"userLogin" label:origin value:nil];
}

- (void)trackUserRegistrationFromOrigin:(NSString *)origin {
	[self trackEventWithCategory:GoalCategory action:@"userRegistration" label:origin value:nil];
    [FBAppEvents logEvent:FBAppEventNameCompletedRegistration
               parameters:@{FBAppEventParameterNameRegistrationMethod: origin}];
}

- (void)trackVideoOriginatorPressed:(NSString *)name {
	[self trackEventWithCategory:UIActionCategory action:@"OrigAvatarClick" label:name value:nil];
}

- (void)trackVideoAddedByPressed:(NSString *)name {
	[self trackEventWithCategory:UIActionCategory action:@"AddedPersonClick" label:name value:nil];
}

- (void)trackShareEmailEnteredIsNew:(BOOL)isNew {
	NSString *label = (isNew ? @"New" : @"fromFB");
	[self trackEventWithCategory:UIActionCategory action:@"provideEmailtoShare" label:label value:nil];
}

- (void)trackVideoShareWithService:(NSString *)service {
	[self trackEventWithCategory:UIActionCategory action:@"videoShareButtonClick" label:service value:nil];
}

- (void)trackCollectionShareWithService:(NSString *)service {
	[self trackEventWithCategory:UIActionCategory action:@"collectionShareButtonClick" label:service value:nil];
}

- (void)trackCollectionFollowFromScreenName:(NSString *)screenName {
	[self trackEventWithCategory:UIActionCategory action:@"collectionFollowButtonClick" label:screenName value:nil];
}

- (void)trackUserCollectionsFollowFromScreenName:(NSString *)screenName {
	[self trackEventWithCategory:UIActionCategory action:@"collectionFollowAllButtonClick" label:screenName value:nil];
}

- (void)trackCollectionSelectedIsNew:(BOOL)isNew {
	NSString *label = (isNew ? @"new" : @"existing");
	[self trackEventWithCategory:UIActionCategory action:@"collectionSelectionClick" label:label value:nil];
}

- (void)trackVideoAddedToCollectionCompleted:(BOOL)isFavouritesChannel {
	NSString *label = (isFavouritesChannel ? @"favouties" : @"notfavourites");
	[self trackEventWithCategory:GoalCategory action:@"collectionUpdated" label:label value:nil];
}

- (void)trackCollectionSaved {
	[self trackEventWithCategory:UIActionCategory action:@"collectionSaveButtonClick"];
}

- (void)trackAvatarUploadFromScreen:(NSString *)screenName {
	[self trackEventWithCategory:UIActionCategory action:@"avatarUpload" label:screenName value:nil];
}

- (void)trackCollectionEdited:(NSString *)name {
	[self trackEventWithCategory:GoalCategory action:@"collectionEdited" label:name value:nil];
}

- (void)trackCoverPhotoUpload {
	[self trackEventWithCategory:UIActionCategory action:@"coverUpload"];
}

- (void)trackVideoLoadTime:(NSTimeInterval)loadTime {
	NSInteger loadTimeInMilliseconds = (NSInteger)(loadTime * 1000);
	[self trackEventWithCategory:NetworkCategory action:@"videoLoadTime" label:nil value:@(loadTimeInMilliseconds)];
}

- (void)trackVideoDescriptionViewForTitle:(NSString *)title {
	[self trackEventWithCategory:GoalCategory action:@"videoReadWatchScrolled" label:title value:nil];
}

- (void)trackVideoUpcomingVideosViewForTitle:(NSString *)title {
	[self trackEventWithCategory:GoalCategory action:@"videoNext3VideoScrolled" label:title value:nil];
}

- (void)trackUpcomingVideoSelectedForTitle:(NSString *)title {
	[self trackEventWithCategory:UIActionCategory action:@"videoNext3videoClick" label:title value:nil];
}

- (void)trackShopMotionAnnotationPressForTitle:(NSString *)title {
	[self trackEventWithCategory:UIActionCategory action:@"videoTouchPointClick" label:title value:nil];
}

- (void)trackShopMotionBagPressForTitle:(NSString *)title URL:(NSURL *)URL {
	NSString *label = [NSString stringWithFormat:@"%@ - %@", title, URL];
	[self trackEventWithCategory:UIActionCategory action:@"videoShopMotionBagClick" label:label value:nil];
    [FBAppEvents logEvent:FBAppEventNameInitiatedCheckout
               parameters:@{FBAppEventParameterNameContentType: @"bag",
                            FBAppEventParameterNameContentID: label}];
}

- (void)trackVideoMaximiseViaRotation {
	[self trackEventWithCategory:UIActionCategory action:@"videoMaximizeTurn"];
}

- (void)trackVideoMaximise {
	[self trackEventWithCategory:UIActionCategory action:@"videoMaximizeClick"];
}

- (void)trackVideoAirPlayUsed {
	[self trackEventWithCategory:UIActionCategory action:@"videoAirPlayUsed"];
}

- (void)trackSearchInitiated {
	[self trackEventWithCategory:UIActionCategory action:@"searchInitiate"];
}

- (void)trackCoverPhotoUploadCompleted {
	[self trackEventWithCategory:GoalCategory action:@"userCoverUploaded"];
}

- (void)trackAvatarPhotoUploadCompleted {
	[self trackEventWithCategory:GoalCategory action:@"userAvatarUpload"];
}

- (void)trackCollectionFollowCompleted {
	[self trackEventWithCategory:GoalCategory action:@"userFollowCollection"];
}

- (void)trackAccountPropertyChanged:(NSString *)property {
	[self trackEventWithCategory:UIActionCategory action:@"accountPropertyChanged" label:property value:nil];
}

- (void)trackAddressBookPermission:(BOOL)granted {
	NSString *label = (granted ? @"accepted" : @"rejected");
	[self trackEventWithCategory:UIActionCategory action:@"AddressBookPerm" label:label value:nil];
}

- (void)trackCollectionCreatedWithName:(NSString *)name {
	[self trackEventWithCategory:GoalCategory action:@"collectionCreated" label:name value:nil];
}

- (void)trackCreateChannelScreenView {
	[self trackScreenViewWithName:@"Create Channel"];
}

- (void)trackStartScreenView {
	[self trackScreenViewWithName:@"Start"];
}

- (void)trackLoginScreenView {
	[self trackScreenViewWithName:@"Login"];
}

- (void)trackForgotPasswordScreenView {
	[self trackScreenViewWithName:@"Forgot password"];
}

- (void)trackRegistrationScreenView {
	[self trackScreenViewWithName:@"Registration"];
}

- (void)trackRegistrationStep2ScreenView {
	[self trackScreenViewWithName:@"Registration 2"];
}

- (void)trackOnboardingScreenView {
	[self trackScreenViewWithName:@"Onboarding"];
}

- (void)trackFeedScreenView {
	[self trackScreenViewWithName:@"My Wonders"];
}

- (void)trackShareScreenView {
	[self trackScreenViewWithName:@"Share"];
}

- (void)trackOwnProfileScreenView {
	[self trackScreenViewWithName:@"Own Profile"];
}

- (void)trackActivityScreenView {
	[self trackScreenViewWithName:@"Activity"];
}

- (void)trackVideoBrowseScreenView {
	[self trackScreenViewWithName:@"Category Videos"];
}

- (void)trackUserBrowseScreenView {
	[self trackScreenViewWithName:@"Category Highlights"];
}

- (void)trackVideoSearchScreenView {
	[self trackScreenViewWithName:@"Video Search"];
}

- (void)trackUserSearchScreenView {
	[self trackScreenViewWithName:@"User Search"];
}

- (void)trackProfileOverlayScreenView {
	[self trackScreenViewWithName:@"More"];
}

- (void)trackEditProfileScreenView {
	[self trackScreenViewWithName:@"Edit Profile"];
}

- (void)trackOwnProfileFollowingScreenView {
	[self trackScreenViewWithName:@"Own Profile Following"];
}

- (void)trackOwnCollectionScreenView {
	[self trackScreenViewWithName:@"Own Collection"];
}

- (void)trackEditCollectionScreenView {
	[self trackScreenViewWithName:@"Edit Collection"];
}

- (void)trackOtherUserProfileScreenView {
	[self trackScreenViewWithName:@"User Profile"];
}

- (void)trackOtherUserCollectionScreenView {
	[self trackScreenViewWithName:@"User Collection"];
}

- (void)trackOtherUserCollectionFollowingScreenView {
	[self trackScreenViewWithName:@"User Profile's following"];
}

- (void)trackOtherUserCollectionVideoScreenView {
	[self trackScreenViewWithName:@"User Profile Video"];
}

- (void)trackCollectionFollowersScreenView {
	[self trackScreenViewWithName:@"Subscriber list"];
}

- (void)trackAccountSettingsScreenView {
	[self trackScreenViewWithName:@"Account"];
}

- (void)trackAboutScreenView {
	[self trackScreenViewWithName:@"About"];
}

- (void)trackFeedbackScreenView {
	[self trackScreenViewWithName:@"Feedback"];
}

- (void)trackHintsScreenView {
	[self trackScreenViewWithName:@"Hints"];
}

- (void)trackFriendsScreenView {
	[self trackScreenViewWithName:@"Friends"];
}

- (void)trackFriendsFBConnectScreenView {
	[self trackScreenViewWithName:@"Friends Fb Connect"];
}

- (void)trackBlogScreenView {
	[self trackScreenViewWithName:@"Blog"];
}

- (void)trackHelpScreenView {
	[self trackScreenViewWithName:@"Help"];
}

- (void)trackRateScreenView {
	[self trackScreenViewWithName:@"Rate"];
}

- (void)trackVideoPlayerScreenView {
	[self trackScreenViewWithName:@"Video"];
}

- (void)trackClickToMoreScreenView {
	[self trackScreenViewWithName:@"Click to more"];
}

- (void)trackMarkAllNotificationAsRead {
	[self trackEventWithCategory:UIActionCategory action:@"markAllAsRead"];
}

- (void)trackSelectedNotificationOfType:(kNotificationObjectType)type {
	NSString *label = @{ @(kNotificationObjectTypeUserLikedYourVideo)         : @"like",
						 @(kNotificationObjectTypeUserSubscibedToYourChannel) : @"follow",
						 @(kNotificationObjectTypeFacebookFriendJoined)       : @"fbfriend",
						 @(kNotificationObjectTypeYourVideoNotAvailable)      : @"unavailable",
						 @(kNotificationObjectTypeCommentMention)             : @"comment" }[@(type)];
	[self trackEventWithCategory:UIActionCategory action:@"notificationTap" label:label value:nil];
}

- (void)trackOnboardingCompletedWithFollowedCount:(NSInteger)followedCount {
	NSString *label = [NSString stringWithFormat:@"%@", @(followedCount)];
	[self trackEventWithCategory:UIActionCategory action:@"completedOnboarding" label:label value:nil];
}

- (void)trackVideoView:(NSString *)videoId currentTime:(CGFloat)currentTime duration:(CGFloat)duration {
    
    // Defensive
    if (duration<currentTime) {
        DebugLog(@"Duration:%f larger than current time%f", duration, currentTime);
        return;
    }
    
	NSInteger percentageViewed = (NSInteger)((currentTime / duration) * 100);
	
    //If the amount of the video watched is below
    //This threshold we do not send the tracking event
    if (currentTime <= 0.0001) {
        return;
    }
    
    if (percentageViewed<0 || percentageViewed > 100) {
        DebugLog(@"Percentage error : %ld", (long)percentageViewed);
        return;
    }
    
	[self trackEventWithCategory:GoalCategory action:@"videoViewed" label:videoId value:@(percentageViewed)];
    
	[self trackEventWithCategory:GoalCategory action:@"videoViewedDuration" label:videoId value:@((int)currentTime)];

    [FBAppEvents logEvent:FBAppEventNameViewedContent
               parameters:@{FBAppEventParameterNameContentType: @"video",
                            FBAppEventParameterNameContentID: videoId}];
}

- (void)trackNetworkErrorCode:(NSInteger)code forURL:(NSString *)url {
	NSString *action = [NSString stringWithFormat:@"Error %@", @(code)];
	[self trackEventWithCategory:NetworkCategory action:action label:url value:nil];
}

- (void)trackExternalLinkOpened:(NSString *)url {
	[self trackEventWithCategory:GoalCategory action:@"openDeepLink" label:url value:nil];
}

- (void)trackCollectionShareCompletedWithService:(NSString *)service {
	[self trackEventWithCategory:GoalCategory action:@"collectionShared" label:service value:nil];
}

- (void)trackVideoShareCompletedWithService:(NSString *)service {
	[self trackEventWithCategory:GoalCategory action:@"videoShared" label:service value:nil];
}

- (void)setAgeDimensionFromBirthDate:(NSDate *)birthDate {
	NSString *ageString = @"unknown";
	if (birthDate) {
		NSDateComponents *ageComponents = [[NSCalendar currentCalendar]	components:NSYearCalendarUnit
																		  fromDate:birthDate
																			toDate:NSDate.date
																		   options:0];
		NSInteger age = [ageComponents year];
		ageString = [NSString ageCategoryStringFromInteger:age];
	}
	
	[[self defaultTracker] set:[GAIFields customDimensionForIndex:TrackingDimensionAge] value:ageString];
}

- (void)setGenderDimension:(Gender)gender {
	NSString *value = @{ @(GenderMale)      : @"male",
						 @(GenderFemale)    : @"female",
						 @(GenderUndecided) : @"unknown" }[@(gender)];
	[[self defaultTracker] set:[GAIFields customDimensionForIndex:TrackingDimensionGender] value:value];
}

- (void)setLocaleDimension:(NSLocale *)locale {
	NSString *languageIdentifier = [NSLocale canonicalLanguageIdentifierFromString:[locale localeIdentifier]];
	[[self defaultTracker] set:[GAIFields customDimensionForIndex:TrackingDimensionLocale] value:languageIdentifier];
}

- (void)setConnectionDimension:(NSString *)connection {
	[[self defaultTracker] set:[GAIFields customDimensionForIndex:TrackingDimensionConnection] value:connection];
}

- (void)setCategoryDimension:(NSString *)name {
	[[self defaultTracker] set:[GAIFields customDimensionForIndex:TrackingDimensionCategory] value:name];
}

- (void)setChannelRelationDimension:(NSString *)relationship {
	[[self defaultTracker] set:[GAIFields customDimensionForIndex:TrackingDimensionChannelRelation] value:relationship];
}

- (void)trackScreenViewWithName:(NSString *)name {
	[[self defaultTracker] set:kGAIScreenName value:name];
	[[self defaultTracker] send:[[GAIDictionaryBuilder createAppView] build]];
}

#pragma mark - Private

- (id<GAITracker>)defaultTracker {
	return [[GAI sharedInstance] defaultTracker];
}

- (void)trackEventWithCategory:(NSString *)category action:(NSString *)action {
	[self trackEventWithCategory:category action:action label:nil value:nil];
}

- (void)trackEventWithCategory:(NSString *)category action:(NSString *)action label:(NSString *)label value:(NSNumber *)value {
	[[self defaultTracker] send:[[GAIDictionaryBuilder createEventWithCategory:category
																		action:action
																		 label:label
																		 value:value] build]];
}

- (void)reachabilityChanged:(NSNotification *)notification {
	[self setConnectionDimension:[self currentConnectionString]];
}

- (void)radioAccessTechnologyChanged:(NSNotification *)notification {
	[self setConnectionDimension:[self currentConnectionString]];
}

- (NSString *)currentConnectionString {
	if ([self.reachability isReachableViaWiFi]) {
		return @"wifi";
	}
	if ([self.reachability isReachableViaWWAN]) {
		return [self cellTechnologyGeneration:self.networkInfo.currentRadioAccessTechnology];
	}
	return @"none";
}

- (NSString *)cellTechnologyGeneration:(NSString *)technology {
	return (@{ CTRadioAccessTechnologyGPRS         : @"2g",
			   CTRadioAccessTechnologyEdge         : @"2g",
			   CTRadioAccessTechnologyWCDMA        : @"3g",
			   CTRadioAccessTechnologyHSDPA        : @"3g",
			   CTRadioAccessTechnologyHSUPA        : @"3g",
			   CTRadioAccessTechnologyCDMA1x       : @"3g",
			   CTRadioAccessTechnologyCDMAEVDORev0 : @"3g",
			   CTRadioAccessTechnologyCDMAEVDORevA : @"3g",
			   CTRadioAccessTechnologyCDMAEVDORevB : @"3g",
			   CTRadioAccessTechnologyeHRPD        : @"3g",
			   CTRadioAccessTechnologyLTE          : @"4g" }[technology] ?: @"unknown");
}

@end
