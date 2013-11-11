//
//  SYNAbstractVideoPlaybacViewController.m
//  dolly
//
//  Created by Nick Banks on 08/11/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNAbstractVideoPlaybackViewController+Private.h"

@implementation SYNAbstractVideoPlaybackViewController

#pragma mark - Object lifecycle

- (void) dealloc
{
    self.placeholderBottomLayerAnimation.delegate = nil;
    self.placeholderMiddleLayerAnimation.delegate = nil;
}

#pragma mark - View lifecycle

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
    [self specificInit];
    
    [self.view insertSubview: self.currentVideoView
                belowSubview: self.shuttleBarView];
    
    [self.view insertSubview: blockBarView
                belowSubview: self.shuttleBarView];
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

- (UIView *) createShuttleBarView
{
    CGFloat shuttleBarButtonOffset = kShuttleBarButtonOffsetiPhone;
    CGFloat shuttleBarButtonWidth = kShuttleBarButtonWidthiPhone;
    CGFloat airplayOffset = 0;
    
    if (IS_IPAD)
    {
        shuttleBarButtonOffset = kShuttleBarButtonWidthiPad;
        shuttleBarButtonWidth = kShuttleBarButtonWidthiPad;
        airplayOffset = 10;
    }
    
    // Create out shuttle bar view at the bottom of our video view
    CGRect shuttleBarFrame = self.view.frame;
    shuttleBarFrame.size.height = kShuttleBarHeight;
    shuttleBarFrame.origin.x = 0.0f;
    shuttleBarFrame.origin.y = self.view.frame.size.height - kShuttleBarHeight;
    UIView *shuttleBarView = [[UIView alloc] initWithFrame: shuttleBarFrame];
    
    // Add transparent background view
    UIView *shuttleBarBackgroundView = [[UIView alloc] initWithFrame: shuttleBarView.bounds];
    shuttleBarBackgroundView.alpha = 0.5f;
    shuttleBarBackgroundView.backgroundColor = [UIColor blackColor];
    shuttleBarBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [shuttleBarView addSubview: shuttleBarBackgroundView];
    
    // Add play/pause button
    self.shuttleBarPlayPauseButton = [UIButton buttonWithType: UIButtonTypeCustom];
    
    // Set this subview to appear slightly offset from the left-hand side
    self.shuttleBarPlayPauseButton.frame = CGRectMake(20, 0, shuttleBarButtonOffset, kShuttleBarHeight);
    
    [self.shuttleBarPlayPauseButton setImage: [UIImage imageNamed: @"ButtonShuttleBarPause.png"]
                                    forState: UIControlStateNormal];
    
    [self.shuttleBarPlayPauseButton addTarget: self
                                       action: @selector(togglePlayPause)
                             forControlEvents: UIControlEventTouchUpInside];
    
    self.shuttleBarPlayPauseButton.backgroundColor = [UIColor clearColor];
    [shuttleBarView addSubview: self.shuttleBarPlayPauseButton];
    
    // Add time labels
    self.currentTimeLabel = [self createTimeLabelAtXPosition: shuttleBarButtonWidth
                                               textAlignment: NSTextAlignmentRight];
    
    self.currentTimeLabel.text =  [NSString timecodeStringFromSeconds: 0.0f];
    
    [shuttleBarView addSubview: self.currentTimeLabel];
    
    self.durationLabel = [self createTimeLabelAtXPosition: self.view.frame.size.width - kShuttleBarTimeLabelWidth - shuttleBarButtonWidth
                                            textAlignment: NSTextAlignmentLeft];
    
    self.durationLabel.text =  [NSString timecodeStringFromSeconds: 0.0f];
    
    self.durationLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [shuttleBarView addSubview: self.durationLabel];
    
    // Add shuttle slider
    // Set custom slider track images
    CGFloat sliderOffset = shuttleBarButtonWidth + kShuttleBarTimeLabelWidth + kShuttleBarSliderOffset;
    
    UIImage *sliderBackgroundImage = [UIImage imageNamed: @"ShuttleBarPlayerBar.png"];
    
    UIImageView *sliderBackgroundImageView = [[UIImageView alloc] initWithFrame: CGRectMake(sliderOffset+2, 17, shuttleBarFrame.size.width - 4 - (2 * sliderOffset), 10)];
    
    sliderBackgroundImageView.image = [sliderBackgroundImage resizableImageWithCapInsets: UIEdgeInsetsMake(0.0f, 10.0f, 0.0f, 10.0f)];
    sliderBackgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [shuttleBarView addSubview: sliderBackgroundImageView];
    
    // Add the progress bar over the background, but underneath the slider
    self.bufferingProgressView = [[SYNProgressView alloc] initWithFrame: CGRectMake(sliderOffset+1, 17, shuttleBarFrame.size.width - 4 -(2 * sliderOffset), 10)];
    UIImage *progressImage = [[UIImage imageNamed: @"ShuttleBarBufferBar.png"] resizableImageWithCapInsets: UIEdgeInsetsMake(0.0f, 10.0f, 0.0f, 10.0f)];
    
    // Note: this image needs to be exactly the same size at the left hand-track bar, or the bar will only display as a line
    UIImage *shuttleSliderRightTrack = [[UIImage imageNamed: @"ShuttleBarRemainingBar.png"] resizableImageWithCapInsets: UIEdgeInsetsMake(0.0f, 10.0f, 0.0f, 10.0f)];
    
    self.bufferingProgressView.progressImage = progressImage;
    self.bufferingProgressView.trackImage = shuttleSliderRightTrack;
    self.bufferingProgressView.progress = 0.0f;
    self.bufferingProgressView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [shuttleBarView addSubview: self.bufferingProgressView];
    
    CGFloat sliderYOffset = 9.0f;
    
    if (IS_IOS_7_OR_GREATER)
    {
        sliderYOffset = 5.0f;
    }
    
    self.shuttleSlider = [[UISlider alloc] initWithFrame: CGRectMake(sliderOffset, sliderYOffset, shuttleBarFrame.size.width - (2 * sliderOffset), 25)];
    
    UIImage *shuttleSliderLeftTrack = [[UIImage imageNamed: @"ShuttleBarProgressBar.png"] resizableImageWithCapInsets: UIEdgeInsetsMake(0.0f, 10.0f, 0.0f, 10.0f)];
    
    
    [self.shuttleSlider setMinimumTrackImage: shuttleSliderLeftTrack
                                    forState: UIControlStateNormal];
	
	[self.shuttleSlider setMaximumTrackImage: shuttleSliderRightTrack
                                    forState: UIControlStateNormal];
	
	// Custom slider thumb image
    [self.shuttleSlider setThumbImage: [UIImage imageNamed: @"ShuttleBarSliderThumb.png"]
                             forState: UIControlStateNormal];
    
    self.shuttleSlider.value = 0.0f;
    
    [self.shuttleSlider addTarget: self
                           action: @selector(updateTimeFromSlider:)
                 forControlEvents: UIControlEventValueChanged];
    
    self.shuttleSlider.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [shuttleBarView addSubview: self.shuttleSlider];
    
    
    // Add max/min button
    self.shuttleBarMaxMinButton = [UIButton buttonWithType: UIButtonTypeCustom];
    
    if (IS_IPHONE)
    {
        // Set this subview to appear slightly offset from the left-hand side
        self.shuttleBarMaxMinButton.frame = CGRectMake(300 - shuttleBarButtonOffset, 0, shuttleBarButtonOffset, kShuttleBarHeight);
    }
    else
    {
        self.shuttleBarMaxMinButton.frame = CGRectMake(719 - shuttleBarButtonOffset, 0, shuttleBarButtonOffset, kShuttleBarHeight);
    }
    
    [self.shuttleBarMaxMinButton setImage: [UIImage imageNamed: @"ButtonShuttleBarMaximise.png"]
                                 forState: UIControlStateNormal];
    
    self.shuttleBarMaxMinButton.backgroundColor = [UIColor clearColor];
    
    self.shuttleBarMaxMinButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    
    [shuttleBarView addSubview: self.shuttleBarMaxMinButton];
    
    // Add AirPlay button
    // This is a crafty (apple approved) hack, where we set the showVolumeSlider parameter to NO, so only the AirPlay symbol gets shown
    MPVolumeView *volumeView = [[MPVolumeView alloc] init];
    volumeView.frame = CGRectMake(self.view.frame.size.width - (35 +  airplayOffset), 12, 44, kShuttleBarHeight);
    [volumeView setShowsVolumeSlider: NO];
    [volumeView sizeToFit];
    volumeView.backgroundColor = [UIColor clearColor];
    volumeView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    
    //Airplay was messing with the maximise button
    [shuttleBarView insertSubview:volumeView belowSubview:self.shuttleBarMaxMinButton];
    [self.view addSubview: shuttleBarView];
    
    self.originalShuttleBarFrame = shuttleBarView.frame;
    
#if 0
    shuttleBarView.backgroundColor = [UIColor redColor];
    self.durationLabel.backgroundColor = [UIColor yellowColor];
    volumeView.backgroundColor = [UIColor greenColor];
    self.shuttleBarMaxMinButton.backgroundColor = [UIColor blueColor];
#endif
    
    return shuttleBarView;
}

