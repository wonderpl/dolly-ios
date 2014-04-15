//
//  SYNVideoInfoViewController.h
//  dolly
//
//  Created by Sherman Lo on 10/04/14.
//  Copyright (c) 2014 Wonder PL Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VideoInstance;
@class SYNPagingModel;
@class SYNVideoInfoViewController;

@protocol SYNVideoInfoViewControllerDelegate <NSObject>

- (void)videoInfoViewController:(SYNVideoInfoViewController *)viewController didSelectVideoAtIndex:(NSInteger)index;

@end

@interface SYNVideoInfoViewController : UIViewController

@property (nonatomic, strong) SYNPagingModel *model;

@property (nonatomic, assign) NSInteger selectedIndex;

@property (nonatomic, weak) id<SYNVideoInfoViewControllerDelegate> delegate;

@end
