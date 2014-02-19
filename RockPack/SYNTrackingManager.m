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

static NSString *const VideoAddAction = @"videoPlusButtonClick";
static NSString *const VideoLikeAction = @"videoLoveButtonClick";
static NSString *const FacebookLoginAction = @"facebookLogin";
static NSString *const VideoShareAction = @"videoShareButtonClick";
static NSString *const CollectionShareAction = @"collectionShareButtonClick";
static NSString *const CollectionFollowAction = @"collectionFollowButtonClick";
static NSString *const UserCollectionsFollowAction = @"collectionFollowAllButtonClick";

static NSString *const VideoMaximiseViaRotationAction = @"videoMaximizeTurn";
static NSString *const VideoMaximiseAction = @"videoMaximizeClick";

static NSString *const AccountPropertyChangedAction = @"accountPropertyChanged";

static NSString *const StartScreenView = @"Start";
static NSString *const LoginScreenView = @"Login";
static NSString *const RegisterScreenView = @"Registration";
static NSString *const RegisterStep2ScreenView = @"Registration 2";
static NSString *const ForgotPasswordScreenView = @"Forgot password";

static NSString *const MoodMinderScreenView = @"Mood-Minder";
static NSString *const FeedScreenView = @"My Wonders";
static NSString *const OwnProfileScreenView = @"Own Profile";
static NSString *const ActivityScreenView = @"Activity";

static NSString *const ProfileOverlayScreenView = @"More";
static NSString *const AccountSettingsScreenView = @"Account";
static NSString *const AboutScreenView = @"About";
static NSString *const FeedbackScreenView = @"Feedback";
static NSString *const HintsScreenView = @"Hints";
static NSString *const FriendsScreenView = @"Friends";
static NSString *const FriendsFBConnectScreenView = @"Friends Fb Connect";
static NSString *const BlogScreenView = @"Blog";
static NSString *const HelpScreenView = @"Help";

static NSString *const EditProfileScreenView = @"Edit Profile";
static NSString *const OwnProfileFollowingScreenView = @"Own Profile Following";

static NSString *const OwnCollectionScreenView = @"Own Collection";
static NSString *const EditCollectionScreenView = @"Edit Collection";

static NSString *const CollectionFollowersScreenView = @"Subscriber list";

static NSString *const OtherUserProfileScreenView = @"User Profile";
static NSString *const OtherUserCollectionScreenView = @"User Collection";
static NSString *const OtherUsersProfileFollowingScreenView = @"User Profile's following";
static NSString *const CommentingScreenView = @"Commenting";

static NSString *const CarouselVideoPlayerScreenView = @"Video 1";
static NSString *const SearchVideoPlayerScreenView = @"Video 2";

static NSString *const ShareScreenView = @"Share";

static NSString *const GoalCategory = @"goal";

static NSString *const UserLoginGoal = @"userLogin";

static const NSInteger TrackingDimensionAge = 1;

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

#pragma mark - Public

- (void)trackVideoAddFromScreenName:(NSString *)screenName {
	[self trackEventWithCategory:UIActionCategory action:VideoAddAction label:screenName value:nil];
}

- (void)trackVideoLikeFromScreenName:(NSString *)screenName {
	[self trackEventWithCategory:UIActionCategory action:VideoLikeAction label:screenName value:nil];
}

- (void)trackFacebookLogin {
	[self trackEventWithCategory:UIActionCategory action:FacebookLoginAction];
}

- (void)trackUserLoginFromOrigin:(NSString *)origin {
	[self trackEventWithCategory:GoalCategory action:UserLoginGoal label:origin value:nil];
}

- (void)trackVideoShareWithService:(NSString *)service {
	[self trackEventWithCategory:UIActionCategory action:VideoShareAction label:service value:nil];
}

- (void)trackCollectionShareWithService:(NSString *)service {
	[self trackEventWithCategory:UIActionCategory action:CollectionShareAction label:service value:nil];
}

- (void)trackCollectionFollowFromScreenName:(NSString *)screenName {
	[self trackEventWithCategory:UIActionCategory action:CollectionFollowAction label:screenName value:nil];
}

- (void)trackUserCollectionsFollowFromScreenName:(NSString *)screenName {
	[self trackEventWithCategory:UIActionCategory action:UserCollectionsFollowAction label:screenName value:nil];
}

