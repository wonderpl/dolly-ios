//
//  SYNCollectionVideoCell.m
//  dolly
//
//  Created by Michael Michailidis on 06/11/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNCollectionVideoCell.h"
#import "UIFont+SYNFont.h"
#import "Video.h"
#import "NSString+Timecode.h"
#import <UIImageView+WebCache.h>
#import "SYNVideoActionsBar.h"

@interface SYNCollectionVideoCell () <SYNVideoActionsBarDelegate>
@property (nonatomic, strong) SYNVideoActionsBar *actionsBar;


@end

@implementation SYNCollectionVideoCell 

- (void)awakeFromNib{
    [super awakeFromNib];
	self.actionsBar.frame = self.videoActionsContainer.bounds;
	[self.videoActionsContainer addSubview:self.actionsBar];
	
	self.titleLabel.font = [UIFont boldCustomFontOfSize:self.titleLabel.font.pointSize];
	self.durationLabel.font = [UIFont regularCustomFontOfSize:self.durationLabel.font.pointSize];
	
	self.imageView.layer.borderColor = [[UIColor colorWithWhite:0 alpha:0.05] CGColor];
	self.imageView.layer.borderWidth = 1.0;

}

#pragma mark - Set Video Instance

- (void)setVideoInstance: (VideoInstance *) videoInstance{
    _videoInstance = videoInstance;
    
	
	self.durationLabel.text = [NSString friendlyLengthFromTimeInterval:videoInstance.video.durationValue];

    
    if (!_videoInstance)
        return;
    
    [self.imageView setImageWithURL: [NSURL URLWithString: videoInstance.thumbnailURL]
                   placeholderImage: [UIImage imageNamed: @"PlaceholderChannelSmall.png"]
                            options: SDWebImageRetryFailed];
    
    self.titleLabel.text = videoInstance.title;
}

#pragma mark - Set delegate


- (void)setDelegate:(id<SYNSocialActionsDelegate>)delegate {
    _delegate = delegate;
    
    //set an extra delete delegate
    [self.deleteButton addTarget:_delegate
                          action:@selector(deleteVideoInstancePressed:)
                   forControlEvents:UIControlEventTouchUpInside];

}

- (void)setUpVideoTap {
    // Tap for showing video
    self.tap = [[UITapGestureRecognizer alloc] initWithTarget: self
                                                       action: @selector(showVideo)];
    [self.imageView addGestureRecognizer: self.tap];

}

- (void)showVideo {
    [self.delegate videoButtonPressed:self];
}

- (SYNVideoActionsBar *)actionsBar {
	if (!_actionsBar) {
		SYNVideoActionsBar *bar = [SYNVideoActionsBar bar];
		bar.delegate = self;
		
		self.actionsBar = bar;
	}
	return _actionsBar;
}



- (void)videoActionsBar:(SYNVideoActionsBar *)bar favouritesButtonPressed:(UIButton *)button {
	
}
- (void)videoActionsBar:(SYNVideoActionsBar *)bar addToChannelButtonPressed:(UIButton *)button {
	
}
- (void)videoActionsBar:(SYNVideoActionsBar *)bar shareButtonPressed:(UIButton *)button {
	
}


@end
