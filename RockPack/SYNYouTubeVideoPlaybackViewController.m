//
//  SYNYoutTubeVideoViewController.m
//  rockpack
//
//  Created by Nick Banks on 15/02/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import "AppConstants.h"
#import "GAI.h"
#import "NSObject+Blocks.h"
#import "SYNDeviceManager.h"
#import "SYNOAuthNetworkEngine.h"
#import "SYNOpaqueView.h"
#import "SYNYouTubeVideoPlaybackViewController.h"
#import <QuartzCore/CoreAnimation.h>
@import CoreData;

#define SHOW_SHUTTLE_DEBUG_COLOURS_
#define SHOW_DEBUG_COLOURS_

@interface SYNYouTubeVideoPlaybackViewController () <UIWebViewDelegate>

@property (nonatomic, assign) float percentageViewed;
@property (nonatomic, assign) float timeViewed;
@property (nonatomic, assign) BOOL autoPlay;
@property (nonatomic, assign) BOOL currentVideoViewedFlag;
@property (nonatomic, assign) BOOL disableTimeUpdating;
@property (nonatomic, assign) BOOL fadeOutScheduled;
@property (nonatomic, assign) BOOL fadeUpScheduled;
@property (nonatomic, assign) BOOL hasReloadedWebView;
@property (nonatomic, assign) BOOL notYetPlaying;
@property (nonatomic, assign) BOOL playFlag;
@property (nonatomic, assign) BOOL shuttledByUser;
@property (nonatomic, assign) BOOL pausedByUser;
@property (nonatomic, assign) BOOL recordedVideoView;
@property (nonatomic, assign) CGRect requestedFrame;
@property (nonatomic, assign) NSTimeInterval currentDuration;
@property (nonatomic, assign) NSTimeInterval lastTime;
@property (nonatomic, assign) int stallCount;
@property (nonatomic, strong) NSString *sourceIdToReload;
@property (nonatomic, strong) NSString *previousSourceId;
@property (nonatomic, strong) NSTimer *shuttleBarUpdateTimer;
@property (nonatomic, strong) NSTimer *recordVideoViewTimer;
@property (nonatomic, strong) NSTimer *videoStallDetectionTimer;
@property (nonatomic, strong) SYNVideoIndexUpdater indexUpdater;
@property (nonatomic, strong) UIView *videoPlaceholderView;
@property (nonatomic, strong) UIWebView *currentVideoWebView;


@end


@implementation SYNYouTubeVideoPlaybackViewController

@synthesize currentVideoInstance;

#pragma mark - Initialization

static UIWebView* youTubeVideoWebViewInstance;

+ (SYNYouTubeVideoPlaybackViewController*) sharedInstance
{
    static SYNYouTubeVideoPlaybackViewController *_sharedInstance = nil;
    
    if (!_sharedInstance)
    {
        static dispatch_once_t oncePredicate;
        dispatch_once(&oncePredicate, ^{
            // Create our shared intance
            _sharedInstance = [[self allocWithZone: nil] init];
            // Create the static instances of our webviews
            youTubeVideoWebViewInstance = [SYNYouTubeVideoPlaybackViewController createNewYouTubeWebView];
        });
    }
    
    return _sharedInstance;
}


#pragma mark - Object lifecycle