- (void) resetShuttleBarFrame
{
    self.shuttleBarView.frame = self.originalShuttleBarFrame;
}


- (UILabel *) createTimeLabelAtXPosition: (CGFloat) xPosition
                           textAlignment: (NSTextAlignment) textAlignment
{
    CGRect timeLabelFrame = self.view.frame;
    timeLabelFrame.size.height = kShuttleBarHeight - 4;
    timeLabelFrame.size.width = kShuttleBarTimeLabelWidth;
    timeLabelFrame.origin.x = xPosition;
    timeLabelFrame.origin.y = 4;
    
    UILabel *timeLabel = [[UILabel alloc] initWithFrame: timeLabelFrame];
    timeLabel.textColor = [UIColor whiteColor];
    timeLabel.textAlignment = textAlignment;
    timeLabel.font = [UIFont regularCustomFontOfSize: 12.0f];
    timeLabel.backgroundColor = [UIColor clearColor];
    
    return timeLabel;
}


- (UIView *) createNewVideoPlaceholderView
{
    self.videoPlaceholderTopImageView = [self createNewVideoPlaceholderImageView: @"PlaceholderVideoTop"];
    self.videoPlaceholderMiddleImageView = [self createNewVideoPlaceholderImageView: @"PlaceholderVideoMiddle"];
    self.videoPlaceholderBottomImageView = [self createNewVideoPlaceholderImageView: @"PlaceholderVideoBottom"];
    
    // Pop them in a view to keep them together
    UIView *videoPlaceholderView = [[UIView alloc] initWithFrame: self.view.bounds];
    
    // Placeholders
    [videoPlaceholderView addSubview: self.videoPlaceholderBottomImageView];
    [videoPlaceholderView addSubview: self.videoPlaceholderMiddleImageView];
    [videoPlaceholderView addSubview: self.videoPlaceholderTopImageView];
    
    [self.view addSubview: videoPlaceholderView];
    
    return videoPlaceholderView;
}

