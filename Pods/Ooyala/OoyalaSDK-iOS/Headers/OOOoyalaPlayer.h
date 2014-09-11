/**
 * @file       OOOoyalaPlayer.h
 * @class      OOOoyalaPlayer OOOoyalaPlayer.h "OOOoyalaPlayer.h"
 * @brief      OOOoyalaPlayer
 * @details    OOOoyalaPlayer.h in OoyalaSDK
 * @date       11/21/11
 * @copyright  Copyright (c) 2012 Ooyala, Inc. All rights reserved.
 */

#import <AVFoundation/AVFoundation.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "OOSignatureGenerator.h"
#import "OOSecureURLGenerator.h"
#import "OOCallbacks.h"
#import "OOEmbedTokenGenerator.h"
#import "OOClosedCaptionsStyle.h"

@class OOContentItem;
@class OOVideo;
@class OOOoyalaError;
@class OOOoyalaAPIClient;
@class OOClosedCaptionsStyle;
@class OOStreamPlayer;
@class OOAdSpot;
@class OOPlayerDomain;

/**
 * Defines player behavior after video playback has ended, defaults to OOOoyalaPlayerActionAtEndContinue
 */
typedef enum
{
    /** Start playing next video if available, otherwise pause */
    OOOoyalaPlayerActionAtEndContinue,
    /** Pause at the end of the video */
    OOOoyalaPlayerActionAtEndPause,
    /** Stops at the end of the video and unloads the video from memory */
    OOOoyalaPlayerActionAtEndStop,
    /** Pause and reset to the beginning of the current video */
    OOOoyalaPlayerActionAtEndReset
} OOOoyalaPlayerActionAtEnd;

/**
 * Defines different possible player states
 */
typedef enum
{
    /** Initial state, player is created but no content is loaded */
    OOOoyalaPlayerStateInit,
    /** Loading content */
    OOOoyalaPlayerStateLoading,
    /** Content is loaded and initialized, player is ready to begin playback */
    OOOoyalaPlayerStateReady,
    /** Player is playing a video */
    OOOoyalaPlayerStatePlaying,
    /** Player is paused, video is showing */
    OOOoyalaPlayerStatePaused,
    /** Player has finished playing content */
    OOOoyalaPlayerStateCompleted,
    /** Player has encountered an error, check OOOoyalaPlayer.error */
    OOOoyalaPlayerStateError
} OOOoyalaPlayerState;

/**
 * Defines different gravity modes, which control how video is adjusted to available screen size
 */
typedef enum
{
  /** Specifies that the video should be stretched to fill the layer’s bounds. */
  OOOoyalaPlayerVideoGravityResize,
  /** Specifies that the player should preserve the video’s aspect ratio and fit the video within the layer’s bounds */
  OOOoyalaPlayerVideoGravityResizeAspect,
  /** Specifies that the player should preserve the video’s aspect ratio and fill the layer’s bounds. */
  OOOoyalaPlayerVideoGravityResizeAspectFill
} OOOoyalaPlayerVideoGravity;

/**
 * Defines which Ooyala API environment is used for API calls.
 * Defaults to OOOoyalaPlayerEnvironmentProduction and should never change for customer apps.
 */
typedef enum
{
  /** Ooyala production environment */
  OOOoyalaPlayerEnvironmentProduction,
  /** Ooyala staging environment */
  OOOoyalaPlayerEnvironmentStaging,
  /** Ooyala local environment */
  OOOoyalaPlayerEnvironmentLocal
} OOOoyalaPlayerEnvironment;

/** @internal
 * Defines different seek modes, which control the way seeking of the video is performed
 */
typedef enum {
  /** @internal No seeking is allowed */
  OOSeekStyleNone,
  /** @internal Seeking is expensive and can only be performed at the end of user action */
  OOSeekStyleBasic,
  /** @internal Continous seeking is allowed */
  OOSeekStyleEnhanced
} OOSeekStyle;

