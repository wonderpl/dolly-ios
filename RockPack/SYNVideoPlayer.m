//
//  SYNVideoPlayer.m
//  dolly
//
//  Created by Sherman Lo on 14/11/13.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNVideoPlayer.h"
#import "SYNYouTubeWebVideoPlayer.h"
#import "SYNOoyalaVideoPlayer.h"
#import "SYNScrubberBar.h"
#import "VideoInstance.h"
#import "Video.h"
#import "SYNVideoLoadingView.h"
#import "SYNVideoPlayer+Protected.h"

@interface SYNVideoPlayer () <SYNScrubberBarDelegate>

@property (nonatomic, assign) SYNVideoPlayerState state;

@property (nonatomic, strong) SYNVideoLoadingView *loadingView;

@property (nonatomic, strong) SYNScrubberBar *scrubberBar;
@property (nonatomic, strong) UIView *playerContainerView;
@property (nonatomic, strong) NSTimer *scrubberUpdateTimer;

@end


@implementation SYNVideoPlayer

#pragma mark - Public class

+ (instancetype)playerForVideoInstance:(VideoInstance *)videoInstance {
	Class videoPlayerClass = [self videoPlayerClassesForSource:videoInstance.video.source];
	SYNVideoPlayer *player = [[videoPlayerClass alloc] init];
	player.videoInstance = videoInstance;
	
	return player;
}

- (id)initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame]) {
		[self addSubview:self.playerContainerView];
		[self addSubview:self.loadingView];
		[self addSubview:self.scrubberBar];
	}
	return self;
}

#pragma mark - Overridden

- (void)willMoveToSuperview:(UIView *)newSuperview {
	[super willMoveToSuperview:newSuperview];
	
	if (!newSuperview) {
		[self stopUpdatingScrubberProgress];
	}
}

#pragma mark - SYNScrubberBarDelegate

- (void)scrubberBarFullScreenToggled:(BOOL)fullScreen {
	if (fullScreen) {
		[self.delegate videoPlayerMaximise];
	} else {
		[self.delegate videoPlayerMinimise];
	}
}

- (void)scrubberBarPlayPauseToggled:(BOOL)playing {
	if (playing) {
		[self play];
	} else {
		[self pause];
	}
}

- (void)scrubberBarCurrentTimeWillChange {
	[self pause];
}

- (void)scrubberBarCurrentTimeChanged:(NSTimeInterval)currentTime {
	self.currentTime = currentTime;
}

- (void)scrubberBarCurrentTimeDidChange {
	[self play];
}

#pragma mark - Getters / Setters

- (UIView *)playerContainerView {
	if (!_playerContainerView) {
		UIView *view = [[UIView alloc] initWithFrame:self.bounds];
		view.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
		
		self.playerContainerView = view;
	}
	return _playerContainerView;
}

- (SYNScrubberBar *)scrubberBar {
	if (!_scrubberBar) {
		SYNScrubberBar *scrubberBar = [SYNScrubberBar view];
		scrubberBar.frame = CGRectMake(0,
									   CGRectGetHeight(self.frame) - CGRectGetHeight(scrubberBar.frame),
									   CGRectGetWidth(self.frame),
									   CGRectGetHeight(scrubberBar.frame));
		scrubberBar.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin);
		scrubberBar.delegate = self;
		
		self.scrubberBar = scrubberBar;
	}
	return _scrubberBar;
}

- (SYNVideoLoadingView *)loadingView {
	if (!_loadingView) {
		SYNVideoLoadingView *loadingView = [[SYNVideoLoadingView alloc] initWithFrame:self.bounds];
		loadingView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
		
		self.loadingView = loadingView;
	}
	return _loadingView;
}

- (void)setVideoInstance:(VideoInstance *)videoInstance {
	_videoInstance = videoInstance;
	
	self.loadingView.videoInstance = videoInstance;
}

- (void)play {
	self.state = SYNVideoPlayerStatePlaying;
	
	[self startUpdatingScrubberProgress];
	self.scrubberBar.playing = YES;
}

- (void)pause {
	self.state = SYNVideoPlayerStatePaused;
	
	self.scrubberBar.playing = NO;
}

- (NSTimeInterval)duration {
	return 0.0;
}

- (float)bufferingProgress {
	return 0.0;
}

#pragma mark - Protected

- (void)handleVideoPlayerStartedPlaying {
	[self fadeOutLoadingView];
}

- (void)handleVideoPlayerFinishedPlaying {
	[self.delegate videoPlayerFinishedPlaying];
}

- (void)handleVideoPlayerError:(NSString *)errorString {
	[self fadeOutLoadingView];
	
	[self.delegate videoPlayerErrorOccurred:errorString];
}

#pragma mark - Private class

+ (Class)videoPlayerClassesForSource:(NSString *)source {
	NSDictionary *mapping = @{
							  VideoSourceYouTube : [SYNYouTubeWebVideoPlayer class],
							  VideoSourceOoyala  : [SYNOoyalaVideoPlayer class]
							  };
	return mapping[source];
}

#pragma mark - Private

- (void)fadeOutLoadingView {
	[UIView animateWithDuration:0.3 animations:^{
		self.loadingView.alpha = 0.0;
	}];
}

- (void)startUpdatingScrubberProgress {
	self.scrubberUpdateTimer = [NSTimer timerWithTimeInterval:0.1
													   target:self
													 selector:@selector(updateScrubberBarProgress)
													 userInfo:nil
													  repeats:YES];
	
	[[NSRunLoop mainRunLoop] addTimer:self.scrubberUpdateTimer forMode:NSRunLoopCommonModes];
}

- (void)stopUpdatingScrubberProgress {
	[self.scrubberUpdateTimer invalidate];
	self.scrubberUpdateTimer = nil;
}

- (void)updateScrubberBarProgress {
	self.scrubberBar.duration = self.duration;
	self.scrubberBar.currentTime = self.currentTime;
	self.scrubberBar.bufferingProgress = self.bufferingProgress;
}

@end
