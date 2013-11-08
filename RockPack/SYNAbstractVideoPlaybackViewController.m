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



@end
