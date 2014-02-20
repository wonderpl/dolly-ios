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
	[self trackEventWithCategory:UIActionCategory action:@"videoPlusButtonClick" label:screenName value:nil];
}

- (void)trackVideoLikeFromScreenName:(NSString *)screenName {
	[self trackEventWithCategory:UIActionCategory action:@"videoLoveButtonClick" label:screenName value:nil];
}

- (void)trackFacebookLogin {
	[self trackEventWithCategory:UIActionCategory action:@"facebookLogin"];
}

- (void)trackUserLoginFromOrigin:(NSString *)origin {
	[self trackEventWithCategory:GoalCategory action:@"userLogin" label:origin value:nil];
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

- (void)trackVideoMaximiseViaRotation {
	[self trackEventWithCategory:UIActionCategory action:@"videoMaximizeTurn"];
}

- (void)trackVideoMaximise {
	[self trackEventWithCategory:UIActionCategory action:@"videoMaximizeClick"];
}

- (void)trackAccountPropertyChanged:(NSString *)property {
	[self trackEventWithCategory:UIActionCategory action:@"accountPropertyChanged" label:property value:nil];
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
