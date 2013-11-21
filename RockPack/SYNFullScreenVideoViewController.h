//
//  SYNFullScreenVideoViewController.h
//  dolly
//
//  Created by Sherman Lo on 20/11/13.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SYNVideoPlayer;

@interface SYNFullScreenVideoViewController : UIViewController

@property (nonatomic, strong, readonly) UIView *backgroundView;

@property (nonatomic, strong) SYNVideoPlayer *videoPlayer;

@end
