//
//  SYNRoundButton.m
//  dolly
//
//  Created by Cong on 21/07/2014.
//  Copyright (c) 2014 Wonder PL Ltd. All rights reserved.
//

#import "SYNRoundButton.h"

@implementation SYNRoundButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
		[self setup];
    }
    return self;
}

- (void) awakeFromNib {
	[super awakeFromNib];
    
	[self setup];
}

- (void)setup {
	self.layer.cornerRadius = self.frame.size.height * 0.5;
	self.layer.masksToBounds = YES;
	self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
	self.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;
}


@end
