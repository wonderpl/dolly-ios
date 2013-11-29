//
//  SYNCarouselVideoPlayerViewController.h
//  dolly
//
//  Created by Sherman Lo on 15/11/13.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNVideoPlayerViewController.h"

@class SYNVideoPlayer;

@interface SYNCarouselVideoPlayerViewController : SYNVideoPlayerViewController

+ (instancetype)viewControllerWithVideoInstances:(NSArray *)videos selectedIndex:(NSInteger)selectedIndex;

@end
