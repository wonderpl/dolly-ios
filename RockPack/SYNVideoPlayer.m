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
#import "VideoAnnotation.h"
#import "SYNVideoAnnotationButton.h"
#import "SYNVideoLoadingView.h"
#import "SYNVideoPlayer+Protected.h"

static CGFloat const VideoViewedThresholdPercentage = 0.1;
static CGFloat const ControlsFadeTimer = 5.0;

@interface SYNVideoPlayer () <SYNScrubberBarDelegate>

@property (nonatomic, assign) SYNVideoPlayerState state;

@property (nonatomic, strong) SYNVideoLoadingView *loadingView;

@property (nonatomic, strong) UITapGestureRecognizer *maximiseMinimiseGestureRecognizer;
@property (nonatomic, strong) UIPinchGestureRecognizer *maximiseMinimisePinchGestureRecognizer;
@property (nonatomic, strong) SYNScrubberBar *scrubberBar;
@property (nonatomic, strong) UIView *playerContainerView;
@property (nonatomic, strong) UIView *controlsFadeTapView;

@property (nonatomic, strong) NSTimer *progressUpdateTimer;
@property (nonatomic, strong) NSTimer *controlsFadeTimer;
@property (nonatomic, strong) UIView *videoPlayerView;

@property (nonatomic, assign) BOOL controlsVisible;
@property (nonatomic, assign) BOOL videoViewed;
@property (nonatomic, assign) BOOL hasBeganPlaying;
@property (nonatomic, copy) NSArray *annotationButtons;

@end


@implementation SYNVideoPlayer

#pragma mark - Public class

+ (instancetype)playerForVideoInstance:(VideoInstance *)videoInstance {
	Class videoPlayerClass = [self videoPlayerClassesForSource:videoInstance.video.source];
	SYNVideoPlayer *player = [[videoPlayerClass alloc] init];
	player.videoInstance = videoInstance;
	
	return player;
}

#pragma mark - Init / Dealloc

- (id)initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame]) {
		self.backgroundColor = [UIColor blackColor];
		
		[self addSubview:self.playerContainerView];
		[self addSubview:self.loadingView];
	}
	return self;
}

#pragma mark - Overridden

- (void)layoutSubviews {
	[super layoutSubviews];
	
	for (SYNVideoAnnotationButton *button in self.annotationButtons) {
		button.frame = [button.videoAnnotation frameForAnnotationInRect:self.bounds];
	}
}

#pragma mark - SYNScrubberBarDelegate

- (void)scrubberBarPlayPauseToggled:(BOOL)playing {
	if (playing) {
		[self play];
	} else {
		[self pause];
	}
}

- (void)scrubberBarFullscreenToggled:(BOOL)fullscreen {
	if (fullscreen) {
		[self handleVideoPlayerMaximise];
	} else {
		[self handleVideoPlayerMinimise];
	}
}

- (void)scrubberBarCurrentTimeWillChange {
	// We don't want the controls to fade out while they're interacting with them
	[self stopControlsFadeTimer];
	
	[self pause];
}

- (void)scrubberBarCurrentTimeChanged:(NSTimeInterval)currentTime {
	self.currentTime = currentTime;
}

- (void)scrubberBarCurrentTimeDidChange {
	[self startControlsTimer];
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
		scrubberBar.alpha = 0.0;
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
		SYNVideoLoadingView *loadingView = [SYNVideoLoadingView loadingViewWithFrame:self.bounds];
		loadingView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
        self.loadingView = loadingView;
        self.loadingView.fullscreen = self.maximised;
	}
	return _loadingView;
}

- (UIView *)controlsFadeTapView {
	if (!_controlsFadeTapView) {
		UIView *view = [[UIView alloc] initWithFrame:self.bounds];
		view.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
		
		UIGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(controlsFadeViewTapped:)];
		[view addGestureRecognizer:gestureRecognizer];
		
		self.controlsFadeTapView = view;
	}
	return _controlsFadeTapView;
}

