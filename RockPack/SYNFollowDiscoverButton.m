//
//  SYNFollowUserButton.m
//  dolly
//
//  Created by Cong on 07/01/2014.
//  Copyright (c) 2014 Rockpack Ltd. All rights reserved.
//

#import "SYNFollowDiscoverButton.h"
#import "UIColor+SYNColor.h"
#import "UIFont+SYNFont.h"

@implementation SYNFollowDiscoverButton


-(void)awakeFromNib
{
    [super awakeFromNib];
	self.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.45];
}

- (UIColor*) selectedColor {
	return [UIColor whiteColor];
}

- (UIColor*) defaultColor {
	return [UIColor whiteColor];
}

- (UIFont*)selectedFont {
	return [UIFont regularCustomFontOfSize:14.0f];
}

- (UIFont*)defaultFont {
	return [UIFont regularCustomFontOfSize:14.0f];
}

- (UIColor*) borderColor {
	return [UIColor colorWithWhite:1.0 alpha:0.7];
}


@end