//
//  SYNVideoPlayerAnimator.h
//  dolly
//
//  Created by Sherman Lo on 16/01/14.
//  Copyright (c) 2014 Rockpack Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SYNVideoInfoCell;

@protocol SYNVideoPlayerAnimatorDelegate <NSObject>

- (id<SYNVideoInfoCell>)videoCellForIndexPath:(NSIndexPath *)indexPath;

@end

@interface SYNVideoPlayerAnimator : NSObject <UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning>

@property (nonatomic, strong) NSIndexPath *cellIndexPath;

@property (nonatomic, weak) id<SYNVideoPlayerAnimatorDelegate> delegate;

@end