- (void) dealloc
{
    self.currentVideoWebView.delegate = nil;
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


- (void) updateWithFrame: (CGRect) frame
          channelCreator: (NSString *) channelCreator
            indexUpdater: (SYNVideoIndexUpdater) indexUpdater;
{
    self.requestedFrame = frame;
    self.indexUpdater = indexUpdater;
    self.channelCreator = channelCreator;
}

- (void) updateChannelCreator: (NSString *) channelCreator
{
    self.channelCreator = channelCreator;
    [self setCreatorText: self.channelCreator];
}


#pragma mark - View lifecyle

// Manually create our view

- (void) viewDidLoad
{
    [super viewDidLoad];

    // Make sure we set the desired frame at this point
    self.view.frame = self.requestedFrame;
    
    self.view.clipsToBounds = YES;

    // Start off by making our view transparent
    self.view.backgroundColor = kVideoBackgroundColour;
    
    // Create view containing animated subviews for the animated placeholder (displayed whilst video is loading)
    self.videoPlaceholderView = [self createNewVideoPlaceholderView];
    
    self.shuttleBarView = [self createShuttleBarView];
    UIView *blockBarView = [[UIView alloc] initWithFrame: self.shuttleBarView.frame];
    blockBarView.userInteractionEnabled = YES;
    blockBarView.backgroundColor = [UIColor clearColor];
    
    // Setup our web views
    youTubeVideoWebViewInstance.frame = self.view.bounds;
    youTubeVideoWebViewInstance.backgroundColor = self.view.backgroundColor;
    
    // Set the webview delegate so that we can received events from the JavaScript
    youTubeVideoWebViewInstance.delegate = self;
    
#ifdef ENABLE_VIMEO_PLAYER
    // Now we know our frame size, update the pre-created webview with size and colour
    vimeoVideoWebViewInstance.frame = self.view.bounds;
    vimeoVideoWebViewInstance.backgroundColor = self.view.backgroundColor;
    
    // Set the webview delegate so that we can received events from the JavaScript
    vimeoVideoWebViewInstance.delegate = self;
#endif
    
    // Default to using YouTube player for now
    self.currentVideoWebView = youTubeVideoWebViewInstance;
    
    [self.view insertSubview: self.currentVideoWebView
                belowSubview: self.shuttleBarView];
    
    [self.view insertSubview: blockBarView
                belowSubview: self.shuttleBarView];
}


- (void) viewWillAppear: (BOOL) animated
{
    [super viewWillAppear: animated];
    
    // Handle re-starting animations when returning from background
     [[NSNotificationCenter defaultCenter] addObserver: self
                                              selector: @selector(applicationDidBecomeActive:)
                                                  name: UIApplicationDidBecomeActiveNotification
                                                object: nil];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(applicationWillResignActive:)
                                                 name: UIApplicationWillResignActiveNotification
                                               object: nil];
    
    // Check to see if were playing when we left this page
    [self playIfVideoActive];
}


- (void) viewDidDisappear: (BOOL) animated
{
    // Stop observing everything (less error-prone than trying to remove observers individually
    [[NSNotificationCenter defaultCenter] removeObserver: self];
    
    [self logViewingStatistics];
    
    // Just pause the video, as we might come back to this view again (if we have pushed any views on top)
    [self pauseIfVideoActive];
    
    [self stopShuttleBarUpdateTimer];
    [self stopVideoStallDetectionTimer];
    [super viewDidDisappear: animated];
}


- (void) playIfVideoActive
{
    if (self.isPaused == TRUE)
    {
        if (self.pausedByUser == NO)
        {
            [self playVideo];
        }
    }
    else
    {
        // Make sure we are displaying the spinner and not the video at this stage
        self.currentVideoWebView.alpha = 0.0f;
        self.videoPlaceholderView.alpha = 1.0f;
    }
    
    // Start animation
    [self animateVideoPlaceholder: YES];
}


- (void) pauseIfVideoActive
{
    if (self.isPlayingOrBuffering == TRUE)
    {
        [self pauseVideo];
    }
    
    // Start animation
    [self animateVideoPlaceholder: NO];
}


#pragma mark - Timer accessors

- (void) setRecordVideoViewTimer: (NSTimer *) timer
{
    [_recordVideoViewTimer invalidate];
    
}

- (void) setPlaylist: (NSArray *) playlistArray
       selectedIndex: (int) selectedIndex
            autoPlay: (BOOL) autoPlay;
{
    self.videoInstanceArray = playlistArray;
    self.currentSelectedIndex = selectedIndex;
    self.autoPlay = autoPlay;
    
    self.currentVideoViewedFlag = FALSE;
    self.previousSourceId = nil;
    
    [self loadCurrentVideoWebView];
}


#pragma mark - YouTube player support

