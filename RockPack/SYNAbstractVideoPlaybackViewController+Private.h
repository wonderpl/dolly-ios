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
@import MediaPlayer;

@interface SYNAbstractVideoPlaybackViewController ()

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
@property (nonatomic, assign) CGRect originalShuttleBarFrame;
@property (nonatomic, assign) CGRect requestedFrame;
@property (nonatomic, assign) NSTimeInterval currentDuration;
@property (nonatomic, assign) NSTimeInterval lastTime;
@property (nonatomic, assign) float percentageViewed;
@property (nonatomic, assign) float timeViewed;
@property (nonatomic, assign) int currentSelectedIndex;
@property (nonatomic, assign) int stallCount;
@property (nonatomic, strong) CAAnimation *bottomPlacholderAnimationViewPosition;
@property (nonatomic, strong) CAAnimation *middlePlacholderAnimationViewPosition;
@property (nonatomic, strong) CABasicAnimation *placeholderBottomLayerAnimation;
@property (nonatomic, strong) CABasicAnimation *placeholderMiddleLayerAnimation;
@property (nonatomic, strong) NSArray *videoInstanceArray;
@property (nonatomic, strong) NSString *channelCreator;
@property (nonatomic, strong) NSString *previousSourceId;
@property (nonatomic, strong) NSTimer *shuttleBarUpdateTimer;
@property (nonatomic, strong) NSTimer *videoStallDetectionTimer;
@property (nonatomic, strong) SYNProgressView *bufferingProgressView;
@property (nonatomic, strong) SYNVideoIndexUpdater indexUpdater;
@property (nonatomic, strong) UIButton *shuttleBarPlayPauseButton;
@property (nonatomic, strong) UIImageView *videoPlaceholderBottomImageView;
@property (nonatomic, strong) UIImageView *videoPlaceholderMiddleImageView;
@property (nonatomic, strong) UIImageView *videoPlaceholderTopImageView;
@property (nonatomic, strong) UILabel *creatorLabel;
@property (nonatomic, strong) UILabel *currentTimeLabel;
@property (nonatomic, strong) UILabel *durationLabel;
@property (nonatomic, strong) UISlider *shuttleSlider;
@property (nonatomic, strong) UIView *videoPlaceholderView;
@property (nonatomic, strong) UIView *currentVideoView;

#pragma mark - Private methods

- (void) updateWithFrame: (CGRect) frame
          channelCreator: (NSString *) channelCreator
            indexUpdater: (SYNVideoIndexUpdater) indexUpdater;

- (void) updateChannelCreator: (NSString *) channelCreator;


- (void) setPlaylist: (NSArray *) playlistArray
       selectedIndex: (int) selectedIndex
            autoPlay: (BOOL) autoPlay;

+ (CGFloat) videoWidth;
+ (CGFloat) videoHeight;
- (NSString *) videoQuality;
- (VideoInstance*) currentVideoInstance;
- (void) incrementVideoIndex;
- (void) decrementVideoIndex;
- (int) nextVideoIndex;
- (int) previousVideoIndex;
- (UIView *) createShuttleBarView;
- (void) resetShuttleBarFrame;
- (UILabel *) createTimeLabelAtXPosition: (CGFloat) xPosition
                           textAlignment: (NSTextAlignment) textAlignment;

- (UIView *) createNewVideoPlaceholderView;
- (void) setCreatorText: (NSString *) creatorText;
- (UIImageView *) createNewVideoPlaceholderImageView: (NSString *) imageName;
- (void) animateVideoPlaceholder: (BOOL) animate;
- (void) spinMiddlePlaceholderImageView;
- (void) spinBottomPlaceholderImageView;

// Setup the placeholder spinning animation
- (CABasicAnimation *) spinView: (UIView *) placeholderView
                       duration: (float) cycleTime
                      clockwise: (BOOL) clockwise
                           name: (NSString *) name;

- (void) animationDidStop: (CAAnimation *) animation
                 finished: (BOOL) finished;

- (void) pauseLayer: (CALayer*) layer;
- (void) resumeLayer: (CALayer*) layer;

- (void) playVideo;
- (void) playIfVideoActive;
- (void) pauseIfVideoActive;
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