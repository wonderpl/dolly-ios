//
//  SYNVideoPlayerCell.m
//  dolly
//
//  Created by Sherman Lo on 1/04/14.
//  Copyright (c) 2014 Wonder PL Ltd. All rights reserved.
//

#import "SYNVideoPlayerCell.h"
#import "SYNVideoPlayer.h"
#import "VideoInstance.h"

@interface SYNVideoPlayerCell ()

@end

@implementation SYNVideoPlayerCell

- (void)awakeFromNib {
    self.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}

- (void)prepareForReuse {
	[self.videoPlayer removeFromSuperview];
}

- (void)setVideoPlayer:(SYNVideoPlayer *)videoPlayer {
	_videoPlayer = videoPlayer;
	
    videoPlayer.frame = self.bounds;
    videoPlayer.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    
    [self.contentView addSubview:videoPlayer];
}

@end
