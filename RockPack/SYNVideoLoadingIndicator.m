//
//  SYNVideoLoadingIndicator.m
//  dolly
//
//  Created by Sherman Lo on 14/11/13.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNVideoLoadingIndicator.h"

static const NSInteger SpinnerDuration = 2.0;

@interface SYNVideoLoadingIndicator ()

@property (nonatomic, strong) UIImageView *logoView;
@property (nonatomic, strong) UIImageView *spinnerView;

@end

@implementation SYNVideoLoadingIndicator

#pragma mark - Init / Dealloc

- (id)initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame]) {
		[self setup];
	}
	return self;
}

#pragma mark - Public

- (void)startAnimating {
	CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
	
	rotationAnimation.toValue = [NSNumber numberWithFloat:M_PI * SpinnerDuration];
	rotationAnimation.duration = SpinnerDuration;
	rotationAnimation.delegate = self;
	
	[self.spinnerView.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}

- (void)stopAnimating {
	[self.spinnerView.layer removeAllAnimations];
}

#pragma mark - Overridden

- (void)awakeFromNib {
	[super awakeFromNib];
	
	[self setup];
}

#pragma mark - CAAnimationDelegate

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)finished {
	if (finished) {
		[self startAnimating]; // Keep repeating the animation forever
	}
}

#pragma mark - Getters / Setters

- (UIImageView *)logoView {
	if (!_logoView) {
		self.logoView = [self imageViewFromImageName:@"PlaceholderVideoTop"];
	}
	return _logoView;
}

- (UIImageView *)spinnerView {
	if (!_spinnerView) {
		self.spinnerView = [self imageViewFromImageName:@"PlaceholderVideoMiddle"];
	}
	return _spinnerView;
}

#pragma mark - Private

- (void)setup {
	[self addSubview:self.logoView];
	[self addSubview:self.spinnerView];
}

- (UIImageView *)imageViewFromImageName:(NSString *)imageName {
	UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
	imageView.center = self.center;
	imageView.backgroundColor = [UIColor clearColor];

	return imageView;
}

@end
