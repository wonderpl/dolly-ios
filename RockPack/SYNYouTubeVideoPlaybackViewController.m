//
//  SYNYoutTubeVideoViewController.m
//  rockpack
//
//  Created by Nick Banks on 15/02/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import "AppConstants.h"
#import "SYNAbstractVideoPlaybackViewController+Private.h"
#import "SYNDeviceManager.h"
#import "SYNOAuthNetworkEngine.h"
#import "SYNYouTubeVideoPlaybackViewController.h"
#import <QuartzCore/CoreAnimation.h>
@import CoreData;


@interface SYNYouTubeVideoPlaybackViewController () <UIWebViewDelegate>

@property (nonatomic, assign) BOOL hasReloadedWebView;
@property (nonatomic, strong) NSString *sourceIdToReload;
@property (nonatomic, strong) UIWebView *currentVideoWebView;

@end


@implementation SYNYouTubeVideoPlaybackViewController

#pragma mark - Initialization

static UIWebView* youTubeVideoWebViewInstance;

+ (instancetype) sharedInstance
{
    static SYNYouTubeVideoPlaybackViewController *_sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        // Create our shared instance
        _sharedInstance = [[self alloc] init];
        // Create the static instances of our webviews
        youTubeVideoWebViewInstance = [SYNYouTubeVideoPlaybackViewController createNewYouTubeWebView];
    });
    
    return _sharedInstance;
}


#pragma mark - Object lifecycle

- (void) dealloc
{
    self.currentVideoWebView.delegate = nil;
}


#pragma mark - View lifecyle

- (void) specificInit
{
    youTubeVideoWebViewInstance.frame = self.view.bounds;
    youTubeVideoWebViewInstance.backgroundColor = self.view.backgroundColor;
    
    // Set the webview delegate so that we can received events from the JavaScript
    youTubeVideoWebViewInstance.delegate = self;
    
    // Default to using YouTube player for now
    self.currentVideoWebView = youTubeVideoWebViewInstance;
    
    self.currentVideoView = self.currentVideoWebView;
}


// Common setup for all video web views
+ (UIWebView *) createNewVideoWebView
{
    UIWebView *newWebViewInstance = [[UIWebView alloc] initWithFrame: CGRectMake (0,  0, [SYNYouTubeVideoPlaybackViewController videoWidth], [SYNYouTubeVideoPlaybackViewController videoHeight])];
    
    newWebViewInstance.opaque = NO;
    newWebViewInstance.alpha = 0.0f;
    newWebViewInstance.autoresizingMask = UIViewAutoresizingNone;
    
    // Stop the user from scrolling the webview
    newWebViewInstance.scrollView.scrollEnabled = false;
    newWebViewInstance.scrollView.bounces = false;
    
    // Enable airplay button on webview player
    newWebViewInstance.mediaPlaybackAllowsAirPlay = YES;
    
    // Required for autoplay
    newWebViewInstance.allowsInlineMediaPlayback = YES;
    
    // Required to work correctly
    newWebViewInstance.mediaPlaybackRequiresUserAction = FALSE;
    
    return newWebViewInstance;
}


// Create YouTube specific webview, based on common setup
+ (UIWebView *) createNewYouTubeWebView
{
    NSError *error = nil;
    
    UIWebView *newYouTubeWebView = [SYNYouTubeVideoPlaybackViewController createNewVideoWebView];
    
    // Get HTML from documents directory (as opposed to the bundle), so that we can update it
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = paths[0];
    NSString *fullPath = [documentsDirectory stringByAppendingPathComponent: @"YouTubeIFramePlayer.html"];
    
    NSString *templateHTMLString = [NSString stringWithContentsOfFile: fullPath
                                                             encoding: NSUTF8StringEncoding
                                                                error: &error];
    
    NSString *iFrameHTML = [NSString stringWithFormat: templateHTMLString,
                            (int) [SYNYouTubeVideoPlaybackViewController videoWidth],
                            (int) [SYNYouTubeVideoPlaybackViewController videoHeight]];
    
    [newYouTubeWebView loadHTMLString: iFrameHTML
                              baseURL: [NSURL URLWithString: @"http://www.youtube.com"]];
    
#ifdef USE_HIRES_PLAYER
    // If we are on the iPad then we need to super-size the webview so that we can scale down again
    if (IS_IPAD)
    {
        newYouTubeWebView.transform = CGAffineTransformMakeScale(739.0f/1280.0f, 739.0f/1280.0f);
    }
#endif
    
    return newYouTubeWebView;
}


#pragma mark - YouTube player support

