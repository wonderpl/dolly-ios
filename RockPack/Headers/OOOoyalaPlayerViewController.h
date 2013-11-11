/**
 * @class      OOOoyalaPlayerViewController OOOoyalaPlayerViewController.h "OOOoyalaPlayerViewController.h"
 * @brief      OOOoyalaPlayerViewController
 * @details    OOOoyalaPlayerViewController.h in OoyalaSDK
 * @date       1/9/12
 * @copyright  Copyright (c) 2012 Ooyala, Inc. All rights reserved.
 */

#import <UIKit/UIKit.h>
#import "OOOoyalaPlayer.h"
#import "OOEmbedTokenGenerator.h"

extern NSString *const OOOoyalaPlayerViewControllerFullscreenEnter;
extern NSString *const OOOoyalaPlayerViewControllerFullscreenExit;

@class OOOoyalaAPIClient;

/**
 * Main ViewController class for Ooyala player.
 * Implements a default skin as well as convenience methods for accesssing and initializing underlying OOOoyalaPlayer.
 */
@interface OOOoyalaPlayerViewController : UIViewController

enum
{
  /** an inline player, expandable to fullscreen */
  OOOoyalaPlayerControlTypeInline,
  /** a fullscreen player, not shrinkable to inline */
  OOOoyalaPlayerControlTypeFullScreen
};
typedef NSInteger OOOoyalaPlayerControlType;

@property (nonatomic, readonly) OOOoyalaPlayerControlType controlType; // initial state
@property (nonatomic, strong) OOOoyalaPlayer *player;

@property (nonatomic, strong) UIView *inlineOverlay;
@property (nonatomic, strong) UIView *fullscreenOverlay;

/**
 * Get the fullscreen state
 * @returns true if in fullscreen mode, false if not
 */
- (BOOL)isFullscreen;

/**
 * Set the fullscreen state
 * @param[in] fullscreen whether the view should be fullscreened
 */
- (void)setFullscreen:(BOOL)fullscreen;

/**
 * Initialize the UI and player with pcode and domain
 * @param[in] pcode Ooyala publisher code
 * @param[in] domain Web domain to which playback will be assigned
 */
- (id)initWithPcode:(NSString *)pcode
             domain:(NSString *)domain;
/**
 * Initialize the UI and player with pcode, domain and control type
 * @param[in] pcode Ooyala publisher code
 * @param[in] domain Web domain to which playback will be assigned
 * @param[in] controlType Selects inline or fullscreen only UI mode
 */
- (id)initWithPcode:(NSString *)pcode
             domain:(NSString *)domain
        controlType:(OOOoyalaPlayerControlType)controlType;

/**
 * Initialize the UI and player with pcode, domain and embed token generator
 * @param[in] pcode Ooyala publisher code
 * @param[in] domain Web domain to which playback will be assigned
 * @param[in] embedTokenGenerator Callback protocol for generating Ooyala Player Tokens
 */
- (id)initWithPcode:(NSString *)pcode
             domain:(NSString *)domain
embedTokenGenerator:(id<OOEmbedTokenGenerator>)embedTokenGenerator;

/**
 * Initialize the UI and player with pcode, domain, embed token generator and control type
 * @param[in] pcode Ooyala publisher code
 * @param[in] domain Web domain to which playback will be assigned
 * @param[in] embedTokenGenerator Callback protocol for generating Ooyala Player Tokens
 * @param[in] controlType Selects inline or fullscreen only UI mode
 */
- (id)initWithPcode:(NSString *)pcode
             domain:(NSString *)domain
embedTokenGenerator:(id<OOEmbedTokenGenerator>)embedTokenGenerator
        controlType:(OOOoyalaPlayerControlType)controlType;

/**
 * Initialize the UI and player with an existing OOOoyalaAPIClient object
 * @param[in] client Reference to existing API client object
 */
- (id)initWithOoyalaAPIClient:(OOOoyalaAPIClient *)client;

/**
 * Initialize the UI and player with an existing OOOoyalaAPIClient object and control type
 * @param[in] client Reference to existing API client object
 * @param[in] controlType Selects inline or fullscreen only UI mode
 */
- (id)initWithOoyalaAPIClient:(OOOoyalaAPIClient *)client
                  controlType:(OOOoyalaPlayerControlType)controlType;

/**
 * Initialize the UI with an existing OOOoyalaPlayer object
 * @param[in] player Reference to OOOoyalaPlayer object
 */
- (id)initWithPlayer:(OOOoyalaPlayer *)player;

/**
 * Initialize the UI with an existing OOOoyalaPlayer object and control type
 * @param[in] player Reference to OOOoyalaPlayer object
 * @param[in] controlType Selects inline or fullscreen only UI mode
 */
- (id)initWithPlayer:(OOOoyalaPlayer *)player
         controlType:(OOOoyalaPlayerControlType)controlType;

/**
 * Loads a dictionary of localized strings for specified locale
 * @param[in] localeId Locale ID such as @"en_US"
 */
+ (NSDictionary*)loadLocalizedStrings:(NSString *)localeId;

/**
 * Instructs the player to use supplied localized strings, regardless of system language
 * @param[in] strings Dictionary of localized strings to use
 */
+ (void)useLocalizedStrings:(NSDictionary *)strings;

/**
 * Returns a dictionary of currently used localized strings
 */
+ (NSDictionary*)currentLocalizedStrings;

/**
 * Shows controls on the current player
 */
- (void)showControls;

/**
 * Hides controls on the current player
 */
- (void)hideControls;

/**
 * Sets visibility of full-screen button on inline player
 * @param[in] showing True to show fullscreen button, false otherwise
 */
- (void)setFullScreenButtonShowing: (BOOL) showing;
@end
