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

- (void)cellDisplayEnded {
	[self.videoPlayer pause];
	
	[self.videoPlayer removeFromSuperview];
	self.videoPlayer = nil;
	self.videoPlayer.delegate = nil;
}

- (void)setVideoPlayer:(SYNVideoPlayer *)videoPlayer {
	_videoPlayer = videoPlayer;
	
	videoPlayer.frame = self.bounds;
	videoPlayer.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
	
	[self addSubview:videoPlayer];
}

@end
