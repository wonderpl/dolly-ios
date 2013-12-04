//
//  SYNAbstractVideoPlaybacViewController.m
//  dolly
//
//  Created by Nick Banks on 08/11/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNAbstractVideoPlaybackViewController+Private.h"
#import "SYNVideoLoadingIndicator.h"
#import "SYNScrubberBar.h"
#import "SYNAppDelegate.h"

@implementation SYNAbstractVideoPlaybackViewController

#pragma mark - View lifecycle

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    // Make sure we set the desired frame at this point
    self.view.frame = self.requestedFrame;
    
    self.view.clipsToBounds = YES;
    
    self.view.backgroundColor = kVideoBackgroundColour;
    
	self.videoLoadingIndicator = [[SYNVideoLoadingIndicator alloc] initWithFrame:self.view.bounds];
	[self.view addSubview:self.videoLoadingIndicator];
	
    // Setup our web views
    [self specificInit];
	
	self.scrubberBar = [SYNScrubberBar view];
	self.scrubberBar.frame = CGRectMake(0,
										CGRectGetHeight(self.view.frame) - CGRectGetHeight(self.scrubberBar.frame),
										CGRectGetWidth(self.view.frame),
										CGRectGetHeight(self.scrubberBar.frame));
	self.scrubberBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	self.scrubberBar.delegate = self;
	
	self.scrubberBar.playing = YES;
	
    UIView *blockBarView = [[UIView alloc] initWithFrame: self.scrubberBar.frame];
    blockBarView.userInteractionEnabled = YES;
    blockBarView.backgroundColor = [UIColor clearColor];
	
	[self.view addSubview:self.scrubberBar];
    
    [self.view insertSubview: self.currentVideoView
                belowSubview: self.scrubberBar];
    
    [self.view insertSubview: blockBarView
                belowSubview: self.scrubberBar];
}


- (void) specificInit
{
    AssertOrLog(@"Should be defined in subclass");
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
	
	[self.videoLoadingIndicator stopAnimating];
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




+ (CGFloat) videoWidth
{
    CGFloat width = 320.0f;
    
    if (IS_IPAD)
    {
#ifdef USE_HIRES_PLAYER
        width = 1280.0f;
#else
        width = 739.0f;
#endif
    }
    return width;
}


+ (CGFloat) videoHeight
{
    CGFloat height = 180.0f;
    
    if (IS_IPAD)
    {
#ifdef USE_HIRES_PLAYER
        height = 768.0f;
#else
        height = 416.0f;
#endif
        
    }
    
    return height;
}


- (NSString *) videoQuality
{
    // Based on empirical evidence (Youtube app), determine the appropriate quality level based on device and connectivity
    SYNAppDelegate* appDelegate = UIApplication.sharedApplication.delegate;
    SYNMasterViewController *masterViewController = (SYNMasterViewController*)appDelegate.masterViewController;
    NSString *suggestedQuality = @"default";
    
    if ([masterViewController.reachability currentReachabilityStatus] == ReachableViaWiFi)
    {
        if (IS_IPAD)
        {
            suggestedQuality = @"hd720";
        }
        else
        {
            suggestedQuality = @"medium";
        }
    }
    else
    {
        // Connected via cellular network
        if (IS_IPAD)
        {
            suggestedQuality = @"medium";
        }
        else
        {
            suggestedQuality = @"small";
        }
    }
    
    DebugLog (@"Attempting to play quality: %@", suggestedQuality);
    return suggestedQuality;
}

#pragma mark - Source / Playlist management

- (VideoInstance*) currentVideoInstance
{
    return (VideoInstance*)self.videoInstanceArray [self.currentSelectedIndex];
}


- (void) incrementVideoIndex
{
    // Calculate new index, wrapping around if necessary
    self.currentSelectedIndex = (self.currentSelectedIndex + 1) % self.videoInstanceArray.count;
}


- (void) decrementVideoIndex
{
    // Calculate new index
    self.currentSelectedIndex = self.currentSelectedIndex -  1;
    
    // wrap around if necessary
    if (self.currentSelectedIndex < 0)
    {
        self.currentSelectedIndex = self.videoInstanceArray.count - 1;
    }
}


- (int) nextVideoIndex
{
    return (self.currentSelectedIndex + 1) % self.videoInstanceArray.count;
}


- (int) previousVideoIndex
{
    int index = self.currentSelectedIndex -  1;
    
    // wrap around if necessary
    if (index < 0)
    {
        index = self.videoInstanceArray.count - 1;
    }
    
    return index;
}

- (void) setCreatorText: (NSString *) creatorText;
{
    self.creatorLabel.text = [NSString stringWithFormat: @"Uploaded by %@", self.channelCreator];
}

- (void) resetPlayerAttributes
{
    // Used to determine if a pause event is caused by shuttling or the user touching the pause button
    self.shuttledByUser = TRUE;
    
    // Make sure we don't receive any shuttle bar or buffer update timer events until we have loaded the new video
    [self stopShuttleBarUpdateTimer];
    // Reset shuttle slider
//    self.shuttleSlider.value = 0.0f;
//    
//    // Reset progress view
//    self.bufferingProgressView.progress = 0.0f;
}


- (void) loadCurrentVideoView
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
	
	self.currentTime = 0.0;
	self.scrubberBar.duration = self.currentDuration;
    
    if ([currentSource isEqualToString: @"youtube"])
    {
        [self playVideoWithSourceId: currentSourceId];
    }
    else if ([currentSource isEqualToString: @"ooyala"])
    {
        [self playVideoWithSourceId: currentSourceId];
    }
    else
    {
        // AssertOrLog(@"Unknown video source type");
        DebugLog(@"WARNING: No Source! ");
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
        [self loadCurrentVideoView];
    }
}


