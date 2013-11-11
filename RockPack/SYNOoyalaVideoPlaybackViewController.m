//
//  SYNOoyalaVideoPlaybackViewController.m
//  dolly
//
//  Created by Nick Banks on 08/11/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNOoyalaVideoPlaybackViewController.h"
#import "OOOoyalaPlayerViewController.h" 
#import "OOOoyalaPlayer.h"

@interface SYNOoyalaVideoPlaybackViewController ()

@property (nonatomic, assign) BOOL firstLaunch;

@end


@implementation SYNOoyalaVideoPlaybackViewController

static OOOoyalaPlayerViewController* ooyalaPlayerViewController;

//NSString * const PCODE = @"YzYW8xOshpVwePawyVliU0L_tBj_";
//NSString * const PLAYERDOMAIN = @"<domain>";

NSString * const EMBED_CODE = @"xxbjk1YjpHm4-VkWfWfEKBbyEkh358su";
NSString * const PCODE = @"Z5Mm06XeZlcDlfU_1R9v_L2KwYG6";
NSString * const PLAYERDOMAIN = @"www.ooyala.com";

+ (instancetype) sharedInstance
{
    static SYNOoyalaVideoPlaybackViewController *_sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        // Create our shared intance
        _sharedInstance = [[self alloc] init];
        
        // Create the static instances of our ooyala player
        ooyalaPlayerViewController = [self createNewOoyalaView];

    });
    
    return _sharedInstance;
}


#pragma mark - Object lifecycle

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}


#pragma mark - View lifecyle

- (void) specificInit
{
    UIView *ooyalaView;
    
    // register for all playback notifications
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(notificationPlayerReceived:)
                                                 name: nil
                                               object: ooyalaPlayerViewController.player];
    
    ooyalaView = ooyalaPlayerViewController.view;
    
#ifdef USE_HIRES_PLAYER
    // If we are on the iPad then we need to super-size the webview so that we can scale down again
    if (IS_IPAD)
    {
        ooyalaView.transform = CGAffineTransformMakeScale(739.0f/1280.0f, 739.0f/1280.0f);
    }
#endif
    ooyalaView.frame = self.view.bounds;
    ooyalaView.backgroundColor = self.view.backgroundColor;
    
    self.currentVideoView = ooyalaView;
}


// Create YouTube specific webview, based on common setup
+ (OOOoyalaPlayerViewController *) createNewOoyalaView
{
    OOOoyalaPlayerViewController *newOoyalaPlayerViewController = [[OOOoyalaPlayerViewController alloc] initWithPcode: PCODE
                                                                                 domain: PLAYERDOMAIN];
    return newOoyalaPlayerViewController;
}


#pragma mark - YouTube player support

- (void) playVideoWithSourceId: (NSString *) sourceId
{
    self.notYetPlaying = TRUE;
    self.pausedByUser = NO;
    self.firstLaunch = YES;
    
    [self startVideoStallDetectionTimer];
    
    [ooyalaPlayerViewController.player setEmbedCode: sourceId];
//    [ooyalaPlayerViewController.player setEmbedCode: @"xxbjk1YjpHm4-VkWfWfEKBbyEkh358su"];
    
    self.playFlag = TRUE;
    
    [self.shuttleBarPlayPauseButton setImage: [UIImage imageNamed: @"ButtonShuttleBarPause.png"]
                                    forState: UIControlStateNormal];
}


- (void) playVideo
{
    if ([self.view superview])
    {
        self.pausedByUser = NO;
        [ooyalaPlayerViewController.player play];
        self.playFlag = TRUE;
    }
    else
    {
        [ooyalaPlayerViewController.player pause];
        self.playFlag = FALSE;;
    }
}


- (void) pauseVideo
{
    [self stopShuttleBarUpdateTimer];
    
    [ooyalaPlayerViewController.player pause];
    
    self.playFlag = FALSE;
}


- (void) stopVideo
{
    [self stopShuttleBarUpdateTimer];
    
    [ooyalaPlayerViewController.player pause];
    
    self.playFlag = FALSE;
}


#pragma mark - Properties

// Get the duration of the current video
- (NSTimeInterval) duration
{
    return [ooyalaPlayerViewController.player duration];
}


// Get the playhead time of the current video
- (NSTimeInterval) currentTime
{
    return [ooyalaPlayerViewController.player playheadTime];
}

// Get the playhead time of the current video
- (void) setCurrentTime: (NSTimeInterval) newTime
{
    [ooyalaPlayerViewController.player setPlayheadTime: newTime];
}


// Get a number between 0 and 1 that indicated how much of the video has been buffered
// Can use this to display a video loading progress indicator
- (float) videoLoadedFraction
{
    return [ooyalaPlayerViewController.player bufferedTime];
}


// Index of currently playing video (if using a playlist)
- (BOOL) isPlaying
{
    return [ooyalaPlayerViewController.player isPlaying];
}


- (BOOL) isPlayingOrBuffering
{
    OOOoyalaPlayerState state = [ooyalaPlayerViewController.player state];
    
    return ((state == OOOoyalaPlayerStateLoading) || (state == OOOoyalaPlayerStatePlaying)) ? TRUE : FALSE;
}


- (BOOL) isPaused
{
    OOOoyalaPlayerState state = [ooyalaPlayerViewController.player state];
    
    return (state == OOOoyalaPlayerStatePaused);
}


#pragma mark - Player state

- (void) notificationPlayerReceived: (NSNotification *) notification
{
    DebugLog(@"State = %@", notification.name);
    
    // notification handle
    if ([notification.name isEqualToString: @"stateChanged"] && self.firstLaunch)
    {
        if ([[OOOoyalaPlayer playerStateToString: [ooyalaPlayerViewController.player state]] isEqualToString: @"ready"])
        {
            [self playVideo];
            
            self.firstLaunch = NO;
        }
    }
    else if ([notification.name isEqualToString: @"playStarted"])
    {
        [self stopVideoStallDetectionTimer];
        
        DebugLog(@"*** Playing: Starting - Fading up player");
        // If we are playing then out shuttle / pause / play cycle is over
        self.shuttledByUser = TRUE;
        self.notYetPlaying = FALSE;
        
        // Now cache the duration of this video for use in the progress updates
        self.currentDuration = self.duration;
        
//        if (self.currentDuration > 0.0f)
//        if (1)
//        {
//            self.fadeUpScheduled = FALSE;
//            // Only start if we have a valid duration
//            [self startShuttleBarUpdateTimer];
//            self.durationLabel.text = [NSString timecodeStringFromSeconds: self.currentDuration];
//        }
        [self fadeUpVideoPlayer];
    }
    else if ([notification.name isEqualToString: @"timeChanged"])
    {
        //        if (activeController.player.duration - activeController.player.playheadTime <= 7.0f && !bufferedControllerSetted)
        //        {
        //            [self selectNextVideo];
        //            [bufferedController.player
        //             setEmbedCode: [[relatedVideo objectAtIndex: relatedVideoIndex] objectForKey: @"embed_code"]];
        //            bufferedControllerSetted = YES;
        //        }
    }
    else if ([notification.name isEqualToString: @"playCompleted"])
    {
        // Finished
    }
}



@end
