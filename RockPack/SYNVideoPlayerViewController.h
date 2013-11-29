//
//  SYNVideoPlayerViewController.h
//  dolly
//
//  Created by Sherman Lo on 27/11/13.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNAbstractViewController.h"

@class VideoInstance;
@class SYNVideoPlayer;

@interface SYNVideoPlayerViewController : SYNAbstractViewController

@property (nonatomic, strong) VideoInstance *videoInstance;

@property (nonatomic, strong, readonly) UIView *videoPlayerContainerView;
@property (nonatomic, strong, readonly) SYNVideoPlayer *currentVideoPlayer;

@end