- (void) playYouTubeVideoWithSourceId: (NSString *) sourceId
{
//    DebugLog(@"*** Playing: Load video command sent");
    self.notYetPlaying = TRUE;
    self.recordedVideoView = FALSE;
    self.pausedByUser = NO;
    
    SYNAppDelegate* appDelegate = UIApplication.sharedApplication.delegate;
    // Check to see if our JS is loaded
    NSString *availability = [self.currentVideoWebView stringByEvaluatingJavaScriptFromString: @"checkPlayerAvailability();"];
    if ([availability isEqualToString: @"true"] && appDelegate.playerUpdated == FALSE)
    {
        // Our JS is loaded
        NSString *loadString = [NSString stringWithFormat: @"player.loadVideoById('%@', '0', '%@');", sourceId, self.videoQuality];
        
        [self startVideoStallDetectionTimer];
        
        [self.currentVideoWebView stringByEvaluatingJavaScriptFromString: loadString];
        
        self.playFlag = TRUE;
        
        [self.shuttleBarPlayPauseButton setImage: [UIImage imageNamed: @"ButtonShuttleBarPause.png"]
                                        forState: UIControlStateNormal];
    }
    else
    {
        // Something unloaded our JS, so use different approach
        // Reload out webview and load the new video when we get an event to say that the player is ready
        self.hasReloadedWebView = TRUE;
        self.sourceIdToReload = sourceId;
        appDelegate.playerUpdated = FALSE;
        
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


- (void) playVideoAtIndex: (int) index
{
    // If we are already at this index, but not playing, then play
    if (index == self.currentSelectedIndex)
    {
        if (!self.isPlaying)
        {
            // If we are not currently playing, then start playing
            [self playVideo];
            self.playFlag = TRUE;
        }
        else
        {
            // If we were already playing then restart the currentl video
            [self setCurrentTime: 0.0f];
        }
    }
    else
    {
        // OK, we are not currently playing this index, so segue to the next video
        [self fadeOutVideoPlayer];
        self.currentSelectedIndex = index;
        [self loadCurrentVideoWebView];
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


- (void) loadNextVideo
{
    [self incrementVideoIndex];
    [self loadCurrentVideoWebView];
    
    // Call index updater block
    self.indexUpdater(self.currentSelectedIndex);
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


#pragma mark - Video playback HTML creation

- (void) resetPlayerAttributes
{
    // Used to determine if a pause event is caused by shuttling or the user touching the pause button
    self.shuttledByUser = TRUE;
    
    // Make sure we don't receive any shuttle bar or buffer update timer events until we have loaded the new video
    [self stopShuttleBarUpdateTimer];
    // Reset shuttle slider
    self.shuttleSlider.value = 0.0f;
    
    // Reset progress view
    self.bufferingProgressView.progress = 0.0f;
    
    // And time value
    self.currentTimeLabel.text = [NSString timecodeStringFromSeconds: 0.0f];
}


- (void) loadCurrentVideoWebView
{
    [self resetPlayerAttributes];
    
    [self logViewingStatistics];
    
    self.currentVideoViewedFlag = FALSE;
    self.percentageViewed = 0.0f;
    self.timeViewed = 0.0f;

    VideoInstance *videoInstance = self.videoInstanceArray [self.currentSelectedIndex];
    
    NSString *currentSource = videoInstance.video.source;
    NSString *currentSourceId = videoInstance.video.sourceId;
    
    self.previousSourceId = currentSourceId;
    
    // Try to set the duration
    self.currentDuration = videoInstance.video.durationValue;
    self.durationLabel.text = [NSString timecodeStringFromSeconds: self.currentDuration];
    
    if ([currentSource isEqualToString: @"youtube"])
    {
        [self playYouTubeVideoWithSourceId: currentSourceId];
    }
    else if ([currentSource isEqualToString: @"vimeo"])
    {
        // TODO: Add Vimeo support here
    }
    else
    {
        // AssertOrLog(@"Unknown video source type");
        DebugLog(@"WARNING: No Source! ");
    }
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
                    [self handleCurrentVimeoPlayerEventNamed: actionName
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
            
            [self.shuttleBarPlayPauseButton setImage: [UIImage imageNamed: @"ButtonShuttleBarPause.png"]
                                            forState: UIControlStateNormal];
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
                self.durationLabel.text = [NSString timecodeStringFromSeconds: self.currentDuration];
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
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Video Quality"
//                                                        message: actionData
//                                                       delegate: nil
//                                              cancelButtonTitle: @"OK"
//                                              otherButtonTitles: nil, nil];
//        [alert show];
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


- (void) handleCurrentVimeoPlayerEventNamed: (NSString *) actionName
                           eventData: (NSString *) actionData
{
    // TODO: Vimeo support
}


- (void) startVideoStallDetectionTimer
{
    [self.videoStallDetectionTimer invalidate];
    
    // Schedule the timer on a different runloop so that we continue to get updates even when scrolling collection views etc.
    self.videoStallDetectionTimer = [NSTimer timerWithTimeInterval: kVideoStallThresholdTime
                                                         target: self
                                                       selector: @selector(videoStallDetected)
                                                       userInfo: nil
                                                        repeats: NO];
    
    [[NSRunLoop mainRunLoop] addTimer: self.videoStallDetectionTimer forMode: NSRunLoopCommonModes];
}



- (void) stopVideoStallDetectionTimer
{
    [self.videoStallDetectionTimer invalidate], self.videoStallDetectionTimer = nil;
}

- (void) videoStallDetected
{
    SYNAppDelegate* appDelegate = UIApplication.sharedApplication.delegate;
    VideoInstance *videoInstance = self.videoInstanceArray [self.currentSelectedIndex];

    SYNMasterViewController *masterViewController = (SYNMasterViewController*)appDelegate.masterViewController;
    
    NSString *errorDescription =  @"Video stalled (Cellular)";

    if ([masterViewController.reachability currentReachabilityStatus] == ReachableViaWiFi)
    {
        errorDescription = @"Video stalled (WiFi)";
    }
    
    [appDelegate.oAuthNetworkEngine reportPlayerErrorForVideoInstanceId: videoInstance.uniqueId
                                                       errorDescription: errorDescription
                                                      completionHandler: ^(NSDictionary * dictionary) {
                                                          DebugLog(@"Reported video stall: %@", errorDescription);
                                                      }
                                                           errorHandler: ^(NSError* error) {
                                                               DebugLog(@"Report video stall failed");
                                                               DebugLog(@"%@", [error debugDescription]);
                                                           }];
}


- (void) startShuttleBarUpdateTimer
{
    [self.shuttleBarUpdateTimer invalidate];
    
    // Schedule the timer on a different runloop so that we continue to get updates even when scrolling collection views etc.
    self.shuttleBarUpdateTimer = [NSTimer timerWithTimeInterval: kShuttleBarUpdateTimerInterval
                                                       target: self
                                                     selector: @selector(updateShuttleBarProgress)
                                                     userInfo: nil
                                                      repeats: YES];
    
    [[NSRunLoop mainRunLoop] addTimer: self.shuttleBarUpdateTimer forMode: NSRunLoopCommonModes];
}




- (void) stopShuttleBarUpdateTimer
{
    [self.shuttleBarUpdateTimer invalidate], self.shuttleBarUpdateTimer = nil;
}


- (void) updateShuttleBarProgress
{
    float bufferLevel = [self videoLoadedFraction];
//    NSLog (@"Buffer level %f", bufferLevel);
    
    // Update the progress bar under our slider
    self.bufferingProgressView.progress = bufferLevel;
    
    // Only update the shuttle if we are playing (this should stop the shuttle bar jumping to zero
    // just after a user shuttle event)
    
    NSTimeInterval currentTime = self.currentTime;
//    DebugLog (@"Current time %lf", currentTime);
    
    // We need to wait until the play time starts to increase before fading up the video
    if (currentTime > 0.0f)
    {
        // Fade up the player if we haven't already
        if (self.fadeUpScheduled == FALSE)
        {
            // Reset our stall count, once per video
            self.stallCount = 0;
            
            // Fade up the video and fade out the placeholder
            self.fadeUpScheduled = TRUE;
            [self fadeUpVideoPlayer];
        }
        
        // Check to see if the player has stalled (a number of instances of the same time)
        if (currentTime == self.lastTime && self.playFlag == TRUE)
        {
            self.stallCount++;
            
            if (self.stallCount > kMaxStallCount)
            {
                DebugLog (@"*** Stalled: Attempting to restart player");
//                [self pauseVideo];
                [self playVideo];

                // Reset our stall count (could make this negative to give restarts longer)
                self.stallCount = 0;
            }
        }
        else
        {
            self.lastTime = currentTime;
            
            // Reset our stall count 
            self.stallCount = 0;
        }
    }
    
    // Update current time label
    self.currentTimeLabel.text = [NSString timecodeStringFromSeconds: currentTime];
//        self.currentTimeLabel.text = [NSString timecodeStringFromSeconds: 9*60*60+59*60+59];
    // Calculate the currently viewed percentage
    float viewedPercentage = currentTime / self.currentDuration;
    
    self.percentageViewed = viewedPercentage;
    self.timeViewed = currentTime;
    
    // and slider
    if (self.disableTimeUpdating == FALSE)
    {
        self.shuttleSlider.value = viewedPercentage;
        
        // We should also check to see if we are in the last 0.5 seconds of a video, and if so, trigger a fadeout
        if ((self.currentDuration - self.currentTime) < 0.5f)
        {
            DebugLog(@"*** In end zone");
            
            if (self.fadeOutScheduled == FALSE)
            {
                self.fadeOutScheduled = TRUE;
                
                [self performBlock: ^{
                    if (self.fadeOutScheduled == TRUE)
                    {
                        self.fadeOutScheduled = FALSE;
                        
                        [self fadeOutVideoPlayer];
                        DebugLog(@"***** Fadeout");
                    }
                    else
                    {
                        DebugLog(@"***** Failed to re-trigger fadeout");
                    }
                }
                        afterDelay: 0.0f
             cancelPreviousRequest: YES];
            }
        }
    }
    
    // Now, if we have viewed more than kPercentageThresholdForView%, then mark as viewed
    if (viewedPercentage > kPercentageThresholdForView && self.currentVideoViewedFlag == FALSE)
    {
        // Don't mark as viewed again
        self.currentVideoViewedFlag = TRUE;
        
        SYNAppDelegate* appDelegate = UIApplication.sharedApplication.delegate;
        
        // Just double-check that we have both params required for
        if (self.currentVideoInstance.uniqueId && appDelegate.currentOAuth2Credentials.userId)
        {
            // Update the star/unstar status on the server
            [appDelegate.oAuthNetworkEngine recordActivityForUserId: appDelegate.currentOAuth2Credentials.userId
                                                             action: @"view"
                                                    videoInstanceId: self.currentVideoInstance.uniqueId
                                                  completionHandler: ^(NSDictionary *responseDictionary) {
                                                  }
                                                       errorHandler: ^(NSDictionary* errorDictionary) {
                                                           DebugLog(@"View action failed");
                                                       }];
        }
        else
        {
            AssertOrLog(@"We seem to be missing one of the parameters for recording video play activity");
        }
    }
}


#pragma mark - User interaction

- (void) togglePlayPause
{
    if (self.playFlag == TRUE)
    {
        // Reset our shuttling flag
        self.shuttledByUser = FALSE;
        self.pausedByUser = YES;
        
        [self.shuttleBarPlayPauseButton setImage: [UIImage imageNamed: @"ButtonShuttleBarPlay.png"]
                                        forState: UIControlStateNormal];
        
        [self pauseVideo];
    }
    else
    {
        [self.shuttleBarPlayPauseButton setImage: [UIImage imageNamed: @"ButtonShuttleBarPause.png"]
                                        forState: UIControlStateNormal];
        
        self.pausedByUser = NO;
        [self playVideo];
    }
}


- (void) updateTimeFromSlider: (UISlider *) slider
{
    // Indicate that a pause event may be caused by the user shuttling
    self.shuttledByUser = TRUE;
    self.disableTimeUpdating = TRUE;
    
    // Only re-enable our upating after a certain period (to stop slider jumping)
    [self performBlock: ^{
        self.disableTimeUpdating = FALSE;
    }
            afterDelay: 1.0f
 cancelPreviousRequest: YES];

    float newTime = slider.value * self.currentDuration;
    
    [self setCurrentTime: newTime];
//    DebugLog (@"Setting time %f", newTime);
    
    self.currentTimeLabel.text = [NSString timecodeStringFromSeconds: newTime];
    
    if (self.updateBlock)
    {
        self.updateBlock();
    }
}


#pragma mark - View animations

// Fades up the video player, fading out any placeholder
- (void) fadeUpVideoPlayer
{
    // Tweaked this as the QuickTime logo seems to appear otherwise
    [UIView animateWithDuration: 0.5f
                          delay: 0.0f
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations: ^ {
                         self.currentVideoWebView.alpha = 1.0f;
                         self.videoPlaceholderView.alpha = 0.0f;
                     }
                     completion: ^(BOOL completed) {
                     }];
}


// Fades out the video player, fading in any placeholder
- (void) fadeOutVideoPlayer
{    
    [UIView animateWithDuration: 0.5f
                          delay: 0.0f
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations: ^ {
                         self.currentVideoWebView.alpha = 0.0f;
                         self.videoPlaceholderView.alpha = 1.0f;
                     }
                     completion: nil];
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

- (void) logViewingStatistics
{
    if (self.previousSourceId != nil && self.percentageViewed > 0.0f)
    {
        id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
        
        [tracker send: [[GAIDictionaryBuilder createEventWithCategory: @"goal"
                                                               action: @"videoViewed"
                                                                label: self.previousSourceId
                                                                value: @((int) (self.percentageViewed  * 100.0f))] build]];
        
        [tracker send: [[GAIDictionaryBuilder createEventWithCategory: @"goal"
                                                               action: @"videoViewedDuration"
                                                                label: self.previousSourceId
                                                                value: @((int) (self.timeViewed))] build]];
    }
}

@end
