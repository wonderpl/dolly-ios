//
//  SYNCarouselVideoPlayerViewController.h
//  dolly
//
//  Created by Sherman Lo on 15/11/13.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNVideoPlayerViewController.h"

@class SYNVideoPlayer;
@class SYNPagingModel;

@interface SYNCarouselVideoPlayerViewController : SYNVideoPlayerViewController

+ (instancetype)viewControllerWithModel:(SYNPagingModel *)model selectedIndex:(NSInteger)selectedIndex;

+ (instancetype)viewControllerWithVideoInstances:(NSArray *)videos selectedIndex:(NSInteger)selectedIndex;

@end
