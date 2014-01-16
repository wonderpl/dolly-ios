//
//  SYNGradientView.m
//  dolly
//
//  Created by Sherman Lo on 14/01/14.
//  Copyright (c) 2014 Rockpack Ltd. All rights reserved.
//

#import "SYNGradientMaskView.h"

@implementation SYNGradientMaskView

- (void)awakeFromNib {
	[super awakeFromNib];
	
	self.backgroundColor = [UIColor whiteColor];
	
	CAGradientLayer *mask = [CAGradientLayer layer];
	mask.colors = @[ (id)[[UIColor whiteColor] CGColor],
					 (id)[[UIColor clearColor] CGColor],
					 (id)[[UIColor clearColor] CGColor],
					 (id)[[UIColor whiteColor] CGColor] ];
	mask.locations = @[ @0.0, @0.2, @0.8, @1.0 ];
	
	mask.frame = self.layer.bounds;
	
	self.layer.mask = mask;
}

- (void)layoutSublayersOfLayer:(CALayer *)layer {
	[super layoutSublayersOfLayer:layer];
	
	layer.mask.frame = layer.bounds;
}

@end
