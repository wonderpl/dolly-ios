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

@import CoreTelephony.CTTelephonyNetworkInfo;

typedef NS_ENUM(NSInteger, SYNYouTubeVideoPlayerState) {
	SYNYouTubeVideoPlayerStateInitialised,
	SYNYouTubeVideoPlayerStateReady,
	SYNYouTubeVideoPlayerStateLoaded,
	SYNYouTubeVideoPlayerStatePlayStarted
};

static const CGFloat bufferingTime = 12;


@interface SYNYouTubeWebVideoPlayer () <UIWebViewDelegate>

@property (nonatomic, strong) UIWebView *youTubeWebView;

@property (nonatomic, assign) SYNYouTubeVideoPlayerState youTubePlayerState;

@property (nonatomic, strong) NSTimer *timer;

@end

@implementation SYNYouTubeWebVideoPlayer

#pragma mark - Init / Dealloc

- (id)initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame]) {
	}
	return self;
}
- (void)dealloc {
    self.timer = nil;
    self.youTubeWebView.delegate = nil;
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

#pragma mark - Getters / Setters

- (UIWebView *)youTubeWebView {
	if (!_youTubeWebView) {
		_youTubeWebView = [self newWebView];
	}
	return _youTubeWebView;
}


- (UIWebView*) newWebView {
    UIWebView *webView = [SYNYouTubeWebView webView];
    // The method is meant to return a number, so the only way it will return an empty string is if the method
    // isn't loaded, which will only happen if the player isn't ready
    BOOL isPlayerReady = ([[webView stringByEvaluatingJavaScriptFromString:@"player.getPlayerState()"] length] > 0);
    if (isPlayerReady) {
        self.youTubePlayerState = SYNYouTubeVideoPlayerStateReady;
    }
    
    webView.delegate = self;
    
    return webView;

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
    NSString *availability = [self.youTubeWebView stringByEvaluatingJavaScriptFromString: @"checkPlayerAvailability();"];
    if ([availability isEqualToString: @"true"]) {
        [super play];
        [self playVideo];
    } else {
        [self reloadVideoPlayer:nil];
    	DebugLog(@"checkPlayerAvailability : reloading player");
    }

}

- (void)playVideo {
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

- (void)stop {
	[super stop];
	
	[self.youTubeWebView stringByEvaluatingJavaScriptFromString:@"player.stopVideo()"];
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

    NSLog(@"actionName :%@, actaionData :%@", actionName, actionData);
    
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
        if ([actionData isEqualToString:@"buffering"]) {
//            self.timer = [NSTimer scheduledTimerWithTimeInterval:[self bufferTIme]
//                                                          target:self
//                                                        selector:@selector(reloadVideoPlayer:)
//                                                        userInfo:nil
//                                                         repeats:NO];
        
        } else {
            [self invalidateTimer];
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

- (void)invalidateTimer {
    if ([self.timer isValid]) {
        [self.timer invalidate];
    }
}

- (void)reloadVideoPlayer:(NSTimer *)timer  {
    
    DebugLog(@"Reloading Video Player with VideoInstance%@", self.videoInstance);
    
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Connection problem" message:@"We are attempting to reload your video" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
    
    _youTubeWebView = [self newWebView];
    
    [super playFirstTime];
	[self playVideo];
}

- (NSTimeInterval) bufferTIme {
 
	NSDictionary *mapping = @{
							  @"CTRadioAccessTechnologyGPRS"			:@(bufferingTime*1.3),
                              @"CTRadioAccessTechnologyEdge"			:@(bufferingTime*1.3),
                              @"CTRadioAccessTechnologyWCDMA" 			:@(bufferingTime),
                              @"CTRadioAccessTechnologyHSDPA" 			:@(bufferingTime),
                              @"CTRadioAccessTechnologyHSUPA" 			:@(bufferingTime),
                              @"CTRadioAccessTechnologyCDMA1x" 			:@(bufferingTime),
                              @"CTRadioAccessTechnologyCDMAEVDORev0" 	:@(bufferingTime),
                              @"CTRadioAccessTechnologyCDMAEVDORevA" 	:@(bufferingTime),
                              @"CTRadioAccessTechnologyCDMAEVDORevB" 	:@(bufferingTime),
                              @"CTRadioAccessTechnologyeHRPD" 			:@(bufferingTime),
                              @"CTRadioAccessTechnologyLTE" 			:@(bufferingTime)
							  };
    
    CTTelephonyNetworkInfo *telephonyInfo = [CTTelephonyNetworkInfo new];
    
    if (mapping[telephonyInfo.currentRadioAccessTechnology] != nil) {
        return [mapping[telephonyInfo.currentRadioAccessTechnology] doubleValue];
    }
	
    //Time for wifi
    return bufferingTime;
}


- (void)loadPlayer {
    if (self.youTubePlayerState == SYNYouTubeVideoPlayerStateReady) {
		NSString *sourceId = self.videoInstance.video.sourceId;
		NSString *loadString = [NSString stringWithFormat:@"player.loadVideoById('%@', '0', '%@');", sourceId, @"default"];
		[self.youTubeWebView stringByEvaluatingJavaScriptFromString:loadString];
		self.youTubePlayerState = SYNYouTubeVideoPlayerStateLoaded;
	}
}

- (UIView *)videoPlayerView {
	return self.youTubeWebView;
}

@end