- (void) setCreatorText: (NSString *) creatorText;
{
    self.creatorLabel.text = [NSString stringWithFormat: @"Uploaded by %@", self.channelCreator];
}


- (UIImageView *) createNewVideoPlaceholderImageView: (NSString *) imageName
{
    UIImageView *imageView = [[UIImageView alloc] initWithFrame: self.view.bounds];
    imageView.contentMode = UIViewContentModeCenter;
    imageView.backgroundColor = [UIColor clearColor];
    imageView.image = [UIImage imageNamed: imageName];
    
    return imageView;
}


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
    self.durationLabel.text = [NSString timecodeStringFromSeconds: self.currentDuration];
    
    if ([currentSource isEqualToString: @"youtube"])
    {
        [self playVideoWithSourceId: currentSourceId];
    }
    else if ([currentSource isEqualToString: @"rockpack"])
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

- (void) animateVideoPlaceholder: (BOOL) animate
{
    if (animate == TRUE)
    {
        // Start the animations
        [self spinBottomPlaceholderImageView];
        [self spinMiddlePlaceholderImageView];
    }
    else
    {
        // Stop the animations
        [self.videoPlaceholderBottomImageView.layer removeAllAnimations];
        [self.videoPlaceholderMiddleImageView.layer removeAllAnimations];
    }
}


- (void) spinMiddlePlaceholderImageView
{
    self.placeholderMiddleLayerAnimation = [self spinView: self.videoPlaceholderMiddleImageView
                                                 duration: kMiddlePlaceholderCycleTime
                                                clockwise: TRUE
                                                     name: kMiddlePlaceholderIdentifier];
}


- (void) spinBottomPlaceholderImageView
{
    self.placeholderBottomLayerAnimation = [self spinView: self.videoPlaceholderBottomImageView
                                                 duration: kBottomPlaceholderCycleTime
                                                clockwise: FALSE
                                                     name: kBottomPlaceholderIdentifier];
}


