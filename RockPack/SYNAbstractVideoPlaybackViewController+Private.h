//
//  SYNAbstractVideoPlaybackViewController+Private.h
//  dolly
//
//  Created by Nick Banks on 08/11/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "NSObject+Blocks.h"
#import "NSString+Timecode.h"
#import "SYNAbstractVideoPlaybackViewController.h"
#import "SYNMasterViewController.h"
#import "SYNProgressView.h"
#import "UIFont+SYNFont.h"
#import "Video.h"
#import "VideoInstance.h"
#import "SYNScrubberBar.h"
@import MediaPlayer;

@class SYNVideoLoadingIndicator;

@interface SYNAbstractVideoPlaybackViewController () <SYNScrubberBarDelegate>

#pragma mark - Private properties

@property (nonatomic, assign) BOOL autoPlay;
@property (nonatomic, assign) BOOL currentVideoViewedFlag;
@property (nonatomic, assign) BOOL disableTimeUpdating;
@property (nonatomic, assign) BOOL fadeOutScheduled;
@property (nonatomic, assign) BOOL fadeUpScheduled;
@property (nonatomic, assign) BOOL notYetPlaying;
@property (nonatomic, assign) BOOL pausedByUser;
@property (nonatomic, assign) BOOL playFlag;
@property (nonatomic, assign) BOOL shuttledByUser;
@property (nonatomic, assign) CGRect requestedFrame;
@property (nonatomic, assign) NSTimeInterval currentDuration;
@property (nonatomic, assign) NSTimeInterval lastTime;
@property (nonatomic, assign) float percentageViewed;
@property (nonatomic, assign) float timeViewed;
@property (nonatomic, assign) int currentSelectedIndex;
@property (nonatomic, assign) int stallCount;
@property (nonatomic, strong) NSArray *videoInstanceArray;
@property (nonatomic, strong) NSString *channelCreator;
@property (nonatomic, strong) NSString *previousSourceId;
@property (nonatomic, strong) NSTimer *shuttleBarUpdateTimer;
@property (nonatomic, strong) NSTimer *videoStallDetectionTimer;
@property (nonatomic, strong) SYNVideoIndexUpdater indexUpdater;
@property (nonatomic, strong) UILabel *creatorLabel;
@property (nonatomic, strong) SYNVideoLoadingIndicator *videoLoadingIndicator;
@property (nonatomic, strong) SYNScrubberBar *scrubberBar;
@property (nonatomic, strong) UIView *currentVideoView;

#pragma mark - Private methods

+ (CGFloat) videoWidth;
+ (CGFloat) videoHeight;
- (NSString *) videoQuality;
- (VideoInstance*) currentVideoInstance;
- (void) incrementVideoIndex;
- (void) decrementVideoIndex;
- (int) nextVideoIndex;
- (int) previousVideoIndex;

- (void) setCreatorText: (NSString *) creatorText;

- (void) playVideo;
- (void) pauseVideo;
- (void) stopVideo;
- (void) loadNextVideo;
- (void) loadCurrentVideoView;
- (void) resetPlayerAttributes;

#pragma mark - Properties

// Get the duration of the current video
- (NSTimeInterval) duration;
- (NSTimeInterval) currentTime;
- (void) setCurrentTime: (NSTimeInterval) newTime;
- (float) videoLoadedFraction;
- (BOOL) isPlaying;
- (BOOL) isPlayingOrBuffering;
- (BOOL) isPaused;

- (void) startShuttleBarUpdateTimer;
- (void) stopShuttleBarUpdateTimer;
- (void) startVideoStallDetectionTimer;
- (void) stopVideoStallDetectionTimer;

- (void) fadeUpVideoPlayer;
- (void) fadeOutVideoPlayer;

@end