- (UITapGestureRecognizer *)maximiseMinimiseGestureRecognizer {
	if (!_maximiseMinimiseGestureRecognizer) {
		UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                            action:@selector(maximiseMinimiseGestureRecognizerTapped:)];
		gestureRecognizer.numberOfTapsRequired = 2;
		
		self.maximiseMinimiseGestureRecognizer = gestureRecognizer;
	}
	return _maximiseMinimiseGestureRecognizer;
}

- (UIPinchGestureRecognizer *)maximiseMinimisePinchGestureRecognizer {
	if (!_maximiseMinimisePinchGestureRecognizer) {
		UIPinchGestureRecognizer *gestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self
                                                                                                action:@selector(maximiseMinimisePinchGestureRecognizerTapped:)];
        
		self.maximiseMinimisePinchGestureRecognizer = gestureRecognizer;
	}
	return _maximiseMinimisePinchGestureRecognizer;
}


- (void)setVideoInstance:(VideoInstance *)videoInstance {
	_videoInstance = videoInstance;
    self.loadingView.videoInstance = videoInstance;
}

- (void)play {
	if (!self.hasBeganPlaying) {
		self.videoPlayerView.frame = self.playerContainerView.bounds;
		[self.playerContainerView addSubview:self.videoPlayerView];
		[self.playerContainerView addSubview:self.controlsFadeTapView];
		[self.playerContainerView addSubview:self.scrubberBar];
		
		[self addGestureRecognizer:self.maximiseMinimiseGestureRecognizer];
		[self addGestureRecognizer:self.maximiseMinimisePinchGestureRecognizer];

		
		self.hasBeganPlaying = YES;
	}
	
	self.state = SYNVideoPlayerStatePlaying;

	self.scrubberBar.playing = YES;
    [self startUpdatingProgress];

}

- (void)pause {
	self.state = SYNVideoPlayerStatePaused;
	self.scrubberBar.playing = NO;
	[self stopControlsFadeTimer];
	[self stopUpdatingProgress];
}

- (void)stop {
	self.state = SYNVideoPlayerStateInitialised;
	self.hasBeganPlaying = NO;
	
	[self stopControlsFadeTimer];
	[self stopUpdatingProgress];
}

- (NSTimeInterval)duration {
	return 0.0;
}

- (float)bufferingProgress {
	return 0.0;
}

#pragma mark - Protected

- (void)handleVideoPlayerStartedPlaying {
	self.scrubberBar.playing = YES;
	
	[self fadeOutLoadingView];
    
	[self fadeInControls];
	
	[self.delegate videoPlayerStartedPlaying];
}

- (void)handleVideoPlayerPaused {
	self.scrubberBar.playing = NO;
}

- (void)handleVideoPlayerFinishedPlaying {
	if (self.state != SYNVideoPlayerStateEnded) {
		self.state = SYNVideoPlayerStateEnded;
		
		[self.delegate videoPlayerFinishedPlaying];
	}
}

