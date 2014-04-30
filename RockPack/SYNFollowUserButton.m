//
//  SYNFollowUserButton.m
//  dolly
//
//  Created by Cong on 07/01/2014.
//  Copyright (c) 2014 Rockpack Ltd. All rights reserved.
//

#import "SYNFollowUserButton.h"
#import "UIColor+SYNColor.h"
#import "UIFont+SYNFont.h"

@implementation SYNFollowUserButton


-(void)awakeFromNib
{
    [super awakeFromNib];
	self.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.45];
	
	self.layer.masksToBounds = NO;
	self.layer.shadowColor = [UIColor blackColor].CGColor;
	self.layer.shadowOpacity = 0.4;
	self.layer.shadowOffset = CGSizeMake(0.0f, 2.0f);

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

- (UIColor*) selectedBorderColor {
	return [UIColor colorWithWhite:1.0 alpha:0.7];
}

- (UIColor*) defaultBorderColor {
	return [UIColor colorWithWhite:1.0 alpha:0.7];
}

@end