- (void) playVideoWithSourceId: (NSString *) sourceId
{
    self.notYetPlaying = TRUE;
    self.pausedByUser = NO;
    
    SYNAppDelegate* appDelegate = UIApplication.sharedApplication.delegate;
    // Check to see if our JS is loaded
    NSString *availability = [self.currentVideoWebView stringByEvaluatingJavaScriptFromString: @"checkPlayerAvailability();"];
    if ([availability isEqualToString: @"true"])
    {
        // Our JS is loaded
        NSString *loadString = [NSString stringWithFormat: @"player.loadVideoById('%@', '0', '%@');", sourceId, self.videoQuality];
        
        [self startVideoStallDetectionTimer];
        
        [self.currentVideoWebView stringByEvaluatingJavaScriptFromString: loadString];
        
        self.playFlag = TRUE;
        
		self.scrubberBar.playing = YES;
    }
    else
    {
        // Something unloaded our JS, so use different approach
        // Reload out webview and load the new video when we get an event to say that the player is ready
        self.hasReloadedWebView = TRUE;
        self.sourceIdToReload = sourceId;
        
        NSError *error = nil;
        
        // Get HTML from documents directory (as opposed to the bundle), so that we can update it
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = paths[0];
        NSString *fullPath = [documentsDirectory stringByAppendingPathComponent: @"YouTubeIFramePlayer.html"];
        
        NSString *templateHTMLString = [NSString stringWithContentsOfFile: fullPath
                                                                 encoding: NSUTF8StringEncoding
                                                                    error: &error];
        
        NSString *iFrameHTML = [NSString stringWithFormat: templateHTMLString,
                                (int) [SYNYouTubeVideoPlaybackViewController videoWidth],
                                (int) [SYNYouTubeVideoPlaybackViewController videoHeight]];
        
        [self.currentVideoWebView loadHTMLString: iFrameHTML
                                         baseURL: [NSURL URLWithString: @"http://www.youtube.com"]];

        self.currentVideoWebView.delegate = self;
    }
}


- (void) playVideo
{
    if ([self.view superview])
    {
        self.pausedByUser = NO;
        [self.currentVideoWebView stringByEvaluatingJavaScriptFromString: @"player.playVideo();"];
        self.playFlag = TRUE;
    }
    else
    {
        [self.currentVideoWebView stringByEvaluatingJavaScriptFromString: @"player.stopVideo();"];
        self.playFlag = FALSE;;
    }
}


- (void) pauseVideo
{
    [self stopShuttleBarUpdateTimer];
    
    [self.currentVideoWebView stringByEvaluatingJavaScriptFromString: @"player.pauseVideo();"];
    
    self.playFlag = FALSE;
}