// Setup the placeholder spinning animation
- (CABasicAnimation *) spinView: (UIView *) placeholderView
                       duration: (float) cycleTime
                      clockwise: (BOOL) clockwise
                           name: (NSString *) name
{
    CABasicAnimation *animation;
    
	[CATransaction begin];
    
	[CATransaction setValue: (id) kCFBooleanTrue
					 forKey: kCATransactionDisableActions];
	
	CGRect frame = [placeholderView frame];
	placeholderView.layer.anchorPoint = CGPointMake(0.5, 0.5);
	placeholderView.layer.position = CGPointMake(frame.origin.x + 0.5 * frame.size.width, frame.origin.y + 0.5 * frame.size.height);
	[CATransaction commit];
	
	[CATransaction begin];
    
	[CATransaction setValue: (id)kCFBooleanFalse
					 forKey: kCATransactionDisableActions];
	
    // Set duration of spin
	[CATransaction setValue: @(cycleTime)
                     forKey: kCATransactionAnimationDuration];
	
	animation = [CABasicAnimation animationWithKeyPath: @"transform.rotation.z"];
    
    // We need to use set an explict key, as the animation is copied and not the same in the callback
    [animation setValue: name
                 forKey: @"name"];
    
    // Alter to/from to change spin direction
    if (clockwise)
    {
        animation.fromValue = @0.0f;
        animation.toValue = @((float)(2 * M_PI));
    }
    else
    {
        animation.fromValue = @((float)(2 * M_PI));
        animation.toValue = @0.0f;
    }
    
	animation.timingFunction = [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionLinear];
	animation.delegate = self;
    
	[placeholderView.layer addAnimation: animation
                                 forKey: @"rotationAnimation"];
	
	[CATransaction commit];
    
    return animation;
}


// Restarts the spin animation on the button when it ends. Again, this is
// largely irrelevant now that the audio is loaded from a local file.

- (void) animationDidStop: (CAAnimation *) animation
                 finished: (BOOL) finished
{
	if (finished)
	{
        if ([[animation valueForKey: @"name"] isEqualToString: kMiddlePlaceholderIdentifier])
        {
            [self spinMiddlePlaceholderImageView];
        }
        else
        {
            [self spinBottomPlaceholderImageView];
        }
	}
}


- (void) applicationWillResignActive: (id) application
{
#ifndef SMART_REANIMATION
    [self animateVideoPlaceholder: FALSE];
#else
    self.bottomPlacholderAnimationViewPosition = [[self.videoPlaceholderBottomImageView.layer animationForKey: @"position"] copy];
    
    // Apple method from QA1673
    [self pauseLayer: self.videoPlaceholderBottomImageView.layer]; // Apple method from QA1673
    
    self.middlePlacholderAnimationViewPosition = [[self.videoPlaceholderMiddleImageView.layer animationForKey: @"position"] copy];
    
    [self pauseLayer: self.videoPlaceholderBottomImageView.layer];
#endif
}


- (void) applicationDidBecomeActive: (id) application
{
#ifndef SMART_REANIMATION
    [self animateVideoPlaceholder: TRUE];
#else
    // Re-animate bottom layer
    if (self.bottomPlacholderAnimationViewPosition != nil)
    {
        // re-add the core animation to the view
        [self.videoPlaceholderBottomImageView.layer addAnimation: self.bottomPlacholderAnimationViewPosition
                                                          forKey: @"position"];
        self.bottomPlacholderAnimationViewPosition = nil;
    }
    
    // Apple method from QA1673
    [self resumeLayer: self.videoPlaceholderBottomImageView.layer];
    
    
    // re-animate middle layer
    if (self.middlePlacholderAnimationViewPosition != nil)
    {
        // re-add the core animation to the view
        [self.videoPlaceholderMiddleImageView.layer addAnimation: self.middlePlacholderAnimationViewPosition
                                                          forKey: @"position"];
        self.middlePlacholderAnimationViewPosition = nil;
    }
    
    // Apple method from QA1673
    [self resumeLayer: self.videoPlaceholderMiddleImageView.layer];
#endif
}


- (void) pauseLayer: (CALayer*) layer
{
    CFTimeInterval pausedTime = [layer convertTime: CACurrentMediaTime()
                                         fromLayer: nil];
    layer.speed = 0.0;
    layer.timeOffset = pausedTime;
}


- (void) resumeLayer: (CALayer*) layer
{
    CFTimeInterval pausedTime = [layer timeOffset];
    layer.speed = 1.0;
    layer.timeOffset = 0.0;
    layer.beginTime = 0.0;
    
    CFTimeInterval timeSincePause = [layer convertTime: CACurrentMediaTime()
                                             fromLayer: nil] - pausedTime;
    layer.beginTime = timeSincePause;
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
                         self.currentVideoView.alpha = 0.0f;
                         self.videoPlaceholderView.alpha = 1.0f;
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
    } afterDelay: 1.0f
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
    float bufferLevel = [self videoLoadedFraction];
    
    // Update the progress bar under our slider
    self.bufferingProgressView.progress = bufferLevel;
    
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
    
    // Update current time label
    self.currentTimeLabel.text = [NSString timecodeStringFromSeconds: currentTime];
    
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
