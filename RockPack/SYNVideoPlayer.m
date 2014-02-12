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

static CGFloat const VideoViewedThresholdPercentage = 0.1;
static CGFloat const ControlsFadeTimer = 5.0;

@interface SYNVideoPlayer () <SYNScrubberBarDelegate>

@property (nonatomic, assign) SYNVideoPlayerState state;

@property (nonatomic, strong) SYNVideoLoadingView *loadingView;

@property (nonatomic, strong) UITapGestureRecognizer *maximiseMinimiseGestureRecognizer;
@property (nonatomic, strong) UIPinchGestureRecognizer *maximiseMinimisePintchGestureRecognizer;
@property (nonatomic, strong) SYNScrubberBar *scrubberBar;
@property (nonatomic, strong) UIView *playerContainerView;
@property (nonatomic, strong) NSTimer *progressUpdateTimer;

@property (nonatomic, strong) UIView *controlsFadeTapView;
@property (nonatomic, strong) NSTimer *controlsFadeTimer;
@property (nonatomic, assign) BOOL controlsVisible;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;

@property (nonatomic, assign) BOOL userPinchedIn;
@property (nonatomic, assign) BOOL userPinchedOut;

@property (nonatomic, assign) BOOL videoViewed;

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
		[self addSubview:self.controlsFadeTapView];
		[self addSubview:self.loadingView];
		[self addSubview:self.scrubberBar];
        [self.loadingView addSubview:self.activityIndicator];
        
		[self addGestureRecognizer:self.maximiseMinimiseGestureRecognizer];
        [self addGestureRecognizer:self.maximiseMinimisePintchGestureRecognizer];
	}
	return self;
}

#pragma mark - Overridden

- (void)willMoveToSuperview:(UIView *)newSuperview {
	[super willMoveToSuperview:newSuperview];
	
	if (!newSuperview) {
		[self stopControlsTimer];
		[self stopUpdatingProgress];
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
	// We don't want the controls to fade out while they're interacting with them
	[self stopControlsTimer];
	
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
		SYNVideoLoadingView *loadingView = [[SYNVideoLoadingView alloc] initWithFrame:self.bounds];
		loadingView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
		
		self.loadingView = loadingView;
	}
	return _loadingView;
}

- (UIActivityIndicatorView*) activityIndicator {
    if (!_activityIndicator) {
        
        UIActivityIndicatorView* activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleGray];
        [activityIndicator startAnimating];
        self.activityIndicator = activityIndicator;
        
        
        
    }
    
    return _activityIndicator;
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

- (UIPinchGestureRecognizer *)maximiseMinimisePintchGestureRecognizer {
	if (!_maximiseMinimisePintchGestureRecognizer) {
		UIPinchGestureRecognizer *gestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self
                                                                                                action:@selector(maximiseMinimisePintchGestureRecognizerTapped:)];
        
		self.maximiseMinimisePintchGestureRecognizer = gestureRecognizer;
	}
	return _maximiseMinimisePintchGestureRecognizer;
}


- (void)setVideoInstance:(VideoInstance *)videoInstance {
	_videoInstance = videoInstance;
	
	self.loadingView.videoInstance = videoInstance;
}

- (void)play {
	self.state = SYNVideoPlayerStatePlaying;
    self.activityIndicator.frame = CGRectMake(self.loadingView.center.x-12.5, (self.loadingView.center.y+self.loadingView.frame.size.height*0.2)-12.5, 25, 25);
    
	[self startUpdatingProgress];
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
    [self.activityIndicator stopAnimating];
    
	[self fadeInControls];
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
	[self stopControlsTimer];
	self.controlsVisible = NO;
	
	[UIView animateWithDuration:0.3 animations:^{
		self.scrubberBar.alpha = 0.0;
	}];
}

- (void)stopControlsTimer {
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
	self.progressUpdateTimer = [NSTimer timerWithTimeInterval:0.1
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
}

- (void)maximiseMinimisePintchGestureRecognizerTapped:(UIPinchGestureRecognizer *)gestureRecognizer {
    
    
    
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan)
    {
        self.userPinchedOut = NO;
        self.userPinchedIn = NO;
        
    }
    else if (gestureRecognizer.state == UIGestureRecognizerStateChanged)
    {
        float scale = gestureRecognizer.scale;
        
        if (scale < 1.0)
        {
            self.userPinchedIn = YES;
        }
        else
        {
            self.userPinchedOut = YES;
        }
    }
    else if (gestureRecognizer.state == UIGestureRecognizerStateEnded)
    {
        if (self.userPinchedOut == YES)
        {
            
            if (!self.maximised) {
                self.maximised = YES;
                [self.delegate videoPlayerMaximise];
            }
        }
        else if (self.userPinchedIn == YES)
        {
            if (self.maximised) {
                self.maximised = NO;
                [self.delegate videoPlayerMinimise];
            }
        }
    }    
}


- (void)maximiseMinimiseGestureRecognizerTapped:(UITapGestureRecognizer *)gestureRecognizer {
	if (self.maximised) {
		self.maximised = NO;
		[self.delegate videoPlayerMinimise];
	} else {
		self.maximised = YES;
		[self.delegate videoPlayerMaximise];
	}
}

@end
