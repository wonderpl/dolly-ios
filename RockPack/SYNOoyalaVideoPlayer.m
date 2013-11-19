//
//  SYNOoyalaVideoPlayer.m
//  dolly
//
//  Created by Sherman Lo on 14/11/13.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNOoyalaVideoPlayer.h"
#import "OOOoyalaPlayer.h"
#import "SYNScrubberBar.h"
#import "Video.h"

static NSString * const EmbedCoded = @"xxbjk1YjpHm4-VkWfWfEKBbyEkh358su";
static NSString * const PCode = @"Z5Mm06XeZlcDlfU_1R9v_L2KwYG6";
static NSString * const PlayerDomain = @"www.ooyala.com";


@interface SYNOoyalaVideoPlayer ()

@property (nonatomic, strong) OOOoyalaPlayer *ooyalaPlayer;

@end


@implementation SYNOoyalaVideoPlayer

#pragma mark - Init / Dealloc

- (id)initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame]) {
		[self.playerContainerView addSubview:self.ooyalaPlayer.view];
		
		NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
		[notificationCenter addObserver:self
							   selector:@selector(ooyalaPlayerStateChanged:)
								   name:OOOoyalaPlayerStateChangedNotification
								 object:self.ooyalaPlayer];
		[notificationCenter addObserver:self
							   selector:@selector(ooyalaPlayerPlayCompleted:)
								   name:OOOoyalaPlayerPlayCompletedNotification
								 object:self.ooyalaPlayer];
	}
	return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Getters / Setters

- (void)setVideo:(Video *)video {
	[super setVideo:video];
	
    [self.ooyalaPlayer setEmbedCode:video.sourceId];
}

- (OOOoyalaPlayer *)ooyalaPlayer {
	if (!_ooyalaPlayer) {
		OOOoyalaPlayer *ooyalaPlayer = [[OOOoyalaPlayer alloc] initWithPcode:PCode domain:PlayerDomain];
		ooyalaPlayer.view.frame = self.bounds;
		ooyalaPlayer.view.alpha = 0.0;
		
		self.ooyalaPlayer = ooyalaPlayer;
	}
	return _ooyalaPlayer;
}

#pragma mark - Overridden

- (void)play {
	[super play];
	
	[self.ooyalaPlayer play];
}

- (void)pause {
	[super pause];
	
	[self.ooyalaPlayer pause];
}

- (void)setCurrentTime:(NSTimeInterval)currentTime {
	[super setCurrentTime:currentTime];
	
	self.ooyalaPlayer.playheadTime = currentTime;
}

- (NSTimeInterval)duration {
	return [self.ooyalaPlayer duration];
}

- (NSTimeInterval)currentTime {
	return [self.ooyalaPlayer playheadTime];
}

- (float)bufferingProgress {
	float progress = [self.ooyalaPlayer bufferedTime] / [self.ooyalaPlayer duration];
	return (isnan(progress) ? 0.0 : progress);
}

#pragma mark - Private

- (void)ooyalaPlayerStateChanged:(NSNotification *)notification {
	OOOoyalaPlayer *ooyalaPlayer = [notification object];
	if (ooyalaPlayer.state == OOOoyalaPlayerStateReady && self.state == SYNVideoPlayerStatePlaying) {
		self.ooyalaPlayer.view.alpha = 1.0;
		
		[self.ooyalaPlayer play];
	}
}

- (void)ooyalaPlayerPlayCompleted:(NSNotification *)notification {
	[self.delegate videoPlayerFinishedPlaying];
}

@end
