//
//  SYNYoutTubeVideoViewController.m
//  rockpack
//
//  Created by Nick Banks on 15/02/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#define kVideoBackgroundColour [UIColor blackColor]
#define kBufferMonitoringTimerInterval 1.0f

#import "SYNVideoPlaybackViewController.h"
#import "VideoInstance.h"
#import "Video.h"

@interface SYNVideoPlaybackViewController () <UIWebViewDelegate>

@property (nonatomic, strong) UIWebView *currentVideoWebView;
@property (nonatomic, strong) UIWebView *nextVideoWebView;
@property (nonatomic, strong) NSString *sourceId;
@property (nonatomic, strong) NSString *source;
@property (nonatomic, strong) NSArray *videoInstanceArray;
@property (nonatomic, assign) int videoIndex;
@property (nonatomic, assign) BOOL autoPlay;
@property (nonatomic, assign) CGRect requestedFrame;
@property (nonatomic, strong) NSTimer *bufferMonitoringTimer;


@end


@implementation SYNVideoPlaybackViewController

#pragma mark - Initialization

- (id) initWithFrame: (CGRect) frame
{
    if ((self = [super init]))
    {
        self.requestedFrame = frame;
    }
    
    return self;
}


#pragma mark - View lifecyle

// Manually create our view

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    // Make sure we set the desired frame at this point
    self.view.frame = self.requestedFrame;

    // Start off by making our view transparent
    self.view.backgroundColor = [UIColor clearColor];
    
    // Create an UIWebView with exactly the same dimensions and background colour as our view
    self.currentVideoWebView = [[UIWebView alloc] initWithFrame: self.view.bounds];
    self.currentVideoWebView.backgroundColor = self.view.backgroundColor;
	self.currentVideoWebView.opaque = NO;
    
    // Stop the user from scrolling the webview
    self.currentVideoWebView.scrollView.scrollEnabled = false;
    self.currentVideoWebView.scrollView.bounces = false;
    
    // Set up out next
    self.currentVideoWebView.delegate = self;
    
    [self.view addSubview: self.currentVideoWebView];
    
    self.nextVideoWebView = [[UIWebView alloc] initWithFrame: self.view.bounds];
    self.nextVideoWebView.backgroundColor = self.view.backgroundColor;
	self.nextVideoWebView.opaque = NO;
    
    // Stop the user from scrolling the webview
    self.nextVideoWebView.scrollView.scrollEnabled = false;
    self.nextVideoWebView.scrollView.bounces = false;
    
    // Set the webview delegate so that we can received events from the JavaScript
    self.nextVideoWebView.delegate = self;
    
    [self.view addSubview: self.currentVideoWebView];
}


- (void) viewWillAppear: (BOOL) animated
{
    [super viewWillAppear: animated];
}


#pragma mark - Source / Playlist management

- (void) incrementVideoIndex
{
    self.videoIndex = self.nextVideoIndex;
}


- (void) decrementVideoIndex
{
    self.videoIndex = self.previousVideoIndex;
}

- (int) nextVideoIndex
{
    int index = 0;
    
    // Don't bother incrementing index if we only have a single video
    if (self.isUsingPlaylist)
    {
        // make sure we wrap around at the end of the video playlist
        index = (self.videoIndex + 1) % self.videoInstanceArray.count;
    }
    
    return index;
}


- (int) previousVideoIndex
{
    int index = 0;
    
    // Don't bother incrementing index if we only have a single video
    if (self.isUsingPlaylist)
    {
        // make sure we wrap around at the end of the video playlist
        index = self.videoIndex - 1;
        
        if (index< 0)
        {
            index = self.videoInstanceArray.count - 1;
        }
    }
    
    return index;
}


- (void) setVideoWithSource: (NSString *) source
                   sourceId: (NSString *) sourceId
                   autoPlay: (BOOL) autoPlay
{
    // Reset index
    self.videoIndex = 0;
    
    // Set autoplay
    self.autoPlay = autoPlay;
    
    // set sources
    self.source = source;
    self.sourceId = sourceId;
    self.videoInstanceArray = nil;
    
    [self loadWebViewWithCurrentVideo];
}


- (void) setPlaylistWithVideoInstanceArray: (NSArray *) videoInstanceArray
                                  autoPlay: (BOOL) autoPlay
{
    // Reset index
    self.videoIndex = 0;
    
    // Set autoplay
    self.autoPlay = autoPlay;
    
    // Set playlist
    self.source = nil;
    self.sourceId = nil;
    self.videoInstanceArray = videoInstanceArray;
    
    [self loadWebViewWithCurrentVideo];
}


// Returns true if we have a playlist
- (BOOL) isUsingPlaylist
{
    return self.videoInstanceArray ? TRUE : FALSE;
}


