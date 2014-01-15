//
//  GAI+Tracking.m
//  dolly
//
//  Created by Sherman Lo on 10/12/13.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "GAI+Tracking.h"
#import "NSString+Utils.h"

static NSString *const UIActionCategory = @"uiAction";

static NSString *const VideoShareAction = @"videoShareButtonClick";
static NSString *const VideoAddAction = @"videoPlusButtonClick";
static NSString *const FacebookLoginAction = @"facebookLogin";

static NSString *const GoalCategory = @"goal";

static NSString *const UserLoginGoal = @"userLogin";

static const NSInteger TrackingDimensionAge = 1;

@implementation GAI (Tracking)

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

- (void)setAgeDimensionFromBirthDate:(NSDate *)birthDate {
	NSDateComponents *ageComponents = [[NSCalendar currentCalendar]	 components: NSYearCalendarUnit
																	   fromDate: birthDate
																		 toDate: NSDate.date
																		options: 0];
	NSInteger age = [ageComponents year];
	NSString *ageString = [NSString ageCategoryStringFromInt:age];
	
	[[self defaultTracker] set:[GAIFields customDimensionForIndex:TrackingDimensionAge] value: ageString];
}

#pragma mark - Private

- (void)trackEventWithCategory:(NSString *)category action:(NSString *)action {
	[self trackEventWithCategory:category action:action label:nil value:nil];
}

- (void)trackEventWithCategory:(NSString *)category action:(NSString *)action label:(NSString *)label value:(NSNumber *)value {
	[[self defaultTracker] send:[[GAIDictionaryBuilder createEventWithCategory:category
																		action:action
																		 label:label
																		 value:value] build]];
}

@end