- (void)handleVideoPlayerResolutionChanged:(BOOL)highDefinition {
	self.scrubberBar.highDefinition = highDefinition;
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

- (void)controlsFadeViewTapped:(UITapGestureRecognizer *)tapGestureRecognizer {
	if (self.controlsVisible) {
		[self fadeOutControls];
	} else {
		[self fadeInControls];
	}
}

- (void)fadeOutLoadingView {
	[UIView animateWithDuration:0.3 animations:^{
		self.loadingView.alpha = 0.0;
	} completion:^(BOOL finished) {
		[self.loadingView removeFromSuperview];
		self.loadingView = nil;
	}];
}

- (void)fadeInControls {
	[self startControlsTimer];
	self.controlsVisible = YES;
	
	[UIView animateWithDuration:0.3 animations:^{
		self.scrubberBar.alpha = 1.0;
	}];
}

- (void)fadeOutControls {
	[self stopControlsFadeTimer];
	self.controlsVisible = NO;
	
	[UIView animateWithDuration:0.3 animations:^{
		self.scrubberBar.alpha = 0.0;
	}];
}

- (void)stopControlsFadeTimer {
	[self.controlsFadeTimer invalidate];
	self.controlsFadeTimer = nil;
}

- (void)startControlsTimer {
	[self.controlsFadeTimer invalidate];
	self.controlsFadeTimer = [NSTimer scheduledTimerWithTimeInterval:ControlsFadeTimer
															  target:self
															selector:@selector(fadeOutControls)
															userInfo:nil
															 repeats:NO];
}

- (void)startUpdatingProgress {
    
    if (self.progressUpdateTimer) {
        [self.progressUpdateTimer invalidate];
    }
	self.progressUpdateTimer = [NSTimer timerWithTimeInterval:0.25
													   target:self
													 selector:@selector(updateProgress)
													 userInfo:nil
													  repeats:YES];
	
	[[NSRunLoop mainRunLoop] addTimer:self.progressUpdateTimer forMode:NSRunLoopCommonModes];
	
}

- (void)stopUpdatingProgress {
	[self.progressUpdateTimer invalidate];
	self.progressUpdateTimer = nil;
}

- (void)updateProgress {
	if (!self.videoViewed) {
		CGFloat viewedPercentage = (self.currentTime / self.duration);
		if (viewedPercentage > VideoViewedThresholdPercentage) {
			self.videoViewed = YES;
			[self.delegate videoPlayerVideoViewed];
		}
	}
	
	self.scrubberBar.duration = self.duration;
	self.scrubberBar.currentTime = self.currentTime;
	self.scrubberBar.bufferingProgress = self.bufferingProgress;
	
	[self updateAnnotationButtonsForTime:self.currentTime];
}

- (void)maximiseMinimisePinchGestureRecognizerTapped:(UIPinchGestureRecognizer *)gestureRecognizer {
	if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
		BOOL pinchedIn = (gestureRecognizer.scale < 1.0);
		if (pinchedIn && self.maximised) {
			[self handleVideoPlayerMinimise];
		} else if (!pinchedIn && !self.maximised) {
			[self handleVideoPlayerMaximise];
		}
	}
}

- (void)maximiseMinimiseGestureRecognizerTapped:(UITapGestureRecognizer *)gestureRecognizer {
	if (self.maximised) {
		[self handleVideoPlayerMinimise];
	} else {
		[self handleVideoPlayerMaximise];
	}
}

- (void)handleVideoPlayerMaximise {
	self.maximised = YES;
	self.scrubberBar.fullscreen = YES;
    [self.delegate videoPlayerMaximise];
}

- (void)handleVideoPlayerMinimise {
	self.maximised = NO;
	self.scrubberBar.fullscreen = NO;
	[self.delegate videoPlayerMinimise];
}

- (void)annotationButtonPressed:(SYNVideoAnnotationButton *)button {
	[self.delegate videoPlayerAnnotationSelected:button.videoAnnotation button:button];
}

- (void)updateAnnotationButtonsForTime:(NSTimeInterval)time {
	NSSet *currentAnnotations = [self.videoInstance.video annotationsAtTime:time];
	
	NSMutableArray *annotationButtons = [NSMutableArray arrayWithArray:self.annotationButtons];
	NSMutableSet *existingAnnotations = [NSMutableSet set];
	
	// Remove existing buttons which no longer have an annotation
	for (SYNVideoAnnotationButton *annotationButton in [annotationButtons copy]) {
		if ([currentAnnotations containsObject:annotationButton.videoAnnotation]) {
			[existingAnnotations addObject:annotationButton.videoAnnotation];
		} else {
			[annotationButton removeFromSuperview];
			[annotationButtons removeObject:annotationButton];
		}
	}
	
	// Now create new buttons for new annotations
	for (VideoAnnotation *annotation in currentAnnotations) {
		if (![existingAnnotations containsObject:annotation]) {
			CGRect frame = [annotation frameForAnnotationInRect:self.bounds];
			SYNVideoAnnotationButton *button = [[SYNVideoAnnotationButton alloc] initWithFrame:frame];
			button.videoAnnotation = annotation;
			[button addTarget:self action:@selector(annotationButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
			
			[annotationButtons addObject:button];
			[self.playerContainerView addSubview:button];
		}
	}
	
	self.annotationButtons = annotationButtons;
}

- (void)setMaximised:(BOOL)maximised {
    _maximised = maximised;
    self.loadingView.fullscreen = _maximised;
}

@end
