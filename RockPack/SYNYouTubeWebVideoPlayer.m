//
//  SYNYouTubeWebVideoPlayer.m
//  dolly
//
//  Created by Sherman Lo on 14/11/13.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNYouTubeWebVideoPlayer.h"
#import "VideoInstance.h"
#import "Video.h"
#import "SYNScrubberBar.h"
#import "SYNVideoPlayer+Protected.h"
#import "SYNYouTubeWebView.h"
#import <Reachability.h>

typedef NS_ENUM(NSInteger, SYNYouTubeVideoPlayerState) {
	SYNYouTubeVideoPlayerStateInitialised,
	SYNYouTubeVideoPlayerStateReady,
	SYNYouTubeVideoPlayerStateLoaded,
	SYNYouTubeVideoPlayerStatePlayStarted
};

@interface SYNYouTubeWebVideoPlayer () <UIWebViewDelegate>

@property (nonatomic, strong) UIWebView *youTubeWebView;

@property (nonatomic, assign) SYNYouTubeVideoPlayerState youTubePlayerState;

@end

@implementation SYNYouTubeWebVideoPlayer

#pragma mark - Init / Dealloc

- (id)initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame]) {
		[self.playerContainerView addSubview:self.youTubeWebView];
	}
	return self;
}

- (void)dealloc {
	_youTubeWebView.delegate = nil;
}

#pragma mark - UIView

- (void)layoutSubviews {
	[super layoutSubviews];
	
	CGRect playerBounds = self.youTubeWebView.bounds;
	CGRect containerBounds = self.playerContainerView.bounds;
	
	CGFloat scaleFactor = CGRectGetWidth(containerBounds) / CGRectGetWidth(playerBounds);
	
	self.youTubeWebView.center = self.playerContainerView.center;
	self.youTubeWebView.transform = CGAffineTransformMakeScale(scaleFactor, scaleFactor);
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
	[super willMoveToSuperview:newSuperview];
	
	if (!newSuperview) {
		// This is needed since we want to trigger viewWillMoveToSuperview on SYNYouTubeWebView straight
		// away instead of when this object is dealloced so that we can reuse the web view
		[self.youTubeWebView removeFromSuperview];
		self.youTubeWebView.delegate = nil;
		self.youTubeWebView = nil;
	}
}

#pragma mark - Getters / Setters

- (UIWebView *)youTubeWebView {
	if (!_youTubeWebView) {
		UIWebView *webView = [SYNYouTubeWebView webView];
		
		// The method is meant to return a number, so the only way it will return an empty string is if the method
		// isn't loaded, which will only happen if the player isn't ready
		BOOL isPlayerReady = ([[webView stringByEvaluatingJavaScriptFromString:@"player.getPlayerState()"] length] > 0);
		if (isPlayerReady) {
			self.youTubePlayerState = SYNYouTubeVideoPlayerStateReady;
		}
		
		webView.delegate = self;
		
		self.youTubeWebView = webView;
	}
	return _youTubeWebView;
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	NSURL *URL = [request URL];
	if ([[URL scheme] isEqualToString:@"ytplayer"]) {
		NSArray *components = [URL pathComponents];
		
		NSString *actionName = ([components count] > 1 ? components[1] : nil);
		NSString *actionData = ([components count] > 2 ? components[2] : nil);
		
		if (actionName) {
			[self handleYouTubePlayerEventNamed:actionName eventData:actionData];
		}
		
		return NO;
	}
	
	return YES;
}

#pragma mark - Overridden

- (void)play {
	[super play];
	
	if (self.youTubePlayerState == SYNYouTubeVideoPlayerStateLoaded || self.youTubePlayerState == SYNYouTubeVideoPlayerStatePlayStarted) {
		[self.youTubeWebView stringByEvaluatingJavaScriptFromString:@"player.playVideo();"];
	} else {
		[self loadPlayer];
	}
}

- (void)pause {
	[super pause];
	
    [self.youTubeWebView stringByEvaluatingJavaScriptFromString:@"player.pauseVideo();"];
}

- (NSTimeInterval)duration {
	return [[self.youTubeWebView stringByEvaluatingJavaScriptFromString: @"player.getDuration();"] doubleValue];
}

- (void)setCurrentTime:(NSTimeInterval)currentTime {
	[super setCurrentTime:currentTime];
	
    NSString *callString = [NSString stringWithFormat: @"player.seekTo(%f);", currentTime];
    [self.youTubeWebView stringByEvaluatingJavaScriptFromString: callString];
}

- (NSTimeInterval)currentTime {
	return [[self.youTubeWebView stringByEvaluatingJavaScriptFromString: @"player.getCurrentTime();"] doubleValue];
}

- (float)bufferingProgress {
	return [[self.youTubeWebView stringByEvaluatingJavaScriptFromString: @"player.getVideoLoadedFraction();"] doubleValue];
}

#pragma mark - Private

- (void)handleYouTubePlayerEventNamed:(NSString *)actionName eventData:(NSString *)actionData {
	if ([actionName isEqualToString:@"ready"]) {
		self.youTubePlayerState = SYNYouTubeVideoPlayerStateReady;
		
		if (self.state == SYNVideoPlayerStatePlaying) {
			[self loadPlayer];
		}
	}
	
	if ([actionName isEqualToString:@"stateChange"]) {
		if ([actionData isEqualToString:@"playing"] && self.youTubePlayerState == SYNYouTubeVideoPlayerStateLoaded) {
			self.youTubePlayerState = SYNYouTubeVideoPlayerStatePlayStarted;
			[self handleVideoPlayerStartedPlaying];
		}
		if ([actionData isEqualToString:@"paused"]) {
			[self handleVideoPlayerPaused];
		}
		if ([actionData isEqualToString:@"ended"]) {
			[self handleVideoPlayerFinishedPlaying];
		}
	}
	
	if ([actionName isEqualToString:@"playbackQuality"]) {
		NSString *quality = actionData;
		BOOL isHighDefinition = [@[ @"hd720", @"hd1080", @"highres" ] containsObject:quality];
		[self handleVideoPlayerResolutionChanged:isHighDefinition];
	}
	
	if ([actionName isEqualToString:@"error"]) {
		[self handleVideoPlayerError:actionData];
	}
}

- (void)updatePlayerSize:(CGSize)size {
	NSString *javascript = [NSString stringWithFormat:@"player.setSize(%f, %f);", size.width, size.height];
	[self.youTubeWebView stringByEvaluatingJavaScriptFromString:javascript];
}

- (void)loadPlayer {
	if (self.youTubePlayerState == SYNYouTubeVideoPlayerStateReady) {
		NSString *sourceId = self.videoInstance.video.sourceId;
		NSString *loadString = [NSString stringWithFormat:@"player.loadVideoById('%@', '0', '%@');", sourceId, @"default"];
		[self.youTubeWebView stringByEvaluatingJavaScriptFromString:loadString];
		
		self.youTubePlayerState = SYNYouTubeVideoPlayerStateLoaded;
	}
}

@end
