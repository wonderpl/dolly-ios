//
//  SYNAvatarButton.m
//  dolly
//
//  Created by Nick Banks on 07/11/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNAvatarButton.h"

@implementation SYNAvatarButton

- (void) awakeFromNib {
	[super awakeFromNib];

	self.layer.cornerRadius = self.frame.size.height * 0.5;

	self.layer.masksToBounds = YES;
	
	self.layer.borderColor = [[UIColor colorWithWhite:219.0 alpha:1.0] CGColor];
	self.layer.borderWidth = (IS_RETINA ? 0.5 : 1.0);

	self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
	self.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;
}

@end