- (void) play
{
    [self.currentVideoWebView stringByEvaluatingJavaScriptFromString: @"player.playVideo();"];
}

- (void) playVideoAtIndex: (int) index
{
    // If we are already at this index, but not playing, then play
    if (index == self.videoIndex)
    {
        if (!self.isPlaying)
        {
            [self play];
        }
    }
    else
    {
        // OK, we are not currently playing this index, so segue to the next video
        self.videoIndex = index;
        
        [self loadWebViewWithCurrentVideo];
    }
}


- (void) pause
{
    [self.currentVideoWebView stringByEvaluatingJavaScriptFromString: @"player.pauseVideo();"];
}


- (void) stop
{
    [self.currentVideoWebView stringByEvaluatingJavaScriptFromString: @"player.stopVideo();"];
}


- (void) loadNextVideo
{
    [self incrementVideoIndex];
    [self loadWebViewWithCurrentVideo];
}

- (void) loadPreviousVideo
{
    [self decrementVideoIndex];
    [self loadWebViewWithCurrentVideo];
}

- (void) seekInCurrentVideoToTime: (NSTimeInterval) seconds
{
    NSString *js = [NSString stringWithFormat: @"player.stopVideo(%lf, TRUE);", seconds];
    [self.currentVideoWebView stringByEvaluatingJavaScriptFromString: js];
}


#pragma mark - Properties

// Get the duration of the current video
- (NSTimeInterval) duration
{
    return [[self.currentVideoWebView stringByEvaluatingJavaScriptFromString: @"player.getDuration();"] doubleValue];
}


// Get the playhead time of the current video
- (NSTimeInterval) currentTime
{
    return [[self.currentVideoWebView stringByEvaluatingJavaScriptFromString: @"player.getCurrentTime();"] doubleValue];
}


// Get a number between 0 and 1 that indicated how much of the video has been buffered
// Can use this to display a video loading progress indicator
- (float) videoLoadedFraction
{
        return [[self.currentVideoWebView stringByEvaluatingJavaScriptFromString: @"player.getVideoLoadedFraction();"] floatValue];
}


// Index of currently playing video (if using a playlist)
- (BOOL) isPlaying
{
    return ([[self.currentVideoWebView stringByEvaluatingJavaScriptFromString: @"player.getPlayerState();"] intValue] == 1)
            ? TRUE : FALSE;
}


#pragma mark - Video playback HTML creation

- (void) loadWebViewWithCurrentVideo
{
    // Assume that we just have a single video as opposed to a playlist
    NSString *currentSource = self.source;
    NSString *currentSourceId = self.sourceId;
    
    // But if we do have a playlist, then load up the source and sourceId for the current video index
    if (self.isUsingPlaylist)
    {
        VideoInstance *videoInstance = (VideoInstance *) self.videoInstanceArray[self.videoIndex];
        currentSource = videoInstance.video.source;
        currentSourceId = videoInstance.video.sourceId;
    }
    
    [self loadWebViewWithPlayerWithSource: currentSource
                                 sourceId: currentSourceId];
}


- (void) loadWebViewWithPlayerWithSource: (NSString *) source
                                sourceId: (NSString *) sourceId
{
    if ([source isEqualToString: @"youtube"])
    {
        [self loadWebViewWithJSAPIUsingYouTubeId: sourceId];
    }
    else if ([source isEqualToString: @"vimeo"])
    {
        [self loadWebViewWithIFrameUsingVimeoId: sourceId];
    }
    else
    {
        AssertOrLog(@"Unknown video source type");
    }
}


// Support for YouTube JavaScript player
- (void) loadWebViewWithJSAPIUsingYouTubeId: (NSString *) sourceId
{
    NSError *error = nil;
    NSString *fullPath = [[NSBundle mainBundle] pathForResource: @"YouTubeJSAPIPlayer"
                                                         ofType: @"html"];
    
    NSString *templateHTMLString = [NSString stringWithContentsOfFile: fullPath
                                                             encoding: NSUTF8StringEncoding
                                                                error: &error];
    
    NSString *iFrameHTML = [NSString stringWithFormat: templateHTMLString, (int) self.view.frame.size.width, (int) self.view.frame.size.height, sourceId];
    
    [self.currentVideoWebView loadHTMLString: iFrameHTML
                              baseURL: [NSURL URLWithString: @"http://www.youtube.com"]];
    
    // Not sure if this makes any difference
    self.currentVideoWebView.mediaPlaybackRequiresUserAction = FALSE;
}