// notifications
extern NSString *const OOOoyalaPlayerTimeChangedNotification; /**< Fires when the Playhead Time Changes */
extern NSString *const OOOoyalaPlayerStateChangedNotification; /**< Fires when the Player's State Changes */
extern NSString *const OOOoyalaPlayerContentTreeReadyNotification; /**< Fires when the content tree's metadata is ready and can be accessed */
extern NSString *const OOOoyalaPlayerAuthorizationReadyNotification; /**< Fires when the authorization status is ready and can be accessed */
extern NSString *const OOOoyalaPlayerPlayStartedNotification; /**< Fires when play starts */
extern NSString *const OOOoyalaplayerLicenseAcquisitionNotification; /**< Fires after a successful license acquisition */
extern NSString *const OOOoyalaPlayerPlayCompletedNotification; /**< Fires when play completes */
extern NSString *const OOOoyalaPlayerCurrentItemChangedNotification; /**< Fires when the current item changes */
extern NSString *const OOOoyalaPlayerAdStartedNotification; /**< Fires when an ad starts playing */
extern NSString *const OOOoyalaPlayerAdCompletedNotification; /**< Fires when an ad completes playing */
extern NSString *const OOOoyalaPlayerAdSkippedNotification; /**< Fires when an ad is skipped */
extern NSString *const OOOoyalaPlayerErrorNotification; /**< Fires when an error occurs */
extern NSString *const OOOoyalaPlayerAdErrorNotification; /**< Fires when an error occurs while trying to play an ad */
extern NSString *const OOOoyalaPlayerMetadataReadyNotification; /**< Fires when content metadata is ready to be accessed */
extern NSString *const OOOoyalaPlayerLanguageChangedNotification; /**< Fires when close caption language changed*/
extern NSString *const OOOoyalaPlayerSeekCompletedNotification; /**< Fires when a seek completes*/

@interface OOOoyalaPlayer : NSObject

@property(readonly, nonatomic, strong) OOVideo *currentItem; /**< The OOOoyalaPlayer's currently playing OOVideo */
@property(readonly, nonatomic, strong) OOContentItem *rootItem; /**< The OOOoyalaPlayer's embedded content (OOVideo, OOChannel, or OOChannelSet) */
@property(readonly, nonatomic, strong) NSDictionary *metadata; /**< The OOOoyalaPlayer's content metadata for currently loaded content */
@property(readonly, nonatomic, strong) OOOoyalaError *error; /**< The OOOoyalaPlayer's current error if it exists */
@property(readonly, nonatomic, strong) UIView *view;
@property(nonatomic) OOOoyalaPlayerVideoGravity videoGravity;
@property(nonatomic) BOOL seekable; /**< Whether or not the Videos that OOOoyalaPlayer plays are seekable */
@property(nonatomic) BOOL adsSeekable; /**< Whether or not the Ads that OOOoyalaPlayer plays are seekable */
@property(readonly, nonatomic) OOSeekStyle seekStyle;

/**
 * Get whether the player is playing the audio only stream in an m3u8
 */
@property(readonly, nonatomic) BOOL isAudioOnlyStreamPlaying;
@property(readonly, nonatomic, getter = isClosedCaptionsTrackAvailable) BOOL closedCaptionsTrackAvailable;
@property(nonatomic, strong) OOClosedCaptionsStyle *closedCaptionsStyle; /**< The OOClosedCaptionsStyle to use when displaying closed captions */
@property(nonatomic, strong) OOCurrentItemChangedCallback currentItemChangedCallback; /**< A callback that will be called every time the current item is changed */
@property(nonatomic, strong) NSString *closedCaptionsLanguage; /**< the current closed captions language, or nil to hide closed captions. */
@property(nonatomic, strong) OOStreamPlayer *basePlayer; /**< the base player to use for displaying content.  Defaults to OOBaseStreamPlayer. */

@property (nonatomic) OOOoyalaPlayerActionAtEnd actionAtEnd; /**< the OOOoyalaPlayerActionAtEnd to perform when the current item finishes playing. */
@property (readonly, nonatomic, getter = isExternalPlaybackActive) BOOL externalPlaybackActive;

@property (nonatomic) BOOL allowsExternalPlayback;
@property (nonatomic) float playbackRate; /** the rate of playback. 1 is the normal speed.  Set to .5 for half speed, 2 for double speed, etc. */
@property (readonly, nonatomic) NSString *authToken;

