//
//  SYNVideoPlayerViewController.h
//  dolly
//
//  Created by Sherman Lo on 27/11/13.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNAbstractViewController.h"
#import "SYNVideoPlayerDismissIndex.h"

@class VideoInstance;
@class SYNVideoPlayer;
@class SYNPagingModel;

@interface SYNVideoPlayerViewController : SYNAbstractViewController

+ (instancetype)viewControllerWithModel:(SYNPagingModel *)model selectedIndex:(NSInteger)selectedIndex;

@property (nonatomic, assign, readonly) NSInteger selectedIndex;

@property (nonatomic, strong, readonly) UIView *videoPlayerContainerView;
@property (nonatomic, strong, readonly) SYNVideoPlayer *currentVideoPlayer;
@property (nonatomic, strong, readonly) UICollectionView *videosCollectionView;
@property (nonatomic, weak) id<SYNVideoPlayerDismissIndex> dismissDelegate;

@end
