//
//  SYNAbstractVideoPlaybackViewController+Private.h
//  dolly
//
//  Created by Nick Banks on 08/11/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNAbstractVideoPlaybackViewController.h"
#import "SYNMasterViewController.h"
#import "SYNProgressView.h"
#import "NSString+Timecode.h"
#import "UIFont+SYNFont.h"
@import MediaPlayer;

@interface SYNAbstractVideoPlaybackViewController ()

@property (nonatomic, assign) int currentSelectedIndex;
@property (nonatomic, strong) NSArray *videoInstanceArray;
@property (nonatomic, strong) CAAnimation *bottomPlacholderAnimationViewPosition;
@property (nonatomic, strong) CAAnimation *middlePlacholderAnimationViewPosition;
@property (nonatomic, strong) UIImageView *videoPlaceholderBottomImageView;
@property (nonatomic, strong) UIImageView *videoPlaceholderMiddleImageView;
@property (nonatomic, strong) UIImageView *videoPlaceholderTopImageView;
@property (nonatomic, strong) CABasicAnimation *placeholderBottomLayerAnimation;
@property (nonatomic, strong) CABasicAnimation *placeholderMiddleLayerAnimation;
@property (nonatomic, strong) UIButton *shuttleBarPlayPauseButton;
@property (nonatomic, strong) UILabel *currentTimeLabel;
@property (nonatomic, strong) UILabel *durationLabel;
@property (nonatomic, strong) UILabel *creatorLabel;
@property (nonatomic, strong) SYNProgressView *bufferingProgressView;
@property (nonatomic, strong) UISlider *shuttleSlider;
@property (nonatomic, assign) CGRect originalShuttleBarFrame;
@property (nonatomic, strong) NSString *channelCreator;

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


@end