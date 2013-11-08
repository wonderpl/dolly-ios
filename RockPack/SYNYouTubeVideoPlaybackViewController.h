//
//  SYNYoutTubeVideoViewController.h
//  rockpack
//
//  Created by Nick Banks on 15/02/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//


#import "SYNAbstractVideoPlaybackViewController+Private.h"
@import UIKit;

// Forward declarations
@class SYNYouTubeVideoPlaybackViewController;

@interface SYNYouTubeVideoPlaybackViewController : SYNAbstractVideoPlaybackViewController

+ (instancetype) sharedInstance;

- (void) setPlaylist: (NSArray *) playlistArray
       selectedIndex: (int) selectedIndex
            autoPlay: (BOOL) autoPlay;



@end
