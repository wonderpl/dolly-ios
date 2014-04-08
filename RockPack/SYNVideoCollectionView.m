//
//  SYNVideoCollectionView.m
//  dolly
//
//  Created by Sherman Lo on 30/01/14.
//  Copyright (c) 2014 Rockpack Ltd. All rights reserved.
//

#import "SYNVideoCollectionView.h"
#import "SYNScrubberBar.h"

@implementation SYNVideoCollectionView

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
	// If the user is interacting with the scrubber then we don't want to unexpectedly scroll the video
	return ![self isTouchInScrubberBar:touch];
}

- (BOOL)isTouchInScrubberBar:(UITouch *)touch {
	for (UIView *view = touch.view; view != self; view = [view superview]) {
		if ([view isKindOfClass:[SYNScrubberBar class]]) {
			return YES;
		}
	}
	return NO;
}

@end
