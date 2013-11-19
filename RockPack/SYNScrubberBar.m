//
//  SYNScrubberBar.m
//  dolly
//
//  Created by Sherman Lo on 14/11/13.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNScrubberBar.h"
#import "SYNProgressView.h"
#import "UIFont+SYNFont.h"
#import "NSString+Timecode.h"
@import MediaPlayer;

@interface SYNScrubberBar ()

@property (nonatomic, strong) IBOutlet UIButton *playPauseButton;

@property (nonatomic, strong) IBOutlet UIButton *fullScreenButton;

@property (nonatomic, strong) IBOutlet UILabel *currentTimeLabel;
@property (nonatomic, strong) IBOutlet UILabel *durationLabel;

@property (nonatomic, strong) IBOutlet SYNProgressView *bufferingProgressView;
@property (nonatomic, strong) IBOutlet UISlider *progressSlider;

@property (nonatomic, strong) IBOutlet MPVolumeView *volumeView;

@property (nonatomic, assign) BOOL changingCurrentTime;

@end

@implementation SYNScrubberBar

#pragma mark - Public class

+ (instancetype)view {
	return [[[NSBundle mainBundle] loadNibNamed:@"SYNScrubberBar" owner:nil options:nil] firstObject];
}

#pragma mark - Overridden

- (void)awakeFromNib {
	[super awakeFromNib];
	
	self.currentTimeLabel.font = [UIFont regularCustomFontOfSize:12.0];
	self.durationLabel.font = [UIFont regularCustomFontOfSize:12.0];
	
	self.volumeView.showsVolumeSlider = NO;
	
    UIImage *shuttleSliderRightTrack = [[UIImage imageNamed: @"ShuttleBarRemainingBar.png"] resizableImageWithCapInsets: UIEdgeInsetsMake(0.0f, 10.0f, 0.0f, 10.0f)];
    UIImage *shuttleSliderLeftTrack = [[UIImage imageNamed: @"ShuttleBarProgressBar.png"] resizableImageWithCapInsets: UIEdgeInsetsMake(0.0f, 10.0f, 0.0f, 10.0f)];
    [self.progressSlider setMinimumTrackImage: shuttleSliderLeftTrack forState: UIControlStateNormal];
	[self.progressSlider setMaximumTrackImage: shuttleSliderRightTrack forState: UIControlStateNormal];
    [self.progressSlider setThumbImage: [UIImage imageNamed: @"ShuttleBarSliderThumb.png"] forState: UIControlStateNormal];
}

#pragma mark - Getters / Setters

- (void)setBufferingProgress:(float)bufferingProgress {
	_bufferingProgress = bufferingProgress;
	
	self.bufferingProgressView.progress = bufferingProgress;
}

- (void)setCurrentTime:(NSTimeInterval)currentTime {
	_currentTime = currentTime;
	
	self.currentTimeLabel.text = [NSString timecodeStringFromSeconds:currentTime];
	self.progressSlider.value = currentTime / self.duration;
}

- (void)setDuration:(NSTimeInterval)duration {
	_duration = duration;
	
	self.durationLabel.text = [NSString timecodeStringFromSeconds:duration];
}

- (void)setPlaying:(BOOL)playing {
	_playing = playing;
	
	NSString *buttonImageName = (playing ? @"ButtonShuttleBarPause.png" : @"ButtonShuttleBarPlay.png");
	[self.playPauseButton setImage:[UIImage imageNamed:buttonImageName] forState:UIControlStateNormal];
}

- (void)setFullScreen:(BOOL)fullScreen {
	_fullScreen = fullScreen;
	
	NSString *buttonImageName = (fullScreen ? @"ButtonShuttleBarMinimise.png" : @"ButtonShuttleBarMaximise.png");
	[self.fullScreenButton setImage:[UIImage imageNamed:buttonImageName] forState:UIControlStateNormal];
}

#pragma mark - IBActions

- (IBAction)playPauseButtonPressed:(UIButton *)button {
	self.playing = !self.playing;
	[self.delegate scrubberBarPlayPauseToggled:self.playing];
}

- (IBAction)fullScreenButtonPressed:(UIButton *)button {
	self.fullScreen = !self.fullScreen;
	[self.delegate scrubberBarFullScreenToggled:self.fullScreen];
}

- (IBAction)sliderTouchDown:(UISlider *)sender {
	[self.delegate scrubberBarCurrentTimeWillChange];
}

- (IBAction)sliderValueChanged:(UISlider *)slider {
	float value = slider.value;
	self.currentTime = self.duration * value;
	
	[self.delegate scrubberBarCurrentTimeChanged:self.currentTime];
}

- (IBAction)sliderTouchUp:(UISlider *)sender {
	[self.delegate scrubberBarCurrentTimeDidChange];
}

@end
