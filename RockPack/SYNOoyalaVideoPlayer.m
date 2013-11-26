//
//  SYNOoyalaVideoPlayer.m
//  dolly
//
//  Created by Sherman Lo on 14/11/13.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNOoyalaVideoPlayer.h"
#import <OOOoyalaPlayer.h>
#import <OOOoyalaError.h>
#import "SYNScrubberBar.h"
#import "VideoInstance.h"
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
		[notificationCenter addObserver:self
							   selector:@selector(ooyalaPlayerErrorOccurred:)
								   name:OOOoyalaPlayerErrorNotification
								 object:self.ooyalaPlayer];
	}
	return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Getters / Setters

- (void)setVideoInstance:(VideoInstance *)videoInstance {
	[super setVideoInstance:videoInstance];
	
    [self.ooyalaPlayer setEmbedCode:videoInstance.video.sourceId];
}

- (OOOoyalaPlayer *)ooyalaPlayer {
	if (!_ooyalaPlayer) {
		OOOoyalaPlayer *ooyalaPlayer = [[OOOoyalaPlayer alloc] initWithPcode:PCode domain:PlayerDomain];
		ooyalaPlayer.view.frame = self.bounds;
		
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

#pragma mark - Notifications

- (void)ooyalaPlayerStateChanged:(NSNotification *)notification {
	OOOoyalaPlayer *ooyalaPlayer = [notification object];
	if (ooyalaPlayer.state == OOOoyalaPlayerStateReady && self.state == SYNVideoPlayerStatePlaying) {
		[ooyalaPlayer play];
	}
}

- (void)ooyalaPlayerPlayCompleted:(NSNotification *)notification {
	[self.delegate videoPlayerFinishedPlaying];
}

- (void)ooyalaPlayerErrorOccurred:(NSNotification *)notification {
	OOOoyalaPlayer *ooyalaPlayer = [notification object];
	[self.delegate videoPlayerErrorOccurred:[self errorStringFromOoyalaError:[ooyalaPlayer error]]];
}

#pragma mark - Private

- (NSString *)errorStringFromOoyalaError:(OOOoyalaError *)error {
	NSDictionary *mapping = @{
							  @(OOOoyalaErrorCodeAuthorizationFailed)			: @"authorization_failed",
							  @(OOOoyalaErrorCodeAuthorizationInvalid)			: @"authorization_invalid",
							  @(OOOoyalaErrorCodeHeartbeatFailed)				: @"hearbeat_failed",
							  @(OOOoyalaErrorCodeContentTreeInvalid)			: @"content_tree_invalid",
							  @(OOOoyalaErrorCodeAuthorizationSignatureInvalid)	: @"authorization_signature_invalid",
							  @(OOOoyalaErrorCodeContentTreeNextFailed)			: @"content_tree_next_failed",
							  @(OOOoyalaErrorCodePlaybackFailed)				: @"playback_failed",
							  @(OOOoyalaErrorCodeAssetNotEncodedForIOS)			: @"asset_not_encoded_for_ios",
							  @(OOOoyalaErrorCodeInternalIOS)					: @"internal_ios",
							  @(OOOoyalaErrorCodeMetadataInvalid)				: @"metadata_invalid"
							  };
	return mapping[@([error code])];
}

@end
