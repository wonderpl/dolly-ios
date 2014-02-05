//
//  SYNFacebookButton.m
//  dolly
//
//  Created by Sherman Lo on 31/01/14.
//  Copyright (c) 2014 Rockpack Ltd. All rights reserved.
//

#import "SYNFacebookButton.h"
#import "UIColor+SYNColor.h"
#import "UIFont+SYNFont.h"

@implementation SYNFacebookButton

- (void)awakeFromNib {
	[super awakeFromNib];
	
	self.layer.cornerRadius = CGRectGetHeight(self.bounds) / 2.0;
	
	self.layer.borderColor = [[UIColor facebookColor] CGColor];
	self.layer.borderWidth = 2.0;
	
	self.titleLabel.font = [UIFont regularCustomFontOfSize:self.titleLabel.font.pointSize];
}

@end