//
//  SYNTabBar.m
//  dolly
//
//  Created by Sherman Lo on 10/01/14.
//  Copyright (c) 2014 Rockpack Ltd. All rights reserved.
//

#import "SYNTabBar.h"

@interface SYNTabBar ()

@property (nonatomic, strong) CALayer *topLineLayer;

@end

@implementation SYNTabBar

#pragma mark - Overridden

- (void)awakeFromNib {
	[super awakeFromNib];
	
	if (IS_IPHONE) {
		[self.layer addSublayer:self.topLineLayer];
	}
}

- (void)layoutSublayersOfLayer:(CALayer *)layer {
	[super layoutSublayersOfLayer:layer];
	
	CGFloat scale = [[UIScreen mainScreen] scale];
	self.topLineLayer.bounds = CGRectMake(0, 0, CGRectGetWidth(layer.bounds) * scale, 1.0 / scale);
}

#pragma mark - Getters / Setters

- (CALayer *)topLineLayer {
	if (!_topLineLayer) {
		CALayer *layer = [CALayer layer];
		layer.contentsScale = self.layer.contentsScale;
		layer.backgroundColor = [[UIColor colorWithRed:100/255.0 green:88/255.0 blue:112/255.0 alpha:1.0] CGColor];
		
		self.topLineLayer = layer;
	}
	return _topLineLayer;
}

@end
