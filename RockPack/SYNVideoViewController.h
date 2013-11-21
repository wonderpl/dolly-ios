//
//  SYNVideoViewController.h
//  dolly
//
//  Created by Sherman Lo on 15/11/13.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SYNVideoPlayer;

@interface SYNVideoViewController : UIViewController

+ (instancetype)viewControllerWithVideoInstances:(NSArray *)videos selectedIndex:(NSInteger)selectedIndex;

@property (nonatomic, strong, readonly) UIView *videoPlayerContainerView;
@property (nonatomic, strong, readonly) SYNVideoPlayer *currentVideoPlayer;

@end
