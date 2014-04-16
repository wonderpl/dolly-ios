//
//  SYNProfileCollectionFollowButton.m
//  dolly
//
//  Created by Cong Le on 15/04/2014.
//  Copyright (c) 2014 Wonder PL Ltd. All rights reserved.
//

#import "SYNFollowChannelButton.h"
#import "UIColor+SYNColor.h"
#import "UIFont+SYNFont.h"

@implementation SYNFollowChannelButton


-(void)awakeFromNib
{
    [super awakeFromNib];
	self.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.45];
}

- (UIColor*) selectedColor {
	return [UIColor dollyGreen];
}

- (UIColor*) defaultColor {
	return [UIColor dollyTextMediumGray];
}

- (UIFont*)selectedFont {
	return [UIFont regularCustomFontOfSize:14.0f];
}

- (UIFont*)defaultFont {
	return [UIFont regularCustomFontOfSize:14.0f];
}

- (UIColor*) selectedBorderColor {
	return [UIColor dollyGreen];
}

- (UIColor*) defaultBorderColor {
	return [UIColor dollyTextMediumGray];
}


@end
