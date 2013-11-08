//
//  SYNYoutTubeVideoViewController.h
//  rockpack
//
//  Created by Nick Banks on 15/02/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import "Video.h"
#import "VideoInstance.h"
#import "SYNAbstractVideoPlaybackViewController+Private.h"
@import UIKit;

typedef void (^SYNVideoIndexUpdater)(int);

// Forward declarations
@class SYNYouTubeVideoPlaybackViewController;

@interface SYNYouTubeVideoPlaybackViewController : SYNAbstractVideoPlaybackViewController

@property (nonatomic, assign, readonly) NSTimeInterval currentTime;
@property (nonatomic, assign, readonly) NSTimeInterval duration;
@property (nonatomic, strong) VideoInstance *currentVideoInstance;

@property (nonatomic, copy) void (^updateBlock) (void);

+ (instancetype) sharedInstance;

// Initialisation
- (void) updateWithFrame: (CGRect) frame
          channelCreator: (NSString *) channelCreator
            indexUpdater: (SYNVideoIndexUpdater) indexUpdater;

- (void) setPlaylist: (NSArray *) playlistArray
       selectedIndex: (int) selectedIndex
            autoPlay: (BOOL) autoPlay;

- (void) updateChannelCreator: (NSString *) channelCreator;

// Player control
- (void) playVideoAtIndex: (int) index;
- (void) playIfVideoActive;
- (void) pauseIfVideoActive;

@end