- (void) stopVideo
{
    [self stopShuttleBarUpdateTimer];
    
    [self.currentVideoWebView stringByEvaluatingJavaScriptFromString: @"player.stopVideo();"];
    
    self.playFlag = FALSE;
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

// Get the playhead time of the current video
- (void) setCurrentTime: (NSTimeInterval) newTime
{
    NSString *callString = [NSString stringWithFormat: @"player.seekTo(%f);", newTime];
    [self.currentVideoWebView stringByEvaluatingJavaScriptFromString: callString];
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
    int playingValue = [[self.currentVideoWebView stringByEvaluatingJavaScriptFromString: @"player.getPlayerState();"] intValue];
    
    return (playingValue == 1) ? TRUE : FALSE;
}

- (BOOL) isPlayingOrBuffering
{
    int playingValue = [[self.currentVideoWebView stringByEvaluatingJavaScriptFromString: @"player.getPlayerState();"] intValue];
    
    return ((playingValue == 1) || (playingValue == 3)) ? TRUE : FALSE;
}

- (BOOL) isPaused
{
    int playingValue = [[self.currentVideoWebView stringByEvaluatingJavaScriptFromString: @"player.getPlayerState();"] intValue];
    
    return (playingValue == 2) ? TRUE : FALSE;
}


#pragma mark - UIWebViewDelegate

// This is where we dectect events from the JS and the youtube player
- (BOOL) webView: (UIWebView *) webView
         shouldStartLoadWithRequest: (NSURLRequest *) request
         navigationType: (UIWebViewNavigationType) navigationType
{
//    DebugLog(@"-----%@", request.debugDescription);
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
                    [self handleCurrentYouTubePlayerEventNamed: actionName
                                                     eventData: actionData];
            }
            else
            {
                AssertOrLog(@"Not sure what format this is");
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
    // TODO: We should have some sort of error handling here
    DebugLog(@"YouTube webview failed to load - %@", [error description]);
}


#pragma mark - JavaScript player handlers

- (void) handleCurrentYouTubePlayerEventNamed: (NSString *) actionName
                                    eventData: (NSString *) actionData
{
//    DebugLog (@"actionname = %@, actiondata = %@", actionName, actionData);
    
    if ([actionName isEqualToString: @"ready"])
    {
        // We probably don't get this event any more as the player is already set up (asynchronously)
//        DebugLog (@"++++++++++ Player ready - player ready");
        
        // If the user moved away from the original player page, then we should have already detected this
        // so we need to start playing again when we have loaded
        if (self.hasReloadedWebView == TRUE)
        {
            self.hasReloadedWebView = FALSE;
            
            NSString *loadString = [NSString stringWithFormat: @"player.loadVideoById('%@', '0', '%@');", self.sourceIdToReload, self.videoQuality];
            [self.currentVideoWebView stringByEvaluatingJavaScriptFromString: loadString];
            
            self.playFlag = TRUE;
            
			self.scrubberBar.playing = YES;
        }
    }
    else if ([actionName isEqualToString: @"stateChange"])
    {
        // Now handle the different state changes
        if ([actionData isEqualToString: @"unstarted"])
        {
            // As we have already called the play method in onReady, we should pause it here if not autoplaying
            if (self.autoPlay == FALSE)
            {
                DebugLog (@"*** Unstarted: Autoplay false - attempting to pause");
                [self pauseVideo];
            }
            else
            {
                DebugLog (@"*** Unstarted: Assuming autoplay - no action taken");
            }
        }
        else if ([actionData isEqualToString: @"ended"])
        {
            DebugLog (@"*** Ended: Stopping - Fading out player & Loading next video");
            self.percentageViewed = 1.0f;
            self.timeViewed = self.currentDuration;
            [self stopShuttleBarUpdateTimer];
            [self stopVideoStallDetectionTimer];
            [self stopVideo];
            [self resetPlayerAttributes];
            [self loadNextVideo];
        }
        else if ([actionData isEqualToString: @"playing"])
        {
            [self stopVideoStallDetectionTimer];
            
            DebugLog(@"*** Playing: Starting - Fading up player");
            // If we are playing then out shuttle / pause / play cycle is over
            self.shuttledByUser = TRUE;
            self.notYetPlaying = FALSE;
            
            // Now cache the duration of this video for use in the progress updates
            self.currentDuration = self.duration;
            
            if (self.currentDuration > 0.0f)
            {
                self.fadeUpScheduled = FALSE;
                // Only start if we have a valid duration
                [self startShuttleBarUpdateTimer];
				self.scrubberBar.duration = self.currentDuration;
            }
        }
        else if ([actionData isEqualToString: @"paused"])
        {
            if (self.shuttledByUser == TRUE && self.playFlag == TRUE)
            {
                DebugLog (@"*** Paused: Paused by shuttle and should be playing? - Attempting to play");
                [self playVideo];
            }
            else
            {
                [self stopVideoStallDetectionTimer];
                DebugLog (@"*** Paused: Paused by user");
            }
        }
        else if ([actionData isEqualToString: @"buffering"])
        {
            // Now cache the duration of this video for use in the progress updates
            if (self.notYetPlaying  == TRUE)
            {
                DebugLog (@"*** Buffering: Normal buffering - No action taken");
            }
            else
            {
                // Should already be playing so try to restart
                DebugLog (@"*** Buffering: Buffering after play - Retrying play");
//                [self pauseVideo];
                [self playVideo];
            }
        }
        else if ([actionData isEqualToString: @"cued"])
        {
            DebugLog (@"*** Cued: No action taken");        }
        else
        {
            AssertOrLog(@"Unexpected YTPlayer state change");
        }
    }
    else if ([actionName isEqualToString: @"playbackQuality"])
    {
        DebugLog (@"!!!!!!!!!! Quality: %@", actionData);
    }
    else if ([actionName isEqualToString: @"playbackRateChange"])
    {
        DebugLog (@"!!!!!!!!!! Playback Rate change");
    }
    else if ([actionName isEqualToString: @"error"])
    {
        DebugLog (@"!!!!!!!!!! Error");
        [self fadeUpVideoPlayer];
        
        SYNAppDelegate* appDelegate = UIApplication.sharedApplication.delegate;
        VideoInstance *videoInstance = self.videoInstanceArray [self.currentSelectedIndex];
        
        [appDelegate.oAuthNetworkEngine reportPlayerErrorForVideoInstanceId: videoInstance.uniqueId
                                                           errorDescription: actionData
                                                          completionHandler: ^(NSDictionary * dictionary) {
                                                              DebugLog(@"Reported video error");
                                                          }
                                                               errorHandler: ^(NSError* error) {
                                                                   DebugLog(@"Report concern failed");
                                                                   DebugLog(@"%@", [error debugDescription]);
                                                               }];

    }
    else if ([actionName isEqualToString: @"apiChange"])
    {
        DebugLog (@"!!!!!!!!!! API change");
    }
    else if ([actionName isEqualToString: @"sizeChange"])
    {
        DebugLog (@"!!!!!!!!!! Size change");
    }
    else
    {
        AssertOrLog(@"Unexpected YTPlayer event");
    }
}


#pragma mark - URL handling

- (void) openYouTubeURL: (id) sender
{
    VideoInstance *videoInstance = self.videoInstanceArray [self.currentSelectedIndex];
    
    NSString *currentSourceId = videoInstance.video.sourceId;
    NSString *URLString = [NSString stringWithFormat: @"http://www.youtube.com/watch?v=%@", currentSourceId];
    NSURL *youTubeURL = [NSURL URLWithString: URLString];
    
    if ([[UIApplication sharedApplication] canOpenURL: youTubeURL])
	{
		[[UIApplication sharedApplication] openURL: youTubeURL];
	}
}

@end
