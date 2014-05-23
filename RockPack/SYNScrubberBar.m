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
#import "SYNTimestampView.h"
#import "SYNTimestampLabel.h"
#import "NSString+Timecode.h"
@import MediaPlayer;

@interface SYNScrubberBar ()

@property (nonatomic, strong) IBOutlet UIButton *playPauseButton;
@property (nonatomic, strong) IBOutlet UIButton *fullscreenButton;

@property (nonatomic, strong) IBOutlet SYNTimestampLabel *timestampLabel;
@property (nonatomic, strong) IBOutlet UILabel *durationLabel;

@property (nonatomic, strong) IBOutlet SYNProgressView *bufferingProgressView;
@property (nonatomic, strong) IBOutlet UISlider *progressSlider;

@property (nonatomic, strong) IBOutlet MPVolumeView *volumeView;

@property (nonatomic, strong) IBOutlet NSLayoutConstraint *highDefinitionWidth;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *highDefinitionTrailingSpace;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *volumeViewTrailingSpace;

@property (nonatomic, strong) CALayer *topLineLayer;

@property (nonatomic, assign) BOOL changingCurrentTime;

@end

@implementation SYNScrubberBar

#pragma mark - Public class

+ (instancetype)view {
	return [[[NSBundle mainBundle] loadNibNamed:@"SYNScrubberBar" owner:nil options:nil] firstObject];
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Overridden

- (void)awakeFromNib {
	[super awakeFromNib];
	
	[self updateHighDefinitionDisplay];
	[self updateVolumeViewDisplay];
	
	self.timestampLabel.font = [UIFont regularCustomFontOfSize:self.timestampLabel.font.pointSize];
	self.durationLabel.font = [UIFont regularCustomFontOfSize:self.durationLabel.font.pointSize];
	
	self.volumeView.showsVolumeSlider = NO;
	
	[self.layer addSublayer:self.topLineLayer];
	
	UIEdgeInsets sliderEdgeInsets = UIEdgeInsetsMake(0.0f, 10.0f, 0.0f, 10.0f);
    UIImage *shuttleSliderRightTrack = [[UIImage imageNamed:@"ShuttleBarRemainingBar.png"] resizableImageWithCapInsets:sliderEdgeInsets];
    UIImage *shuttleSliderLeftTrack = [[UIImage imageNamed:@"ShuttleBarProgressBar.png"] resizableImageWithCapInsets:sliderEdgeInsets];
    [self.progressSlider setMinimumTrackImage:shuttleSliderLeftTrack forState: UIControlStateNormal];
	[self.progressSlider setMaximumTrackImage:shuttleSliderRightTrack forState: UIControlStateNormal];
    [self.progressSlider setThumbImage:[UIImage imageNamed: @"ShuttleBarSliderThumb.png"] forState: UIControlStateNormal];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(wirelessRoutesDidChange:)
												 name:MPVolumeViewWirelessRoutesAvailableDidChangeNotification
											   object:self.volumeView];
}

- (void)layoutSublayersOfLayer:(CALayer *)layer {
	[super layoutSublayersOfLayer:layer];
	
	self.topLineLayer.frame = CGRectMake(0,
										 0,
										 CGRectGetWidth(self.layer.frame),
										 (IS_RETINA ? 0.5 : 1.0));
}

#pragma mark - Getters / Setters

- (void)setBufferingProgress:(float)bufferingProgress {
	_bufferingProgress = bufferingProgress;
	
	self.bufferingProgressView.progress = bufferingProgress;
}

- (void)setCurrentTime:(NSTimeInterval)currentTime {
	_currentTime = currentTime;
	
	self.timestampLabel.text = [NSString timecodeStringFromSeconds:currentTime];
	self.progressSlider.value = currentTime / self.duration;
}

- (void)setDuration:(NSTimeInterval)duration {
	if (_duration != duration) {
		_duration = duration;
		
		self.timestampLabel.maxTimestamp = duration;
		self.durationLabel.text = [NSString timecodeStringFromSeconds:duration];
	}
}

- (void)setPlaying:(BOOL)playing {
	_playing = playing;
	
	NSString *buttonImageName = (playing ? @"ButtonShuttleBarPause.png" : @"ButtonShuttleBarPlay.png");
	[self.playPauseButton setImage:[UIImage imageNamed:buttonImageName] forState:UIControlStateNormal];
}

- (void)setHighDefinition:(BOOL)highDefinition {
	_highDefinition = highDefinition;
	
//	[self updateHighDefinitionDisplay];
}

- (void)setFullscreen:(BOOL)fullscreen {
	_fullscreen = fullscreen;
	
	self.fullscreenButton.selected = fullscreen;
}

- (CALayer *)topLineLayer {
	if (!_topLineLayer) {
		CALayer *layer = [CALayer layer];
		layer.backgroundColor = [[UIColor colorWithWhite:1.0 alpha:0.73] CGColor];
		
		self.topLineLayer = layer;
	}
	return _topLineLayer;
}

#pragma mark - IBActions

- (IBAction)playPauseButtonPressed:(UIButton *)button {
	self.playing = !self.playing;
	[self.delegate scrubberBarPlayPauseToggled:self.playing];
}

- (IBAction)sliderTouchDown:(UISlider *)slider {
	[self.delegate scrubberBarCurrentTimeWillChange];
}

- (IBAction)sliderValueChanged:(UISlider *)slider {
	float value = slider.value;
	self.currentTime = self.duration * value;
	
	[self.delegate scrubberBarCurrentTimeChanged:self.currentTime];
}

- (IBAction)sliderTouchUp:(UISlider *)slider {
	[self.delegate scrubberBarCurrentTimeDidChange];
}

- (IBAction)fullscreenButtonPressed:(UIButton *)button {
	button.selected = !button.selected;
	
	[self.delegate scrubberBarFullscreenToggled:button.selected];
}

#pragma mark - Private

- (void)updateHighDefinitionDisplay {
	static NSNumber *highDefinitionWidth = nil;
	if (!highDefinitionWidth) {
		highDefinitionWidth = @(self.highDefinitionWidth.constant);
	}
	static NSNumber *highDefinitionTrailingSpace = nil;
	if (!highDefinitionTrailingSpace) {
		highDefinitionTrailingSpace = @(self.highDefinitionTrailingSpace.constant);
	}
	
	if (self.highDefinition) {
		self.highDefinitionWidth.constant = [highDefinitionWidth doubleValue];
		self.highDefinitionTrailingSpace.constant = [highDefinitionTrailingSpace doubleValue];
	} else {
		self.highDefinitionWidth.constant = 0.0;
		self.highDefinitionTrailingSpace.constant = 0.0;
	}
	
	[UIView animateWithDuration:0.2 animations:^{
		[self layoutIfNeeded];
	}];
}

- (void)updateVolumeViewDisplay {
	static NSNumber *initialTrailingSpace = nil;
	if (!initialTrailingSpace) {
		initialTrailingSpace = @(self.volumeViewTrailingSpace.constant);
	}
	
	if (self.volumeView.wirelessRoutesAvailable) {
		self.volumeViewTrailingSpace.constant = [initialTrailingSpace doubleValue];
	} else {
		self.volumeViewTrailingSpace.constant = -CGRectGetWidth(self.volumeView.frame);
	}
	
	[UIView animateWithDuration:0.2 animations:^{
		[self layoutIfNeeded];
	}];
}

- (void)wirelessRoutesDidChange:(NSNotification *)notification {
	[self updateVolumeViewDisplay];
}

@end
