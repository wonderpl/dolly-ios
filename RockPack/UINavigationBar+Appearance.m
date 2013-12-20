//
//  UINavigationBar+Appearance.m
//  dolly
//
//  Created by Sherman Lo on 20/12/13.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "UINavigationBar+Appearance.h"

@implementation UINavigationBar (Appearance)

- (void)setBackgroundTransparent:(BOOL)transparent {
	if (transparent) {
		UIImage *clearImage = [[UIImage alloc] init];
		[self setBackgroundImage:clearImage forBarMetrics:UIBarMetricsDefault];
		self.shadowImage = clearImage;
	} else {
		[self setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
		self.shadowImage = nil;
	}
}

@end
