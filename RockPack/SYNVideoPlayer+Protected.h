//
//  SYNVideoPlayer+Protected.h
//  dolly
//
//  Created by Sherman Lo on 27/11/13.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

@interface SYNVideoPlayer ()

@property (nonatomic, strong) VideoInstance *videoInstance;

- (void)handleVideoPlayerStartedPlaying;
- (void)handleVideoPlayerFinishedPlaying;
- (void)handleVideoPlayerPaused;
- (void)handleVideoPlayerResolutionChanged:(BOOL)highDefinition;
- (void)handleVideoPlayerError:(NSString *)errorString;

@end