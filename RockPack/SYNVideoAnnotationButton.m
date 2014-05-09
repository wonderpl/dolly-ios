//
//  SYNVideoAnnotationButton.m
//  dolly
//
//  Created by Sherman Lo on 7/05/14.
//  Copyright (c) 2014 Wonder PL Ltd. All rights reserved.
//

#import "SYNVideoAnnotationButton.h"

@implementation SYNVideoAnnotationButton

- (id)initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame]) {
		self.imageView.contentMode = UIViewContentModeScaleAspectFit;
		[self setImage:[UIImage imageNamed:@"ShopMotionActionButton"] forState:UIControlStateNormal];
	}
	return self;
}

@end