// Support for Vimeo player
// TODO: We need to support http://player.vimeo.com/video/VIDEO_ID?api=1&player_id=vimeoplayer
// See http://developer.vimeo.com/player/js-api
- (void) loadWebViewWithIFrameUsingVimeoId: (NSString *) sourceId
{
    NSString *parameterString = @"";
    
    NSError *error = nil;
    NSString *fullPath = [[NSBundle mainBundle] pathForResource: @"VimeoIFramePlayer"
                                                         ofType: @"html"];
    
    NSString *templateHTMLString = [NSString stringWithContentsOfFile: fullPath
                                                             encoding: NSUTF8StringEncoding
                                                                error: &error];
    
    NSString *iFrameHTML = [NSString stringWithFormat: templateHTMLString, sourceId, parameterString, self.view.frame.size.width, self.view.frame.size.height];
    
    [self.currentVideoWebView loadHTMLString: iFrameHTML
                              baseURL: nil];
}


#pragma mark - UIWebViewDelegate

// This is where we dectect events from the JS and the youtube player
- (BOOL) webView: (UIWebView *) webView
         shouldStartLoadWithRequest: (NSURLRequest *) request
         navigationType: (UIWebViewNavigationType) navigationType
{
    NSString *scheme = request.URL.scheme;
    
    // If we have an event from one of our players (as opposed to something else)
    if ([scheme isEqualToString: @"ytplayer"] || [scheme isEqualToString: @"vimeoplayer"])
    {
        // Split the URL up into it's componenents
        NSArray *components = request.URL.pathComponents;
        
        if (components.count > 1)
        {
            NSString *actionName = components[1];
            NSString *actionData = nil;
            
            if (components.count > 2)
            {
                actionData = components[2];
            }
            
            // Call our handler functions
            if ([scheme isEqualToString: @"ytplayer"])
            {
                [self handleYouTubePlayerEventNamed: actionName
                                          eventData: actionData];
            }
            else
            {
                [self handleVimeoPlayerEventNamed: actionName
                                        eventData: actionData];
            }
        }
        
        return NO;
    }
    else
    {
        // Just pass throught the load
        return YES;
    }
}


// If something went wrong, then log the error
- (void) webView: (UIWebView *) webView
         didFailLoadWithError: (NSError *) error
{
    DebugLog(@"YouTube webview failed to load - %@", [error description]);
}


#pragma mark - JavaScript player handlers

- (void) handleYouTubePlayerEventNamed: (NSString *) actionName
                             eventData: (NSString *) actionData
{
    NSLog (@"*** YTPlayer: %@ : %@", actionName, actionData);
    
    if ([actionName isEqualToString: @"ready"])
    {

    }
    else if ([actionName isEqualToString: @"stateChange"])
    {
        // Now handle the different state changes
        if ([actionData isEqualToString: @"unstarted"])
        {
            if (self.autoPlay == TRUE)
            {
                [self play];
            }
        }
        else if ([actionData isEqualToString: @"ended"])
        {
            NSTimeInterval currentTime = self.currentTime;
            NSLog (@"%lf", currentTime);
            [self stopBufferMonitoringTimer];
            [self pause];
            [self seekInCurrentVideoToTime: currentTime];
//            [self loadNextVideo];
        }
        else if ([actionData isEqualToString: @"playing"])
        {
            [self startBufferMonitoringTimer];
        }
        else if ([actionData isEqualToString: @"paused"])
        {
            [self stopBufferMonitoringTimer];  
        }
        else if ([actionData isEqualToString: @"buffering"])
        {
            
        }
        else if ([actionData isEqualToString: @"cued"])
        {
            
        }
        else
        {
            AssertOrLog(@"Unexpected YTPlayer state change");
        }
    }
    else if ([actionName isEqualToString: @"playbackQuality"])
    {
        
    }
    else if ([actionName isEqualToString: @"playbackRateChange"])
    {
        
    }
    else if ([actionName isEqualToString: @"error"])
    {
        
    }
    else if ([actionName isEqualToString: @"apiChange"])
    {
        
    }
    else
    {
        AssertOrLog(@"Unexpected YTPlayer event");
    }
}

- (void) handleVimeoPlayerEventNamed: (NSString *) actionName
                           eventData: (NSString *) actionData
{
    
}

- (void) startBufferMonitoringTimer
{
    self.bufferMonitoringTimer = [NSTimer scheduledTimerWithTimeInterval: kBufferMonitoringTimerInterval
                                                                  target: self
                                                                selector: @selector(monitorBufferLevel)
                                                                userInfo: nil
                                                                 repeats: YES];
    
}


- (void) stopBufferMonitoringTimer
{
    [self.bufferMonitoringTimer invalidate], self.bufferMonitoringTimer = nil;
}


- (void) monitorBufferLevel
{
    float bufferLevel = [self videoLoadedFraction];
    
    NSLog (@"Buffer Level %f", bufferLevel);
    
    if (bufferLevel == 1.0f)
    {
        [self precacheNextVideo];
    }
}

- (void) precacheNextVideo
{
    
}

@end
