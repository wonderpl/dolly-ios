//
//  SYNVideoPlayerAnimator.h
//  dolly
//
//  Created by Sherman Lo on 16/01/14.
//  Copyright (c) 2014 Rockpack Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SYNVideoInfoCell;

@interface SYNVideoPlayerAnimator : NSObject <UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning>

@property (nonatomic, strong) id<SYNVideoInfoCell> videoInfoCell;

@end
