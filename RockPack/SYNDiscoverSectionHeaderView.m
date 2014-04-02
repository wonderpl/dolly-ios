//
//  SYNDiscoverSectionHeaderView.m
//  dolly
//
//  Created by Cong Le on 02/04/2014.
//  Copyright (c) 2014 Wonder PL Ltd. All rights reserved.
//

#import "SYNDiscoverSectionHeaderView.h"
#import "UIFont+SYNFont.h"

@interface SYNDiscoverSectionHeaderView ()


@end

@implementation SYNDiscoverSectionHeaderView


- (void) awakeFromNib {
	[super awakeFromNib];
	self.titleLabel.font = [UIFont lightCustomFontOfSize:23];
}

- (void) prepareForReuse {
	[super prepareForReuse];
}


@end
