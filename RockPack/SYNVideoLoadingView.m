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
#import "SYNVideoThumbnailDownloader.h"

@interface SYNVideoLoadingView ()

@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (nonatomic, strong) IBOutlet UIImageView *imageView;

@property (nonatomic, strong) IBOutlet UILabel *loadingLabel;

@end

@implementation SYNVideoLoadingView

#pragma mark - Factory

+ (instancetype)loadingViewWithFrame:(CGRect)frame {
	UINib *nib = [UINib nibWithNibName:NSStringFromClass(self) bundle:nil];
	
	SYNVideoLoadingView *loadingView = [[nib instantiateWithOwner:self options:nil] firstObject];
	loadingView.frame = frame;
	
	return loadingView;
}

- (void)awakeFromNib {
	[super awakeFromNib];
	
	self.loadingLabel.font = [UIFont lightCustomFontOfSize:self.loadingLabel.font.pointSize];
	
	self.activityIndicator.transform = CGAffineTransformMakeScale(0.7, 0.7);
}

#pragma mark - Getters / Setters

- (void)setVideoInstance:(VideoInstance *)videoInstance {
	_videoInstance = videoInstance;
    __weak SYNVideoLoadingView* wself = self;

	[[SYNVideoThumbnailDownloader sharedDownloader] blurredImageForVideoInstance:wself.videoInstance.video completion:^(UIImage *image) {
		wself.imageView.image = image;
	}];
}

@end
