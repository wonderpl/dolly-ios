//
//  UILabel+Animation.m
//  dolly
//
//  Created by Sherman Lo on 20/01/14.
//  Copyright (c) 2014 Rockpack Ltd. All rights reserved.
//

#import "UILabel+Animation.h"

static const CGFloat AnimationDuration = 0.3;

@implementation UILabel (Animation)

- (void)setText:(NSString *)text animated:(BOOL)animated {
	if (animated) {
		CATransition *transitionAnimation = [CATransition animation];
		[transitionAnimation setType:kCATransitionFade];
		[transitionAnimation setDuration:AnimationDuration];
		[transitionAnimation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
		[transitionAnimation setFillMode:kCAFillModeBoth];
		[self.layer addAnimation:transitionAnimation forKey:nil];
	}
	self.text = text;
}

@end
