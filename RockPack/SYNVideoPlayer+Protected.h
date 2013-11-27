//
//  SYNVideoPlayer+Protected.h
//  dolly
//
//  Created by Sherman Lo on 27/11/13.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

@interface SYNVideoPlayer (Protected)

- (void)handleVideoPlayerStartedPlaying;
- (void)handleVideoPlayerFinishedPlaying;
- (void)handleVideoPlayerError:(NSString *)errorString;

@end