/**
 * @internal
 */
+ (void)setEnvironment:(OOOoyalaPlayerEnvironment)e;

/**
 * Get the version and RC of the Ooyala SDK
 * @returns the string that represents the SDK version
 */
+ (NSString *)version;

/**
 * Initialize an OOOoyalaPlayer with the given parameters
 * @param[in] apiClient the initialized OOOoyalaAPIClient to use
 * @returns the initialized OOOoyalaPlayer
 */
- (id)initWithOoyalaAPIClient:(OOOoyalaAPIClient *)apiClient;

/**
 * Initialize an OOOoyalaPlayer with the given parameters
 * @param[in] pcode Your Provider Code
 * @param[in] domain Your Embed Domain
 * @returns the initialized OOOoyalaPlayer
 */
- (id)initWithPcode:(NSString *)pcode
             domain:(OOPlayerDomain *)domain;

/**
 * Initialize an OOOoyalaPlayer with the given parameters
 * @param[in] pcode Your Provider Code
 * @param[in] domain Your Embed Domain
 * @param[in] embedTokenGenerator the initialized OOEmbedTokenGenerator to use
 * @returns the initialized OOOoyalaPlayer
 */
- (id)initWithPcode:(NSString *)pcode
             domain:(OOPlayerDomain *)domain
embedTokenGenerator:(id<OOEmbedTokenGenerator>)embedTokenGenerator;

/**
 * Reinitializes the player with a new embedCode.
 * @param[in] embedCode the embed code to use
 * @returns YES if successful; otherwise, returns NO (check OOOoyalaPlayer.error for reason)
 */
- (BOOL)setEmbedCode:(NSString *)embedCode;

/**
 * Reinitializes the player with the new embedCodes (as an array).
 * @param[in] embedCodes the embed code(s) to use. If more than one is specified, OOOoyalaPlayer.rootItem becomes a OODynamicChannel.
 * @returns YES if successful; otherwise, returns NO (check OOOoyalaPlayer.error for reason)
 */
- (BOOL)setEmbedCodes:(NSArray *)embedCodes;

/**
 * Reinitializes the player with a new embedCode and sets the ad set dynamically.
 * @param[in] embedCode the embed code to use
 * @param[in] adSetCode the ad set code to use
 * @returns YES if successful; otherwise, returns NO (check OOOoyalaPlayer.error for reason)
 */
- (BOOL)setEmbedCode:(NSString *)embedCode adSetCode:(NSString *)adSetCode;

/**
 * Reinitializes the player with the new embedCodes (as an array) and sets the ad set dynamically.
 * @param[in] embedCodes the embed code(s) to use. If more than one is specified, OOOoyalaPlayer.rootItem becomes a OODynamicChannel.
 * @param[in] adSetCode the ad set code to use.
 * @returns YES if successful; otherwise, returns NO (check OOOoyalaPlayer.error for reason)
 */
- (BOOL)setEmbedCodes:(NSArray *)embedCodes adSetCode:(NSString *)adSetCode;

/**
 * Reinitializes the player with a new external ID. External IDs enable you to assign custom identifiers to your assets so they are easier to organize, update, and modify. 
 * @param[in] externalId the external ID to use
 * @returns YES if successful; otherwise, returns NO (check OOOoyalaPlayer.error for reason)
 */
- (BOOL)setExternalId:(NSString *)externalId;

/**
 * Reinitializes the player with the new external IDs (as an array). External IDs enable you to assign custom identifiers to your assets so they are easier to organize, update, and modify. 
 * @param[in] externalIds the external ID(s) to use. If more than one is specified, OOOoyalaPlayer.rootItem becomes a OODynamicChannel.
 * @returns YES if successful; otherwise, returns NO (check OOOoyalaPlayer.error for reason)
 */
- (BOOL)setExternalIds:(NSArray *)externalIds;

/**
 * Reinitializes the player with a root item.
 * @param[in] theRootItem the root item to use
 */
- (void)setRootItem:(OOContentItem *)theRootItem;

/**
 * Sets the current video in a channel, if the video is present.
 * @param[in] embedCode the embed code of the video to play 
 * @returns YES if successful; otherwise, returns NO (check OOOoyalaPlayer.error for reason)
 */