- (void) loadNextVideo
{
    [self incrementVideoIndex];
    [self loadCurrentVideoView];
    
    // Call index updater block
    self.indexUpdater(self.currentSelectedIndex);
}

#pragma mark - Placeholder Animation

- (void)applicationWillResignActive:(NSNotification *)notification {
	[self.videoLoadingIndicator stopAnimating];
}

- (void)applicationDidBecomeActive:(NSNotification *)notification {
	[self.videoLoadingIndicator startAnimating];
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
                         self.currentVideoView.alpha = 1.0f;
                         self.videoLoadingIndicator.alpha = 0.0f;
                     }
                     completion: ^(BOOL completed) {
						 [self.videoLoadingIndicator stopAnimating];
                     }];
}


// Fades out the video player, fading in any placeholder
- (void) fadeOutVideoPlayer
{
    [UIView animateWithDuration: 0.5f
                          delay: 0.0f
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations: ^ {
                         self.currentVideoView.alpha = 0.0f;
                         self.videoLoadingIndicator.alpha = 1.0f;
						 [self.videoLoadingIndicator startAnimating];
                     }
                     completion: nil];
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
        self.currentVideoView.alpha = 0.0f;
        self.videoLoadingIndicator.alpha = 1.0f;
		
		[self.videoLoadingIndicator startAnimating];
    }
    
}


- (void) pauseIfVideoActive
{
    if (self.isPlayingOrBuffering == TRUE)
    {
        [self pauseVideo];
    }
    
	[self.videoLoadingIndicator stopAnimating];
}

- (void) startShuttleBarUpdateTimer
{
    [self.shuttleBarUpdateTimer invalidate];
    

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

#pragma mark - User interaction

- (void) setPlaylist: (NSArray *) playlistArray
       selectedIndex: (int) selectedIndex
            autoPlay: (BOOL) autoPlay;
{
    self.videoInstanceArray = playlistArray;
    self.currentSelectedIndex = selectedIndex;
    self.autoPlay = autoPlay;
    
    self.currentVideoViewedFlag = FALSE;
    self.previousSourceId = nil;
    
    [self loadCurrentVideoView];
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


- (void) updateShuttleBarProgress
{
	self.scrubberBar.bufferingProgress = [self videoLoadedFraction];
    
    // Only update the shuttle if we are playing (this should stop the shuttle bar jumping to zero
    // just after a user shuttle event)
    NSTimeInterval currentTime = self.currentTime;
    
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
	
	self.scrubberBar.currentTime = currentTime;
    
    // Calculate the currently viewed percentage
    float viewedPercentage = currentTime / self.currentDuration;
    
    self.percentageViewed = viewedPercentage;
    self.timeViewed = currentTime;
    
    // and slider
    if (self.disableTimeUpdating == FALSE)
    {
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

#pragma mark - SYNScrubberBarDelegate

- (void)scrubberBarPlayPauseToggled:(BOOL)playing {
	if (playing) {
		self.pausedByUser = NO;
		
		[self playVideo];
	} else {
		self.shuttledByUser = NO;
		self.pausedByUser = YES;
		
		[self pauseVideo];
	}
}

- (void)scrubberBarCurrentTimeWillChange {
	//TOOD: If playing
	self.pausedByUser = YES;
	
	[self pauseVideo];
}

- (void)scrubberBarCurrentTimeChanged:(NSTimeInterval)currentTime {
	[self setCurrentTime:currentTime];
}

- (void)scrubberBarCurrentTimeDidChange {
	[self playVideo];
}

- (void)scrubberBarFullScreenToggled:(BOOL)fullScreen {
	SYNAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	[appDelegate.masterViewController.videoViewerViewController userTouchedMaxMinButton];
}


#pragma mark - Abstract functions

- (NSTimeInterval) duration
{
    AssertOrLog(@"Abstract method called");
    return 0.0f;
}


- (NSTimeInterval) currentTime
{
    AssertOrLog(@"Abstract method called");
    return 0.0f;
}


- (void) setCurrentTime: (NSTimeInterval) newTime
{
    AssertOrLog(@"Abstract method called");
}


- (float) videoLoadedFraction
{
    AssertOrLog(@"Abstract method called");
    return 0.0f;
}


- (BOOL) isPlaying
{
    AssertOrLog(@"Abstract method called");
    return FALSE;
}


- (BOOL) isPlayingOrBuffering
{
    AssertOrLog(@"Abstract method called");
    return FALSE;
}


- (BOOL) isPaused
{
    AssertOrLog(@"Abstract method called");
    return FALSE;
}


- (void) playVideo;
{
    AssertOrLog(@"Abstract method called");
}

- (void) pauseVideo
{
    AssertOrLog(@"Abstract method called");
}


- (void) stopVideo
{
    AssertOrLog(@"Abstract method called");
}

- (void) playVideoWithSourceId: (NSString *) sourceId
{
    AssertOrLog(@"Abstract method called");
}

@end
