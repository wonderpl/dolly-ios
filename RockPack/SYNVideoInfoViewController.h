//
//  SYNVideoInfoViewController.h
//  dolly
//
//  Created by Sherman Lo on 10/04/14.
//  Copyright (c) 2014 Wonder PL Ltd. All rights reserved.
//

#import "SYNAbstractViewController.h"

@class VideoInstance;
@class SYNPagingModel;
@class SYNVideoInfoViewController;

@protocol SYNVideoInfoViewControllerDelegate <NSObject>

- (void)videoInfoViewController:(SYNVideoInfoViewController *)viewController didScrollToContentOffset:(CGPoint)contentOffset;
- (void)videoInfoViewController:(SYNVideoInfoViewController *)viewController didSelectVideoAtIndex:(NSInteger)index;

@end

@interface SYNVideoInfoViewController : SYNAbstractViewController

@property (nonatomic, strong) SYNPagingModel *model;

@property (nonatomic, assign) NSInteger selectedIndex;

@property (nonatomic, weak) id<SYNVideoInfoViewControllerDelegate> delegate;

@end
