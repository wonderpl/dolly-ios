//
//  SYNVideoLoadingView.m
//  dolly
//
//  Created by Sherman Lo on 25/11/13.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNVideoLoadingView.h"
#import "UIFont+SYNFont.h"
#import "VideoInstance.h"
#import "Video.h"
#import "UIImage+Blur.h"
#import <SDWebImageManager.h>

static NSString *const LoadingMessage = @"Your video is loading...";

static const CGFloat TextSideInset = 20.0;

@interface SYNVideoLoadingView ()

@property (nonatomic, strong) CALayer *imageLayer;
@property (nonatomic, strong) CALayer *overlayLayer;
@property (nonatomic, strong) CALayer *textLayer;
@property (nonatomic, strong) CALayer *textOverlayLayer;

@end

@implementation SYNVideoLoadingView

#pragma mark - Init / Dealloc

- (instancetype)initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame]) {
		[self.layer addSublayer:self.imageLayer]; // The actual image
		[self.layer addSublayer:self.overlayLayer]; // The grey overlay over the image
		[self.layer addSublayer:self.textLayer]; // The image masked by the text
		[self.layer addSublayer:self.textOverlayLayer]; // The overlay over the masked text to make it more legible
	}
	return self;
}

#pragma mark - UIView

- (void)layoutSublayersOfLayer:(CALayer *)layer {
	[super layoutSublayersOfLayer:layer];
	
	if (layer == self.layer) {
		self.backgroundColor = [UIColor whiteColor];
		
		self.imageLayer.frame = self.bounds;
		self.overlayLayer.frame = self.bounds;
		self.textLayer.frame = self.bounds;
		self.textOverlayLayer.frame = self.bounds;
		
		NSString *title = self.videoInstance.title;
		self.textLayer.mask = [self createOverlayMaskWithTitle:title subtitle:LoadingMessage];
		self.textOverlayLayer.mask = [self createOverlayMaskWithTitle:title subtitle:LoadingMessage];
	}
}

#pragma mark - Getters / Setters

- (CALayer *)imageLayer {
	if (!_imageLayer) {
		CALayer *layer = [CALayer layer];
		layer.bounds = self.bounds;
		self.imageLayer = layer;
	}
	return _imageLayer;
}

- (CALayer *)overlayLayer {
	if (!_overlayLayer) {
		CALayer *layer = [CALayer layer];
		layer.backgroundColor = [[UIColor colorWithWhite:0.5 alpha:0.36] CGColor];
		layer.bounds = self.bounds;
		self.overlayLayer = layer;
	}
	return _overlayLayer;
}

- (CALayer *)textLayer {
	if (!_textLayer) {
		CALayer *layer = [CALayer layer];
		layer.bounds = self.bounds;
		self.textLayer = layer;
	}
	return _textLayer;
}

- (CALayer *)textOverlayLayer {
	if (!_textOverlayLayer) {
		CALayer *layer = [CALayer layer];
		layer.backgroundColor = [[UIColor colorWithWhite:1.0 alpha:0.4] CGColor];
		layer.bounds = self.bounds;
		self.textOverlayLayer = layer;
	}
	return _textOverlayLayer;
}

- (void)setVideoInstance:(VideoInstance *)videoInstance {
	_videoInstance = videoInstance;
	
	[[SDWebImageManager sharedManager] downloadWithURL:[NSURL URLWithString:videoInstance.video.thumbnailURL]
											   options:0
											  progress:nil
											 completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished) {
												 UIImage *blurredImage = [UIImage blurredImageFromImage:image];
												 self.imageLayer.contents = (__bridge id)blurredImage.CGImage;
												 self.textLayer.contents = (__bridge id)blurredImage.CGImage;
											 }];
}

#pragma mark - Private

- (CALayer *)createOverlayMaskWithTitle:(NSString *)title subtitle:(NSString *)subtitle {
	CALayer *layer = [CALayer layer];
	layer.frame = self.bounds;
	
	UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, [[UIScreen mainScreen] scale]);
	
	NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
	style.alignment = NSTextAlignmentCenter;
	
	UIFont *titleFont = [self titleFont];
	NSDictionary *titleAttributes = @{ NSFontAttributeName : titleFont,
									   NSForegroundColorAttributeName : [UIColor blackColor],
									   NSParagraphStyleAttributeName : style };
	CGRect titleRect = CGRectMake(TextSideInset,
								  CGRectGetHeight(self.bounds) / 4.0,
								  CGRectGetWidth(self.bounds) - TextSideInset * 2,
								  titleFont.pointSize * 2.0);
	[title drawWithRect:titleRect
				options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin
			 attributes:titleAttributes
				context:nil];
	
	UIFont *subtitleFont = [self subtitleFont];
	NSDictionary *subtitleAttributes = @{ NSFontAttributeName : subtitleFont,
										  NSForegroundColorAttributeName : [UIColor blackColor],
										  NSParagraphStyleAttributeName : style };
	CGRect subtitleRect = CGRectMake(TextSideInset,
									 CGRectGetHeight(self.bounds) / 2.0,
									 CGRectGetWidth(self.bounds) - TextSideInset * 2,
									 subtitleFont.pointSize * 2.0);
	[subtitle drawInRect:subtitleRect withAttributes:subtitleAttributes];
	
	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	layer.contents = (__bridge id)([image CGImage]);
	
	UIGraphicsEndImageContext();
	
	return layer;
}

- (UIFont *)titleFont {
	return (IS_IPAD ? [UIFont lightCustomFontOfSize:40.0] : [UIFont lightCustomFontOfSize:20.0]);
}

- (UIFont *)subtitleFont {
	return (IS_IPAD ? [UIFont regularCustomFontOfSize:25.0] : [UIFont regularCustomFontOfSize:14.0]);
}

@end
