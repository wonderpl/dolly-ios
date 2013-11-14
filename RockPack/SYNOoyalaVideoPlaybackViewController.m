    //
//  SYNOoyalaVideoPlaybackViewController.m
//  dolly
//
//  Created by Nick Banks on 08/11/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//


#import "OOOoyalaError.h"
#import "OOOoyalaPlayer.h"
#import "SYNAbstractVideoPlaybackViewController+Private.h"
#import "SYNOoyalaVideoPlaybackViewController.h"

@interface SYNOoyalaVideoPlaybackViewController ()

@property (nonatomic, assign) BOOL firstLaunch;

@end


@implementation SYNOoyalaVideoPlaybackViewController

static OOOoyalaPlayer* ooyalaPlayer;

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
        ooyalaPlayer = [self createNewOoyalaView];

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
                                               object: ooyalaPlayer];
    
    ooyalaView = ooyalaPlayer.view;
    
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
+ (OOOoyalaPlayer *) createNewOoyalaView
{
    OOOoyalaPlayer *newOoyalaPlayer = [[OOOoyalaPlayer alloc] initWithPcode: PCODE
                                                                     domain: PLAYERDOMAIN];
    
    
    return newOoyalaPlayer;
}


#pragma mark - YouTube player support

- (void) playVideoWithSourceId: (NSString *) sourceId
{
    self.notYetPlaying = YES;
    self.pausedByUser = NO;
    self.firstLaunch = YES;
    
    [self startVideoStallDetectionTimer];
    
    [ooyalaPlayer setEmbedCode: sourceId];
    
    self.playFlag = YES;
    
    [self.shuttleBarPlayPauseButton setImage: [UIImage imageNamed: @"ButtonShuttleBarPause.png"]
                                    forState: UIControlStateNormal];
}


- (void) playVideo
{
    if ([self.view superview])
    {
        self.pausedByUser = NO;
        [ooyalaPlayer play];
        self.playFlag = YES;
    }
    else
    {
        [ooyalaPlayer pause];
        self.playFlag = NO;
    }
}


- (void) pauseVideo
{
    [self stopShuttleBarUpdateTimer];
    
    [ooyalaPlayer pause];
    
    self.playFlag = NO;
}


- (void) stopVideo
{
    [self stopShuttleBarUpdateTimer];
    
    [ooyalaPlayer pause];
    
    self.playFlag = NO;
}


#pragma mark - Properties

// Get the duration of the current video
- (NSTimeInterval) duration
{
    Float64 duration = [ooyalaPlayer duration];
    DebugLog(@"duration %lf", duration);
    return duration;
}


// Get the playhead time of the current video
- (NSTimeInterval) currentTime
{
    return [ooyalaPlayer playheadTime];
}

// Get the playhead time of the current video
- (void) setCurrentTime: (NSTimeInterval) newTime
{
    [ooyalaPlayer setPlayheadTime: newTime];
}


// Get a number between 0 and 1 that indicated how much of the video has been buffered
// Can use this to display a video loading progress indicator
- (float) videoLoadedFraction
{
    return ooyalaPlayer.bufferedTime / self.currentDuration;
}


// Index of currently playing video (if using a playlist)
- (BOOL) isPlaying
{
    return [ooyalaPlayer isPlaying];
}


- (BOOL) isPlayingOrBuffering
{
    OOOoyalaPlayerState state = [ooyalaPlayer state];
    return ((state == OOOoyalaPlayerStateLoading) || (state == OOOoyalaPlayerStatePlaying)) ? TRUE : FALSE;
}


- (BOOL) isPaused
{
    OOOoyalaPlayerState state = [ooyalaPlayer state];
    return (state == OOOoyalaPlayerStatePaused);
}


#pragma mark - Player state

- (void) notificationPlayerReceived: (NSNotification *) notification
{
    DebugLog(@"Notification = %@", notification.name);
    
    // notification handle
    if ([notification.name isEqualToString: @"stateChanged"] && self.firstLaunch)
    {
        DebugLog(@"State = %@", [OOOoyalaPlayer playerStateToString: ooyalaPlayer.state]);
        switch (ooyalaPlayer.state)
        {
            // Initial state, player is created but no content is loaded
            case OOOoyalaPlayerStateInit:
                break;
                
            // Loading content
            case OOOoyalaPlayerStateLoading:
                break;
                
            // Content is loaded and initialized, player is ready to begin playback
            case OOOoyalaPlayerStateReady:
                break;
                
            // Player is playing a video
            case OOOoyalaPlayerStatePlaying:
            {
                [self stopVideoStallDetectionTimer];
                
                DebugLog(@"*** Playing: Starting - Fading up player");
                // If we are playing then out shuttle / pause / play cycle is over
                self.shuttledByUser = YES;
                self.notYetPlaying = NO;
                
                // Now cache the duration of this video for use in the progress updates
                self.currentDuration = self.duration;
                
                if (self.currentDuration > 0.0f)
                {
                    self.fadeUpScheduled = NO;
                    // Only start if we have a valid duration
                    [self startShuttleBarUpdateTimer];
                    self.durationLabel.text = [NSString timecodeStringFromSeconds: self.currentDuration];
                }
        
                break;
            }

            // Player is paused, video is showing
            case OOOoyalaPlayerStatePaused:
                if (self.shuttledByUser && self.playFlag)
                {
                    DebugLog (@"*** Paused: Paused by shuttle and should be playing? - Attempting to play");
                    [self playVideo];
                }
                else
                {
                    [self stopVideoStallDetectionTimer];
                    DebugLog (@"*** Paused: Paused by user");
                }
                break;
                
            // Player has finished playing content
            case OOOoyalaPlayerStateCompleted:
                self.percentageViewed = 1.0f;
                self.timeViewed = self.currentDuration;
                [self stopShuttleBarUpdateTimer];
                [self stopVideoStallDetectionTimer];
                [self stopVideo];
                [self resetPlayerAttributes];
                [self loadNextVideo];
                break;
                
            // Player has encountered an error, check OOOoyalaPlayer.error
            case OOOoyalaPlayerStateError:
            {
                [self fadeUpVideoPlayer];
                
                SYNAppDelegate* appDelegate = UIApplication.sharedApplication.delegate;
                VideoInstance *videoInstance = self.videoInstanceArray [self.currentSelectedIndex];
                NSString *errorString = ooyalaPlayer.error.description;
                [appDelegate.oAuthNetworkEngine reportPlayerErrorForVideoInstanceId: videoInstance.uniqueId
                                                                   errorDescription: errorString
                                                                  completionHandler: ^(NSDictionary * dictionary) {
                                                                      DebugLog(@"Reported video error");
                                                                  }
                                                                       errorHandler: ^(NSError* error) {
                                                                           DebugLog(@"Report concern failed");
                                                                           DebugLog(@"%@", [error debugDescription]);
                                                                       }];
                break;
            }

            default:
                AssertOrLog(@"Unexpected state");
                break;
        }
        if ([[OOOoyalaPlayer playerStateToString: [ooyalaPlayer state]] isEqualToString: @"ready"])
        {
            [self playVideo];
            
            self.firstLaunch = NO;
        }
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
