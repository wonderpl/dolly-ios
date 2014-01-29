//
//  SYNGradientSeparator.m
//  dolly
//
//  Created by Sherman Lo on 29/01/14.
//  Copyright (c) 2014 Rockpack Ltd. All rights reserved.
//

#import "SYNGradientSeparatorView.h"

@interface SYNGradientSeparatorView ()

@property (nonatomic, strong) CALayer *layerMask;

@end

@implementation SYNGradientSeparatorView

#pragma mark - Nib loading

- (void)awakeFromNib {
	[super awakeFromNib];
	
	self.layer.mask = self.layerMask;
}

#pragma mark - Getters / Setters

- (CALayer *)layerMask {
	if (!_layerMask) {
		CAGradientLayer *mask = [CAGradientLayer layer];
		mask.colors = @[ (id) [[UIColor clearColor] CGColor],
						 (id) [[UIColor whiteColor] CGColor],
						 (id) [[UIColor clearColor] CGColor] ];
		mask.locations = @[ @0.0, @0.5, @1.0 ];
		mask.startPoint = CGPointMake(0.0, 0.5);
		mask.endPoint = CGPointMake(1.0, 0.5);
		
		self.layerMask = mask;
	}
	return _layerMask;
}

#pragma mark - Overridden

- (void)layoutSublayersOfLayer:(CALayer *)layer {
	[super layoutSublayersOfLayer:layer];
	
	self.layerMask.frame = self.bounds;
}

@end
