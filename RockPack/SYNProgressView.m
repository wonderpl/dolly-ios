//
//  SYNProgressView.m
//  rockpack
//
//  Created by Nick Banks on 10/09/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNProgressView.h"

@interface SYNProgressView ()

@property (nonatomic, strong) UIImageView *trackImageView;
@property (nonatomic, strong) UIImageView *progressImageView;

@end

@implementation SYNProgressView

#pragma mark - Init / Dealloc

- (instancetype)initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame]) {
		[self setup];
	}
	return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
	if (self = [super initWithCoder:aDecoder]) {
		[self setup];
	}
	return self;
}

#pragma mark - Getters / Setters

- (UIImageView *)progressImageView {
	if (!_progressImageView) {
		UIImage *progressImage = [[UIImage imageNamed: @"ShuttleBarBufferBar.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0f, 10.0f, 0.0f, 10.0f)];
		
		UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 0.0, CGRectGetHeight(self.bounds))];
		imageView.image = progressImage;
		
		self.progressImageView = imageView;
	}
	return _progressImageView;
}

- (UIImageView *)trackImageView {
	if (!_trackImageView) {
		UIImage *trackImage = [[UIImage imageNamed: @"ShuttleBarPlayerBar.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0f, 10.0f, 0.0f, 10.0f)];
		
		UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.bounds];
		imageView.image = trackImage;
		imageView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
		
		self.trackImageView = imageView;
	}
	return _trackImageView;
}

- (void)setProgress:(float)progress {
	_progress = progress;
	
	[self updateProgressView];
}

#pragma mark - Overridden

- (void)layoutSubviews {
	[super layoutSubviews];
	
	[self updateProgressView];
}

#pragma mark - Private

- (void)setup {
	self.backgroundColor = [UIColor clearColor];
	
	[self addSubview:self.trackImageView];
	[self addSubview:self.progressImageView];
}

- (void)updateProgressView {
	self.progressImageView.frame = CGRectMake(CGRectGetMinX(self.progressImageView.frame),
											  CGRectGetMinY(self.progressImageView.frame),
											  round(CGRectGetWidth(self.frame) * MIN(self.progress, 1.0)),
											  CGRectGetHeight(self.progressImageView.frame));
}

@end
