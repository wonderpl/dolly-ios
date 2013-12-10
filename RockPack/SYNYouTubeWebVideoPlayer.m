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
#import "SYNVideoLoadingView.h"
#import "SYNVideoPlayer+Protected.h"
#import <Reachability.h>

@interface SYNYouTubeWebVideoPlayer () <UIWebViewDelegate>

@property (nonatomic, strong) UIWebView *youTubeWebView;

@property (nonatomic, assign) BOOL playerReady;

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
	self.youTubeWebView.delegate = nil;
}

- (void)layoutSubviews {
	[super layoutSubviews];
	
	[self updatePlayerSize:self.youTubeWebView.frame.size];
}

#pragma mark - Getters / Setters

- (UIWebView *)youTubeWebView {
	if (!_youTubeWebView) {
		UIWebView *webView = [[UIWebView alloc] initWithFrame:self.playerContainerView.bounds];
		webView.scrollView.scrollEnabled = NO;
		webView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
		webView.allowsInlineMediaPlayback = YES;
		webView.mediaPlaybackRequiresUserAction = NO;
		
		NSString *templateHTMLString = [NSString stringWithContentsOfURL:[self URLForPlayerHTML] encoding:NSUTF8StringEncoding error:nil];
		
		NSString *iFrameHTML = [NSString stringWithFormat:templateHTMLString, 0, 0];
		
		[webView loadHTMLString:iFrameHTML baseURL:[NSURL URLWithString: @"http://www.youtube.com"]];
		
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
	
	[self.youTubeWebView stringByEvaluatingJavaScriptFromString:@"player.playVideo();"];
}

- (void)pause {
	[super pause];
	
    [self.youTubeWebView stringByEvaluatingJavaScriptFromString: @"player.pauseVideo();"];
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

- (NSString *)videoQuality {
    // Based on empirical evidence (Youtube app), determine the appropriate quality level based on device and connectivity
	Reachability *reachability = [Reachability reachabilityWithHostname:@"http://www.youtube.com/"];

	NSString *suggestedQuality = @"default";

	if ([reachability currentReachabilityStatus] == ReachableViaWiFi) {
		if (IS_IPAD) {
			suggestedQuality = @"hd720";
		} else {
			suggestedQuality = @"medium";
		}
	} else {
		// Connected via cellular network
		if (IS_IPAD) {
			suggestedQuality = @"medium";
		} else {
			suggestedQuality = @"small";
		}
	}

	DebugLog (@"Attempting to play quality: %@", suggestedQuality);
	return suggestedQuality;
}

- (void)handleYouTubePlayerEventNamed:(NSString *)actionName eventData:(NSString *)actionData {
	if ([actionName isEqualToString:@"ready"]) {
		NSString *sourceId = self.videoInstance.video.sourceId;
		NSString *videoQuality = [self videoQuality];
		
		[self updatePlayerSize:self.youTubeWebView.frame.size];
		
		NSString *loadString = [NSString stringWithFormat:@"player.loadVideoById('%@', '0', '%@');", sourceId, videoQuality];
		[self.youTubeWebView stringByEvaluatingJavaScriptFromString:loadString];
		
	}
	
	if ([actionName isEqualToString:@"stateChange"]) {
		if ([actionData isEqualToString:@"playing"]) {
			[self handleVideoPlayerStartedPlaying];
		}
		if ([actionData isEqualToString:@"ended"]) {
			[self handleVideoPlayerFinishedPlaying];
		}
	}
	
	if ([actionName isEqualToString:@"error"]) {
		[self handleVideoPlayerError:actionData];
	}
}

- (void)updatePlayerSize:(CGSize)size {
	NSString *javascript = [NSString stringWithFormat:@"player.setSize(%f, %f);", size.width, size.height];
	[self.youTubeWebView stringByEvaluatingJavaScriptFromString:javascript];
}

- (NSURL *)URLForPlayerHTML {
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	NSURL *documentsURL = [fileManager URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:nil];
	NSURL *fileURL = [documentsURL URLByAppendingPathComponent:@"YouTubeIFramePlayer.html"];
	
	if ([fileManager fileExistsAtPath:[fileURL path]]) {
		return fileURL;
	}
	
	return [[NSBundle mainBundle] URLForResource:@"YouTubeIFramePlayer" withExtension:@"html"];
}

@end
