//
//  SYNYouTubeWebVideoPlayer.h
//  dolly
//
//  Created by Sherman Lo on 14/11/13.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNVideoPlayer.h"

@interface SYNYouTubeWebVideoPlayer : SYNVideoPlayer

//Timer used to relaod videos that are stuck in a buffering state. This timer is invalidated in VideoPlayerView Controller when a new video is selected.

@property (nonatomic, strong) NSTimer *reloadVideoTimer;

@end