- (BOOL)changeCurrentItemToEmbedCode:(NSString *)embedCode;

/**
 * Sets the current video.  OOVideo must be a part of the content tree provided by the root item.
 * @returns a BOOL indicating that the item was successfully changed
 */
- (BOOL)changeCurrentItemToVideo:(OOVideo *)video;

/**
 * Gets the current playhead time (the part of the video currently being accessed).
 * @returns the current playhead time, in milliseconds
 */
- (Float64)playheadTime;

/**
 * Gets the  (approximate) real time of a live stream
 * @returns currently playing time
 */
- (NSDate *)liveTime;

/**
 * Gets the duration of the asset.
 * @returns the duration of the currently playing asset, in seconds
 */
- (Float64)duration;

/**
 * Get the maximum buffered time
 * @returns the buffered time in seconds of the currently playing item
 */
- (Float64)bufferedTime;

/**
 * Sets the current playhead time of the player (same as seek). For example, to start a video at the 30 second point, you would set the playhead to 30.
 * @param[in] time the playhead time, in seconds
 */
- (void)setPlayheadTime:(Float64) time;

/**
 * Gets the player's current state.
 * @returns a string containing the current state
 */
- (OOOoyalaPlayerState)state;

/**
 * Pauses the current video.
 */
- (void)pause;

/**
 * Plays the current video.
 */
- (void)play;

 /**
  * Plays the current video with an initial time
  */
- (void)playWithInitialTime:(Float64) time;

/**
 * Sets the current playhead time of the player (same as setPlayheadTime).
 * @param[in] time the playhead time, in seconds
 */
- (void)seek:(Float64) time;

/**
 * Get whether the player is playing
 * @returns a BOOL indicating the current player is playing
 */
- (BOOL)isPlaying;

/**
 * Get whether the player is playing ad
 * @returns a BOOL indicating the current player is playing ad
 */
- (BOOL)isShowingAd;

/**
 * Tries to set the current video to the next video in the OOChannel or ChannetSet
 * @returns a BOOL indicating that the item was successfully changed
 */
- (BOOL)nextVideo;

/**
 * Tries to set the current video to the previous video in the OOChannel or ChannetSet
 * @returns a BOOL indicating that the item was successfully changed
 */
- (BOOL)previousVideo;

/**
 * Get the available closed captions languages
 * @returns an NSArray containing the available closed captions languages as NSStrings
 */
- (NSArray *)availableClosedCaptionsLanguages;

/**
 * Set the closed caption with given language
 */
- (void)setClosedCaptionsLanguage:(NSString *)language;


- (void)setClosedCaptionsPresentationStyle: (OOClosedCaptionPresentation) presentationStyle;

/**
 * Get the current bitrate
 * @returns a double indicating the current bitrate in bytes
 */
- (double)bitrate;

/**
 * Reset the state of ad plays. Calling this will cause all ads which have been played to play again.
 */
- (void)resetAds;

/**
 * Skips the currently playing ad (if one is playing. does nothing if not)
 */
- (void)skipAd;

/**
 * current seekable range for main video.
 */
- (CMTimeRange) seekableTimeRange;

/**
 * Sets a tag for custom analytics
 * @param[in] tags n array of NSStrings
 */
- (void)setCustomAnalyticsTags:(NSArray *)tags;

/**
 * Converts PlayerState to a String.
 * @param[in] state the PlayerState
 * @returns an external facing state string
 */
+ (NSString *)playerStateToString:(OOOoyalaPlayerState)state;

- (BOOL)playAd:(OOAdSpot *)ad;

- (void)registerAdPlayer:(Class)adPlayerClass forType:(Class)adClass;

- (void)updateClosedCaptionsViewPosition:(CGRect)bottomControlsRect withControlsHide:(BOOL)hidden;

- (CGRect)videoRect;

/**
 * set encryptedloopback.
 * @param[in] true if enabled, false if disabled
 */
+ (void)setEncryptedLoopback:(BOOL)enabled;

/**
 * get encryptedloopback.
 * @returns encryptedLoopback;
 */
+ (BOOL)encryptedLoopback;
@end
