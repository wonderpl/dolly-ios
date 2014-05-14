//
//  SYNScrubberBar.h
//  dolly
//
//  Created by Sherman Lo on 14/11/13.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SYNScrubberBarDelegate <NSObject>

- (void)scrubberBarPlayPauseToggled:(BOOL)playing;
- (void)scrubberBarFullscreenToggled:(BOOL)fullscreen;

- (void)scrubberBarCurrentTimeWillChange;
- (void)scrubberBarCurrentTimeChanged:(NSTimeInterval)currentTime;
- (void)scrubberBarCurrentTimeDidChange;

@end

@interface SYNScrubberBar : UIView

@property (nonatomic, assign) id<SYNScrubberBarDelegate> delegate;

@property (nonatomic, assign) BOOL playing;
@property (nonatomic, assign) BOOL fullscreen;
@property (nonatomic, assign) BOOL highDefinition;
@property (nonatomic, assign) float bufferingProgress;
@property (nonatomic, assign) NSTimeInterval currentTime;
@property (nonatomic, assign) NSTimeInterval duration;

+ (instancetype)view;

@end
