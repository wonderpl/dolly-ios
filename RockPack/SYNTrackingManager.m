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

static NSString *const VideoShareAction = @"videoShareButtonClick";
static NSString *const VideoAddAction = @"videoPlusButtonClick";
static NSString *const FacebookLoginAction = @"facebookLogin";

static NSString *const StartScreenView = @"Start";
static NSString *const LoginScreenView = @"Login";
static NSString *const RegisterScreenView = @"Register";
static NSString *const RegisterStep2ScreenView = @"Register 2";
static NSString *const ForgotPasswordScreenView = @"Forgot password";

static NSString *const GoalCategory = @"goal";

static NSString *const UserLoginGoal = @"userLogin";

static const NSInteger TrackingDimensionAge = 1;

@interface SYNTrackingManager ()

@end

@implementation SYNTrackingManager

+ (instancetype)sharedManager {
	static SYNTrackingManager *manager;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		manager = [[SYNTrackingManager alloc] init];
	});
	return manager;
}

- (id)init {
	if (self = [super init]) {
		
	}
	return self;
}


- (void)trackVideoShare {
	[self trackEventWithCategory:UIActionCategory action:VideoShareAction];
}

- (void)trackVideoAdd {
	[self trackEventWithCategory:UIActionCategory action:VideoAddAction];
}

- (void)trackFacebookLogin {
	[self trackEventWithCategory:UIActionCategory action:FacebookLoginAction];
}

- (void)trackUserLoginFromOrigin:(NSString *)origin {
	[self trackEventWithCategory:GoalCategory
						  action:UserLoginGoal
						   label:origin
						   value:nil];
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

- (void)trackRegisterScreenView {
	[self trackScreenViewWithName:RegisterScreenView];
}

- (void)trackRegisterStep2ScreenView {
	[self trackScreenViewWithName:RegisterStep2ScreenView];
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
