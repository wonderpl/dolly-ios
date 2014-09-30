//
//  SYNHomeTopTabViewController.h
//  rockpack
//
//  Created by Nick Banks on 07/12/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import "SYNAbstractViewController.h"

@class SYNFeedModel;

@interface SYNFeedRootViewController : SYNAbstractViewController

@property (nonatomic, strong, readonly) UICollectionView *feedCollectionView;

@property (nonatomic, strong, readonly) SYNFeedModel *model;

+ (instancetype)viewController;

- (void)updateWidgetFeedItem;

@end
