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

@class VideoInstance;
@class SYNScrubberBar;
@class SYNVideoLoadingView;

@protocol SYNVideoPlayerDelegate <NSObject>

- (void)videoPlayerMaximise;
- (void)videoPlayerMinimise;

- (void)videoPlayerVideoViewed;
- (void)videoPlayerFinishedPlaying;

- (void)videoPlayerErrorOccurred:(NSString *)reason;

@end

@interface SYNVideoPlayer : UIView

@property (nonatomic, assign, readonly) SYNVideoPlayerState state;

@property (nonatomic, weak) id<SYNVideoPlayerDelegate> delegate;

@property (nonatomic, assign) NSTimeInterval currentTime;
@property (nonatomic, assign) BOOL maximised;

@property (nonatomic, strong, readonly) UIView *playerContainerView;

+ (instancetype)playerForVideoInstance:(VideoInstance *)videoInstance;

- (void)play;
- (void)pause;

- (NSTimeInterval)duration;

@end
