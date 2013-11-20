//
//  SYNAbstractVideoPlaybacViewController.h
//  dolly
//
//  Created by Nick Banks on 08/11/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNAppDelegate.h"
@import Foundation;

@class SYNScrubberBar;

#pragma mark - Block typedefs

typedef void (^SYNVideoIndexUpdater)(int);

@interface SYNAbstractVideoPlaybackViewController : GAITrackedViewController

@property (nonatomic, assign, readonly) NSTimeInterval currentTime;
@property (nonatomic, assign, readonly) NSTimeInterval duration;
@property (nonatomic, strong) UIButton *shuttleBarMaxMinButton;
@property (nonatomic, strong, readonly) SYNScrubberBar *scrubberBar;
@property (nonatomic, strong) VideoInstance *currentVideoInstance;
@property (nonatomic, copy) void (^updateBlock) (void);

// Player control
- (void) playVideoAtIndex: (int) index;

- (void) updateChannelCreator: (NSString *) channelCreator;

- (void) setPlaylist: (NSArray *) playlistArray
       selectedIndex: (int) selectedIndex
            autoPlay: (BOOL) autoPlay;

- (void) updateWithFrame: (CGRect) frame
          channelCreator: (NSString *) channelCreator
            indexUpdater: (SYNVideoIndexUpdater) indexUpdater;

- (void) playIfVideoActive;
- (void) pauseIfVideoActive;

@end