- (void)trackVideoMaximiseViaRotation {
	[self trackEventWithCategory:UIActionCategory action:VideoMaximiseViaRotationAction];
}

- (void)trackVideoMaximise {
	[self trackEventWithCategory:UIActionCategory action:VideoMaximiseAction];
}

- (void)trackAccountPropertyChanged:(NSString *)property {
	[self trackEventWithCategory:UIActionCategory action:AccountPropertyChangedAction label:property value:nil];
}

- (void)trackStartScreenView {
	[self trackScreenViewWithName:StartScreenView];
}

- (void)trackLoginScreenView {
	[self trackScreenViewWithName:LoginScreenView];
}

- (void)trackForgotPasswordScreenView {
	[self trackScreenViewWithName:ForgotPasswordScreenView];
}

- (void)trackRegistrationScreenView {
	[self trackScreenViewWithName:RegisterScreenView];
}

- (void)trackRegistrationStep2ScreenView {
	[self trackScreenViewWithName:RegisterStep2ScreenView];
}

- (void)trackMoodMinderScreenView {
	[self trackScreenViewWithName:MoodMinderScreenView];
}

- (void)trackFeedScreenView {
	[self trackScreenViewWithName:FeedScreenView];
}

- (void)trackShareScreenView {
	[self trackScreenViewWithName:ShareScreenView];
}

- (void)trackOwnProfileScreenView {
	[self trackScreenViewWithName:OwnProfileScreenView];
}

- (void)trackActivityScreenView {
	[self trackScreenViewWithName:ActivityScreenView];
}

- (void)trackProfileOverlayScreenView {
	[self trackScreenViewWithName:ProfileOverlayScreenView];
}

- (void)trackEditProfileScreenView {
	[self trackScreenViewWithName:EditProfileScreenView];
}

- (void)trackOwnProfileFollowingScreenView {
	[self trackScreenViewWithName:OwnProfileFollowingScreenView];
}

- (void)trackOwnCollectionScreenView {
	[self trackScreenViewWithName:OwnCollectionScreenView];
}

- (void)trackEditCollectionScreenView {
	[self trackScreenViewWithName:EditCollectionScreenView];
}

- (void)trackOtherUserProfileScreenView {
	[self trackScreenViewWithName:OtherUserProfileScreenView];
}

- (void)trackOtherUserCollectionScreenView {
	[self trackScreenViewWithName:OtherUserCollectionScreenView];
}

- (void)trackOtherUserCollectionFollowingScreenView {
	[self trackScreenViewWithName:OtherUsersProfileFollowingScreenView];
}

- (void)trackCollectionFollowersScreenView {
	[self trackScreenViewWithName:CollectionFollowersScreenView];
}

- (void)trackCommentingScreenView {
	[self trackScreenViewWithName:CommentingScreenView];
}

- (void)trackAccountSettingsScreenView {
	[self trackScreenViewWithName:AccountSettingsScreenView];
}

- (void)trackAboutScreenView {
	[self trackScreenViewWithName:AboutScreenView];
}

- (void)trackFeedbackScreenView {
	[self trackScreenViewWithName:FeedbackScreenView];
}

- (void)trackHintsScreenView {
	[self trackScreenViewWithName:HintsScreenView];
}

- (void)trackFriendsScreenView {
	[self trackScreenViewWithName:FriendsScreenView];
}

- (void)trackFriendsFBConnectScreenView {
	[self trackScreenViewWithName:FriendsFBConnectScreenView];
}

- (void)trackBlogScreenView {
	[self trackScreenViewWithName:BlogScreenView];
}

- (void)trackHelpScreenView {
	[self trackScreenViewWithName:HelpScreenView];
}

- (void)trackCarouselVideoPlayerScreenView {
	[self trackScreenViewWithName:CarouselVideoPlayerScreenView];
}

- (void)trackSearchVideoPlayerScreenView {
	[self trackScreenViewWithName:SearchVideoPlayerScreenView];
}

- (void)setAgeDimensionFromBirthDate:(NSDate *)birthDate {
	NSDateComponents *ageComponents = [[NSCalendar currentCalendar]	components:NSYearCalendarUnit
																	  fromDate:birthDate
																		toDate:NSDate.date
																	   options:0];
	NSInteger age = [ageComponents year];
	NSString *ageString = [NSString ageCategoryStringFromInt:age];
	
	[[self defaultTracker] set:[GAIFields customDimensionForIndex:TrackingDimensionAge] value: ageString];
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
