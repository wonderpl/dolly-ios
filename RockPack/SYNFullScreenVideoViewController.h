//
//  SYNFullScreenVideoViewController.h
//  dolly
//
//  Created by Sherman Lo on 20/11/13.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SYNVideoPlayerViewController;

@interface SYNFullScreenVideoViewController : UIViewController

@property (nonatomic, strong, readonly) UIView *backgroundView;

@property (nonatomic, strong, readonly) UIView *videoContainerView;

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, weak) SYNVideoPlayerViewController *videoPlayerViewController;

@property (nonatomic, assign, readonly) UIDeviceOrientation videoOrientation;

@end
