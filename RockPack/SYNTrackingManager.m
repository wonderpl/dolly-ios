//
//  SYNTrackingManager.m
//  dolly
//
//  Created by Sherman Lo on 18/02/14.
//  Copyright (c) 2014 Rockpack Ltd. All rights reserved.
//

#import "SYNTrackingManager.h"
#import "NSString+Utils.h"
#import <GAI.h>

static NSString *const UIActionCategory = @"uiAction";
static NSString *const GoalCategory = @"goal";

static const NSInteger TrackingDimensionAge = 1;
static const NSInteger TrackingDimensionGender = 3;
static const NSInteger TrackingDimensionLocale = 4;

@interface SYNTrackingManager ()

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

- (void)setup {
	GAI *gai = [GAI sharedInstance];
	
    [gai trackerWithTrackingId:kGoogleAnalyticsId];
	
	gai.trackUncaughtExceptions = YES;
    gai.dispatchInterval = 30;
}

#pragma mark - Public

- (void)trackVideoAddFromScreenName:(NSString *)screenName {
	[self trackEventWithCategory:UIActionCategory action:@"videoPlusButtonClick" label:screenName value:nil];
}

- (void)trackVideoLikeFromScreenName:(NSString *)screenName {
	[self trackEventWithCategory:UIActionCategory action:@"videoLoveButtonClick" label:screenName value:nil];
}

- (void)trackVideoCommentFromScreenName:(NSString *)screenName {
	[self trackEventWithCategory:UIActionCategory action:@"CommentButtonClick" label:screenName value:nil];
}

- (void)trackFacebookLogin {
	[self trackEventWithCategory:UIActionCategory action:@"facebookLogin"];
}

- (void)trackDiscoverScreenView {
	[self trackScreenViewWithName:@"Discover"];
}

- (void)trackVideoSwipeToVideo:(BOOL)isPrevious {
	NSString *label = (isPrevious ? @"prev" : @"next");
	[self trackEventWithCategory:UIActionCategory action:@"videoSwipe" label:label value:nil];
}

- (void)trackUserLoginFromOrigin:(NSString *)origin {
	[self trackEventWithCategory:GoalCategory action:@"userLogin" label:origin value:nil];
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

- (void)trackCollectionSelectionSaved {
	[self trackEventWithCategory:UIActionCategory action:@"collectionSaveButtonClick"];
}

- (void)trackAvatarUploadFromScreen:(NSString *)screenName {
	[self trackEventWithCategory:UIActionCategory action:@"avatarUpload" label:screenName value:nil];
}

- (void)trackCoverPhotoUpload {
	[self trackEventWithCategory:UIActionCategory action:@"coverUpload"];
}

- (void)trackVideoMaximiseViaRotation {
	[self trackEventWithCategory:UIActionCategory action:@"videoMaximizeTurn"];
}

- (void)trackVideoMaximise {
	[self trackEventWithCategory:UIActionCategory action:@"videoMaximizeClick"];
}

- (void)trackCarouselVideoSelected {
	[self trackEventWithCategory:UIActionCategory action:@"videoBarClick"];
}

- (void)trackSearchVideoPlayerAppearsInSelected {
	[self trackEventWithCategory:UIActionCategory action:@"viewer2AppearsIn"];
}

- (void)trackSearchVideoPlayerLovedBySelected {
	[self trackEventWithCategory:UIActionCategory action:@"viewer2LovedBy"];
}

- (void)trackSearchInitiated {
	[self trackEventWithCategory:UIActionCategory action:@"searchInitiate"];
}

//- (void)trackMoodSelected:(NSString *)moodName {
//	[self trackEventWithCategory:UIActionCategory action:MoodSelectedAction label:moodName value:nil];
//}
//
//- (void)trackMoodChooseAnotherSelected:(NSString *)moodName {
//	[self trackEventWithCategory:UIActionCategory action:MoodChooseAnotherSelectedAction label:moodName value:nil];
//}

- (void)trackAccountPropertyChanged:(NSString *)property {
	[self trackEventWithCategory:UIActionCategory action:@"accountPropertyChanged" label:property value:nil];
}

- (void)trackAddressBookPermission:(BOOL)granted {
	NSString *label = (granted ? @"accepted" : @"rejected");
	[self trackEventWithCategory:UIActionCategory action:@"AddressBookPerm" label:label value:nil];
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

- (void)trackMoodMinderScreenView {
	[self trackScreenViewWithName:@"Mood-Minder"];
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

- (void)trackCollectionFollowersScreenView {
	[self trackScreenViewWithName:@"Subscriber list"];
}

- (void)trackCommentingScreenView {
	[self trackScreenViewWithName:@"Commenting"];
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

- (void)trackCarouselVideoPlayerScreenView {
	[self trackScreenViewWithName:@"Video 1"];
}

- (void)trackSearchVideoPlayerScreenView {
	[self trackScreenViewWithName:@"Video 2"];
}

- (void)trackMarkAllNotificationAsRead {
	[self trackEventWithCategory:UIActionCategory action:@"markAllAsRead"];
}

- (void)trackSelectedNotificationOfType:(NSString *)type {
	[self trackEventWithCategory:UIActionCategory action:@"notificationTap" label:type value:nil];
}

- (void)trackOnboardingCompletedWithFollowedCount:(NSInteger)followedCount {
	NSString *label = [NSString stringWithFormat:@"%d", followedCount];
	[self trackEventWithCategory:UIActionCategory action:@"completedOnboarding" label:label value:nil];
}

- (void)trackVideoView:(NSString *)videoId currentTime:(CGFloat)currentTime duration:(CGFloat)duration {
	NSInteger percentageViewed = (NSInteger)((currentTime / duration) * 100);
	
	[self trackEventWithCategory:GoalCategory action:@"videoViewed" label:videoId value:@(percentageViewed)];
	[self trackEventWithCategory:GoalCategory action:@"videoViewedDuration" label:videoId value:@((int)currentTime)];
}

- (void)setAgeDimensionFromBirthDate:(NSDate *)birthDate {
	NSString *ageString = @"unknown";
	if (birthDate) {
		NSDateComponents *ageComponents = [[NSCalendar currentCalendar]	components:NSYearCalendarUnit
																		  fromDate:birthDate
																			toDate:NSDate.date
																		   options:0];
		NSInteger age = [ageComponents year];
		ageString = [NSString ageCategoryStringFromInt:age];
	}
	
	[[self defaultTracker] set:[GAIFields customDimensionForIndex:TrackingDimensionAge] value:ageString];
}

- (void)setGenderDimension:(Gender)gender {
	NSString *value = @{ @(GenderMale) : @"male",
						 @(GenderFemale) : @"female",
						 @(GenderUndecided) : @"unknown" }[@(gender)];
	[[self defaultTracker] set:[GAIFields customDimensionForIndex:TrackingDimensionGender] value:value];
}

- (void)setLocaleDimension:(NSLocale *)locale {
	NSString *languageIdentifier = [NSLocale canonicalLanguageIdentifierFromString:[locale localeIdentifier]];
	[[self defaultTracker] set:[GAIFields customDimensionForIndex:TrackingDimensionLocale] value:languageIdentifier];
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

- (void)trackScreenViewWithName:(NSString *)name {
	[[self defaultTracker] set:kGAIScreenName value:name];
    [[self defaultTracker] send:[[GAIDictionaryBuilder createAppView] build]];
}

@end
