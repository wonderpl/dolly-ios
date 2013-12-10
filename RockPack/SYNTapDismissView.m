//
//  SYNTapDismissView.m
//  dolly
//
//  Created by Sherman Lo on 12/11/13.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNTapDismissView.h"

@interface SYNTapDismissView () <UIGestureRecognizerDelegate>

@end

@implementation SYNTapDismissView

#pragma mark - Init / Dealloc

- (instancetype)initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame]) {
		self.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.4];
		self.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
		
		UIGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
		gestureRecognizer.delegate = self;
		[self addGestureRecognizer:gestureRecognizer];
	}
	return self;
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
	// We only want to recognize touches directly on this view, not on subviews
	return (touch.view == self);
}

#pragma mark - Private

- (void)viewTapped:(UITapGestureRecognizer *)gestureRecognizer {
	if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
		[self.parentViewController dismissViewControllerAnimated:YES completion:nil];
	}
}

@end
