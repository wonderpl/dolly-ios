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
@import MediaPlayer;

@interface SYNScrubberBar ()

@property (nonatomic, strong) IBOutlet UIButton *playPauseButton;

@property (nonatomic, strong) IBOutlet SYNProgressView *bufferingProgressView;
@property (nonatomic, strong) IBOutlet UISlider *progressSlider;

@property (nonatomic, strong) IBOutlet MPVolumeView *volumeView;

@property (nonatomic, strong) IBOutlet NSLayoutConstraint *highDefinitionWidth;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *highDefinitionTrailingSpace;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *volumeViewTrailingSpace;

@property (nonatomic, strong) CALayer *topLineLayer;

@property (nonatomic, assign) BOOL changingCurrentTime;

@property (nonatomic, strong) SYNTimestampView *timestampView;

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
	
	self.volumeView.showsVolumeSlider = NO;
	
	[self.layer addSublayer:self.topLineLayer];
	
    UIImage *shuttleSliderRightTrack = [[UIImage imageNamed: @"ShuttleBarRemainingBar.png"] resizableImageWithCapInsets: UIEdgeInsetsMake(0.0f, 10.0f, 0.0f, 10.0f)];
    UIImage *shuttleSliderLeftTrack = [[UIImage imageNamed: @"ShuttleBarProgressBar.png"] resizableImageWithCapInsets: UIEdgeInsetsMake(0.0f, 10.0f, 0.0f, 10.0f)];
    [self.progressSlider setMinimumTrackImage: shuttleSliderLeftTrack forState: UIControlStateNormal];
	[self.progressSlider setMaximumTrackImage: shuttleSliderRightTrack forState: UIControlStateNormal];
    [self.progressSlider setThumbImage: [UIImage imageNamed: @"ShuttleBarSliderThumb.png"] forState: UIControlStateNormal];
	
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
	
	self.progressSlider.value = currentTime / self.duration;
}

- (void)setPlaying:(BOOL)playing {
	_playing = playing;
	
	NSString *buttonImageName = (playing ? @"ButtonShuttleBarPause.png" : @"ButtonShuttleBarPlay.png");
	[self.playPauseButton setImage:[UIImage imageNamed:buttonImageName] forState:UIControlStateNormal];
}

- (void)setHighDefinition:(BOOL)highDefinition {
	_highDefinition = highDefinition;
	
	[self updateHighDefinitionDisplay];
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
	SYNTimestampView *timestampView = [SYNTimestampView viewWithMaxDuration:self.duration];
	[self addSubview:timestampView];
	self.timestampView = timestampView;
	
	[self updateTimestamp];
	
	[self.delegate scrubberBarCurrentTimeWillChange];
}

- (IBAction)sliderValueChanged:(UISlider *)slider {
	float value = slider.value;
	self.currentTime = self.duration * value;
	
	[self updateTimestamp];
	
	[self.delegate scrubberBarCurrentTimeChanged:self.currentTime];
}

- (IBAction)sliderTouchUp:(UISlider *)sender {
	[self.timestampView removeFromSuperview];
	self.timestampView = nil;
	
	[self.delegate scrubberBarCurrentTimeDidChange];
}

#pragma mark - Private

- (void)updateTimestamp {
	self.timestampView.timestamp = self.currentTime;
	
	CGFloat sliderValue = self.progressSlider.value;
	CGFloat xPosition = CGRectGetMinX(self.progressSlider.frame) + (CGRectGetWidth(self.progressSlider.frame) - 14) * sliderValue;
	self.timestampView.center = CGPointMake(xPosition, -(5 + (CGRectGetHeight(self.frame) / 2.0)));
}

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
