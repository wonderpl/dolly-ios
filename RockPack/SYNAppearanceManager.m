//
//  SYNAppearanceManager.m
//  dolly
//
//  Created by Sherman Lo on 19/03/14.
//  Copyright (c) 2014 Wonder PL Ltd. All rights reserved.
//

#import "SYNAppearanceManager.h"
#import "UIColor+SYNColor.h"
#import "UIFont+SYNFont.h"

@implementation SYNAppearanceManager

+ (void)setupGlobalAppAppearance {
	[self setupSearchBarAppearance];
	
	[self setupNavigationBarAppearance];
}

+ (void)setupSearchBarAppearance {
	[[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setBackgroundColor:[UIColor dollySearchBarColor]];
    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setFont:[UIFont regularCustomFontOfSize:15]];
}

+ (void)setupNavigationBarAppearance {
	UIImage *backButtonImage = [[UIImage imageNamed:@"BackButtonApp.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
	[[UINavigationBar appearance] setBackIndicatorImage:backButtonImage];
	[[UINavigationBar appearance] setBackIndicatorTransitionMaskImage:backButtonImage];
	
	if (IS_IPAD) {
		[self setupIPadNavigationBarAppearance];
	} else {
		[self setupIPhoneNavigationBarAppearance];
	}
}

+ (void)setupIPhoneNavigationBarAppearance {
	NSDictionary *navigationBarTitleAttributes = @{ NSFontAttributeName : [UIFont regularCustomFontOfSize:15.0] };
	[[UINavigationBar appearance] setTitleTextAttributes:navigationBarTitleAttributes];
	
	NSDictionary *barButtonTitleAttributes = @{ NSFontAttributeName : [UIFont regularCustomFontOfSize:15.0] };
	[[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil] setTitleTextAttributes:barButtonTitleAttributes
																							forState:UIControlStateNormal];
}

+ (void)setupIPadNavigationBarAppearance {
	NSDictionary *navigationBarTitleAttributes = @{ NSFontAttributeName : [UIFont regularCustomFontOfSize:22.0] };
	[[UINavigationBar appearance] setTitleTextAttributes:navigationBarTitleAttributes];
	
	NSDictionary *barButtonTitleAttributes = @{ NSFontAttributeName : [UIFont regularCustomFontOfSize:17.0] };
	[[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil] setTitleTextAttributes:barButtonTitleAttributes
																							forState:UIControlStateNormal];
}

@end