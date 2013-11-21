//
//  SYNVideoPlayer.h
//  dolly
//
//  Created by Sherman Lo on 14/11/13.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef NS_ENUM(NSInteger, SYNVideoPlayerState) {
	SYNVideoPlayerStateInitialised,
	SYNVideoPlayerStatePlaying,
	SYNVideoPlayerStatePaused
};

@class Video;
@class SYNScrubberBar;

@protocol SYNVideoPlayerDelegate <NSObject>

- (void)videoPlayerMaximise;
- (void)videoPlayerMinimise;

- (void)videoPlayerFinishedPlaying;

- (void)videoPlayerErrorOccurred:(NSString *)reason;

@end

@interface SYNVideoPlayer : UIView

@property (nonatomic, assign, readonly) SYNVideoPlayerState state;

@property (nonatomic, assign) id<SYNVideoPlayerDelegate> delegate;

@property (nonatomic, assign) NSTimeInterval currentTime;
@property (nonatomic, assign, getter=isPlaying) BOOL playing;

@property (nonatomic, strong, readonly) UIView *playerContainerView;

@property (nonatomic, strong, readonly) SYNScrubberBar *scrubberBar;

@property (nonatomic, strong) Video *video;

+ (instancetype)playerForVideo:(Video *)video;

- (void)play;
- (void)pause;

- (NSTimeInterval)duration;
- (float)bufferingProgress;

- (void)startUpdatingScrubberProgress;

@end
