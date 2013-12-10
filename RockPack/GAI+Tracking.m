//
//  GAI+Tracking.m
//  dolly
//
//  Created by Sherman Lo on 10/12/13.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "GAI+Tracking.h"

static NSString *const UIActionCategory = @"uiAction";
static NSString *const VideoShareAction = @"videoShareButtonClick";

@implementation GAI (Tracking)

- (void)trackVideoShare {
	[self trackEventWithCategory:UIActionCategory action:VideoShareAction];
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
