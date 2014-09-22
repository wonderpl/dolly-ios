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
@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, assign) BOOL maximise;

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
    self.imageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin |UIViewAutoresizingFlexibleTopMargin |UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;
    self.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin |UIViewAutoresizingFlexibleTopMargin |UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;
    self.loadingLabel.font = [UIFont lightCustomFontOfSize:self.loadingLabel.font.pointSize];
	self.activityIndicator.transform = CGAffineTransformMakeScale(0.7, 0.7);
    self.titleLabel.font = [UIFont boldCustomFontOfSize:self.titleLabel.font.pointSize];
}

#pragma mark - Getters / Setters

- (void)setVideoInstance:(VideoInstance *)videoInstance {
	_videoInstance = videoInstance;
    __weak SYNVideoLoadingView* wself = self;

	[[SYNVideoThumbnailDownloader sharedDownloader] blurredImageForVideoInstance:wself.videoInstance.video completion:^(UIImage *image) {
		wself.imageView.image = image;
	}];
    
    [self.titleLabel setText:videoInstance.title];

}

- (void) setFullscreen:(BOOL)fullscreen {
    _fullscreen = fullscreen;
    if (self.fullscreen) {
        self.titleLabel.hidden = NO;
    } else {
        self.titleLabel.hidden = YES;
    }
}


@end
