/**
 * @class      OOPlayer OOPlayer.h "OOPlayer.h"
 * @brief      OOPlayer
 * @details    OOPlayer.h in OoyalaSDK
 * @date       12/14/11
 * @copyright  Copyright (c) 2012 Ooyala, Inc. All rights reserved.
 */

#import <AVFoundation/AVFoundation.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "OOOoyalaPlayer.h"

@interface OOPlayer : NSObject {
@protected
  OOOoyalaPlayerState state;
  NSString *error;
  UIView *view;
  BOOL seekable;
  BOOL completed;
}

extern NSString *const PlayerErrorNotification;

@property(nonatomic) OOOoyalaPlayerState state; /** the current state of the player */
@property(nonatomic) Float64 playheadTime; /** KVO compatible playhead time */
@property(readonly, nonatomic, strong) NSString *error; /**< The OOPlayer's current error if it exists */
@property(readonly, nonatomic, strong) UIView *view;
@property(nonatomic) BOOL seekable; /**< Whether or not the OOVideo that this OOPlayer plays is seekable */
@property(nonatomic) BOOL completed;
@property(readonly, nonatomic, getter = isExternalPlaybackActive) BOOL externalPlaybackActive;
@property(readonly, nonatomic, getter = isLiveClosedCaptionsAvailable) BOOL liveClosedCaptionsAvailable;
@property(nonatomic) BOOL allowsExternalPlayback;
@property(nonatomic) float rate;
@property(readonly) double bitrate;
/**
 * Init the player
 */
- (id) initWithStreams:(NSArray *)streams;

/**
 * Pause the current video
 */
- (void)pause;

/**
 * Play the current video
 */
- (void)play;

/**
 * Stop playback, remove listeners
 */
- (void)stop;

/**
 * Get the current playhead time
 * @returns the current playhead time as CMTime
 */
- (Float64)currentTime;

/**
 * Get the current item's duration
 * @returns duration as CMTime
 */
- (Float64)duration;

/**
 * Get the current item's buffer
 * @returns buffer as CMTimeRange
 */
- (Float64)buffer;

/**
 * Set the current playhead time of the player
 * @param[in] time CMTime to set the playhead time to
 */
- (void)seekToTime:(Float64)time;

- (BOOL)isPlaying;

- (void)setVideoGravity:(OOOoyalaPlayerVideoGravity)gravity;

- (BOOL)isAudioOnlyStreamPlaying;

- (void) setLiveClosedCaptionsEnabled:(BOOL)enabled;

- (CMTimeRange) seekableTimeRange;

-(CGRect)videoRect;
@end
