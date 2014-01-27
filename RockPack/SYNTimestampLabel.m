//
//  SYNTimestampLabel.m
//  dolly
//
//  Created by Sherman Lo on 27/01/14.
//  Copyright (c) 2014 Rockpack Ltd. All rights reserved.
//

#import "SYNTimestampLabel.h"
#import "UIFont+SYNFont.h"

@implementation SYNTimestampLabel

- (void)awakeFromNib {
	[super awakeFromNib];
	
	self.font = [UIFont lightCustomFontOfSize:self.font.pointSize];
}

- (CGSize)intrinsicContentSize {
	CGSize contentSize = [super intrinsicContentSize];
	return CGSizeMake(contentSize.width + 8.0, contentSize.height);
}

@end
