//
//  SYNVideoLoadingView.h
//  dolly
//
//  Created by Sherman Lo on 25/11/13.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VideoInstance;

@interface SYNVideoLoadingView : UIView

@property (nonatomic, strong) VideoInstance *videoInstance;
@property (nonatomic, assign) BOOL fullscreen;

+ (instancetype)loadingViewWithFrame:(CGRect)frame;

@end
